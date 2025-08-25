const express = require('express');
const { body, validationResult } = require('express-validator');
const User = require('../models/User');
const Cart = require('../models/Cart');
const { auth, customerOnly } = require('../middleware/auth');

const router = express.Router();

// @route   GET /api/users/profile
// @desc    Get user profile
// @access  Private
router.get('/profile', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.userId).select('-password');
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json({
      success: true,
      data: user.getPublicProfile()
    });

  } catch (error) {
    console.error('Get user profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching profile'
    });
  }
});

// @route   PUT /api/users/profile
// @desc    Update user profile
// @access  Private
router.put('/profile', auth, [
  body('name')
    .optional()
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage('Name must be between 2 and 50 characters'),
  body('phone')
    .optional()
    .trim(),
  body('address.street')
    .optional()
    .trim(),
  body('address.city')
    .optional()
    .trim(),
  body('address.state')
    .optional()
    .trim(),
  body('address.zipCode')
    .optional()
    .trim(),
  body('address.country')
    .optional()
    .trim()
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

    const user = await User.findById(req.user.userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const { name, phone, address, avatar } = req.body;

    // Update fields
    if (name) user.name = name;
    if (phone) user.phone = phone;
    if (address) {
      user.address = { ...user.address, ...address };
    }
    if (avatar) user.avatar = avatar;

    await user.save();

    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: user.getPublicProfile()
    });

  } catch (error) {
    console.error('Update user profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating profile'
    });
  }
});

// @route   GET /api/users/cart
// @desc    Get user's cart
// @access  Private (Customer only)
router.get('/cart', [auth, customerOnly], async (req, res) => {
  try {
    let cart = await Cart.findOne({ user: req.user.userId })
      .populate({
        path: 'items.product',
        select: 'name price images stock isActive',
        populate: {
          path: 'vendor',
          select: 'name vendorInfo.shopName'
        }
      })
      .populate('savedItems.product', 'name price images stock isActive')
      .lean();

    if (!cart) {
      cart = new Cart({ user: req.user.userId });
      await cart.save();
      cart = cart.toObject();
    }

    // Validate cart items and remove unavailable products
    if (cart.items && cart.items.length > 0) {
      const validItems = cart.items.filter(item => 
        item.product && 
        item.product.isActive && 
        item.product.stock >= item.quantity
      );

      if (validItems.length !== cart.items.length) {
        await Cart.findByIdAndUpdate(cart._id, {
          items: validItems
        });
        cart.items = validItems;
      }
    }

    res.json({
      success: true,
      data: cart
    });

  } catch (error) {
    console.error('Get cart error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching cart'
    });
  }
});

// @route   POST /api/users/cart/add
// @desc    Add item to cart
// @access  Private (Customer only)
router.post('/cart/add', [auth, customerOnly], [
  body('productId')
    .isMongoId()
    .withMessage('Invalid product ID'),
  body('quantity')
    .isInt({ min: 1, max: 10 })
    .withMessage('Quantity must be between 1 and 10'),
  body('customization')
    .optional()
    .trim()
    .isLength({ max: 200 })
    .withMessage('Customization note cannot exceed 200 characters')
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

    const { productId, quantity, customization = '' } = req.body;

    // Check if product exists and is available
    const product = await Product.findById(productId).populate('vendor');
    if (!product || !product.isActive) {
      return res.status(404).json({
        success: false,
        message: 'Product not found or not available'
      });
    }

    // Check stock
    if (product.stock < quantity) {
      return res.status(400).json({
        success: false,
        message: 'Insufficient stock',
        availableStock: product.stock
      });
    }

    // Get or create cart
    let cart = await Cart.findOne({ user: req.user.userId });
    if (!cart) {
      cart = new Cart({ user: req.user.userId });
    }

    // Add item to cart
    await cart.addItem(
      productId,
      product.vendor._id,
      quantity,
      product.price,
      customization
    );

    // Populate cart for response
    const populatedCart = await Cart.findById(cart._id)
      .populate({
        path: 'items.product',
        select: 'name price images',
        populate: {
          path: 'vendor',
          select: 'name vendorInfo.shopName'
        }
      })
      .lean();

    res.json({
      success: true,
      message: 'Item added to cart successfully',
      data: populatedCart
    });

  } catch (error) {
    console.error('Add to cart error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while adding item to cart'
    });
  }
});

