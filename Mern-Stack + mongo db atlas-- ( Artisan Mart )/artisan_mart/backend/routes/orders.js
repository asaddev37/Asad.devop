const express = require('express');
const { body, validationResult, query } = require('express-validator');
const Order = require('../models/Order');
const Product = require('../models/Product');
const Cart = require('../models/Cart');
const User = require('../models/User');
const { auth, customerOnly, vendorOnly, adminOnly, vendorOrAdmin } = require('../middleware/auth');

const router = express.Router();

// @route   POST /api/orders
// @desc    Create a new order
// @access  Private (Customer only)
router.post('/', [auth, customerOnly], [
  body('items')
    .isArray({ min: 1 })
    .withMessage('Order must contain at least one item'),
  body('items.*.product')
    .isMongoId()
    .withMessage('Invalid product ID'),
  body('items.*.quantity')
    .isInt({ min: 1 })
    .withMessage('Quantity must be at least 1'),
  body('shippingAddress.fullName')
    .trim()
    .notEmpty()
    .withMessage('Full name is required'),
  body('shippingAddress.street')
    .trim()
    .notEmpty()
    .withMessage('Street address is required'),
  body('shippingAddress.city')
    .trim()
    .notEmpty()
    .withMessage('City is required'),
  body('shippingAddress.state')
    .trim()
    .notEmpty()
    .withMessage('State is required'),
  body('shippingAddress.zipCode')
    .trim()
    .notEmpty()
    .withMessage('Zip code is required'),
  body('shippingAddress.country')
    .trim()
    .notEmpty()
    .withMessage('Country is required')
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

    const { items, shippingAddress, billingAddress, customerNotes } = req.body;

    // Validate and get product details
    const productIds = items.map(item => item.product);
    const products = await Product.find({ 
      _id: { $in: productIds }, 
      isActive: true 
    }).populate('vendor', 'vendorInfo.commission');

    if (products.length !== items.length) {
      return res.status(400).json({
        success: false,
        message: 'Some products are not available'
      });
    }

    // Check stock availability
    const stockIssues = [];
    for (const item of items) {
      const product = products.find(p => p._id.toString() === item.product);
      if (product.stock < item.quantity) {
        stockIssues.push({
          product: product.name,
          requested: item.quantity,
          available: product.stock
        });
      }
    }

    if (stockIssues.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Insufficient stock for some items',
        stockIssues
      });
    }

    // Group items by vendor
    const vendorGroups = {};
    let totalAmount = 0;
    let totalCommission = 0;

    for (const item of items) {
      const product = products.find(p => p._id.toString() === item.product);
      const vendorId = product.vendor._id.toString();
      const itemTotal = product.price * item.quantity;
      const commission = product.vendor.vendorInfo.commission || 10;
      const commissionAmount = (itemTotal * commission) / 100;

      if (!vendorGroups[vendorId]) {
        vendorGroups[vendorId] = {
          vendor: product.vendor._id,
          items: [],
          subtotal: 0,
          commission: commission,
          vendorEarnings: 0
        };
      }

      vendorGroups[vendorId].items.push({
        product: product._id,
        vendor: product.vendor._id,
        name: product.name,
        image: product.images[0]?.url || '',
        price: product.price,
        quantity: item.quantity,
        customization: item.customization || ''
      });

      vendorGroups[vendorId].subtotal += itemTotal;
      vendorGroups[vendorId].vendorEarnings += itemTotal - commissionAmount;
      totalAmount += itemTotal;
      totalCommission += commissionAmount;
    }

    // Create order
    const orderData = {
      customer: req.user.userId,
      vendorOrders: Object.values(vendorGroups),
      shippingAddress,
      billingAddress: billingAddress || shippingAddress,
      customerNotes,
      paymentInfo: {
        method: 'stripe',
        status: 'pending'
      },
      orderSummary: {
        subtotal: totalAmount,
        shippingTotal: 0, // Calculate based on vendor shipping policies
        tax: 0, // Calculate based on location
        total: totalAmount,
        totalCommission
      }
    };

    const order = new Order(orderData);
    await order.save();

    // Update product stock
    for (const item of items) {
      await Product.findByIdAndUpdate(
        item.product,
        { $inc: { stock: -item.quantity } }
      );
    }

    // Clear user's cart
    await Cart.findOneAndUpdate(
      { user: req.user.userId },
      { $set: { items: [] } }
    );

    // Populate order for response
    const populatedOrder = await Order.findById(order._id)
      .populate('customer', 'name email')
      .populate('vendorOrders.vendor', 'name vendorInfo.shopName')
      .populate('vendorOrders.items.product', 'name slug')
      .lean();

    res.status(201).json({
      success: true,
      message: 'Order created successfully',
      data: populatedOrder
    });

  } catch (error) {
    console.error('Create order error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while creating order'
    });
  }
});

