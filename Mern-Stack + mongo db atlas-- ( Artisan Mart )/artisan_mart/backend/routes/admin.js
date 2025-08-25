const express = require('express');
const { body, validationResult, query } = require('express-validator');
const User = require('../models/User');
const Product = require('../models/Product');
const Order = require('../models/Order');
const Review = require('../models/Review');
const { auth, adminOnly } = require('../middleware/auth');

const router = express.Router();

// @route   GET /api/admin/dashboard
// @desc    Get admin dashboard statistics
// @access  Private (Admin only)
router.get('/dashboard', [auth, adminOnly], async (req, res) => {
  try {
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const startOfLastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1);
    const endOfLastMonth = new Date(now.getFullYear(), now.getMonth(), 0);
    const startOfYear = new Date(now.getFullYear(), 0, 1);

    const [userStats, productStats, orderStats, revenueStats, monthlyStats] = await Promise.all([
      // User statistics
      User.aggregate([
        {
          $group: {
            _id: '$role',
            count: { $sum: 1 },
            activeCount: {
              $sum: { $cond: [{ $eq: ['$isActive', true] }, 1, 0] }
            }
          }
        }
      ]),

      // Product statistics
      Product.aggregate([
        {
          $group: {
            _id: null,
            totalProducts: { $sum: 1 },
            activeProducts: {
              $sum: { $cond: [{ $eq: ['$isActive', true] }, 1, 0] }
            },
            featuredProducts: {
              $sum: { $cond: [{ $eq: ['$isFeatured', true] }, 1, 0] }
            },
            lowStockProducts: {
              $sum: { $cond: [{ $lte: ['$stock', 5] }, 1, 0] }
            },
            totalViews: { $sum: '$views' },
            totalSales: { $sum: '$sales' }
          }
        }
      ]),

      // Order statistics
      Order.aggregate([
        {
          $group: {
            _id: '$status',
            count: { $sum: 1 },
            totalValue: { $sum: '$summary.total' }
          }
        }
      ]),

      // Revenue statistics
      Order.aggregate([
        {
          $match: {
            status: { $ne: 'cancelled' },
            createdAt: { $gte: startOfYear }
          }
        },
        {
          $group: {
            _id: null,
            totalRevenue: { $sum: '$summary.total' },
            totalCommission: { $sum: '$summary.totalCommission' },
            totalOrders: { $sum: 1 },
            avgOrderValue: { $avg: '$summary.total' }
          }
        }
      ]),

      // Monthly comparison
      Order.aggregate([
        {
          $match: {
            status: { $ne: 'cancelled' },
            createdAt: { $gte: startOfLastMonth }
          }
        },
        {
          $group: {
            _id: {
              month: { $month: '$createdAt' },
              year: { $year: '$createdAt' }
            },
            orders: { $sum: 1 },
            revenue: { $sum: '$summary.total' },
            commission: { $sum: '$summary.totalCommission' }
          }
        }
      ])
    ]);

    // Process user stats
    const users = {
      total: 0,
      customers: 0,
      vendors: 0,
      admins: 0,
      activeUsers: 0,
      pendingVendors: 0
    };

    userStats.forEach(stat => {
      users.total += stat.count;
      users.activeUsers += stat.activeCount;
      
      switch (stat._id) {
        case 'customer':
          users.customers = stat.count;
          break;
        case 'vendor':
          users.vendors = stat.count;
          break;
        case 'admin':
          users.admins = stat.count;
          break;
      }
    });

    // Get pending vendors count
    const pendingVendorsCount = await User.countDocuments({
      role: 'vendor',
      'vendorInfo.isApproved': false,
      isActive: true
    });
    users.pendingVendors = pendingVendorsCount;

    // Process product stats
    const products = productStats[0] || {
      totalProducts: 0,
      activeProducts: 0,
      featuredProducts: 0,
      lowStockProducts: 0,
      totalViews: 0,
      totalSales: 0
    };

    // Process order stats
    const orders = {
      total: 0,
      pending: 0,
      processing: 0,
      shipped: 0,
      delivered: 0,
      cancelled: 0,
      totalValue: 0
    };

    orderStats.forEach(stat => {
      orders.total += stat.count;
      orders.totalValue += stat.totalValue;
      orders[stat._id] = stat.count;
    });

    // Process revenue stats
    const revenue = revenueStats[0] || {
      totalRevenue: 0,
      totalCommission: 0,
      totalOrders: 0,
      avgOrderValue: 0
    };

    // Process monthly comparison
    const currentMonth = monthlyStats.find(stat => 
      stat._id.month === now.getMonth() + 1 && stat._id.year === now.getFullYear()
    );
    const lastMonth = monthlyStats.find(stat => 
      stat._id.month === startOfLastMonth.getMonth() + 1 && stat._id.year === startOfLastMonth.getFullYear()
    );

    const currentMonthRevenue = currentMonth?.revenue || 0;
    const lastMonthRevenue = lastMonth?.revenue || 0;
    const currentMonthOrders = currentMonth?.orders || 0;
    const lastMonthOrders = lastMonth?.orders || 0;

    const revenueGrowth = lastMonthRevenue > 0 
      ? ((currentMonthRevenue - lastMonthRevenue) / lastMonthRevenue) * 100 
      : 0;
    const orderGrowth = lastMonthOrders > 0 
      ? ((currentMonthOrders - lastMonthOrders) / lastMonthOrders) * 100 
      : 0;

    // Get recent activities
    const [recentOrders, recentUsers, recentProducts] = await Promise.all([
      Order.find()
        .populate('customer', 'name email')
        .sort({ createdAt: -1 })
        .limit(5)
        .lean(),
      User.find({ role: { $ne: 'admin' } })
        .sort({ createdAt: -1 })
        .limit(5)
        .select('name email role vendorInfo.shopName createdAt')
        .lean(),
      Product.find()
        .populate('vendor', 'name vendorInfo.shopName')
        .sort({ createdAt: -1 })
        .limit(5)
        .select('name price vendor createdAt')
        .lean()
    ]);

    const dashboardData = {
      users,
      products,
      orders,
      revenue: {
        ...revenue,
        monthlyGrowth: Math.round(revenueGrowth * 100) / 100,
        orderGrowth: Math.round(orderGrowth * 100) / 100
      },
      recentActivity: {
        orders: recentOrders,
        users: recentUsers,
        products: recentProducts
      }
    };

    res.json({
      success: true,
      data: dashboardData
    });

  } catch (error) {
    console.error('Get admin dashboard error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching dashboard data'
    });
  }
});

