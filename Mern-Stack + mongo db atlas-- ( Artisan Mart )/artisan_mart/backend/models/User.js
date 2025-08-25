const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Name is required'],
    trim: true,
    maxlength: [50, 'Name cannot exceed 50 characters']
  },
  email: {
    type: String,
    required: [true, 'Email is required'],
    unique: true,
    lowercase: true,
    match: [/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/, 'Please enter a valid email']
  },
  password: {
    type: String,
    required: function() {
      return !this.googleId; // Password not required for Google OAuth users
    },
    minlength: [6, 'Password must be at least 6 characters']
  },
  role: {
    type: String,
    enum: ['customer', 'vendor', 'admin'],
    default: 'customer'
  },
  avatar: {
    type: String,
    default: ''
  },
  phone: {
    type: String,
    trim: true
  },
  address: {
    street: String,
    city: String,
    state: String,
    zipCode: String,
    country: String
  },
  // Google OAuth
  googleId: {
    type: String,
    sparse: true
  },
  // Vendor specific fields
  vendorInfo: {
    shopName: {
      type: String,
      trim: true
    },
    shopDescription: {
      type: String,
      trim: true,
      maxlength: [500, 'Shop description cannot exceed 500 characters']
    },
    shopLogo: {
      type: String,
      default: ''
    },
    isApproved: {
      type: Boolean,
      default: false
    },
    stripeAccountId: {
      type: String,
      default: ''
    },
    commission: {
      type: Number,
      default: 10 // 10% commission
    }
  },
  isActive: {
    type: Boolean,
    default: true
  },
  emailVerified: {
    type: Boolean,
    default: false
  },
  lastLogin: {
    type: Date
  }
}, {
  timestamps: true
});

// Index for better query performance
userSchema.index({ email: 1 });
userSchema.index({ role: 1 });
userSchema.index({ 'vendorInfo.isApproved': 1 });

// Hash password before saving
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  try {
    const salt = await bcrypt.genSalt(12);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Compare password method
userSchema.methods.comparePassword = async function(candidatePassword) {
  if (!this.password) return false;
  return await bcrypt.compare(candidatePassword, this.password);
};

// Get public profile
userSchema.methods.getPublicProfile = function() {
  const userObject = this.toObject();
  delete userObject.password;
  delete userObject.googleId;
  return userObject;
};

// Virtual for vendor shop URL
userSchema.virtual('shopUrl').get(function() {
  if (this.role === 'vendor' && this.vendorInfo.shopName) {
    return `/shop/${this.vendorInfo.shopName.toLowerCase().replace(/\s+/g, '-')}`;
  }
  return null;
});

module.exports = mongoose.model('User', userSchema);