// @route   GET /api/orders
// @desc    Get user's orders (customer) or vendor's orders (vendor)
// @access  Private
router.get('/', auth, [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 50 }).withMessage('Limit must be between 1 and 50'),
  query('status').optional().trim()
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

    const { page = 1, limit = 10, status } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);

    let filter = {};
    let populateOptions = [];

    if (req.user.role === 'customer') {
      filter.customer = req.user.userId;
      populateOptions = [
        { path: 'vendorOrders.vendor', select: 'name vendorInfo.shopName' },
        { path: 'vendorOrders.items.product', select: 'name slug' }
      ];
    } else if (req.user.role === 'vendor') {
      filter['vendorOrders.vendor'] = req.user.userId;
      populateOptions = [
        { path: 'customer', select: 'name email' },
        { path: 'vendorOrders.items.product', select: 'name slug' }
      ];
    } else if (req.user.role === 'admin') {
      // Admin can see all orders
      populateOptions = [
        { path: 'customer', select: 'name email' },
        { path: 'vendorOrders.vendor', select: 'name vendorInfo.shopName' },
        { path: 'vendorOrders.items.product', select: 'name slug' }
      ];
    }

    if (status) {
      filter.status = status;
    }

    const [orders, totalOrders] = await Promise.all([
      Order.find(filter)
        .populate(populateOptions)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit))
        .lean(),
      Order.countDocuments(filter)
    ]);

    // Filter vendor orders for vendors
    if (req.user.role === 'vendor') {
      orders.forEach(order => {
        order.vendorOrders = order.vendorOrders.filter(
          vo => vo.vendor._id.toString() === req.user.userId.toString()
        );
      });
    }

    const totalPages = Math.ceil(totalOrders / parseInt(limit));

    res.json({
      success: true,
      data: {
        orders,
        pagination: {
          currentPage: parseInt(page),
          totalPages,
          totalOrders,
          hasNextPage: parseInt(page) < totalPages,
          hasPrevPage: parseInt(page) > 1,
          limit: parseInt(limit)
        }
      }
    });

  } catch (error) {
    console.error('Get orders error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching orders'
    });
  }
});

// @route   GET /api/orders/:id
// @desc    Get single order by ID
// @access  Private
router.get('/:id', auth, async (req, res) => {
  try {
    const order = await Order.findById(req.params.id)
      .populate('customer', 'name email phone')
      .populate('vendorOrders.vendor', 'name vendorInfo.shopName vendorInfo.shopLogo')
      .populate('vendorOrders.items.product', 'name slug images')
      .lean();

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    // Check access permissions
    const hasAccess = 
      req.user.role === 'admin' ||
      (req.user.role === 'customer' && order.customer._id.toString() === req.user.userId.toString()) ||
      (req.user.role === 'vendor' && order.vendorOrders.some(vo => vo.vendor._id.toString() === req.user.userId.toString()));

    if (!hasAccess) {
      return res.status(403).json({
        success: false,
        message: 'Access denied'
      });
    }

    // Filter vendor orders for vendors
    if (req.user.role === 'vendor') {
      order.vendorOrders = order.vendorOrders.filter(
        vo => vo.vendor._id.toString() === req.user.userId.toString()
      );
    }

    res.json({
      success: true,
      data: order
    });

  } catch (error) {
    console.error('Get order error:', error);
    if (error.name === 'CastError') {
      return res.status(400).json({
        success: false,
        message: 'Invalid order ID'
      });
    }
    res.status(500).json({
      success: false,
      message: 'Server error while fetching order'
    });
  }
});

// @route   PUT /api/orders/:id/vendor-status
// @desc    Update vendor order status
// @access  Private (Vendor only)
router.put('/:id/vendor-status', [auth, vendorOnly], [
  body('status')
    .isIn(['confirmed', 'processing', 'shipped', 'delivered', 'cancelled'])
    .withMessage('Invalid status'),
  body('trackingNumber')
    .optional()
    .trim(),
  body('estimatedDelivery')
    .optional()
    .isISO8601()
    .withMessage('Invalid date format')
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

    const { status, trackingNumber, estimatedDelivery } = req.body;

    const order = await Order.findById(req.params.id);
    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    // Find vendor's order
    const vendorOrder = order.vendorOrders.find(
      vo => vo.vendor.toString() === req.user.userId.toString()
    );

    if (!vendorOrder) {
      return res.status(404).json({
        success: false,
        message: 'Vendor order not found'
      });
    }

    // Update vendor order status
    vendorOrder.status = status;
    if (trackingNumber) vendorOrder.trackingNumber = trackingNumber;
    if (estimatedDelivery) vendorOrder.estimatedDelivery = new Date(estimatedDelivery);

    // Set timestamps
    if (status === 'shipped') {
      vendorOrder.shippedAt = new Date();
    } else if (status === 'delivered') {
      vendorOrder.deliveredAt = new Date();
    }

    // Update overall order status
    order.updateOrderStatus();

    await order.save();

    // Update product sales count if delivered
    if (status === 'delivered') {
      for (const item of vendorOrder.items) {
        await Product.findByIdAndUpdate(
          item.product,
          { $inc: { sales: item.quantity } }
        );
      }
    }

    res.json({
      success: true,
      message: 'Order status updated successfully',
      data: {
        orderId: order._id,
        orderNumber: order.orderNumber,
        vendorOrderStatus: status,
        overallOrderStatus: order.status
      }
    });

  } catch (error) {
    console.error('Update vendor order status error:', error);
    if (error.name === 'CastError') {
      return res.status(400).json({
        success: false,
        message: 'Invalid order ID'
      });
    }
    res.status(500).json({
      success: false,
      message: 'Server error while updating order status'
    });
  }
});

