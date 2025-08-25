const mongoose = require('mongoose');

const cartItemSchema = new mongoose.Schema({
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
  quantity: {
    type: Number,
    required: true,
    min: [1, 'Quantity must be at least 1'],
    max: [10, 'Quantity cannot exceed 10']
  },
  price: {
    type: Number,
    required: true,
    min: 0
  },
  customization: {
    type: String,
    trim: true,
    maxlength: [200, 'Customization note cannot exceed 200 characters']
  },
  addedAt: {
    type: Date,
    default: Date.now
  }
});

const cartSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true
  },
  items: [cartItemSchema],
  totalItems: {
    type: Number,
    default: 0
  },
  totalPrice: {
    type: Number,
    default: 0
  },
  lastModified: {
    type: Date,
    default: Date.now
  },
  // For guest users (future enhancement)
  sessionId: {
    type: String,
    sparse: true
  },
  // Saved for later items
  savedItems: [{
    product: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Product'
    },
    savedAt: {
      type: Date,
      default: Date.now
    }
  }]
}, {
  timestamps: true
});

// Indexes for better query performance
cartSchema.index({ user: 1 });
cartSchema.index({ sessionId: 1 });
cartSchema.index({ lastModified: 1 });

// Pre-save middleware to calculate totals
cartSchema.pre('save', function(next) {
  this.totalItems = this.items.reduce((total, item) => total + item.quantity, 0);
  this.totalPrice = this.items.reduce((total, item) => total + (item.price * item.quantity), 0);
  this.lastModified = new Date();
  next();
});

// Virtual for grouped items by vendor
cartSchema.virtual('itemsByVendor').get(function() {
  const vendorGroups = {};
  
  this.items.forEach(item => {
    const vendorId = item.vendor.toString();
    if (!vendorGroups[vendorId]) {
      vendorGroups[vendorId] = {
        vendor: item.vendor,
        items: [],
        subtotal: 0,
        itemCount: 0
      };
    }
    
    vendorGroups[vendorId].items.push(item);
    vendorGroups[vendorId].subtotal += item.price * item.quantity;
    vendorGroups[vendorId].itemCount += item.quantity;
  });
  
  return Object.values(vendorGroups);
});

// Method to add item to cart
cartSchema.methods.addItem = function(productId, vendorId, quantity, price, customization = '') {
  const existingItemIndex = this.items.findIndex(
    item => item.product.toString() === productId.toString() && 
           item.customization === customization
  );
  
  if (existingItemIndex > -1) {
    // Update existing item quantity
    this.items[existingItemIndex].quantity += quantity;
    this.items[existingItemIndex].price = price; // Update price in case it changed
  } else {
    // Add new item
    this.items.push({
      product: productId,
      vendor: vendorId,
      quantity,
      price,
      customization
    });
  }
  
  return this.save();
};

// Method to update item quantity
cartSchema.methods.updateItemQuantity = function(itemId, quantity) {
  const item = this.items.id(itemId);
  if (item) {
    if (quantity <= 0) {
      this.items.pull(itemId);
    } else {
      item.quantity = quantity;
    }
    return this.save();
  }
  throw new Error('Item not found in cart');
};

// Method to remove item from cart
cartSchema.methods.removeItem = function(itemId) {
  this.items.pull(itemId);
  return this.save();
};

// Method to clear cart
cartSchema.methods.clearCart = function() {
  this.items = [];
  return this.save();
};

// Method to move item to saved for later
cartSchema.methods.saveForLater = function(itemId) {
  const item = this.items.id(itemId);
  if (item) {
    // Check if already saved
    const alreadySaved = this.savedItems.some(
      saved => saved.product.toString() === item.product.toString()
    );
    
    if (!alreadySaved) {
      this.savedItems.push({
        product: item.product
      });
    }
    
    this.items.pull(itemId);
    return this.save();
  }
  throw new Error('Item not found in cart');
};

// Method to move saved item back to cart
cartSchema.methods.moveToCart = async function(savedItemId, quantity = 1, customization = '') {
  const savedItem = this.savedItems.id(savedItemId);
  if (savedItem) {
    // Get product details
    const Product = mongoose.model('Product');
    const product = await Product.findById(savedItem.product).populate('vendor');
    
    if (product && product.stock >= quantity) {
      await this.addItem(
        product._id,
        product.vendor._id,
        quantity,
        product.price,
        customization
      );
      
      this.savedItems.pull(savedItemId);
      return this.save();
    } else {
      throw new Error('Product not available or insufficient stock');
    }
  }
  throw new Error('Saved item not found');
};

// Method to remove saved item
cartSchema.methods.removeSavedItem = function(savedItemId) {
  this.savedItems.pull(savedItemId);
  return this.save();
};

// Method to validate cart items (check stock, prices, etc.)
cartSchema.methods.validateCart = async function() {
  const Product = mongoose.model('Product');
  const issues = [];
  
  for (let i = this.items.length - 1; i >= 0; i--) {
    const item = this.items[i];
    const product = await Product.findById(item.product);
    
    if (!product || !product.isActive) {
      this.items.splice(i, 1);
      issues.push({
        type: 'unavailable',
        message: `Product "${item.product}" is no longer available`
      });
    } else if (product.stock < item.quantity) {
      if (product.stock > 0) {
        item.quantity = product.stock;
        issues.push({
          type: 'stock_limited',
          message: `Quantity for "${product.name}" reduced to ${product.stock} (available stock)`
        });
      } else {
        this.items.splice(i, 1);
        issues.push({
          type: 'out_of_stock',
          message: `Product "${product.name}" is out of stock`
        });
      }
    } else if (product.price !== item.price) {
      item.price = product.price;
      issues.push({
        type: 'price_changed',
        message: `Price for "${product.name}" has been updated`
      });
    }
  }
  
  if (issues.length > 0) {
    await this.save();
  }
  
  return issues;
};

// Static method to cleanup old carts
cartSchema.statics.cleanupOldCarts = async function() {
  const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
  return this.deleteMany({
    lastModified: { $lt: thirtyDaysAgo },
    'items.0': { $exists: false } // Only delete empty carts
  });
};

module.exports = mongoose.model('Cart', cartSchema);