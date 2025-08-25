const express = require('express');
const { body, validationResult, query } = require('express-validator');
const Review = require('../models/Review');
const Product = require('../models/Product');
const Order = require('../models/Order');
const { auth, customerOnly, vendorOrAdmin } = require('../middleware/auth');

const router = express.Router();

// @route   POST /api/reviews
// @desc    Create a new review
// @access  Private (Customer only)
router.post('/', [auth, customerOnly], [
  body('product')
    .notEmpty()
    .isMongoId()
    .withMessage('Valid product ID is required'),
  body('order')
    .notEmpty()
    .isMongoId()
    .withMessage('Valid order ID is required'),
  body('rating')
    .isInt({ min: 1, max: 5 })
    .withMessage('Rating must be between 1 and 5'),
  body('title')
    .trim()
    .isLength({ min: 5, max: 100 })
    .withMessage('Review title must be between 5 and 100 characters'),
  body('comment')
    .trim()
    .isLength({ min: 10, max: 1000 })
    .withMessage('Review comment must be between 10 and 1000 characters'),
  body('images')
    .optional()
    .isArray({ max: 5 })
    .withMessage('Maximum 5 images allowed')
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

    const { product, order, rating, title, comment, images } = req.body;
    const customerId = req.user.userId;

    // Verify the product exists
    const productDoc = await Product.findById(product);
    if (!productDoc) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    // Verify the order exists and belongs to the customer
    const orderDoc = await Order.findOne({
      _id: order,
      customer: customerId,
      status: 'delivered'
    });

    if (!orderDoc) {
      return res.status(400).json({
        success: false,
        message: 'Order not found or not delivered yet'
      });
    }

    // Check if the product was actually purchased in this order
    const productInOrder = orderDoc.vendorOrders.some(vendorOrder =>
      vendorOrder.items.some(item => item.product.toString() === product)
    );

    if (!productInOrder) {
      return res.status(400).json({
        success: false,
        message: 'Product was not purchased in this order'
      });
    }

    // Check if review already exists
    const existingReview = await Review.findOne({
      product,
      customer: customerId,
      order
    });

    if (existingReview) {
      return res.status(400).json({
        success: false,
        message: 'You have already reviewed this product for this order'
      });
    }

    // Create the review
    const review = new Review({
      product,
      customer: customerId,
      order,
      rating,
      title,
      comment,
      images: images || [],
      isVerifiedPurchase: true
    });

    await review.save();

    // Populate the review for response
    await review.populate([
      { path: 'customer', select: 'name avatar' },
      { path: 'product', select: 'name images' }
    ]);

    res.status(201).json({
      success: true,
      message: 'Review created successfully',
      data: review
    });

  } catch (error) {
    console.error('Create review error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while creating review'
    });
  }
});

// @route   GET /api/reviews/product/:productId
// @desc    Get reviews for a specific product
// @access  Public
router.get('/product/:productId', [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 50 }).withMessage('Limit must be between 1 and 50'),
  query('sort').optional().isIn(['newest', 'oldest', 'rating_high', 'rating_low', 'helpful']).withMessage('Invalid sort option'),
  query('rating').optional().isInt({ min: 1, max: 5 }).withMessage('Rating filter must be between 1 and 5')
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

    const {
      page = 1,
      limit = 10,
      sort = 'newest',
      rating
    } = req.query;

    const productId = req.params.productId;

    // Verify product exists
    const product = await Product.findById(productId);
    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    // Build filter
    const filter = {
      product: productId,
      isModerated: false
    };

    if (rating) {
      filter.rating = parseInt(rating);
    }

    // Build sort object
    let sortObj = {};
    switch (sort) {
      case 'newest':
        sortObj = { createdAt: -1 };
        break;
      case 'oldest':
        sortObj = { createdAt: 1 };
        break;
      case 'rating_high':
        sortObj = { rating: -1, createdAt: -1 };
        break;
      case 'rating_low':
        sortObj = { rating: 1, createdAt: -1 };
        break;
      case 'helpful':
        sortObj = { helpfulCount: -1, createdAt: -1 };
        break;
      default:
        sortObj = { createdAt: -1 };
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const [reviews, totalReviews, reviewStats] = await Promise.all([
      Review.find(filter)
        .populate('customer', 'name avatar')
        .sort(sortObj)
        .skip(skip)
        .limit(parseInt(limit))
        .lean(),
      Review.countDocuments(filter),
      Review.getReviewStats(productId)
    ]);

    const totalPages = Math.ceil(totalReviews / parseInt(limit));

    res.json({
      success: true,
      data: {
        reviews,
        stats: reviewStats,
        pagination: {
          currentPage: parseInt(page),
          totalPages,
          totalReviews,
          hasNextPage: parseInt(page) < totalPages,
          hasPrevPage: parseInt(page) > 1,
          limit: parseInt(limit)
        }
      }
    });

  } catch (error) {
    console.error('Get product reviews error:', error);
    if (error.name === 'CastError') {
      return res.status(400).json({
        success: false,
        message: 'Invalid product ID'
      });
    }
    res.status(500).json({
      success: false,
      message: 'Server error while fetching reviews'
    });
  }
});

