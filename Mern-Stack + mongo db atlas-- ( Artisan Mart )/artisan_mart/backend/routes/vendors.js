const express = require('express');
const { body, validationResult, query } = require('express-validator');
const User = require('../models/User');
const Product = require('../models/Product');
const Order = require('../models/Order');
const { auth, vendorOnly, adminOnly, vendorOrAdmin, optionalAuth } = require('../middleware/auth');

const router = express.Router();

// @route   GET /api/vendors
// @desc    Get all approved vendors
// @access  Public
router.get('/', [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 50 }).withMessage('Limit must be between 1 and 50'),
  query('search').optional().trim()
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

    const { page = 1, limit = 12, search } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);

    // Build filter
    const filter = {
      role: 'vendor',
      isActive: true,
      'vendorInfo.isApproved': true
    };

    if (search) {
      filter.$or = [
        { 'vendorInfo.shopName': { $regex: search, $options: 'i' } },
        { 'vendorInfo.shopDescription': { $regex: search, $options: 'i' } },
        { name: { $regex: search, $options: 'i' } }
      ];
    }

    const [vendors, totalVendors] = await Promise.all([
      User.find(filter)
        .select('name vendorInfo avatar createdAt')
        .sort({ 'vendorInfo.shopName': 1 })
        .skip(skip)
        .limit(parseInt(limit))
        .lean(),
      User.countDocuments(filter)
    ]);

    // Get product counts for each vendor
    const vendorIds = vendors.map(v => v._id);
    const productCounts = await Product.aggregate([
      {
        $match: {
          vendor: { $in: vendorIds },
          isActive: true
        }
      },
      {
        $group: {
          _id: '$vendor',
          productCount: { $sum: 1 },
          avgRating: { $avg: '$averageRating' }
        }
      }
    ]);

    // Merge product counts with vendor data
    const vendorsWithStats = vendors.map(vendor => {
      const stats = productCounts.find(pc => pc._id.toString() === vendor._id.toString());
      return {
        ...vendor,
        productCount: stats?.productCount || 0,
        avgRating: stats?.avgRating ? Math.round(stats.avgRating * 10) / 10 : 0
      };
    });

    const totalPages = Math.ceil(totalVendors / parseInt(limit));

    res.json({
      success: true,
      data: {
        vendors: vendorsWithStats,
        pagination: {
          currentPage: parseInt(page),
          totalPages,
          totalVendors,
          hasNextPage: parseInt(page) < totalPages,
          hasPrevPage: parseInt(page) > 1,
          limit: parseInt(limit)
        }
      }
    });

  } catch (error) {
    console.error('Get vendors error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching vendors'
    });
  }
});

// @route   GET /api/vendors/:id
// @desc    Get vendor profile and shop details
// @access  Public
router.get('/:id', async (req, res) => {
  try {
    const vendor = await User.findOne({
      _id: req.params.id,
      role: 'vendor',
      isActive: true,
      'vendorInfo.isApproved': true
    })
      .select('name vendorInfo avatar createdAt')
      .lean();

    if (!vendor) {
      return res.status(404).json({
        success: false,
        message: 'Vendor not found'
      });
    }

    // Get vendor statistics
    const [productStats, orderStats] = await Promise.all([
      Product.aggregate([
        {
          $match: {
            vendor: vendor._id,
            isActive: true
          }
        },
        {
          $group: {
            _id: null,
            totalProducts: { $sum: 1 },
            avgRating: { $avg: '$averageRating' },
            totalReviews: { $sum: '$numReviews' },
            totalSales: { $sum: '$sales' }
          }
        }
      ]),
      Order.aggregate([
        {
          $match: {
            'vendorOrders.vendor': vendor._id,
            status: { $ne: 'cancelled' }
          }
        },
        {
          $unwind: '$vendorOrders'
        },
        {
          $match: {
            'vendorOrders.vendor': vendor._id
          }
        },
        {
          $group: {
            _id: null,
            totalOrders: { $sum: 1 },
            totalRevenue: { $sum: '$vendorOrders.vendorEarnings' }
          }
        }
      ])
    ]);

    const stats = {
      products: productStats[0]?.totalProducts || 0,
      avgRating: productStats[0]?.avgRating ? Math.round(productStats[0].avgRating * 10) / 10 : 0,
      totalReviews: productStats[0]?.totalReviews || 0,
      totalSales: productStats[0]?.totalSales || 0,
      totalOrders: orderStats[0]?.totalOrders || 0,
      totalRevenue: orderStats[0]?.totalRevenue || 0
    };

    res.json({
      success: true,
      data: {
        vendor,
        stats
      }
    });

  } catch (error) {
    console.error('Get vendor error:', error);
    if (error.name === 'CastError') {
      return res.status(400).json({
        success: false,
        message: 'Invalid vendor ID'
      });
    }
    res.status(500).json({
      success: false,
      message: 'Server error while fetching vendor'
    });
  }
});

