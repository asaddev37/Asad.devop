import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import api from '../../services/api';
import { toast } from 'react-hot-toast';

// Initial state
const initialState = {
  vendors: [],
  currentVendor: null,
  vendorProducts: [],
  vendorStats: null,
  vendorOrders: [],
  pendingVendors: [],
  pagination: {
    currentPage: 1,
    totalPages: 1,
    totalVendors: 0,
    limit: 12,
  },
  productsPagination: {
    currentPage: 1,
    totalPages: 1,
    totalProducts: 0,
    limit: 12,
  },
  filters: {
    search: '',
    category: '',
    location: '',
    rating: '',
    sortBy: 'createdAt',
    sortOrder: 'desc',
  },
  loading: false,
  vendorLoading: false,
  productsLoading: false,
  statsLoading: false,
  error: null,
};

// Async thunks

// Fetch all vendors
export const fetchVendors = createAsyncThunk(
  'vendors/fetchVendors',
  async (params = {}, { rejectWithValue, getState }) => {
    try {
      const { vendors } = getState();
      const queryParams = {
        page: params.page || vendors.pagination.currentPage,
        limit: params.limit || vendors.pagination.limit,
        ...vendors.filters,
        ...params,
      };
      
      // Remove empty values
      Object.keys(queryParams).forEach(key => {
        if (queryParams[key] === '' || queryParams[key] === null || queryParams[key] === undefined) {
          delete queryParams[key];
        }
      });
      
      const response = await api.get('/vendors', { params: queryParams });
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

// Fetch single vendor
export const fetchVendor = createAsyncThunk(
  'vendors/fetchVendor',
  async (vendorId, { rejectWithValue }) => {
    try {
      const response = await api.get(`/vendors/${vendorId}`);
      return response.data.vendor;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to fetch vendor';
      return rejectWithValue(message);
    }
  }
);

// Fetch vendor products
export const fetchVendorProducts = createAsyncThunk(
  'vendors/fetchVendorProducts',
  async ({ vendorId, params = {} }, { rejectWithValue, getState }) => {
    try {
      const { vendors } = getState();
      const queryParams = {
        page: params.page || vendors.productsPagination.currentPage,
        limit: params.limit || vendors.productsPagination.limit,
        ...params,
      };
      
      // Remove empty values
      Object.keys(queryParams).forEach(key => {
        if (queryParams[key] === '' || queryParams[key] === null || queryParams[key] === undefined) {
          delete queryParams[key];
        }
      });
      
      const response = await api.get(`/vendors/${vendorId}/products`, { params: queryParams });
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
      const message = error.response?.data?.message || 'Failed to fetch vendor products';
      return rejectWithValue(message);
    }
  }
);

// Fetch vendor dashboard stats
export const fetchVendorStats = createAsyncThunk(
  'vendors/fetchVendorStats',
  async (params = {}, { rejectWithValue }) => {
    try {
      const response = await api.get('/vendors/dashboard/stats', { params });
      return response.data.stats;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to fetch vendor statistics';
      return rejectWithValue(message);
    }
  }
);

// Update vendor profile
export const updateVendorProfile = createAsyncThunk(
  'vendors/updateVendorProfile',
  async (vendorData, { rejectWithValue }) => {
    try {
      const response = await api.put('/vendors/profile', vendorData);
      toast.success('Vendor profile updated successfully!');
      return response.data.vendor;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to update vendor profile';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

// Fetch pending vendor applications (admin only)
export const fetchPendingVendors = createAsyncThunk(
  'vendors/fetchPendingVendors',
  async (params = {}, { rejectWithValue }) => {
    try {
      const queryParams = {
        page: params.page || 1,
        limit: params.limit || 10,
        ...params,
      };
      
      const response = await api.get('/admin/vendors/pending', { params: queryParams });
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
      const message = error.response?.data?.message || 'Failed to fetch pending vendors';
      return rejectWithValue(message);
    }
  }
);

// Approve vendor (admin only)
export const approveVendor = createAsyncThunk(
  'vendors/approveVendor',
  async (vendorId, { rejectWithValue }) => {
    try {
      const response = await api.put(`/admin/vendors/${vendorId}/approve`);
      toast.success('Vendor approved successfully!');
      return { vendorId, vendor: response.data.vendor };
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to approve vendor';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

// Reject vendor (admin only)
export const rejectVendor = createAsyncThunk(
  'vendors/rejectVendor',
  async ({ vendorId, reason }, { rejectWithValue }) => {
    try {
      const response = await api.put(`/admin/vendors/${vendorId}/reject`, { reason });
      toast.success('Vendor application rejected');
      return { vendorId, vendor: response.data.vendor };
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to reject vendor';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

// Search vendors
export const searchVendors = createAsyncThunk(
  'vendors/searchVendors',
  async (searchQuery, { rejectWithValue }) => {
    try {
      const response = await api.get('/vendors', {
        params: {
          search: searchQuery,
          limit: 20,
        },
      });
      return response.data.vendors;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to search vendors';
      return rejectWithValue(message);
    }
  }
);

// Vendor slice
const vendorSlice = createSlice({
  name: 'vendors',
  initialState,
  reducers: {
    // Set filters
    setVendorFilters: (state, action) => {
      state.filters = { ...state.filters, ...action.payload };
      state.pagination.currentPage = 1;
    },
    
    // Clear filters
    clearVendorFilters: (state) => {
      state.filters = {
        search: '',
        category: '',
        location: '',
        rating: '',
        sortBy: 'createdAt',
        sortOrder: 'desc',
      };
      state.pagination.currentPage = 1;
    },
    
    // Set current page
    setVendorCurrentPage: (state, action) => {
      state.pagination.currentPage = action.payload;
    },
    
    // Set products current page
    setProductsCurrentPage: (state, action) => {
      state.productsPagination.currentPage = action.payload;
    },
    
    // Set sort options
    setVendorSortOptions: (state, action) => {
      state.filters.sortBy = action.payload.sortBy;
      state.filters.sortOrder = action.payload.sortOrder;
      state.pagination.currentPage = 1;
    },
    
    // Clear current vendor
    clearCurrentVendor: (state) => {
      state.currentVendor = null;
      state.vendorProducts = [];
      state.vendorStats = null;
    },
    
    // Clear error
    clearVendorError: (state) => {
      state.error = null;
    },
    
    // Update vendor in list
    updateVendorInList: (state, action) => {
      const updatedVendor = action.payload;
      const index = state.vendors.findIndex(v => v._id === updatedVendor._id);
      if (index !== -1) {
        state.vendors[index] = updatedVendor;
      }
      
      // Update current vendor if it's the same
      if (state.currentVendor && state.currentVendor._id === updatedVendor._id) {
        state.currentVendor = updatedVendor;
      }
    },
    
    // Remove vendor from pending list
    removeFromPendingList: (state, action) => {
      const vendorId = action.payload;
      state.pendingVendors = state.pendingVendors.filter(v => v._id !== vendorId);
    },
    
    // Add vendor to approved list
    addToApprovedList: (state, action) => {
      const vendor = action.payload;
      if (vendor.status === 'approved') {
        state.vendors.unshift(vendor);
      }
    },
    
    // Reset vendors state
    resetVendors: (state) => {
      return initialState;
    },
    
    // Update vendor stats
    updateVendorStats: (state, action) => {
      state.vendorStats = { ...state.vendorStats, ...action.payload };
    },
  },
  extraReducers: (builder) => {
    builder
      // Fetch vendors
      .addCase(fetchVendors.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchVendors.fulfilled, (state, action) => {
        state.loading = false;
        state.vendors = action.payload.vendors;
        state.pagination = action.payload.pagination;
        state.error = null;
      })
      .addCase(fetchVendors.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      
      // Fetch single vendor
      .addCase(fetchVendor.pending, (state) => {
        state.vendorLoading = true;
        state.error = null;
      })
      .addCase(fetchVendor.fulfilled, (state, action) => {
        state.vendorLoading = false;
        state.currentVendor = action.payload;
        state.error = null;
      })
      .addCase(fetchVendor.rejected, (state, action) => {
        state.vendorLoading = false;
        state.error = action.payload;
        state.currentVendor = null;
      })
      
      // Fetch vendor products
      .addCase(fetchVendorProducts.pending, (state) => {
        state.productsLoading = true;
        state.error = null;
      })
      .addCase(fetchVendorProducts.fulfilled, (state, action) => {
        state.productsLoading = false;
        state.vendorProducts = action.payload.products;
        state.productsPagination = action.payload.pagination;
        state.error = null;
      })
      .addCase(fetchVendorProducts.rejected, (state, action) => {
        state.productsLoading = false;
        state.error = action.payload;
      })
      
      // Fetch vendor stats
      .addCase(fetchVendorStats.pending, (state) => {
        state.statsLoading = true;
        state.error = null;
      })
      .addCase(fetchVendorStats.fulfilled, (state, action) => {
        state.statsLoading = false;
        state.vendorStats = action.payload;
        state.error = null;
      })
      .addCase(fetchVendorStats.rejected, (state, action) => {
        state.statsLoading = false;
        state.error = action.payload;
      })
      
      // Update vendor profile
      .addCase(updateVendorProfile.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(updateVendorProfile.fulfilled, (state, action) => {
        state.loading = false;
        const updatedVendor = action.payload;
        
        // Update current vendor
        state.currentVendor = updatedVendor;
        
        // Update in vendors list
        const index = state.vendors.findIndex(v => v._id === updatedVendor._id);
        if (index !== -1) {
          state.vendors[index] = updatedVendor;
        }
        
        state.error = null;
      })
      .addCase(updateVendorProfile.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      
      // Fetch pending vendors
      .addCase(fetchPendingVendors.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchPendingVendors.fulfilled, (state, action) => {
        state.loading = false;
        state.pendingVendors = action.payload.vendors;
        state.error = null;
      })
      .addCase(fetchPendingVendors.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      
      // Approve vendor
      .addCase(approveVendor.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(approveVendor.fulfilled, (state, action) => {
        state.loading = false;
        const { vendorId, vendor } = action.payload;
        
        // Remove from pending list
        state.pendingVendors = state.pendingVendors.filter(v => v._id !== vendorId);
        
        // Add to approved vendors list
        state.vendors.unshift(vendor);
        
        state.error = null;
      })
      .addCase(approveVendor.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      
      // Reject vendor
      .addCase(rejectVendor.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(rejectVendor.fulfilled, (state, action) => {
        state.loading = false;
        const { vendorId } = action.payload;
        
        // Remove from pending list
        state.pendingVendors = state.pendingVendors.filter(v => v._id !== vendorId);
        
        state.error = null;
      })
      .addCase(rejectVendor.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      
      // Search vendors
      .addCase(searchVendors.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(searchVendors.fulfilled, (state, action) => {
        state.loading = false;
        state.vendors = action.payload;
        state.error = null;
      })
      .addCase(searchVendors.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      });
  },
});

// Export actions
export const {
  setVendorFilters,
  clearVendorFilters,
  setVendorCurrentPage,
  setProductsCurrentPage,
  setVendorSortOptions,
  clearCurrentVendor,
  clearVendorError,
  updateVendorInList,
  removeFromPendingList,
  addToApprovedList,
  resetVendors,
  updateVendorStats,
} = vendorSlice.actions;

// Selectors
export const selectVendors = (state) => state.vendors.vendors;
export const selectCurrentVendor = (state) => state.vendors.currentVendor;
export const selectVendorProducts = (state) => state.vendors.vendorProducts;
export const selectVendorStats = (state) => state.vendors.vendorStats;
export const selectPendingVendors = (state) => state.vendors.pendingVendors;
export const selectVendorPagination = (state) => state.vendors.pagination;
export const selectProductsPagination = (state) => state.vendors.productsPagination;
export const selectVendorFilters = (state) => state.vendors.filters;
export const selectVendorsLoading = (state) => state.vendors.loading;
export const selectVendorLoading = (state) => state.vendors.vendorLoading;
export const selectProductsLoading = (state) => state.vendors.productsLoading;
export const selectStatsLoading = (state) => state.vendors.statsLoading;
export const selectVendorsError = (state) => state.vendors.error;

// Complex selectors
export const selectVendorsByCategory = (state) => {
  const vendors = state.vendors.vendors;
  const grouped = {};
  
  vendors.forEach(vendor => {
    const categories = vendor.categories || ['Other'];
    categories.forEach(category => {
      if (!grouped[category]) {
        grouped[category] = [];
      }
      grouped[category].push(vendor);
    });
  });
  
  return grouped;
};

export const selectTopVendors = (state) => {
  return state.vendors.vendors
    .filter(vendor => vendor.rating >= 4.0)
    .sort((a, b) => b.rating - a.rating)
    .slice(0, 10);
};

export const selectVendorById = (state, vendorId) => {
  return state.vendors.vendors.find(vendor => vendor._id === vendorId);
};

export default vendorSlice.reducer;