// @route   PUT /api/admin/vendors/:id/approve
// @desc    Approve or reject vendor application
// @access  Private (Admin only)
router.put('/vendors/:id/approve', [auth, adminOnly], [
  body('approved')
    .isBoolean()
    .withMessage('Approved status must be a boolean'),
  body('rejectionReason')
    .optional()
    .trim()
    .isLength({ max: 500 })
    .withMessage('Rejection reason cannot exceed 500 characters')
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

    const { approved, rejectionReason } = req.body;
    const vendorId = req.params.id;

    const vendor = await User.findOne({
      _id: vendorId,
      role: 'vendor'
    });

    if (!vendor) {
      return res.status(404).json({
        success: false,
        message: 'Vendor not found'
      });
    }

    vendor.vendorInfo.isApproved = approved;
    vendor.vendorInfo.approvedAt = approved ? new Date() : null;
    vendor.vendorInfo.approvedBy = approved ? req.user.userId : null;
    
    if (!approved && rejectionReason) {
      vendor.vendorInfo.rejectionReason = rejectionReason;
    }

    await vendor.save();

    res.json({
      success: true,
      message: `Vendor ${approved ? 'approved' : 'rejected'} successfully`,
      data: {
        vendorId: vendor._id,
        shopName: vendor.vendorInfo.shopName,
        approved: vendor.vendorInfo.isApproved,
        approvedAt: vendor.vendorInfo.approvedAt
      }
    });

  } catch (error) {
    console.error('Approve vendor error:', error);
    if (error.name === 'CastError') {
      return res.status(400).json({
        success: false,
        message: 'Invalid vendor ID'
      });
    }
    res.status(500).json({
      success: false,
      message: 'Server error while updating vendor status'
    });
  }
});