// @route   PUT /api/users/cart/update/:itemId
// @desc    Update cart item quantity
// @access  Private (Customer only)
router.put('/cart/update/:itemId', [auth, customerOnly], [
  body('quantity')
    .isInt({ min: 1, max: 10 })
    .withMessage('Quantity must be between 1 and 10')
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

    const { quantity } = req.body;

    const cart = await Cart.findOne({ user: req.user.userId });
    if (!cart) {
      return res.status(404).json({
        success: false,
        message: 'Cart not found'
      });
    }

    await cart.updateItemQuantity(req.params.itemId, quantity);

    // Populate cart for response
    const populatedCart = await Cart.findById(cart._id)
      .populate({
        path: 'items.product',
        select: 'name price images',
        populate: {
          path: 'vendor',
          select: 'name vendorInfo.shopName'
        }
      })
      .lean();

    res.json({
      success: true,
      message: 'Cart updated successfully',
      data: populatedCart
    });

  } catch (error) {
    console.error('Update cart error:', error);
    if (error.message === 'Item not found in cart') {
      return res.status(404).json({
        success: false,
        message: error.message
      });
    }
    res.status(500).json({
      success: false,
      message: 'Server error while updating cart'
    });
  }
});

// @route   DELETE /api/users/cart/remove/:itemId
// @desc    Remove item from cart
// @access  Private (Customer only)
router.delete('/cart/remove/:itemId', [auth, customerOnly], async (req, res) => {
  try {
    const cart = await Cart.findOne({ user: req.user.userId });
    if (!cart) {
      return res.status(404).json({
        success: false,
        message: 'Cart not found'
      });
    }

    await cart.removeItem(req.params.itemId);

    // Populate cart for response
    const populatedCart = await Cart.findById(cart._id)
      .populate({
        path: 'items.product',
        select: 'name price images',
        populate: {
          path: 'vendor',
          select: 'name vendorInfo.shopName'
        }
      })
      .lean();

    res.json({
      success: true,
      message: 'Item removed from cart successfully',
      data: populatedCart
    });

  } catch (error) {
    console.error('Remove from cart error:', error);
    if (error.message === 'Item not found in cart') {
      return res.status(404).json({
        success: false,
        message: error.message
      });
    }
    res.status(500).json({
      success: false,
      message: 'Server error while removing item from cart'
    });
  }
});

// @route   DELETE /api/users/cart/clear
// @desc    Clear cart
// @access  Private (Customer only)
router.delete('/cart/clear', [auth, customerOnly], async (req, res) => {
  try {
    const cart = await Cart.findOne({ user: req.user.userId });
    if (!cart) {
      return res.status(404).json({
        success: false,
        message: 'Cart not found'
      });
    }

    await cart.clearCart();

    res.json({
      success: true,
      message: 'Cart cleared successfully',
      data: {
        items: [],
        totalItems: 0,
        totalPrice: 0
      }
    });

  } catch (error) {
    console.error('Clear cart error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while clearing cart'
    });
  }
});

// @route   POST /api/users/cart/save-for-later/:itemId
// @desc    Save item for later
// @access  Private (Customer only)
router.post('/cart/save-for-later/:itemId', [auth, customerOnly], async (req, res) => {
  try {
    const cart = await Cart.findOne({ user: req.user.userId });
    if (!cart) {
      return res.status(404).json({
        success: false,
        message: 'Cart not found'
      });
    }

    await cart.saveForLater(req.params.itemId);

    // Populate cart for response
    const populatedCart = await Cart.findById(cart._id)
      .populate({
        path: 'items.product',
        select: 'name price images',
        populate: {
          path: 'vendor',
          select: 'name vendorInfo.shopName'
        }
      })
      .populate('savedItems.product', 'name price images')
      .lean();

    res.json({
      success: true,
      message: 'Item saved for later successfully',
      data: populatedCart
    });

  } catch (error) {
    console.error('Save for later error:', error);
    if (error.message === 'Item not found in cart') {
      return res.status(404).json({
        success: false,
        message: error.message
      });
    }
    res.status(500).json({
      success: false,
      message: 'Server error while saving item for later'
    });
  }
});

module.exports = router;