// @route   GET /api/vendors/:id/products
// @desc    Get vendor's products
// @access  Public
router.get('/:id/products', [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 50 }).withMessage('Limit must be between 1 and 50'),
  query('category').optional().trim(),
  query('sort').optional().isIn(['newest', 'oldest', 'price_low', 'price_high', 'rating', 'popular']).withMessage('Invalid sort option')
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
      limit = 12,
      category,
      sort = 'newest'
    } = req.query;

    // Verify vendor exists and is approved
    const vendor = await User.findOne({
      _id: req.params.id,
      role: 'vendor',
      isActive: true,
      'vendorInfo.isApproved': true
    });

    if (!vendor) {
      return res.status(404).json({
        success: false,
        message: 'Vendor not found'
      });
    }

    // Build filter
    const filter = {
      vendor: req.params.id,
      isActive: true
    };

    if (category) {
      filter.category = category;
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
      case 'price_low':
        sortObj = { price: 1 };
        break;
      case 'price_high':
        sortObj = { price: -1 };
        break;
      case 'rating':
        sortObj = { averageRating: -1, numReviews: -1 };
        break;
      case 'popular':
        sortObj = { sales: -1, views: -1 };
        break;
      default:
        sortObj = { createdAt: -1 };
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const [products, totalProducts] = await Promise.all([
      Product.find(filter)
        .populate('vendor', 'name vendorInfo.shopName')
        .sort(sortObj)
        .skip(skip)
        .limit(parseInt(limit))
        .lean(),
      Product.countDocuments(filter)
    ]);

    const totalPages = Math.ceil(totalProducts / parseInt(limit));

    res.json({
      success: true,
      data: {
        vendor: {
          _id: vendor._id,
          name: vendor.name,
          shopName: vendor.vendorInfo.shopName,
          shopDescription: vendor.vendorInfo.shopDescription,
          shopLogo: vendor.vendorInfo.shopLogo
        },
        products,
        pagination: {
          currentPage: parseInt(page),
          totalPages,
          totalProducts,
          hasNextPage: parseInt(page) < totalPages,
          hasPrevPage: parseInt(page) > 1,
          limit: parseInt(limit)
        }
      }
    });

  } catch (error) {
    console.error('Get vendor products error:', error);
    if (error.name === 'CastError') {
      return res.status(400).json({
        success: false,
        message: 'Invalid vendor ID'
      });
    }
    res.status(500).json({
      success: false,
      message: 'Server error while fetching vendor products'
    });
  }
});

// @route   GET /api/vendors/dashboard/stats
// @desc    Get vendor dashboard statistics
// @access  Private (Vendor only)
router.get('/dashboard/stats', [auth, vendorOnly], async (req, res) => {
  try {
    const vendorId = req.user.userId;

    // Get date ranges
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const startOfLastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1);
    const endOfLastMonth = new Date(now.getFullYear(), now.getMonth(), 0);

    const [productStats, orderStats, monthlyStats, recentOrders] = await Promise.all([
      // Product statistics
      Product.aggregate([
        {
          $match: {
            vendor: vendorId,
            isActive: true
          }
        },
        {
          $group: {
            _id: null,
            totalProducts: { $sum: 1 },
            avgRating: { $avg: '$averageRating' },
            totalViews: { $sum: '$views' },
            totalSales: { $sum: '$sales' },
            lowStockProducts: {
              $sum: { $cond: [{ $lte: ['$stock', 5] }, 1, 0] }
            }
          }
        }
      ]),

      // Order statistics
      Order.aggregate([
        {
          $match: {
            'vendorOrders.vendor': vendorId
          }
        },
        {
          $unwind: '$vendorOrders'
        },
        {
          $match: {
            'vendorOrders.vendor': vendorId
          }
        },
        {
          $group: {
            _id: null,
            totalOrders: { $sum: 1 },
            totalEarnings: { $sum: '$vendorOrders.vendorEarnings' },
            pendingOrders: {
              $sum: { $cond: [{ $eq: ['$vendorOrders.status', 'pending'] }, 1, 0] }
            },
            processingOrders: {
              $sum: { $cond: [{ $eq: ['$vendorOrders.status', 'processing'] }, 1, 0] }
            },
            shippedOrders: {
              $sum: { $cond: [{ $eq: ['$vendorOrders.status', 'shipped'] }, 1, 0] }
            }
          }
        }
      ]),

      // Monthly comparison
      Order.aggregate([
        {
          $match: {
            'vendorOrders.vendor': vendorId,
            createdAt: { $gte: startOfLastMonth }
          }
        },
        {
          $unwind: '$vendorOrders'
        },
        {
          $match: {
            'vendorOrders.vendor': vendorId
          }
        },
        {
          $group: {
            _id: {
              month: { $month: '$createdAt' },
              year: { $year: '$createdAt' }
            },
            orders: { $sum: 1 },
            earnings: { $sum: '$vendorOrders.vendorEarnings' }
          }
        }
      ]),

      // Recent orders
      Order.find({
        'vendorOrders.vendor': vendorId
      })
        .populate('customer', 'name email')
        .sort({ createdAt: -1 })
        .limit(5)
        .lean()
    ]);

    // Process monthly stats
    const currentMonth = monthlyStats.find(stat => 
      stat._id.month === now.getMonth() + 1 && stat._id.year === now.getFullYear()
    );
    const lastMonth = monthlyStats.find(stat => 
      stat._id.month === startOfLastMonth.getMonth() + 1 && stat._id.year === startOfLastMonth.getFullYear()
    );

    const currentMonthOrders = currentMonth?.orders || 0;
    const lastMonthOrders = lastMonth?.orders || 0;
    const currentMonthEarnings = currentMonth?.earnings || 0;
    const lastMonthEarnings = lastMonth?.earnings || 0;

    const orderGrowth = lastMonthOrders > 0 
      ? ((currentMonthOrders - lastMonthOrders) / lastMonthOrders) * 100 
      : 0;
    const earningsGrowth = lastMonthEarnings > 0 
      ? ((currentMonthEarnings - lastMonthEarnings) / lastMonthEarnings) * 100 
      : 0;

    // Filter recent orders for this vendor
    const vendorRecentOrders = recentOrders.map(order => ({
      ...order,
      vendorOrders: order.vendorOrders.filter(
        vo => vo.vendor.toString() === vendorId.toString()
      )
    })).filter(order => order.vendorOrders.length > 0);

    const stats = {
      products: {
        total: productStats[0]?.totalProducts || 0,
        avgRating: productStats[0]?.avgRating ? Math.round(productStats[0].avgRating * 10) / 10 : 0,
        totalViews: productStats[0]?.totalViews || 0,
        totalSales: productStats[0]?.totalSales || 0,
        lowStock: productStats[0]?.lowStockProducts || 0
      },
      orders: {
        total: orderStats[0]?.totalOrders || 0,
        pending: orderStats[0]?.pendingOrders || 0,
        processing: orderStats[0]?.processingOrders || 0,
        shipped: orderStats[0]?.shippedOrders || 0,
        monthlyGrowth: Math.round(orderGrowth * 100) / 100
      },
      earnings: {
        total: orderStats[0]?.totalEarnings || 0,
        thisMonth: currentMonthEarnings,
        lastMonth: lastMonthEarnings,
        monthlyGrowth: Math.round(earningsGrowth * 100) / 100
      },
      recentOrders: vendorRecentOrders.slice(0, 5)
    };

    res.json({
      success: true,
      data: stats
    });

  } catch (error) {
    console.error('Get vendor dashboard stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching dashboard statistics'
    });
  }
});