// @route   GET /api/admin/users
// @desc    Get all users with filtering and pagination
// @access  Private (Admin only)
router.get('/users', [auth, adminOnly], [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
  query('role').optional().isIn(['customer', 'vendor', 'admin']).withMessage('Invalid role'),
  query('status').optional().isIn(['active', 'inactive', 'pending']).withMessage('Invalid status'),
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

    const {
      page = 1,
      limit = 20,
      role,
      status,
      search
    } = req.query;

    // Build filter
    const filter = {};
    
    if (role) {
      filter.role = role;
    }

    if (status) {
      switch (status) {
        case 'active':
          filter.isActive = true;
          break;
        case 'inactive':
          filter.isActive = false;
          break;
        case 'pending':
          filter.role = 'vendor';
          filter['vendorInfo.isApproved'] = false;
          filter.isActive = true;
          break;
      }
    }

    if (search) {
      filter.$or = [
        { name: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
        { 'vendorInfo.shopName': { $regex: search, $options: 'i' } }
      ];
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const [users, totalUsers] = await Promise.all([
      User.find(filter)
        .select('-password')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit))
        .lean(),
      User.countDocuments(filter)
    ]);

    const totalPages = Math.ceil(totalUsers / parseInt(limit));

    res.json({
      success: true,
      data: {
        users,
        pagination: {
          currentPage: parseInt(page),
          totalPages,
          totalUsers,
          hasNextPage: parseInt(page) < totalPages,
          hasPrevPage: parseInt(page) > 1,
          limit: parseInt(limit)
        }
      }
    });

  } catch (error) {
    console.error('Get admin users error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching users'
    });
  }
});

// @route   PUT /api/admin/users/:id/status
// @desc    Update user status (activate/deactivate)
// @access  Private (Admin only)
router.put('/users/:id/status', [auth, adminOnly], [
  body('isActive')
    .isBoolean()
    .withMessage('Active status must be a boolean')
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

    const { isActive } = req.body;
    const userId = req.params.id;

    // Prevent admin from deactivating themselves
    if (userId === req.user.userId.toString()) {
      return res.status(400).json({
        success: false,
        message: 'You cannot deactivate your own account'
      });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    user.isActive = isActive;
    await user.save();

    res.json({
      success: true,
      message: `User ${isActive ? 'activated' : 'deactivated'} successfully`,
      data: {
        userId: user._id,
        name: user.name,
        email: user.email,
        isActive: user.isActive
      }
    });

  } catch (error) {
    console.error('Update user status error:', error);
    if (error.name === 'CastError') {
      return res.status(400).json({
        success: false,
        message: 'Invalid user ID'
      });
    }
    res.status(500).json({
      success: false,
      message: 'Server error while updating user status'
    });
  }
});

// @route   GET /api/admin/products
// @desc    Get all products with filtering and pagination
// @access  Private (Admin only)
router.get('/products', [auth, adminOnly], [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
  query('category').optional().trim(),
  query('status').optional().isIn(['active', 'inactive', 'featured']).withMessage('Invalid status'),
  query('vendor').optional().isMongoId().withMessage('Invalid vendor ID'),
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

    const {
      page = 1,
      limit = 20,
      category,
      status,
      vendor,
      search
    } = req.query;

    // Build filter
    const filter = {};
    
    if (category) {
      filter.category = category;
    }

    if (vendor) {
      filter.vendor = vendor;
    }

    if (status) {
      switch (status) {
        case 'active':
          filter.isActive = true;
          break;
        case 'inactive':
          filter.isActive = false;
          break;
        case 'featured':
          filter.isFeatured = true;
          break;
      }
    }

    if (search) {
      filter.$or = [
        { name: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
        { sku: { $regex: search, $options: 'i' } }
      ];
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const [products, totalProducts] = await Promise.all([
      Product.find(filter)
        .populate('vendor', 'name vendorInfo.shopName')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit))
        .lean(),
      Product.countDocuments(filter)
    ]);

    const totalPages = Math.ceil(totalProducts / parseInt(limit));

    res.json({
      success: true,
      data: {
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
    console.error('Get admin products error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching products'
    });
  }
});

// @route   PUT /api/admin/products/:id/featured
// @desc    Toggle product featured status
// @access  Private (Admin only)
router.put('/products/:id/featured', [auth, adminOnly], [
  body('isFeatured')
    .isBoolean()
    .withMessage('Featured status must be a boolean')
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

    const { isFeatured } = req.body;
    const productId = req.params.id;

    const product = await Product.findById(productId);
    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    product.isFeatured = isFeatured;
    await product.save();

    res.json({
      success: true,
      message: `Product ${isFeatured ? 'featured' : 'unfeatured'} successfully`,
      data: {
        productId: product._id,
        name: product.name,
        isFeatured: product.isFeatured
      }
    });

  } catch (error) {
    console.error('Update product featured status error:', error);
    if (error.name === 'CastError') {
      return res.status(400).json({
        success: false,
        message: 'Invalid product ID'
      });
    }
    res.status(500).json({
      success: false,
      message: 'Server error while updating product status'
    });
  }
});

