const mongoose = require('mongoose');

const orderItemSchema = new mongoose.Schema({
  product: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product',
    required: true
  },
  vendor: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  name: {
    type: String,
    required: true
  },
  image: {
    type: String,
    required: true
  },
  price: {
    type: Number,
    required: true,
    min: 0
  },
  quantity: {
    type: Number,
    required: true,
    min: 1
  },
  customization: {
    type: String,
    trim: true
  }
});

const shippingAddressSchema = new mongoose.Schema({
  fullName: {
    type: String,
    required: true,
    trim: true
  },
  street: {
    type: String,
    required: true,
    trim: true
  },
  city: {
    type: String,
    required: true,
    trim: true
  },
  state: {
    type: String,
    required: true,
    trim: true
  },
  zipCode: {
    type: String,
    required: true,
    trim: true
  },
  country: {
    type: String,
    required: true,
    trim: true
  },
  phone: {
    type: String,
    trim: true
  }
});

const paymentInfoSchema = new mongoose.Schema({
  method: {
    type: String,
    enum: ['stripe', 'paypal', 'card'],
    default: 'stripe'
  },
  stripePaymentIntentId: {
    type: String
  },
  transactionId: {
    type: String
  },
  status: {
    type: String,
    enum: ['pending', 'processing', 'succeeded', 'failed', 'refunded'],
    default: 'pending'
  },
  paidAt: {
    type: Date
  },
  refundedAt: {
    type: Date
  },
  refundAmount: {
    type: Number,
    default: 0
  }
});

const vendorOrderSchema = new mongoose.Schema({
  vendor: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  items: [orderItemSchema],
  subtotal: {
    type: Number,
    required: true,
    min: 0
  },
  shippingCost: {
    type: Number,
    default: 0,
    min: 0
  },
  commission: {
    type: Number,
    required: true,
    min: 0
  },
  vendorEarnings: {
    type: Number,
    required: true,
    min: 0
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled'],
    default: 'pending'
  },
  trackingNumber: {
    type: String,
    trim: true
  },
  estimatedDelivery: {
    type: Date
  },
  shippedAt: {
    type: Date
  },
  deliveredAt: {
    type: Date
  }
});

const orderSchema = new mongoose.Schema({
  orderNumber: {
    type: String,
    unique: true,
    required: true
  },
  customer: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  vendorOrders: [vendorOrderSchema],
  shippingAddress: {
    type: shippingAddressSchema,
    required: true
  },
  billingAddress: {
    type: shippingAddressSchema
  },
  paymentInfo: {
    type: paymentInfoSchema,
    required: true
  },
  orderSummary: {
    subtotal: {
      type: Number,
      required: true,
      min: 0
    },
    shippingTotal: {
      type: Number,
      default: 0,
      min: 0
    },
    tax: {
      type: Number,
      default: 0,
      min: 0
    },
    total: {
      type: Number,
      required: true,
      min: 0
    },
    totalCommission: {
      type: Number,
      required: true,
      min: 0
    }
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'processing', 'partially_shipped', 'shipped', 'delivered', 'cancelled', 'refunded'],
    default: 'pending'
  },
  notes: {
    type: String,
    trim: true
  },
  customerNotes: {
    type: String,
    trim: true
  },
  cancelReason: {
    type: String,
    trim: true
  },
  cancelledAt: {
    type: Date
  },
  completedAt: {
    type: Date
  }
}, {
  timestamps: true
});

// Indexes for better query performance
orderSchema.index({ customer: 1 });
orderSchema.index({ orderNumber: 1 });
orderSchema.index({ status: 1 });
orderSchema.index({ createdAt: -1 });
orderSchema.index({ 'vendorOrders.vendor': 1 });
orderSchema.index({ 'paymentInfo.stripePaymentIntentId': 1 });

// Generate order number before saving
orderSchema.pre('save', function(next) {
  if (this.isNew && !this.orderNumber) {
    const timestamp = Date.now().toString();
    const random = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
    this.orderNumber = `AM${timestamp.slice(-6)}${random}`;
  }
  next();
});

// Virtual for total items count
orderSchema.virtual('totalItems').get(function() {
  return this.vendorOrders.reduce((total, vendorOrder) => {
    return total + vendorOrder.items.reduce((itemTotal, item) => itemTotal + item.quantity, 0);
  }, 0);
});

// Virtual for overall order status based on vendor orders
orderSchema.virtual('overallStatus').get(function() {
  if (this.status === 'cancelled' || this.status === 'refunded') {
    return this.status;
  }

  const vendorStatuses = this.vendorOrders.map(vo => vo.status);
  
  if (vendorStatuses.every(status => status === 'delivered')) {
    return 'delivered';
  } else if (vendorStatuses.some(status => status === 'delivered') || vendorStatuses.some(status => status === 'shipped')) {
    return 'partially_shipped';
  } else if (vendorStatuses.every(status => status === 'confirmed' || status === 'processing')) {
    return 'processing';
  } else {
    return 'pending';
  }
});

// Method to update order status based on vendor orders
orderSchema.methods.updateOrderStatus = function() {
  const vendorStatuses = this.vendorOrders.map(vo => vo.status);
  
  if (vendorStatuses.every(status => status === 'delivered')) {
    this.status = 'delivered';
    this.completedAt = new Date();
  } else if (vendorStatuses.some(status => status === 'delivered') || vendorStatuses.some(status => status === 'shipped')) {
    this.status = 'partially_shipped';
  } else if (vendorStatuses.every(status => status === 'confirmed' || status === 'processing')) {
    this.status = 'processing';
  } else if (vendorStatuses.every(status => status === 'cancelled')) {
    this.status = 'cancelled';
    this.cancelledAt = new Date();
  }
};

// Method to calculate vendor earnings
orderSchema.methods.calculateVendorEarnings = function() {
  this.vendorOrders.forEach(vendorOrder => {
    const commissionRate = vendorOrder.commission / 100;
    const commissionAmount = vendorOrder.subtotal * commissionRate;
    vendorOrder.vendorEarnings = vendorOrder.subtotal - commissionAmount;
  });
};

module.exports = mongoose.model('Order', orderSchema);