// @route   PUT /api/reviews/:id/helpful
// @desc    Mark review as helpful or not helpful
// @access  Private
router.put('/:id/helpful', [auth], [
  body('helpful')
    .isBoolean()
    .withMessage('Helpful must be a boolean value')
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

    const { helpful } = req.body;
    const userId = req.user.userId;
    const reviewId = req.params.id;

    const review = await Review.findById(reviewId);
    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Review not found'
      });
    }

    // Prevent users from marking their own reviews as helpful
    if (review.customer.toString() === userId.toString()) {
      return res.status(400).json({
        success: false,
        message: 'You cannot mark your own review as helpful'
      });
    }

    await review.markHelpful(userId, helpful);

    res.json({
      success: true,
      message: `Review marked as ${helpful ? 'helpful' : 'not helpful'}`,
      data: {
        helpfulCount: review.helpfulCount,
        notHelpfulCount: review.notHelpfulCount
      }
    });

  } catch (error) {
    console.error('Mark review helpful error:', error);
    if (error.name === 'CastError') {
      return res.status(400).json({
        success: false,
        message: 'Invalid review ID'
      });
    }
    res.status(500).json({
      success: false,
      message: 'Server error while updating review'
    });
  }
});

// @route   POST /api/reviews/:id/response
// @desc    Add vendor response to review
// @access  Private (Vendor or Admin)
router.post('/:id/response', [auth, vendorOrAdmin], [
  body('response')
    .trim()
    .isLength({ min: 10, max: 500 })
    .withMessage('Response must be between 10 and 500 characters')
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

    const { response } = req.body;
    const userId = req.user.userId;
    const reviewId = req.params.id;

    const review = await Review.findById(reviewId).populate('product', 'vendor');
    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Review not found'
      });
    }

    // Check if user is the vendor of the product or an admin
    if (req.user.role !== 'admin' && review.product.vendor.toString() !== userId.toString()) {
      return res.status(403).json({
        success: false,
        message: 'You can only respond to reviews of your own products'
      });
    }

    await review.addVendorResponse(userId, response);

    res.json({
      success: true,
      message: 'Response added successfully',
      data: review.vendorResponse
    });

  } catch (error) {
    console.error('Add vendor response error:', error);
    if (error.name === 'CastError') {
      return res.status(400).json({
        success: false,
        message: 'Invalid review ID'
      });
    }
    res.status(500).json({
      success: false,
      message: 'Server error while adding response'
    });
  }
});