// @route   GET /api/admin/analytics
// @desc    Get detailed analytics data
// @access  Private (Admin only)
router.get('/analytics', [auth, adminOnly], [
  query('period').optional().isIn(['7d', '30d', '90d', '1y']).withMessage('Invalid period'),
  query('type').optional().isIn(['revenue', 'orders', 'users', 'products']).withMessage('Invalid analytics type')
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

    const { period = '30d', type = 'revenue' } = req.query;

    // Calculate date range
    const now = new Date();
    let startDate;
    
    switch (period) {
      case '7d':
        startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        break;
      case '30d':
        startDate = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
        break;
      case '90d':
        startDate = new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000);
        break;
      case '1y':
        startDate = new Date(now.getTime() - 365 * 24 * 60 * 60 * 1000);
        break;
      default:
        startDate = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
    }

    let analyticsData;

    switch (type) {
      case 'revenue':
        analyticsData = await Order.aggregate([
          {
            $match: {
              createdAt: { $gte: startDate },
              status: { $ne: 'cancelled' }
            }
          },
          {
            $group: {
              _id: {
                year: { $year: '$createdAt' },
                month: { $month: '$createdAt' },
                day: { $dayOfMonth: '$createdAt' }
              },
              revenue: { $sum: '$summary.total' },
              commission: { $sum: '$summary.totalCommission' },
              orders: { $sum: 1 }
            }
          },
          {
            $sort: { '_id.year': 1, '_id.month': 1, '_id.day': 1 }
          }
        ]);
        break;

      case 'orders':
        analyticsData = await Order.aggregate([
          {
            $match: {
              createdAt: { $gte: startDate }
            }
          },
          {
            $group: {
              _id: {
                year: { $year: '$createdAt' },
                month: { $month: '$createdAt' },
                day: { $dayOfMonth: '$createdAt' },
                status: '$status'
              },
              count: { $sum: 1 }
            }
          },
          {
            $sort: { '_id.year': 1, '_id.month': 1, '_id.day': 1 }
          }
        ]);
        break;

      case 'users':
        analyticsData = await User.aggregate([
          {
            $match: {
              createdAt: { $gte: startDate }
            }
          },
          {
            $group: {
              _id: {
                year: { $year: '$createdAt' },
                month: { $month: '$createdAt' },
                day: { $dayOfMonth: '$createdAt' },
                role: '$role'
              },
              count: { $sum: 1 }
            }
          },
          {
            $sort: { '_id.year': 1, '_id.month': 1, '_id.day': 1 }
          }
        ]);
        break;

      case 'products':
        analyticsData = await Product.aggregate([
          {
            $match: {
              createdAt: { $gte: startDate }
            }
          },
          {
            $group: {
              _id: {
                year: { $year: '$createdAt' },
                month: { $month: '$createdAt' },
                day: { $dayOfMonth: '$createdAt' },
                category: '$category'
              },
              count: { $sum: 1 },
              totalViews: { $sum: '$views' },
              totalSales: { $sum: '$sales' }
            }
          },
          {
            $sort: { '_id.year': 1, '_id.month': 1, '_id.day': 1 }
          }
        ]);
        break;

      default:
        return res.status(400).json({
          success: false,
          message: 'Invalid analytics type'
        });
    }

    res.json({
      success: true,
      data: {
        period,
        type,
        startDate,
        endDate: now,
        analytics: analyticsData
      }
    });

  } catch (error) {
    console.error('Get analytics error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching analytics data'
    });
  }
});

module.exports = router;