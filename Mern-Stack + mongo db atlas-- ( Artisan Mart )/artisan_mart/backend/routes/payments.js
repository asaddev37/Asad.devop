const express = require('express');
const { body, validationResult } = require('express-validator');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const Order = require('../models/Order');
const Product = require('../models/Product');
const Cart = require('../models/Cart');
const User = require('../models/User');
const { auth, customerOnly } = require('../middleware/auth');

const router = express.Router();

// @route   POST /api/payments/create-payment-intent
// @desc    Create payment intent for order
// @access  Private (Customer only)
router.post('/create-payment-intent', [auth, customerOnly], [
  body('orderId')
    .notEmpty()
    .isMongoId()
    .withMessage('Valid order ID is required')
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { orderId } = req.body;
    const customerId = req.user.userId;

    // Find the order
    const order = await Order.findOne({
      _id: orderId,
      customer: customerId,
      status: 'pending'
    }).populate('vendorOrders.vendor', 'vendorInfo.stripeAccountId');

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found or already processed'
      });
    }

    // Check if payment intent already exists
    if (order.payment.stripePaymentIntentId) {
      try {
        const existingIntent = await stripe.paymentIntents.retrieve(
          order.payment.stripePaymentIntentId
        );
        
        if (existingIntent.status === 'requires_payment_method' || 
            existingIntent.status === 'requires_confirmation') {
          return res.json({
            success: true,
            data: {
              clientSecret: existingIntent.client_secret,
              paymentIntentId: existingIntent.id
            }
          });
        }
      } catch (error) {
        console.log('Existing payment intent not found, creating new one');
      }
    }

    // Calculate application fee (platform commission)
    const applicationFeeAmount = Math.round(order.summary.totalCommission * 100); // Convert to cents
    const totalAmount = Math.round(order.summary.total * 100); // Convert to cents

    // Create payment intent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: totalAmount,
      currency: 'usd',
      application_fee_amount: applicationFeeAmount,
      metadata: {
        orderId: order._id.toString(),
        customerId: customerId.toString(),
        orderNumber: order.orderNumber
      },
      description: `ArtisanMart Order #${order.orderNumber}`,
      // For multi-vendor, we'll handle transfers separately
      // transfer_data: {
      //   destination: vendorStripeAccountId,
      // },
    });

    // Update order with payment intent ID
    order.payment.stripePaymentIntentId = paymentIntent.id;
    order.payment.status = 'pending';
    await order.save();

    res.json({
      success: true,
      data: {
        clientSecret: paymentIntent.client_secret,
        paymentIntentId: paymentIntent.id
      }
    });

  } catch (error) {
    console.error('Create payment intent error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while creating payment intent'
    });
  }
});

