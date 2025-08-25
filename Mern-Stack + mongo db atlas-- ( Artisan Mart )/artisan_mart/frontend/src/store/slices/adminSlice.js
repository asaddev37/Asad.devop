import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import api from '../../services/api';
import { toast } from 'react-hot-toast';

// Initial state
const initialState = {
  // Dashboard data
  dashboardStats: null,
  analytics: null,
  recentActivities: [],
  
  // Users management
  users: [],
  currentUser: null,
  usersPagination: {
    currentPage: 1,
    totalPages: 1,
    totalUsers: 0,
    limit: 10,
  },
  usersFilters: {
    role: '',
    status: '',
    verified: '',
    sortBy: 'createdAt',
    sortOrder: 'desc',
    search: '',
  },
  
  // Products management
  products: [],
  currentProduct: null,
  productsPagination: {
    currentPage: 1,
    totalPages: 1,
    totalProducts: 0,
    limit: 10,
  },
  productsFilters: {
    category: '',
    status: '',
    featured: '',
    vendor: '',
    sortBy: 'createdAt',
    sortOrder: 'desc',
    search: '',
  },
  
  // Orders management
  orders: [],
  currentOrder: null,
  ordersPagination: {
    currentPage: 1,
    totalPages: 1,
    totalOrders: 0,
    limit: 10,
  },
  ordersFilters: {
    status: '',
    paymentStatus: '',
    vendor: '',
    sortBy: 'createdAt',
    sortOrder: 'desc',
    search: '',
  },
  
  // Vendors management
  vendors: [],
  pendingVendors: [],
  currentVendor: null,
  vendorsPagination: {
    currentPage: 1,
    totalPages: 1,
    totalVendors: 0,
    limit: 10,
  },
  vendorsFilters: {
    status: '',
    verified: '',
    sortBy: 'createdAt',
    sortOrder: 'desc',
    search: '',
  },
  
  // Reviews management
  reviews: [],
  reportedReviews: [],
  currentReview: null,
  reviewsPagination: {
    currentPage: 1,
    totalPages: 1,
    totalReviews: 0,
    limit: 10,
  },
  reviewsFilters: {
    rating: '',
    reported: '',
    product: '',
    user: '',
    sortBy: 'createdAt',
    sortOrder: 'desc',
  },
  
  // Loading states
  loading: false,
  dashboardLoading: false,
  usersLoading: false,
  productsLoading: false,
  ordersLoading: false,
  vendorsLoading: false,
  reviewsLoading: false,
  
  // Error states
  error: null,
  dashboardError: null,
  usersError: null,
  productsError: null,
  ordersError: null,
  vendorsError: null,
  reviewsError: null,
};

// Async thunks

// Fetch dashboard statistics
export const fetchDashboardStats = createAsyncThunk(
  'admin/fetchDashboardStats',
  async (_, { rejectWithValue }) => {
    try {
      const response = await api.get('/admin/dashboard');
      return response.data;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to fetch dashboard statistics';
      return rejectWithValue(message);
    }
  }
);

// Fetch analytics data
export const fetchAnalytics = createAsyncThunk(
  'admin/fetchAnalytics',
  async ({ period = '30d', type = 'revenue' }, { rejectWithValue }) => {
    try {
      const response = await api.get('/admin/analytics', {
        params: { period, type }
      });
      return response.data;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to fetch analytics data';
      return rejectWithValue(message);
    }
  }
);

// Users management
export const fetchUsers = createAsyncThunk(
  'admin/fetchUsers',
  async (params = {}, { rejectWithValue, getState }) => {
    try {
      const { admin } = getState();
      const queryParams = {
        page: params.page || admin.usersPagination.currentPage,
        limit: params.limit || admin.usersPagination.limit,
        ...admin.usersFilters,
        ...params,
      };
      
      // Remove empty values
      Object.keys(queryParams).forEach(key => {
        if (queryParams[key] === '' || queryParams[key] === null || queryParams[key] === undefined) {
          delete queryParams[key];
        }
      });
      
      const response = await api.get('/admin/users', { params: queryParams });
      return {
        users: response.data.users,
        pagination: {
          currentPage: response.data.currentPage,
          totalPages: response.data.totalPages,
          totalUsers: response.data.totalUsers,
          limit: response.data.limit,
        },
      };
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to fetch users';
      return rejectWithValue(message);
    }
  }
);