// @route   PUT /api/orders/:id/cancel
// @desc    Cancel an order
// @access  Private (Customer - own orders, Admin - all orders)
router.put('/:id/cancel', auth, [
  body('reason')
    .optional()
    .trim()
    .isLength({ max: 500 })
    .withMessage('Cancel reason cannot exceed 500 characters')
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

    const { reason } = req.body;

    const order = await Order.findById(req.params.id);
    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    // Check access permissions
    const canCancel = 
      req.user.role === 'admin' ||
      (req.user.role === 'customer' && order.customer.toString() === req.user.userId.toString());

    if (!canCancel) {
      return res.status(403).json({
        success: false,
        message: 'Access denied'
      });
    }

    // Check if order can be cancelled
    if (['delivered', 'cancelled', 'refunded'].includes(order.status)) {
      return res.status(400).json({
        success: false,
        message: 'Order cannot be cancelled in current status'
      });
    }

    // Cancel all vendor orders
    order.vendorOrders.forEach(vendorOrder => {
      if (!['delivered', 'cancelled'].includes(vendorOrder.status)) {
        vendorOrder.status = 'cancelled';
      }
    });

    order.status = 'cancelled';
    order.cancelReason = reason;
    order.cancelledAt = new Date();

    await order.save();

    // Restore product stock
    for (const vendorOrder of order.vendorOrders) {
      for (const item of vendorOrder.items) {
        await Product.findByIdAndUpdate(
          item.product,
          { $inc: { stock: item.quantity } }
        );
      }
    }

    res.json({
      success: true,
      message: 'Order cancelled successfully',
      data: {
        orderId: order._id,
        orderNumber: order.orderNumber,
        status: order.status,
        cancelledAt: order.cancelledAt
      }
    });

  } catch (error) {
    console.error('Cancel order error:', error);
    if (error.name === 'CastError') {
      return res.status(400).json({
        success: false,
        message: 'Invalid order ID'
      });
    }
    res.status(500).json({
      success: false,
      message: 'Server error while cancelling order'
    });
  }
});

// @route   GET /api/orders/stats/summary
// @desc    Get order statistics
// @access  Private (Vendor - own stats, Admin - all stats)
router.get('/stats/summary', [auth, vendorOrAdmin], async (req, res) => {
  try {
    let matchStage = {};
    
    if (req.user.role === 'vendor') {
      matchStage['vendorOrders.vendor'] = req.user.userId;
    }

    const stats = await Order.aggregate([
      { $match: matchStage },
      {
        $group: {
          _id: null,
          totalOrders: { $sum: 1 },
          totalRevenue: { $sum: '$orderSummary.total' },
          averageOrderValue: { $avg: '$orderSummary.total' },
          pendingOrders: {
            $sum: { $cond: [{ $eq: ['$status', 'pending'] }, 1, 0] }
          },
          processingOrders: {
            $sum: { $cond: [{ $eq: ['$status', 'processing'] }, 1, 0] }
          },
          shippedOrders: {
            $sum: { $cond: [{ $in: ['$status', ['shipped', 'partially_shipped']] }, 1, 0] }
          },
          deliveredOrders: {
            $sum: { $cond: [{ $eq: ['$status', 'delivered'] }, 1, 0] }
          },
          cancelledOrders: {
            $sum: { $cond: [{ $eq: ['$status', 'cancelled'] }, 1, 0] }
          }
        }
      }
    ]);

    const result = stats[0] || {
      totalOrders: 0,
      totalRevenue: 0,
      averageOrderValue: 0,
      pendingOrders: 0,
      processingOrders: 0,
      shippedOrders: 0,
      deliveredOrders: 0,
      cancelledOrders: 0
    };

    res.json({
      success: true,
      data: result
    });

  } catch (error) {
    console.error('Get order stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching order statistics'
    });
  }
});

module.exports = router;