// @route   POST /api/payments/confirm-payment
// @desc    Confirm payment and process order
// @access  Private (Customer only)
router.post('/confirm-payment', [auth, customerOnly], [
  body('paymentIntentId')
    .notEmpty()
    .withMessage('Payment intent ID is required'),
  body('orderId')
    .notEmpty()
    .isMongoId()
    .withMessage('Valid order ID is required')
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { paymentIntentId, orderId } = req.body;
    const customerId = req.user.userId;

    // Find the order
    const order = await Order.findOne({
      _id: orderId,
      customer: customerId
    }).populate('vendorOrders.vendor', 'vendorInfo.stripeAccountId vendorInfo.shopName');

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    // Retrieve payment intent from Stripe
    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);

    if (paymentIntent.status !== 'succeeded') {
      return res.status(400).json({
        success: false,
        message: 'Payment not completed successfully'
      });
    }

    // Update order payment status
    order.payment.status = 'completed';
    order.payment.stripePaymentIntentId = paymentIntentId;
    order.payment.transactionId = paymentIntent.charges.data[0]?.id;
    order.payment.paidAt = new Date();
    order.status = 'confirmed';

    // Update vendor order statuses
    order.vendorOrders.forEach(vendorOrder => {
      vendorOrder.status = 'confirmed';
    });

    await order.save();

    // Create transfers to vendors (in test mode, this simulates the transfer)
    const transferPromises = order.vendorOrders.map(async (vendorOrder) => {
      const vendor = vendorOrder.vendor;
      const transferAmount = Math.round(vendorOrder.vendorEarnings * 100); // Convert to cents

      // In test mode, we'll just log the transfer
      // In production, you would create actual transfers to vendor Stripe accounts
      console.log(`Simulated transfer to vendor ${vendor.vendorInfo.shopName}: $${vendorOrder.vendorEarnings}`);
      
      // For actual implementation with Stripe Connect:
      // if (vendor.vendorInfo.stripeAccountId) {
      //   try {
      //     const transfer = await stripe.transfers.create({
      //       amount: transferAmount,
      //       currency: 'usd',
      //       destination: vendor.vendorInfo.stripeAccountId,
      //       metadata: {
      //         orderId: order._id.toString(),
      //         vendorOrderId: vendorOrder._id.toString(),
      //         orderNumber: order.orderNumber
      //       }
      //     });
      //     console.log(`Transfer created: ${transfer.id}`);
      //   } catch (transferError) {
      //     console.error(`Transfer failed for vendor ${vendor._id}:`, transferError);
      //   }
      // }

      return {
        vendorId: vendor._id,
        amount: vendorOrder.vendorEarnings,
        status: 'simulated' // In test mode
      };
    });

    const transfers = await Promise.all(transferPromises);

    // Clear customer's cart
    await Cart.findOneAndUpdate(
      { user: customerId },
      { 
        $set: { 
          items: [],
          totalItems: 0,
          totalPrice: 0
        }
      }
    );

    res.json({
      success: true,
      message: 'Payment confirmed and order processed successfully',
      data: {
        order: {
          _id: order._id,
          orderNumber: order.orderNumber,
          status: order.status,
          total: order.summary.total,
          paymentStatus: order.payment.status
        },
        transfers: transfers
      }
    });

  } catch (error) {
    console.error('Confirm payment error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while confirming payment'
    });
  }
});