// @route   PUT /api/vendors/profile
// @desc    Update vendor profile
// @access  Private (Vendor only)
router.put('/profile', [auth, vendorOnly], [
  body('vendorInfo.shopName')
    .optional()
    .trim()
    .isLength({ min: 2, max: 100 })
    .withMessage('Shop name must be between 2 and 100 characters'),
  body('vendorInfo.shopDescription')
    .optional()
    .trim()
    .isLength({ max: 500 })
    .withMessage('Shop description cannot exceed 500 characters'),
  body('name')
    .optional()
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage('Name must be between 2 and 50 characters')
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

    const vendor = await User.findById(req.user.userId);
    if (!vendor) {
      return res.status(404).json({
        success: false,
        message: 'Vendor not found'
      });
    }

    const { name, phone, address, avatar, vendorInfo } = req.body;

    // Update basic fields
    if (name) vendor.name = name;
    if (phone) vendor.phone = phone;
    if (address) vendor.address = { ...vendor.address, ...address };
    if (avatar) vendor.avatar = avatar;

    // Update vendor info
    if (vendorInfo) {
      if (vendorInfo.shopName) vendor.vendorInfo.shopName = vendorInfo.shopName;
      if (vendorInfo.shopDescription) vendor.vendorInfo.shopDescription = vendorInfo.shopDescription;
      if (vendorInfo.shopLogo) vendor.vendorInfo.shopLogo = vendorInfo.shopLogo;
    }

    await vendor.save();

    res.json({
      success: true,
      message: 'Vendor profile updated successfully',
      data: vendor.getPublicProfile()
    });

  } catch (error) {
    console.error('Update vendor profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating vendor profile'
    });
  }
});

// @route   GET /api/vendors/pending
// @desc    Get pending vendor applications (Admin only)
// @access  Private (Admin only)
router.get('/pending', [auth, adminOnly], async (req, res) => {
  try {
    const { page = 1, limit = 10 } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);

    const [pendingVendors, totalPending] = await Promise.all([
      User.find({
        role: 'vendor',
        'vendorInfo.isApproved': false,
        isActive: true
      })
        .select('name email vendorInfo createdAt')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit))
        .lean(),
      User.countDocuments({
        role: 'vendor',
        'vendorInfo.isApproved': false,
        isActive: true
      })
    ]);

    const totalPages = Math.ceil(totalPending / parseInt(limit));

    res.json({
      success: true,
      data: {
        vendors: pendingVendors,
        pagination: {
          currentPage: parseInt(page),
          totalPages,
          totalPending,
          hasNextPage: parseInt(page) < totalPages,
          hasPrevPage: parseInt(page) > 1,
          limit: parseInt(limit)
        }
      }
    });

  } catch (error) {
    console.error('Get pending vendors error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching pending vendors'
    });
  }
});

module.exports = router;