export const updateUserStatus = createAsyncThunk(
  'admin/updateUserStatus',
  async ({ userId, status }, { rejectWithValue }) => {
    try {
      const response = await api.put(`/admin/users/${userId}/status`, { status });
      toast.success('User status updated successfully!');
      return response.data.user;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to update user status';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

// Products management
export const fetchAdminProducts = createAsyncThunk(
  'admin/fetchProducts',
  async (params = {}, { rejectWithValue, getState }) => {
    try {
      const { admin } = getState();
      const queryParams = {
        page: params.page || admin.productsPagination.currentPage,
        limit: params.limit || admin.productsPagination.limit,
        ...admin.productsFilters,
        ...params,
      };
      
      // Remove empty values
      Object.keys(queryParams).forEach(key => {
        if (queryParams[key] === '' || queryParams[key] === null || queryParams[key] === undefined) {
          delete queryParams[key];
        }
      });
      
      const response = await api.get('/admin/products', { params: queryParams });
      return {
        products: response.data.products,
        pagination: {
          currentPage: response.data.currentPage,
          totalPages: response.data.totalPages,
          totalProducts: response.data.totalProducts,
          limit: response.data.limit,
        },
      };
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to fetch products';
      return rejectWithValue(message);
    }
  }
);

export const toggleProductFeatured = createAsyncThunk(
  'admin/toggleProductFeatured',
  async ({ productId, featured }, { rejectWithValue }) => {
    try {
      const response = await api.put(`/admin/products/${productId}/featured`, { featured });
      toast.success(`Product ${featured ? 'featured' : 'unfeatured'} successfully!`);
      return response.data.product;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to update product featured status';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

export const deleteProduct = createAsyncThunk(
  'admin/deleteProduct',
  async (productId, { rejectWithValue }) => {
    try {
      await api.delete(`/admin/products/${productId}`);
      toast.success('Product deleted successfully!');
      return productId;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to delete product';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

// Orders management
export const fetchAdminOrders = createAsyncThunk(
  'admin/fetchOrders',
  async (params = {}, { rejectWithValue, getState }) => {
    try {
      const { admin } = getState();
      const queryParams = {
        page: params.page || admin.ordersPagination.currentPage,
        limit: params.limit || admin.ordersPagination.limit,
        ...admin.ordersFilters,
        ...params,
      };
      
      // Remove empty values
      Object.keys(queryParams).forEach(key => {
        if (queryParams[key] === '' || queryParams[key] === null || queryParams[key] === undefined) {
          delete queryParams[key];
        }
      });
      
      const response = await api.get('/admin/orders', { params: queryParams });
      return {
        orders: response.data.orders,
        pagination: {
          currentPage: response.data.currentPage,
          totalPages: response.data.totalPages,
          totalOrders: response.data.totalOrders,
          limit: response.data.limit,
        },
      };
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to fetch orders';
      return rejectWithValue(message);
    }
  }
);

// Vendors management
export const fetchAdminVendors = createAsyncThunk(
  'admin/fetchVendors',
  async (params = {}, { rejectWithValue, getState }) => {
    try {
      const { admin } = getState();
      const queryParams = {
        page: params.page || admin.vendorsPagination.currentPage,
        limit: params.limit || admin.vendorsPagination.limit,
        ...admin.vendorsFilters,
        ...params,
      };
      
      // Remove empty values
      Object.keys(queryParams).forEach(key => {
        if (queryParams[key] === '' || queryParams[key] === null || queryParams[key] === undefined) {
          delete queryParams[key];
        }
      });
      
      const response = await api.get('/admin/vendors', { params: queryParams });
      return {
        vendors: response.data.vendors,
        pagination: {
          currentPage: response.data.currentPage,
          totalPages: response.data.totalPages,
          totalVendors: response.data.totalVendors,
          limit: response.data.limit,
        },
      };
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to fetch vendors';
      return rejectWithValue(message);
    }
  }
);

export const fetchPendingVendors = createAsyncThunk(
  'admin/fetchPendingVendors',
  async (_, { rejectWithValue }) => {
    try {
      const response = await api.get('/admin/vendors/pending');
      return response.data.vendors;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to fetch pending vendors';
      return rejectWithValue(message);
    }
  }
);

export const approveVendor = createAsyncThunk(
  'admin/approveVendor',
  async (vendorId, { rejectWithValue }) => {
    try {
      const response = await api.put(`/admin/vendors/${vendorId}/approve`);
      toast.success('Vendor approved successfully!');
      return response.data.vendor;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to approve vendor';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

export const rejectVendor = createAsyncThunk(
  'admin/rejectVendor',
  async ({ vendorId, reason }, { rejectWithValue }) => {
    try {
      const response = await api.put(`/admin/vendors/${vendorId}/reject`, { reason });
      toast.success('Vendor rejected successfully!');
      return response.data.vendor;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to reject vendor';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

// Reviews management
export const fetchAdminReviews = createAsyncThunk(
  'admin/fetchReviews',
  async (params = {}, { rejectWithValue, getState }) => {
    try {
      const { admin } = getState();
      const queryParams = {
        page: params.page || admin.reviewsPagination.currentPage,
        limit: params.limit || admin.reviewsPagination.limit,
        ...admin.reviewsFilters,
        ...params,
      };
      
      // Remove empty values
      Object.keys(queryParams).forEach(key => {
        if (queryParams[key] === '' || queryParams[key] === null || queryParams[key] === undefined) {
          delete queryParams[key];
        }
      });
      
      const response = await api.get('/admin/reviews', { params: queryParams });
      return {
        reviews: response.data.reviews,
        pagination: {
          currentPage: response.data.currentPage,
          totalPages: response.data.totalPages,
          totalReviews: response.data.totalReviews,
          limit: response.data.limit,
        },
      };
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to fetch reviews';
      return rejectWithValue(message);
    }
  }
);

export const fetchReportedReviews = createAsyncThunk(
  'admin/fetchReportedReviews',
  async (_, { rejectWithValue }) => {
    try {
      const response = await api.get('/admin/reviews/reported');
      return response.data.reviews;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to fetch reported reviews';
      return rejectWithValue(message);
    }
  }
);

export const deleteReview = createAsyncThunk(
  'admin/deleteReview',
  async (reviewId, { rejectWithValue }) => {
    try {
      await api.delete(`/admin/reviews/${reviewId}`);
      toast.success('Review deleted successfully!');
      return reviewId;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to delete review';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

// Admin slice
const adminSlice = createSlice({
  name: 'admin',
  initialState,
  reducers: {
    // Users filters
    setUsersFilters: (state, action) => {
      state.usersFilters = { ...state.usersFilters, ...action.payload };
      state.usersPagination.currentPage = 1;
    },
    
    clearUsersFilters: (state) => {
      state.usersFilters = {
        role: '',
        status: '',
        verified: '',
        sortBy: 'createdAt',
        sortOrder: 'desc',
        search: '',
      };
      state.usersPagination.currentPage = 1;
    },
    
    setUsersCurrentPage: (state, action) => {
      state.usersPagination.currentPage = action.payload;
    },
    
    // Products filters
    setProductsFilters: (state, action) => {
      state.productsFilters = { ...state.productsFilters, ...action.payload };
      state.productsPagination.currentPage = 1;
    },
    
    clearProductsFilters: (state) => {
      state.productsFilters = {
        category: '',
        status: '',
        featured: '',
        vendor: '',
        sortBy: 'createdAt',
        sortOrder: 'desc',
        search: '',
      };
      state.productsPagination.currentPage = 1;
    },
    
    setProductsCurrentPage: (state, action) => {
      state.productsPagination.currentPage = action.payload;
    },
    
    // Orders filters
    setOrdersFilters: (state, action) => {
      state.ordersFilters = { ...state.ordersFilters, ...action.payload };
      state.ordersPagination.currentPage = 1;
    },
    
    clearOrdersFilters: (state) => {
      state.ordersFilters = {
        status: '',
        paymentStatus: '',
        vendor: '',
        sortBy: 'createdAt',
        sortOrder: 'desc',
        search: '',
      };
      state.ordersPagination.currentPage = 1;
    },
    
    setOrdersCurrentPage: (state, action) => {
      state.ordersPagination.currentPage = action.payload;
    },
    
    // Vendors filters
    setVendorsFilters: (state, action) => {
      state.vendorsFilters = { ...state.vendorsFilters, ...action.payload };
      state.vendorsPagination.currentPage = 1;
    },
    
    clearVendorsFilters: (state) => {
      state.vendorsFilters = {
        status: '',
        verified: '',
        sortBy: 'createdAt',
        sortOrder: 'desc',
        search: '',
      };
      state.vendorsPagination.currentPage = 1;
    },
    
    setVendorsCurrentPage: (state, action) => {
      state.vendorsPagination.currentPage = action.payload;
    },
    
    // Reviews filters
    setReviewsFilters: (state, action) => {
      state.reviewsFilters = { ...state.reviewsFilters, ...action.payload };
      state.reviewsPagination.currentPage = 1;
    },
    
    clearReviewsFilters: (state) => {
      state.reviewsFilters = {
        rating: '',
        reported: '',
        product: '',
        user: '',
        sortBy: 'createdAt',
        sortOrder: 'desc',
      };
      state.reviewsPagination.currentPage = 1;
    },
    
    setReviewsCurrentPage: (state, action) => {
      state.reviewsPagination.currentPage = action.payload;
    },
    
    // Clear errors
    clearAdminError: (state) => {
      state.error = null;
    },
    
    clearDashboardError: (state) => {
      state.dashboardError = null;
    },
    
    clearUsersError: (state) => {
      state.usersError = null;
    },
    
    clearProductsError: (state) => {
      state.productsError = null;
    },
    
    clearOrdersError: (state) => {
      state.ordersError = null;
    },
    
    clearVendorsError: (state) => {
      state.vendorsError = null;
    },
    
    clearReviewsError: (state) => {
      state.reviewsError = null;
    },
    
    // Update items in lists
    updateUserInList: (state, action) => {
      const updatedUser = action.payload;
      const index = state.users.findIndex(user => user._id === updatedUser._id);
      if (index !== -1) {
        state.users[index] = updatedUser;
      }
    },
    
    updateProductInList: (state, action) => {
      const updatedProduct = action.payload;
      const index = state.products.findIndex(product => product._id === updatedProduct._id);
      if (index !== -1) {
        state.products[index] = updatedProduct;
      }
    },
    
    updateVendorInList: (state, action) => {
      const updatedVendor = action.payload;
      const index = state.vendors.findIndex(vendor => vendor._id === updatedVendor._id);
      if (index !== -1) {
        state.vendors[index] = updatedVendor;
      }
      
      // Remove from pending if approved/rejected
      if (updatedVendor.status !== 'pending') {
        state.pendingVendors = state.pendingVendors.filter(vendor => vendor._id !== updatedVendor._id);
      }
    },
    
    // Remove items from lists
    removeProductFromList: (state, action) => {
      const productId = action.payload;
      state.products = state.products.filter(product => product._id !== productId);
    },
    
    removeReviewFromList: (state, action) => {
      const reviewId = action.payload;
      state.reviews = state.reviews.filter(review => review._id !== reviewId);
      state.reportedReviews = state.reportedReviews.filter(review => review._id !== reviewId);
    },
    
    // Reset admin state
    resetAdminState: (state) => {
      return initialState;
    },
  },
  extraReducers: (builder) => {
    builder
      // Dashboard stats
      .addCase(fetchDashboardStats.pending, (state) => {
        state.dashboardLoading = true;
        state.dashboardError = null;
      })
      .addCase(fetchDashboardStats.fulfilled, (state, action) => {
        state.dashboardLoading = false;
        state.dashboardStats = action.payload.stats;
        state.recentActivities = action.payload.recentActivities;
        state.dashboardError = null;
      })
      .addCase(fetchDashboardStats.rejected, (state, action) => {
        state.dashboardLoading = false;
        state.dashboardError = action.payload;
      })
      
      // Analytics
      .addCase(fetchAnalytics.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchAnalytics.fulfilled, (state, action) => {
        state.loading = false;
        state.analytics = action.payload;
        state.error = null;
      })
      .addCase(fetchAnalytics.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      
      // Users
      .addCase(fetchUsers.pending, (state) => {
        state.usersLoading = true;
        state.usersError = null;
      })
      .addCase(fetchUsers.fulfilled, (state, action) => {
        state.usersLoading = false;
        state.users = action.payload.users;
        state.usersPagination = action.payload.pagination;
        state.usersError = null;
      })
      .addCase(fetchUsers.rejected, (state, action) => {
        state.usersLoading = false;
        state.usersError = action.payload;
      })
      
      .addCase(updateUserStatus.fulfilled, (state, action) => {
        const updatedUser = action.payload;
        const index = state.users.findIndex(user => user._id === updatedUser._id);
        if (index !== -1) {
          state.users[index] = updatedUser;
        }
      })
      
      // Products
      .addCase(fetchAdminProducts.pending, (state) => {
        state.productsLoading = true;
        state.productsError = null;
      })
      .addCase(fetchAdminProducts.fulfilled, (state, action) => {
        state.productsLoading = false;
        state.products = action.payload.products;
        state.productsPagination = action.payload.pagination;
        state.productsError = null;
      })
      .addCase(fetchAdminProducts.rejected, (state, action) => {
        state.productsLoading = false;
        state.productsError = action.payload;
      })
      
      .addCase(toggleProductFeatured.fulfilled, (state, action) => {
        const updatedProduct = action.payload;
        const index = state.products.findIndex(product => product._id === updatedProduct._id);
        if (index !== -1) {
          state.products[index] = updatedProduct;
        }
      })
      
      .addCase(deleteProduct.fulfilled, (state, action) => {
        const productId = action.payload;
        state.products = state.products.filter(product => product._id !== productId);
      })
      
      // Orders
      .addCase(fetchAdminOrders.pending, (state) => {
        state.ordersLoading = true;
        state.ordersError = null;
      })
      .addCase(fetchAdminOrders.fulfilled, (state, action) => {
        state.ordersLoading = false;
        state.orders = action.payload.orders;
        state.ordersPagination = action.payload.pagination;
        state.ordersError = null;
      })
      .addCase(fetchAdminOrders.rejected, (state, action) => {
        state.ordersLoading = false;
        state.ordersError = action.payload;
      })
      
      // Vendors
      .addCase(fetchAdminVendors.pending, (state) => {
        state.vendorsLoading = true;
        state.vendorsError = null;
      })
      .addCase(fetchAdminVendors.fulfilled, (state, action) => {
        state.vendorsLoading = false;
        state.vendors = action.payload.vendors;
        state.vendorsPagination = action.payload.pagination;
        state.vendorsError = null;
      })
      .addCase(fetchAdminVendors.rejected, (state, action) => {
        state.vendorsLoading = false;
        state.vendorsError = action.payload;
      })
      
      .addCase(fetchPendingVendors.fulfilled, (state, action) => {
        state.pendingVendors = action.payload;
      })
      
      .addCase(approveVendor.fulfilled, (state, action) => {
        const approvedVendor = action.payload;
        
        // Update in vendors list
        const index = state.vendors.findIndex(vendor => vendor._id === approvedVendor._id);
        if (index !== -1) {
          state.vendors[index] = approvedVendor;
        }
        
        // Remove from pending
        state.pendingVendors = state.pendingVendors.filter(vendor => vendor._id !== approvedVendor._id);
      })
      
      .addCase(rejectVendor.fulfilled, (state, action) => {
        const rejectedVendor = action.payload;
        
        // Update in vendors list
        const index = state.vendors.findIndex(vendor => vendor._id === rejectedVendor._id);
        if (index !== -1) {
          state.vendors[index] = rejectedVendor;
        }
        
        // Remove from pending
        state.pendingVendors = state.pendingVendors.filter(vendor => vendor._id !== rejectedVendor._id);
      })
      
      // Reviews
      .addCase(fetchAdminReviews.pending, (state) => {
        state.reviewsLoading = true;
        state.reviewsError = null;
      })
      .addCase(fetchAdminReviews.fulfilled, (state, action) => {
        state.reviewsLoading = false;
        state.reviews = action.payload.reviews;
        state.reviewsPagination = action.payload.pagination;
        state.reviewsError = null;
      })
      .addCase(fetchAdminReviews.rejected, (state, action) => {
        state.reviewsLoading = false;
        state.reviewsError = action.payload;
      })
      
      .addCase(fetchReportedReviews.fulfilled, (state, action) => {
        state.reportedReviews = action.payload;
      })
      
      .addCase(deleteReview.fulfilled, (state, action) => {
        const reviewId = action.payload;
        state.reviews = state.reviews.filter(review => review._id !== reviewId);
        state.reportedReviews = state.reportedReviews.filter(review => review._id !== reviewId);
      });
  },
});

// Export actions
export const {
  setUsersFilters,
  clearUsersFilters,
  setUsersCurrentPage,
  setProductsFilters,
  clearProductsFilters,
  setProductsCurrentPage,
  setOrdersFilters,
  clearOrdersFilters,
  setOrdersCurrentPage,
  setVendorsFilters,
  clearVendorsFilters,
  setVendorsCurrentPage,
  setReviewsFilters,
  clearReviewsFilters,
  setReviewsCurrentPage,
  clearAdminError,
  clearDashboardError,
  clearUsersError,
  clearProductsError,
  clearOrdersError,
  clearVendorsError,
  clearReviewsError,
  updateUserInList,
  updateProductInList,
  updateVendorInList,
  removeProductFromList,
  removeReviewFromList,
  resetAdminState,
} = adminSlice.actions;

// Selectors
export const selectDashboardStats = (state) => state.admin.dashboardStats;
export const selectAnalytics = (state) => state.admin.analytics;
export const selectRecentActivities = (state) => state.admin.recentActivities;
export const selectAdminUsers = (state) => state.admin.users;
export const selectAdminProducts = (state) => state.admin.products;
export const selectAdminOrders = (state) => state.admin.orders;
export const selectAdminVendors = (state) => state.admin.vendors;
export const selectPendingVendors = (state) => state.admin.pendingVendors;
export const selectAdminReviews = (state) => state.admin.reviews;
export const selectReportedReviews = (state) => state.admin.reportedReviews;

// Pagination selectors
export const selectUsersPagination = (state) => state.admin.usersPagination;
export const selectProductsPagination = (state) => state.admin.productsPagination;
export const selectOrdersPagination = (state) => state.admin.ordersPagination;
export const selectVendorsPagination = (state) => state.admin.vendorsPagination;
export const selectReviewsPagination = (state) => state.admin.reviewsPagination;

// Filters selectors
export const selectUsersFilters = (state) => state.admin.usersFilters;
export const selectProductsFilters = (state) => state.admin.productsFilters;
export const selectOrdersFilters = (state) => state.admin.ordersFilters;
export const selectVendorsFilters = (state) => state.admin.vendorsFilters;
export const selectReviewsFilters = (state) => state.admin.reviewsFilters;

// Loading selectors
export const selectDashboardLoading = (state) => state.admin.dashboardLoading;
export const selectUsersLoading = (state) => state.admin.usersLoading;
export const selectProductsLoading = (state) => state.admin.productsLoading;
export const selectOrdersLoading = (state) => state.admin.ordersLoading;
export const selectVendorsLoading = (state) => state.admin.vendorsLoading;
export const selectReviewsLoading = (state) => state.admin.reviewsLoading;

// Error selectors
export const selectDashboardError = (state) => state.admin.dashboardError;
export const selectUsersError = (state) => state.admin.usersError;
export const selectProductsError = (state) => state.admin.productsError;
export const selectOrdersError = (state) => state.admin.ordersError;
export const selectVendorsError = (state) => state.admin.vendorsError;
export const selectReviewsError = (state) => state.admin.reviewsError;

export default adminSlice.reducer;