import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import api from '../../services/api';
import { toast } from 'react-hot-toast';

// Initial state
const initialState = {
  items: [],
  totalItems: 0,
  totalPrice: 0,
  savedItems: [],
  loading: false,
  error: null,
  lastModified: null,
};

// Helper functions
const calculateTotals = (items) => {
  const totalItems = items.reduce((sum, item) => sum + item.quantity, 0);
  const totalPrice = items.reduce((sum, item) => sum + (item.price * item.quantity), 0);
  return { totalItems, totalPrice };
};

const findItemIndex = (items, productId, customization = {}) => {
  return items.findIndex(item => 
    item.product._id === productId && 
    JSON.stringify(item.customization || {}) === JSON.stringify(customization)
  );
};

// Async thunks

// Fetch cart from server
export const fetchCart = createAsyncThunk(
  'cart/fetchCart',
  async (_, { rejectWithValue }) => {
    try {
      const response = await api.get('/users/cart');
      return response.data.cart;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to fetch cart';
      return rejectWithValue(message);
    }
  }
);

// Add item to cart
export const addToCart = createAsyncThunk(
  'cart/addToCart',
  async ({ productId, quantity = 1, customization = {} }, { rejectWithValue }) => {
    try {
      const response = await api.post('/users/cart/add', {
        productId,
        quantity,
        customization
      });
      toast.success('Item added to cart!');
      return response.data.cart;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to add item to cart';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

// Update cart item
export const updateCartItem = createAsyncThunk(
  'cart/updateCartItem',
  async ({ productId, quantity, customization = {} }, { rejectWithValue }) => {
    try {
      const response = await api.put('/users/cart/update', {
        productId,
        quantity,
        customization
      });
      return response.data.cart;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to update cart item';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

// Remove item from cart
export const removeFromCart = createAsyncThunk(
  'cart/removeFromCart',
  async ({ productId, customization = {} }, { rejectWithValue }) => {
    try {
      const response = await api.delete('/users/cart/remove', {
        data: { productId, customization }
      });
      toast.success('Item removed from cart');
      return response.data.cart;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to remove item from cart';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

// Clear cart
export const clearCart = createAsyncThunk(
  'cart/clearCart',
  async (_, { rejectWithValue }) => {
    try {
      const response = await api.delete('/users/cart/clear');
      toast.success('Cart cleared');
      return response.data.cart;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to clear cart';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

// Save item for later
export const saveForLater = createAsyncThunk(
  'cart/saveForLater',
  async ({ productId, customization = {} }, { rejectWithValue }) => {
    try {
      const response = await api.post('/users/cart/save-for-later', {
        productId,
        customization
      });
      toast.success('Item saved for later');
      return response.data.cart;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to save item for later';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

// Move item back to cart
export const moveToCart = createAsyncThunk(
  'cart/moveToCart',
  async ({ productId, customization = {} }, { rejectWithValue }) => {
    try {
      const response = await api.post('/users/cart/move-to-cart', {
        productId,
        customization
      });
      toast.success('Item moved to cart');
      return response.data.cart;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to move item to cart';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

// Remove saved item
export const removeSavedItem = createAsyncThunk(
  'cart/removeSavedItem',
  async ({ productId, customization = {} }, { rejectWithValue }) => {
    try {
      const response = await api.delete('/users/cart/remove-saved', {
        data: { productId, customization }
      });
      toast.success('Saved item removed');
      return response.data.cart;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to remove saved item';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

// Cart slice
const cartSlice = createSlice({
  name: 'cart',
  initialState,
  reducers: {
    // Local cart operations (for guest users)
    addToCartLocal: (state, action) => {
      const { product, quantity = 1, customization = {} } = action.payload;
      const existingIndex = findItemIndex(state.items, product._id, customization);
      
      if (existingIndex >= 0) {
        state.items[existingIndex].quantity += quantity;
      } else {
        state.items.push({
          product,
          quantity,
          price: product.price,
          customization,
          addedAt: new Date().toISOString()
        });
      }
      
      const totals = calculateTotals(state.items);
      state.totalItems = totals.totalItems;
      state.totalPrice = totals.totalPrice;
      state.lastModified = new Date().toISOString();
    },
    
    updateCartItemLocal: (state, action) => {
      const { productId, quantity, customization = {} } = action.payload;
      const existingIndex = findItemIndex(state.items, productId, customization);
      
      if (existingIndex >= 0) {
        if (quantity <= 0) {
          state.items.splice(existingIndex, 1);
        } else {
          state.items[existingIndex].quantity = quantity;
        }
        
        const totals = calculateTotals(state.items);
        state.totalItems = totals.totalItems;
        state.totalPrice = totals.totalPrice;
        state.lastModified = new Date().toISOString();
      }
    },
    
    removeFromCartLocal: (state, action) => {
      const { productId, customization = {} } = action.payload;
      const existingIndex = findItemIndex(state.items, productId, customization);
      
      if (existingIndex >= 0) {
        state.items.splice(existingIndex, 1);
        
        const totals = calculateTotals(state.items);
        state.totalItems = totals.totalItems;
        state.totalPrice = totals.totalPrice;
        state.lastModified = new Date().toISOString();
      }
    },
    
    clearCartLocal: (state) => {
      state.items = [];
      state.totalItems = 0;
      state.totalPrice = 0;
      state.lastModified = new Date().toISOString();
    },
    
    // Sync local cart with server cart
    syncCart: (state, action) => {
      const serverCart = action.payload;
      state.items = serverCart.items || [];
      state.savedItems = serverCart.savedItems || [];
      state.totalItems = serverCart.totalItems || 0;
      state.totalPrice = serverCart.totalPrice || 0;
      state.lastModified = serverCart.lastModified || new Date().toISOString();
    },
    
    // Clear error
    clearError: (state) => {
      state.error = null;
    },
    
    // Reset cart
    resetCart: (state) => {
      return initialState;
    },
    
    // Update item price (for price changes)
    updateItemPrice: (state, action) => {
      const { productId, newPrice } = action.payload;
      const item = state.items.find(item => item.product._id === productId);
      if (item) {
        item.price = newPrice;
        const totals = calculateTotals(state.items);
        state.totalItems = totals.totalItems;
        state.totalPrice = totals.totalPrice;
      }
    },
  },
  extraReducers: (builder) => {
    builder
      // Fetch cart
      .addCase(fetchCart.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchCart.fulfilled, (state, action) => {
        state.loading = false;
        state.items = action.payload.items || [];
        state.savedItems = action.payload.savedItems || [];
        state.totalItems = action.payload.totalItems || 0;
        state.totalPrice = action.payload.totalPrice || 0;
        state.lastModified = action.payload.lastModified;
        state.error = null;
      })
      .addCase(fetchCart.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      
      // Add to cart
      .addCase(addToCart.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(addToCart.fulfilled, (state, action) => {
        state.loading = false;
        state.items = action.payload.items || [];
        state.totalItems = action.payload.totalItems || 0;
        state.totalPrice = action.payload.totalPrice || 0;
        state.lastModified = action.payload.lastModified;
        state.error = null;
      })
      .addCase(addToCart.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      
      // Update cart item
      .addCase(updateCartItem.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(updateCartItem.fulfilled, (state, action) => {
        state.loading = false;
        state.items = action.payload.items || [];
        state.totalItems = action.payload.totalItems || 0;
        state.totalPrice = action.payload.totalPrice || 0;
        state.lastModified = action.payload.lastModified;
        state.error = null;
      })
      .addCase(updateCartItem.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      
      // Remove from cart
      .addCase(removeFromCart.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(removeFromCart.fulfilled, (state, action) => {
        state.loading = false;
        state.items = action.payload.items || [];
        state.totalItems = action.payload.totalItems || 0;
        state.totalPrice = action.payload.totalPrice || 0;
        state.lastModified = action.payload.lastModified;
        state.error = null;
      })
      .addCase(removeFromCart.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      
      // Clear cart
      .addCase(clearCart.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(clearCart.fulfilled, (state, action) => {
        state.loading = false;
        state.items = [];
        state.totalItems = 0;
        state.totalPrice = 0;
        state.lastModified = action.payload.lastModified;
        state.error = null;
      })
      .addCase(clearCart.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      
      // Save for later
      .addCase(saveForLater.fulfilled, (state, action) => {
        state.items = action.payload.items || [];
        state.savedItems = action.payload.savedItems || [];
        state.totalItems = action.payload.totalItems || 0;
        state.totalPrice = action.payload.totalPrice || 0;
        state.lastModified = action.payload.lastModified;
      })
      
      // Move to cart
      .addCase(moveToCart.fulfilled, (state, action) => {
        state.items = action.payload.items || [];
        state.savedItems = action.payload.savedItems || [];
        state.totalItems = action.payload.totalItems || 0;
        state.totalPrice = action.payload.totalPrice || 0;
        state.lastModified = action.payload.lastModified;
      })
      
      // Remove saved item
      .addCase(removeSavedItem.fulfilled, (state, action) => {
        state.savedItems = action.payload.savedItems || [];
        state.lastModified = action.payload.lastModified;
      });
  },
});

// Export actions
export const {
  addToCartLocal,
  updateCartItemLocal,
  removeFromCartLocal,
  clearCartLocal,
  syncCart,
  clearError,
  resetCart,
  updateItemPrice,
} = cartSlice.actions;

// Selectors
export const selectCart = (state) => state.cart;
export const selectCartItems = (state) => state.cart.items;
export const selectCartTotalItems = (state) => state.cart.totalItems;
export const selectCartTotalPrice = (state) => state.cart.totalPrice;
export const selectSavedItems = (state) => state.cart.savedItems;
export const selectCartLoading = (state) => state.cart.loading;
export const selectCartError = (state) => state.cart.error;
export const selectCartIsEmpty = (state) => state.cart.items.length === 0;

// Complex selectors
export const selectCartItemsByVendor = (state) => {
  const items = state.cart.items;
  const groupedItems = {};
  
  items.forEach(item => {
    const vendorId = item.product.vendor._id;
    if (!groupedItems[vendorId]) {
      groupedItems[vendorId] = {
        vendor: item.product.vendor,
        items: [],
        subtotal: 0
      };
    }
    groupedItems[vendorId].items.push(item);
    groupedItems[vendorId].subtotal += item.price * item.quantity;
  });
  
  return Object.values(groupedItems);
};

export const selectCartItemCount = (state, productId, customization = {}) => {
  const item = state.cart.items.find(item => 
    item.product._id === productId && 
    JSON.stringify(item.customization || {}) === JSON.stringify(customization)
  );
  return item ? item.quantity : 0;
};

export default cartSlice.reducer;