// @route   POST /api/payments/webhook
// @desc    Handle Stripe webhooks
// @access  Public (Stripe webhook)
router.post('/webhook', express.raw({ type: 'application/json' }), async (req, res) => {
  const sig = req.headers['stripe-signature'];
  const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;

  let event;

  try {
    event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
  } catch (err) {
    console.error('Webhook signature verification failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Handle the event
  try {
    switch (event.type) {
      case 'payment_intent.succeeded':
        const paymentIntent = event.data.object;
        console.log('Payment succeeded:', paymentIntent.id);
        
        // Update order status if not already updated
        const order = await Order.findOne({
          'payment.stripePaymentIntentId': paymentIntent.id
        });
        
        if (order && order.payment.status !== 'completed') {
          order.payment.status = 'completed';
          order.payment.paidAt = new Date();
          order.status = 'confirmed';
          await order.save();
        }
        break;

      case 'payment_intent.payment_failed':
        const failedPayment = event.data.object;
        console.log('Payment failed:', failedPayment.id);
        
        // Update order status
        const failedOrder = await Order.findOne({
          'payment.stripePaymentIntentId': failedPayment.id
        });
        
        if (failedOrder) {
          failedOrder.payment.status = 'failed';
          failedOrder.status = 'payment_failed';
          await failedOrder.save();
        }
        break;

      case 'transfer.created':
        const transfer = event.data.object;
        console.log('Transfer created:', transfer.id);
        break;

      case 'transfer.failed':
        const failedTransfer = event.data.object;
        console.log('Transfer failed:', failedTransfer.id);
        break;

      default:
        console.log(`Unhandled event type ${event.type}`);
    }

    res.json({ received: true });
  } catch (error) {
    console.error('Webhook handler error:', error);
    res.status(500).json({ error: 'Webhook handler failed' });
  }
});

// @route   GET /api/payments/order/:orderId/status
// @desc    Get payment status for an order
// @access  Private (Customer only)
router.get('/order/:orderId/status', [auth, customerOnly], async (req, res) => {
  try {
    const orderId = req.params.orderId;
    const customerId = req.user.userId;

    const order = await Order.findOne({
      _id: orderId,
      customer: customerId
    }).select('payment status orderNumber summary');

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    let paymentIntentStatus = null;
    if (order.payment.stripePaymentIntentId) {
      try {
        const paymentIntent = await stripe.paymentIntents.retrieve(
          order.payment.stripePaymentIntentId
        );
        paymentIntentStatus = paymentIntent.status;
      } catch (error) {
        console.error('Error retrieving payment intent:', error);
      }
    }

    res.json({
      success: true,
      data: {
        orderId: order._id,
        orderNumber: order.orderNumber,
        orderStatus: order.status,
        paymentStatus: order.payment.status,
        stripePaymentStatus: paymentIntentStatus,
        total: order.summary.total,
        paidAt: order.payment.paidAt
      }
    });

  } catch (error) {
    console.error('Get payment status error:', error);
    if (error.name === 'CastError') {
      return res.status(400).json({
        success: false,
        message: 'Invalid order ID'
      });
    }
    res.status(500).json({
      success: false,
      message: 'Server error while fetching payment status'
    });
  }
});

// @route   POST /api/payments/refund
// @desc    Process refund for an order
// @access  Private (Admin only)
router.post('/refund', [auth], [
  body('orderId')
    .notEmpty()
    .isMongoId()
    .withMessage('Valid order ID is required'),
  body('amount')
    .optional()
    .isFloat({ min: 0.01 })
    .withMessage('Refund amount must be greater than 0'),
  body('reason')
    .optional()
    .trim()
    .isLength({ max: 500 })
    .withMessage('Refund reason cannot exceed 500 characters')
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    // Only admin can process refunds
    if (req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Only administrators can process refunds'
      });
    }

    const { orderId, amount, reason } = req.body;

    const order = await Order.findById(orderId);
    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    if (order.payment.status !== 'completed') {
      return res.status(400).json({
        success: false,
        message: 'Cannot refund order that has not been paid'
      });
    }

    if (!order.payment.stripePaymentIntentId) {
      return res.status(400).json({
        success: false,
        message: 'No payment intent found for this order'
      });
    }

    // Calculate refund amount (default to full amount)
    const refundAmount = amount ? Math.round(amount * 100) : Math.round(order.summary.total * 100);

    // Create refund in Stripe
    const refund = await stripe.refunds.create({
      payment_intent: order.payment.stripePaymentIntentId,
      amount: refundAmount,
      metadata: {
        orderId: order._id.toString(),
        orderNumber: order.orderNumber,
        reason: reason || 'Admin refund'
      }
    });

    // Update order status
    order.payment.status = 'refunded';
    order.status = 'refunded';
    order.payment.refundId = refund.id;
    order.payment.refundedAt = new Date();
    order.payment.refundAmount = refundAmount / 100; // Convert back to dollars
    order.payment.refundReason = reason;

    await order.save();

    res.json({
      success: true,
      message: 'Refund processed successfully',
      data: {
        refundId: refund.id,
        amount: refundAmount / 100,
        status: refund.status,
        orderId: order._id,
        orderNumber: order.orderNumber
      }
    });

  } catch (error) {
    console.error('Process refund error:', error);
    if (error.type === 'StripeCardError') {
      return res.status(400).json({
        success: false,
        message: error.message
      });
    }
    res.status(500).json({
      success: false,
      message: 'Server error while processing refund'
    });
  }
});

// @route   GET /api/payments/test-connection
// @desc    Test Stripe connection
// @access  Private (Admin only)
router.get('/test-connection', [auth], async (req, res) => {
  try {
    // Only admin can test connection
    if (req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Only administrators can test payment connection'
      });
    }

    // Test Stripe connection by retrieving account info
    const account = await stripe.accounts.retrieve();
    
    res.json({
      success: true,
      message: 'Stripe connection successful',
      data: {
        accountId: account.id,
        country: account.country,
        currency: account.default_currency,
        testMode: !account.livemode
      }
    });

  } catch (error) {
    console.error('Test Stripe connection error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to connect to Stripe',
      error: error.message
    });
  }
});

module.exports = router;