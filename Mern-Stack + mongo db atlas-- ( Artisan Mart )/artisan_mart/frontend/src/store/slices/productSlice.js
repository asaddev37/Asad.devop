import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import api from '../../services/api';
import { toast } from 'react-hot-toast';

// Initial state
const initialState = {
  products: [],
  featuredProducts: [],
  categories: [],
  currentProduct: null,
  relatedProducts: [],
  searchResults: [],
  filters: {
    category: '',
    minPrice: '',
    maxPrice: '',
    rating: '',
    vendor: '',
    search: '',
    sortBy: 'createdAt',
    sortOrder: 'desc',
  },
  pagination: {
    currentPage: 1,
    totalPages: 1,
    totalProducts: 0,
    limit: 12,
  },
  loading: false,
  searchLoading: false,
  productLoading: false,
  error: null,
  searchError: null,
};

// Async thunks

// Fetch all products
export const fetchProducts = createAsyncThunk(
  'products/fetchProducts',
  async (params = {}, { rejectWithValue, getState }) => {
    try {
      const { products } = getState();
      const queryParams = {
        page: params.page || products.pagination.currentPage,
        limit: params.limit || products.pagination.limit,
        ...products.filters,
        ...params,
      };
      
      // Remove empty values
      Object.keys(queryParams).forEach(key => {
        if (queryParams[key] === '' || queryParams[key] === null || queryParams[key] === undefined) {
          delete queryParams[key];
        }
      });
      
      const response = await api.get('/products', { params: queryParams });
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

// Fetch featured products
export const fetchFeaturedProducts = createAsyncThunk(
  'products/fetchFeaturedProducts',
  async (_, { rejectWithValue }) => {
    try {
      const response = await api.get('/products/featured');
      return response.data.products;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to fetch featured products';
      return rejectWithValue(message);
    }
  }
);

// Fetch product categories
export const fetchCategories = createAsyncThunk(
  'products/fetchCategories',
  async (_, { rejectWithValue }) => {
    try {
      const response = await api.get('/products/categories');
      return response.data.categories;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to fetch categories';
      return rejectWithValue(message);
    }
  }
);

// Fetch single product
export const fetchProduct = createAsyncThunk(
  'products/fetchProduct',
  async (productId, { rejectWithValue }) => {
    try {
      const response = await api.get(`/products/${productId}`);
      return {
        product: response.data.product,
        relatedProducts: response.data.relatedProducts || [],
      };
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to fetch product';
      return rejectWithValue(message);
    }
  }
);

// Search products
export const searchProducts = createAsyncThunk(
  'products/searchProducts',
  async (searchQuery, { rejectWithValue }) => {
    try {
      const response = await api.get('/products', {
        params: {
          search: searchQuery,
          limit: 20,
        },
      });
      return response.data.products;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to search products';
      return rejectWithValue(message);
    }
  }
);

// Create product (vendor only)
export const createProduct = createAsyncThunk(
  'products/createProduct',
  async (productData, { rejectWithValue }) => {
    try {
      const response = await api.post('/products', productData);
      toast.success('Product created successfully!');
      return response.data.product;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to create product';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

// Update product (vendor only)
export const updateProduct = createAsyncThunk(
  'products/updateProduct',
  async ({ productId, productData }, { rejectWithValue }) => {
    try {
      const response = await api.put(`/products/${productId}`, productData);
      toast.success('Product updated successfully!');
      return response.data.product;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to update product';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

// Delete product (vendor only)
export const deleteProduct = createAsyncThunk(
  'products/deleteProduct',
  async (productId, { rejectWithValue }) => {
    try {
      await api.delete(`/products/${productId}`);
      toast.success('Product deleted successfully!');
      return productId;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to delete product';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

// Product slice
const productSlice = createSlice({
  name: 'products',
  initialState,
  reducers: {
    // Set filters
    setFilters: (state, action) => {
      state.filters = { ...state.filters, ...action.payload };
      state.pagination.currentPage = 1; // Reset to first page when filters change
    },
    
    // Clear filters
    clearFilters: (state) => {
      state.filters = {
        category: '',
        minPrice: '',
        maxPrice: '',
        rating: '',
        vendor: '',
        search: '',
        sortBy: 'createdAt',
        sortOrder: 'desc',
      };
      state.pagination.currentPage = 1;
    },
    
    // Set current page
    setCurrentPage: (state, action) => {
      state.pagination.currentPage = action.payload;
    },
    
    // Set sort options
    setSortOptions: (state, action) => {
      state.filters.sortBy = action.payload.sortBy;
      state.filters.sortOrder = action.payload.sortOrder;
      state.pagination.currentPage = 1;
    },
    
    // Clear current product
    clearCurrentProduct: (state) => {
      state.currentProduct = null;
      state.relatedProducts = [];
    },
    
    // Clear search results
    clearSearchResults: (state) => {
      state.searchResults = [];
      state.searchError = null;
    },
    
    // Clear error
    clearError: (state) => {
      state.error = null;
      state.searchError = null;
    },
    
    // Update product in list (for real-time updates)
    updateProductInList: (state, action) => {
      const updatedProduct = action.payload;
      const index = state.products.findIndex(p => p._id === updatedProduct._id);
      if (index !== -1) {
        state.products[index] = updatedProduct;
      }
      
      // Update in featured products if exists
      const featuredIndex = state.featuredProducts.findIndex(p => p._id === updatedProduct._id);
      if (featuredIndex !== -1) {
        state.featuredProducts[featuredIndex] = updatedProduct;
      }
      
      // Update current product if it's the same
      if (state.currentProduct && state.currentProduct._id === updatedProduct._id) {
        state.currentProduct = updatedProduct;
      }
    },
    
    // Remove product from list
    removeProductFromList: (state, action) => {
      const productId = action.payload;
      state.products = state.products.filter(p => p._id !== productId);
      state.featuredProducts = state.featuredProducts.filter(p => p._id !== productId);
      state.searchResults = state.searchResults.filter(p => p._id !== productId);
      
      if (state.currentProduct && state.currentProduct._id === productId) {
        state.currentProduct = null;
      }
    },
    
    // Reset products state
    resetProducts: (state) => {
      return initialState;
    },
  },
  extraReducers: (builder) => {
    builder
      // Fetch products
      .addCase(fetchProducts.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchProducts.fulfilled, (state, action) => {
        state.loading = false;
        state.products = action.payload.products;
        state.pagination = action.payload.pagination;
        state.error = null;
      })
      .addCase(fetchProducts.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      
      // Fetch featured products
      .addCase(fetchFeaturedProducts.pending, (state) => {
        state.loading = true;
      })
      .addCase(fetchFeaturedProducts.fulfilled, (state, action) => {
        state.loading = false;
        state.featuredProducts = action.payload;
        state.error = null;
      })
      .addCase(fetchFeaturedProducts.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      
      // Fetch categories
      .addCase(fetchCategories.pending, (state) => {
        state.loading = true;
      })
      .addCase(fetchCategories.fulfilled, (state, action) => {
        state.loading = false;
        state.categories = action.payload;
        state.error = null;
      })
      .addCase(fetchCategories.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      
      // Fetch single product
      .addCase(fetchProduct.pending, (state) => {
        state.productLoading = true;
        state.error = null;
      })
      .addCase(fetchProduct.fulfilled, (state, action) => {
        state.productLoading = false;
        state.currentProduct = action.payload.product;
        state.relatedProducts = action.payload.relatedProducts;
        state.error = null;
      })
      .addCase(fetchProduct.rejected, (state, action) => {
        state.productLoading = false;
        state.error = action.payload;
        state.currentProduct = null;
      })
      
      // Search products
      .addCase(searchProducts.pending, (state) => {
        state.searchLoading = true;
        state.searchError = null;
      })
      .addCase(searchProducts.fulfilled, (state, action) => {
        state.searchLoading = false;
        state.searchResults = action.payload;
        state.searchError = null;
      })
      .addCase(searchProducts.rejected, (state, action) => {
        state.searchLoading = false;
        state.searchError = action.payload;
      })
      
      // Create product
      .addCase(createProduct.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(createProduct.fulfilled, (state, action) => {
        state.loading = false;
        state.products.unshift(action.payload); // Add to beginning of list
        state.error = null;
      })
      .addCase(createProduct.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      
      // Update product
      .addCase(updateProduct.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(updateProduct.fulfilled, (state, action) => {
        state.loading = false;
        const updatedProduct = action.payload;
        
        // Update in products list
        const index = state.products.findIndex(p => p._id === updatedProduct._id);
        if (index !== -1) {
          state.products[index] = updatedProduct;
        }
        
        // Update current product if it's the same
        if (state.currentProduct && state.currentProduct._id === updatedProduct._id) {
          state.currentProduct = updatedProduct;
        }
        
        state.error = null;
      })
      .addCase(updateProduct.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      
      // Delete product
      .addCase(deleteProduct.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(deleteProduct.fulfilled, (state, action) => {
        state.loading = false;
        const productId = action.payload;
        state.products = state.products.filter(p => p._id !== productId);
        state.featuredProducts = state.featuredProducts.filter(p => p._id !== productId);
        
        if (state.currentProduct && state.currentProduct._id === productId) {
          state.currentProduct = null;
        }
        
        state.error = null;
      })
      .addCase(deleteProduct.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      });
  },
});

// Export actions
export const {
  setFilters,
  clearFilters,
  setCurrentPage,
  setSortOptions,
  clearCurrentProduct,
  clearSearchResults,
  clearError,
  updateProductInList,
  removeProductFromList,
  resetProducts,
} = productSlice.actions;

// Selectors
export const selectProducts = (state) => state.products.products;
export const selectFeaturedProducts = (state) => state.products.featuredProducts;
export const selectCategories = (state) => state.products.categories;
export const selectCurrentProduct = (state) => state.products.currentProduct;
export const selectRelatedProducts = (state) => state.products.relatedProducts;
export const selectSearchResults = (state) => state.products.searchResults;
export const selectProductFilters = (state) => state.products.filters;
export const selectProductPagination = (state) => state.products.pagination;
export const selectProductsLoading = (state) => state.products.loading;
export const selectSearchLoading = (state) => state.products.searchLoading;
export const selectProductLoading = (state) => state.products.productLoading;
export const selectProductsError = (state) => state.products.error;
export const selectSearchError = (state) => state.products.searchError;

// Complex selectors
export const selectFilteredProducts = (state) => {
  const { products, filters } = state.products;
  let filtered = [...products];
  
  // Apply client-side filters if needed
  if (filters.search) {
    const searchTerm = filters.search.toLowerCase();
    filtered = filtered.filter(product => 
      product.name.toLowerCase().includes(searchTerm) ||
      product.description.toLowerCase().includes(searchTerm) ||
      product.category.toLowerCase().includes(searchTerm)
    );
  }
  
  return filtered;
};

export const selectProductsByCategory = (state) => {
  const products = state.products.products;
  const grouped = {};
  
  products.forEach(product => {
    if (!grouped[product.category]) {
      grouped[product.category] = [];
    }
    grouped[product.category].push(product);
  });
  
  return grouped;
};

export default productSlice.reducer;