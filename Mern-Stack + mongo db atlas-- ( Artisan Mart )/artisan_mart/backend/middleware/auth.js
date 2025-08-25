const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Basic authentication middleware
const auth = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'No token provided, authorization denied'
      });
    }

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Check if user still exists
    const user = await User.findById(decoded.userId).select('-password');
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Token is not valid - user not found'
      });
    }

    // Check if user is active
    if (!user.isActive) {
      return res.status(401).json({
        success: false,
        message: 'Account is deactivated'
      });
    }

    req.user = { userId: user._id, role: user.role };
    next();
    
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        message: 'Token is not valid'
      });
    }
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Token has expired'
      });
    }
    
    console.error('Auth middleware error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error in authentication'
    });
  }
};

// Role-based authorization middleware
const authorize = (...roles) => {
  return async (req, res, next) => {
    try {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          message: 'Authentication required'
        });
      }

      const user = await User.findById(req.user.userId).select('role vendorInfo');
      if (!user) {
        return res.status(401).json({
          success: false,
          message: 'User not found'
        });
      }

      if (!roles.includes(user.role)) {
        return res.status(403).json({
          success: false,
          message: `Access denied. Required role: ${roles.join(' or ')}`
        });
      }

      // Additional check for vendors - must be approved
      if (user.role === 'vendor' && !user.vendorInfo.isApproved) {
        return res.status(403).json({
          success: false,
          message: 'Vendor account is not approved yet'
        });
      }

      req.user.role = user.role;
      next();
      
    } catch (error) {
      console.error('Authorization middleware error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error in authorization'
      });
    }
  };
};

// Vendor ownership middleware - ensures vendor can only access their own resources
const vendorOwnership = async (req, res, next) => {
  try {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required'
      });
    }

    const user = await User.findById(req.user.userId);
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'User not found'
      });
    }

    // Admin can access all resources
    if (user.role === 'admin') {
      return next();
    }

    // Vendor can only access their own resources
    if (user.role === 'vendor') {
      // Check if the resource belongs to the vendor
      const resourceVendorId = req.params.vendorId || req.body.vendor || req.query.vendor;
      
      if (resourceVendorId && resourceVendorId.toString() !== user._id.toString()) {
        return res.status(403).json({
          success: false,
          message: 'Access denied. You can only access your own resources.'
        });
      }
    }

    next();
    
  } catch (error) {
    console.error('Vendor ownership middleware error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error in ownership check'
    });
  }
};

// Optional authentication middleware (for routes that work with or without auth)
const optionalAuth = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return next(); // Continue without authentication
    }

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Check if user still exists
    const user = await User.findById(decoded.userId).select('-password');
    if (user && user.isActive) {
      req.user = { userId: user._id, role: user.role };
    }

    next();
    
  } catch (error) {
    // If token is invalid, continue without authentication
    next();
  }
};

// Admin only middleware
const adminOnly = authorize('admin');

// Vendor only middleware
const vendorOnly = authorize('vendor');

// Customer only middleware
const customerOnly = authorize('customer');

// Vendor or Admin middleware
const vendorOrAdmin = authorize('vendor', 'admin');

// Customer or Admin middleware
const customerOrAdmin = authorize('customer', 'admin');

module.exports = {
  auth,
  authorize,
  vendorOwnership,
  optionalAuth,
  adminOnly,
  vendorOnly,
  customerOnly,
  vendorOrAdmin,
  customerOrAdmin
};