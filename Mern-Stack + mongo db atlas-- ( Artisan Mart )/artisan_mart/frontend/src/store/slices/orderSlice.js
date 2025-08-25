import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import api from '../../services/api';
import { toast } from 'react-hot-toast';

// Initial state
const initialState = {
  orders: [],
  currentOrder: null,
  orderHistory: [],
  vendorOrders: [],
  orderStats: null,
  pagination: {
    currentPage: 1,
    totalPages: 1,
    totalOrders: 0,
    limit: 10,
  },
  filters: {
    status: '',
    dateFrom: '',
    dateTo: '',
    vendor: '',
  },
  loading: false,
  orderLoading: false,
  statsLoading: false,
  error: null,
};

// Async thunks

// Create order
export const createOrder = createAsyncThunk(
  'orders/createOrder',
  async (orderData, { rejectWithValue }) => {
    try {
      const response = await api.post('/orders', orderData);
      toast.success('Order placed successfully!');
      return response.data.order;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to create order';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

// Fetch user orders
export const fetchUserOrders = createAsyncThunk(
  'orders/fetchUserOrders',
  async (params = {}, { rejectWithValue, getState }) => {
    try {
      const { orders } = getState();
      const queryParams = {
        page: params.page || orders.pagination.currentPage,
        limit: params.limit || orders.pagination.limit,
        ...orders.filters,
        ...params,
      };
      
      // Remove empty values
      Object.keys(queryParams).forEach(key => {
        if (queryParams[key] === '' || queryParams[key] === null || queryParams[key] === undefined) {
          delete queryParams[key];
        }
      });
      
      const response = await api.get('/orders', { params: queryParams });
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

// Fetch single order
export const fetchOrder = createAsyncThunk(
  'orders/fetchOrder',
  async (orderId, { rejectWithValue }) => {
    try {
      const response = await api.get(`/orders/${orderId}`);
      return response.data.order;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to fetch order';
      return rejectWithValue(message);
    }
  }
);

// Update order status (vendor only)
export const updateOrderStatus = createAsyncThunk(
  'orders/updateOrderStatus',
  async ({ orderId, status, trackingNumber }, { rejectWithValue }) => {
    try {
      const response = await api.put(`/orders/${orderId}/status`, {
        status,
        trackingNumber,
      });
      toast.success('Order status updated successfully!');
      return response.data.order;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to update order status';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

// Cancel order
export const cancelOrder = createAsyncThunk(
  'orders/cancelOrder',
  async ({ orderId, reason }, { rejectWithValue }) => {
    try {
      const response = await api.put(`/orders/${orderId}/cancel`, { reason });
      toast.success('Order cancelled successfully!');
      return response.data.order;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to cancel order';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

// Fetch vendor orders
export const fetchVendorOrders = createAsyncThunk(
  'orders/fetchVendorOrders',
  async (params = {}, { rejectWithValue }) => {
    try {
      const queryParams = {
        page: params.page || 1,
        limit: params.limit || 10,
        ...params,
      };
      
      // Remove empty values
      Object.keys(queryParams).forEach(key => {
        if (queryParams[key] === '' || queryParams[key] === null || queryParams[key] === undefined) {
          delete queryParams[key];
        }
      });
      
      const response = await api.get('/orders/vendor', { params: queryParams });
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
      const message = error.response?.data?.message || 'Failed to fetch vendor orders';
      return rejectWithValue(message);
    }
  }
);

// Fetch order statistics
export const fetchOrderStats = createAsyncThunk(
  'orders/fetchOrderStats',
  async (params = {}, { rejectWithValue }) => {
    try {
      const response = await api.get('/orders/stats', { params });
      return response.data.stats;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to fetch order statistics';
      return rejectWithValue(message);
    }
  }
);

// Request refund
export const requestRefund = createAsyncThunk(
  'orders/requestRefund',
  async ({ orderId, reason, amount }, { rejectWithValue }) => {
    try {
      const response = await api.post(`/orders/${orderId}/refund`, {
        reason,
        amount,
      });
      toast.success('Refund request submitted successfully!');
      return response.data.order;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to request refund';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

// Order slice
const orderSlice = createSlice({
  name: 'orders',
  initialState,
  reducers: {
    // Set filters
    setOrderFilters: (state, action) => {
      state.filters = { ...state.filters, ...action.payload };
      state.pagination.currentPage = 1;
    },
    
    // Clear filters
    clearOrderFilters: (state) => {
      state.filters = {
        status: '',
        dateFrom: '',
        dateTo: '',
        vendor: '',
      };
      state.pagination.currentPage = 1;
    },
    
    // Set current page
    setOrderCurrentPage: (state, action) => {
      state.pagination.currentPage = action.payload;
    },
    
    // Clear current order
    clearCurrentOrder: (state) => {
      state.currentOrder = null;
    },
    
    // Clear error
    clearOrderError: (state) => {
      state.error = null;
    },
    
    // Update order in list
    updateOrderInList: (state, action) => {
      const updatedOrder = action.payload;
      
      // Update in orders list
      const orderIndex = state.orders.findIndex(o => o._id === updatedOrder._id);
      if (orderIndex !== -1) {
        state.orders[orderIndex] = updatedOrder;
      }
      
      // Update in vendor orders list
      const vendorOrderIndex = state.vendorOrders.findIndex(o => o._id === updatedOrder._id);
      if (vendorOrderIndex !== -1) {
        state.vendorOrders[vendorOrderIndex] = updatedOrder;
      }
      
      // Update current order if it's the same
      if (state.currentOrder && state.currentOrder._id === updatedOrder._id) {
        state.currentOrder = updatedOrder;
      }
    },
    
    // Add new order to list
    addOrderToList: (state, action) => {
      const newOrder = action.payload;
      state.orders.unshift(newOrder);
      state.pagination.totalOrders += 1;
    },
    
    // Reset orders state
    resetOrders: (state) => {
      return initialState;
    },
    
    // Set order loading
    setOrderLoading: (state, action) => {
      state.orderLoading = action.payload;
    },
  },
  extraReducers: (builder) => {
    builder
      // Create order
      .addCase(createOrder.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(createOrder.fulfilled, (state, action) => {
        state.loading = false;
        state.currentOrder = action.payload;
        state.orders.unshift(action.payload);
        state.error = null;
      })
      .addCase(createOrder.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      
      // Fetch user orders
      .addCase(fetchUserOrders.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchUserOrders.fulfilled, (state, action) => {
        state.loading = false;
        state.orders = action.payload.orders;
        state.pagination = action.payload.pagination;
        state.error = null;
      })
      .addCase(fetchUserOrders.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      
      // Fetch single order
      .addCase(fetchOrder.pending, (state) => {
        state.orderLoading = true;
        state.error = null;
      })
      .addCase(fetchOrder.fulfilled, (state, action) => {
        state.orderLoading = false;
        state.currentOrder = action.payload;
        state.error = null;
      })
      .addCase(fetchOrder.rejected, (state, action) => {
        state.orderLoading = false;
        state.error = action.payload;
        state.currentOrder = null;
      })
      
      // Update order status
      .addCase(updateOrderStatus.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(updateOrderStatus.fulfilled, (state, action) => {
        state.loading = false;
        const updatedOrder = action.payload;
        
        // Update in orders list
        const orderIndex = state.orders.findIndex(o => o._id === updatedOrder._id);
        if (orderIndex !== -1) {
          state.orders[orderIndex] = updatedOrder;
        }
        
        // Update in vendor orders list
        const vendorOrderIndex = state.vendorOrders.findIndex(o => o._id === updatedOrder._id);
        if (vendorOrderIndex !== -1) {
          state.vendorOrders[vendorOrderIndex] = updatedOrder;
        }
        
        // Update current order
        if (state.currentOrder && state.currentOrder._id === updatedOrder._id) {
          state.currentOrder = updatedOrder;
        }
        
        state.error = null;
      })
      .addCase(updateOrderStatus.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      
      // Cancel order
      .addCase(cancelOrder.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(cancelOrder.fulfilled, (state, action) => {
        state.loading = false;
        const updatedOrder = action.payload;
        
        // Update in orders list
        const orderIndex = state.orders.findIndex(o => o._id === updatedOrder._id);
        if (orderIndex !== -1) {
          state.orders[orderIndex] = updatedOrder;
        }
        
        // Update current order
        if (state.currentOrder && state.currentOrder._id === updatedOrder._id) {
          state.currentOrder = updatedOrder;
        }
        
        state.error = null;
      })
      .addCase(cancelOrder.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      
      // Fetch vendor orders
      .addCase(fetchVendorOrders.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchVendorOrders.fulfilled, (state, action) => {
        state.loading = false;
        state.vendorOrders = action.payload.orders;
        state.pagination = action.payload.pagination;
        state.error = null;
      })
      .addCase(fetchVendorOrders.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      
      // Fetch order stats
      .addCase(fetchOrderStats.pending, (state) => {
        state.statsLoading = true;
        state.error = null;
      })
      .addCase(fetchOrderStats.fulfilled, (state, action) => {
        state.statsLoading = false;
        state.orderStats = action.payload;
        state.error = null;
      })
      .addCase(fetchOrderStats.rejected, (state, action) => {
        state.statsLoading = false;
        state.error = action.payload;
      })
      
      // Request refund
      .addCase(requestRefund.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(requestRefund.fulfilled, (state, action) => {
        state.loading = false;
        const updatedOrder = action.payload;
        
        // Update in orders list
        const orderIndex = state.orders.findIndex(o => o._id === updatedOrder._id);
        if (orderIndex !== -1) {
          state.orders[orderIndex] = updatedOrder;
        }
        
        // Update current order
        if (state.currentOrder && state.currentOrder._id === updatedOrder._id) {
          state.currentOrder = updatedOrder;
        }
        
        state.error = null;
      })
      .addCase(requestRefund.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      });
  },
});

// Export actions
export const {
  setOrderFilters,
  clearOrderFilters,
  setOrderCurrentPage,
  clearCurrentOrder,
  clearOrderError,
  updateOrderInList,
  addOrderToList,
  resetOrders,
  setOrderLoading,
} = orderSlice.actions;

// Selectors
export const selectOrders = (state) => state.orders.orders;
export const selectCurrentOrder = (state) => state.orders.currentOrder;
export const selectVendorOrders = (state) => state.orders.vendorOrders;
export const selectOrderStats = (state) => state.orders.orderStats;
export const selectOrderPagination = (state) => state.orders.pagination;
export const selectOrderFilters = (state) => state.orders.filters;
export const selectOrdersLoading = (state) => state.orders.loading;
export const selectOrderLoading = (state) => state.orders.orderLoading;
export const selectStatsLoading = (state) => state.orders.statsLoading;
export const selectOrdersError = (state) => state.orders.error;

// Complex selectors
export const selectOrdersByStatus = (state) => {
  const orders = state.orders.orders;
  const grouped = {};
  
  orders.forEach(order => {
    if (!grouped[order.status]) {
      grouped[order.status] = [];
    }
    grouped[order.status].push(order);
  });
  
  return grouped;
};

export const selectRecentOrders = (state) => {
  return state.orders.orders.slice(0, 5);
};

export const selectOrdersTotal = (state) => {
  return state.orders.orders.reduce((total, order) => total + order.totalAmount, 0);
};

export default orderSlice.reducer;