// @route   PUT /api/reviews/:id
// @desc    Update review (customer can edit their own review)
// @access  Private (Customer only - own reviews)
router.put('/:id', [auth, customerOnly], [
  body('rating')
    .optional()
    .isInt({ min: 1, max: 5 })
    .withMessage('Rating must be between 1 and 5'),
  body('title')
    .optional()
    .trim()
    .isLength({ min: 5, max: 100 })
    .withMessage('Review title must be between 5 and 100 characters'),
  body('comment')
    .optional()
    .trim()
    .isLength({ min: 10, max: 1000 })
    .withMessage('Review comment must be between 10 and 1000 characters'),
  body('images')
    .optional()
    .isArray({ max: 5 })
    .withMessage('Maximum 5 images allowed')
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

    const reviewId = req.params.id;
    const customerId = req.user.userId;
    const { rating, title, comment, images } = req.body;

    const review = await Review.findOne({
      _id: reviewId,
      customer: customerId
    });

    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Review not found or you do not have permission to edit it'
      });
    }

    // Update fields if provided
    if (rating !== undefined) review.rating = rating;
    if (title) review.title = title;
    if (comment) review.comment = comment;
    if (images !== undefined) review.images = images;

    review.updatedAt = new Date();
    await review.save();

    // Populate the review for response
    await review.populate([
      { path: 'customer', select: 'name avatar' },
      { path: 'product', select: 'name images' }
    ]);

    res.json({
      success: true,
      message: 'Review updated successfully',
      data: review
    });

  } catch (error) {
    console.error('Update review error:', error);
    if (error.name === 'CastError') {
      return res.status(400).json({
        success: false,
        message: 'Invalid review ID'
      });
    }
    res.status(500).json({
      success: false,
      message: 'Server error while updating review'
    });
  }
});

// @route   DELETE /api/reviews/:id
// @desc    Delete review
// @access  Private (Customer - own reviews, Admin - any review)
router.delete('/:id', [auth], async (req, res) => {
  try {
    const reviewId = req.params.id;
    const userId = req.user.userId;
    const userRole = req.user.role;

    const review = await Review.findById(reviewId);
    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Review not found'
      });
    }

    // Check permissions: customer can delete own reviews, admin can delete any
    if (userRole !== 'admin' && review.customer.toString() !== userId.toString()) {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to delete this review'
      });
    }

    await Review.findByIdAndDelete(reviewId);

    res.json({
      success: true,
      message: 'Review deleted successfully'
    });

  } catch (error) {
    console.error('Delete review error:', error);
    if (error.name === 'CastError') {
      return res.status(400).json({
        success: false,
        message: 'Invalid review ID'
      });
    }
    res.status(500).json({
      success: false,
      message: 'Server error while deleting review'
    });
  }
});

// @route   GET /api/reviews/customer/:customerId
// @desc    Get reviews by customer
// @access  Private (Customer - own reviews, Admin - any customer)
router.get('/customer/:customerId', [auth], [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 50 }).withMessage('Limit must be between 1 and 50')
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

    const customerId = req.params.customerId;
    const userId = req.user.userId;
    const userRole = req.user.role;

    // Check permissions: customer can view own reviews, admin can view any
    if (userRole !== 'admin' && customerId !== userId.toString()) {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to view these reviews'
      });
    }

    const { page = 1, limit = 10 } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);

    const [reviews, totalReviews] = await Promise.all([
      Review.find({ customer: customerId })
        .populate('product', 'name images vendor')
        .populate('customer', 'name avatar')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit))
        .lean(),
      Review.countDocuments({ customer: customerId })
    ]);

    const totalPages = Math.ceil(totalReviews / parseInt(limit));

    res.json({
      success: true,
      data: {
        reviews,
        pagination: {
          currentPage: parseInt(page),
          totalPages,
          totalReviews,
          hasNextPage: parseInt(page) < totalPages,
          hasPrevPage: parseInt(page) > 1,
          limit: parseInt(limit)
        }
      }
    });

  } catch (error) {
    console.error('Get customer reviews error:', error);
    if (error.name === 'CastError') {
      return res.status(400).json({
        success: false,
        message: 'Invalid customer ID'
      });
    }
    res.status(500).json({
      success: false,
      message: 'Server error while fetching customer reviews'
    });
  }
});

module.exports = router;