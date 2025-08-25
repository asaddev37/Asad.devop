import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import api from '../../services/api';
import { toast } from 'react-hot-toast';

// Initial state
const initialState = {
  reviews: [],
  productReviews: [],
  userReviews: [],
  currentReview: null,
  reviewStats: null,
  pagination: {
    currentPage: 1,
    totalPages: 1,
    totalReviews: 0,
    limit: 10,
  },
  filters: {
    rating: '',
    sortBy: 'createdAt',
    sortOrder: 'desc',
    verified: '',
  },
  loading: false,
  reviewLoading: false,
  error: null,
};

// Async thunks

// Fetch product reviews
export const fetchProductReviews = createAsyncThunk(
  'reviews/fetchProductReviews',
  async ({ productId, params = {} }, { rejectWithValue, getState }) => {
    try {
      const { reviews } = getState();
      const queryParams = {
        page: params.page || reviews.pagination.currentPage,
        limit: params.limit || reviews.pagination.limit,
        ...reviews.filters,
        ...params,
      };
      
      // Remove empty values
      Object.keys(queryParams).forEach(key => {
        if (queryParams[key] === '' || queryParams[key] === null || queryParams[key] === undefined) {
          delete queryParams[key];
        }
      });
      
      const response = await api.get(`/products/${productId}/reviews`, { params: queryParams });
      return {
        reviews: response.data.reviews,
        stats: response.data.stats,
        pagination: {
          currentPage: response.data.currentPage,
          totalPages: response.data.totalPages,
          totalReviews: response.data.totalReviews,
          limit: response.data.limit,
        },
      };
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to fetch product reviews';
      return rejectWithValue(message);
    }
  }
);

// Fetch user reviews
export const fetchUserReviews = createAsyncThunk(
  'reviews/fetchUserReviews',
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
      
      const response = await api.get('/reviews/user', { params: queryParams });
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
      const message = error.response?.data?.message || 'Failed to fetch user reviews';
      return rejectWithValue(message);
    }
  }
);

// Create review
export const createReview = createAsyncThunk(
  'reviews/createReview',
  async (reviewData, { rejectWithValue }) => {
    try {
      const response = await api.post('/reviews', reviewData);
      toast.success('Review submitted successfully!');
      return response.data.review;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to create review';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

// Update review
export const updateReview = createAsyncThunk(
  'reviews/updateReview',
  async ({ reviewId, reviewData }, { rejectWithValue }) => {
    try {
      const response = await api.put(`/reviews/${reviewId}`, reviewData);
      toast.success('Review updated successfully!');
      return response.data.review;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to update review';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

// Delete review
export const deleteReview = createAsyncThunk(
  'reviews/deleteReview',
  async (reviewId, { rejectWithValue }) => {
    try {
      await api.delete(`/reviews/${reviewId}`);
      toast.success('Review deleted successfully!');
      return reviewId;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to delete review';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

// Mark review as helpful
export const markReviewHelpful = createAsyncThunk(
  'reviews/markReviewHelpful',
  async ({ reviewId, helpful }, { rejectWithValue }) => {
    try {
      const response = await api.post(`/reviews/${reviewId}/helpful`, { helpful });
      return {
        reviewId,
        helpfulCount: response.data.helpfulCount,
        notHelpfulCount: response.data.notHelpfulCount,
        userHelpfulVote: helpful,
      };
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to mark review as helpful';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

// Add vendor response
export const addVendorResponse = createAsyncThunk(
  'reviews/addVendorResponse',
  async ({ reviewId, response }, { rejectWithValue }) => {
    try {
      const apiResponse = await api.post(`/reviews/${reviewId}/response`, { response });
      toast.success('Response added successfully!');
      return {
        reviewId,
        vendorResponse: apiResponse.data.vendorResponse,
      };
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to add vendor response';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

// Report review
export const reportReview = createAsyncThunk(
  'reviews/reportReview',
  async ({ reviewId, reason }, { rejectWithValue }) => {
    try {
      await api.post(`/reviews/${reviewId}/report`, { reason });
      toast.success('Review reported successfully!');
      return reviewId;
    } catch (error) {
      const message = error.response?.data?.message || 'Failed to report review';
      toast.error(message);
      return rejectWithValue(message);
    }
  }
);

// Review slice
const reviewSlice = createSlice({
  name: 'reviews',
  initialState,
  reducers: {
    // Set filters
    setReviewFilters: (state, action) => {
      state.filters = { ...state.filters, ...action.payload };
      state.pagination.currentPage = 1;
    },
    
    // Clear filters
    clearReviewFilters: (state) => {
      state.filters = {
        rating: '',
        sortBy: 'createdAt',
        sortOrder: 'desc',
        verified: '',
      };
      state.pagination.currentPage = 1;
    },
    
    // Set current page
    setReviewCurrentPage: (state, action) => {
      state.pagination.currentPage = action.payload;
    },
    
    // Set sort options
    setReviewSortOptions: (state, action) => {
      state.filters.sortBy = action.payload.sortBy;
      state.filters.sortOrder = action.payload.sortOrder;
      state.pagination.currentPage = 1;
    },
    
    // Clear current review
    clearCurrentReview: (state) => {
      state.currentReview = null;
    },
    
    // Clear product reviews
    clearProductReviews: (state) => {
      state.productReviews = [];
      state.reviewStats = null;
    },
    
    // Clear error
    clearReviewError: (state) => {
      state.error = null;
    },
    
    // Update review in list
    updateReviewInList: (state, action) => {
      const updatedReview = action.payload;
      
      // Update in product reviews
      const productIndex = state.productReviews.findIndex(r => r._id === updatedReview._id);
      if (productIndex !== -1) {
        state.productReviews[productIndex] = updatedReview;
      }
      
      // Update in user reviews
      const userIndex = state.userReviews.findIndex(r => r._id === updatedReview._id);
      if (userIndex !== -1) {
        state.userReviews[userIndex] = updatedReview;
      }
      
      // Update current review
      if (state.currentReview && state.currentReview._id === updatedReview._id) {
        state.currentReview = updatedReview;
      }
    },
    
    // Remove review from list
    removeReviewFromList: (state, action) => {
      const reviewId = action.payload;
      state.productReviews = state.productReviews.filter(r => r._id !== reviewId);
      state.userReviews = state.userReviews.filter(r => r._id !== reviewId);
      
      if (state.currentReview && state.currentReview._id === reviewId) {
        state.currentReview = null;
      }
    },
    
    // Add review to list
    addReviewToList: (state, action) => {
      const newReview = action.payload;
      state.productReviews.unshift(newReview);
      state.userReviews.unshift(newReview);
      state.pagination.totalReviews += 1;
    },
    
    // Reset reviews state
    resetReviews: (state) => {
      return initialState;
    },
    
    // Update helpful votes
    updateHelpfulVotes: (state, action) => {
      const { reviewId, helpfulCount, notHelpfulCount, userHelpfulVote } = action.payload;
      
      // Update in product reviews
      const productReview = state.productReviews.find(r => r._id === reviewId);
      if (productReview) {
        productReview.helpfulCount = helpfulCount;
        productReview.notHelpfulCount = notHelpfulCount;
        productReview.userHelpfulVote = userHelpfulVote;
      }
      
      // Update in user reviews
      const userReview = state.userReviews.find(r => r._id === reviewId);
      if (userReview) {
        userReview.helpfulCount = helpfulCount;
        userReview.notHelpfulCount = notHelpfulCount;
        userReview.userHelpfulVote = userHelpfulVote;
      }
    },
  },
  extraReducers: (builder) => {
    builder
      // Fetch product reviews
      .addCase(fetchProductReviews.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchProductReviews.fulfilled, (state, action) => {
        state.loading = false;
        state.productReviews = action.payload.reviews;
        state.reviewStats = action.payload.stats;
        state.pagination = action.payload.pagination;
        state.error = null;
      })
      .addCase(fetchProductReviews.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      
      // Fetch user reviews
      .addCase(fetchUserReviews.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchUserReviews.fulfilled, (state, action) => {
        state.loading = false;
        state.userReviews = action.payload.reviews;
        state.pagination = action.payload.pagination;
        state.error = null;
      })
      .addCase(fetchUserReviews.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      
      // Create review
      .addCase(createReview.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(createReview.fulfilled, (state, action) => {
        state.loading = false;
        const newReview = action.payload;
        state.productReviews.unshift(newReview);
        state.userReviews.unshift(newReview);
        state.error = null;
      })
      .addCase(createReview.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      
      // Update review
      .addCase(updateReview.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(updateReview.fulfilled, (state, action) => {
        state.loading = false;
        const updatedReview = action.payload;
        
        // Update in product reviews
        const productIndex = state.productReviews.findIndex(r => r._id === updatedReview._id);
        if (productIndex !== -1) {
          state.productReviews[productIndex] = updatedReview;
        }
        
        // Update in user reviews
        const userIndex = state.userReviews.findIndex(r => r._id === updatedReview._id);
        if (userIndex !== -1) {
          state.userReviews[userIndex] = updatedReview;
        }
        
        state.error = null;
      })
      .addCase(updateReview.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      
      // Delete review
      .addCase(deleteReview.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(deleteReview.fulfilled, (state, action) => {
        state.loading = false;
        const reviewId = action.payload;
        state.productReviews = state.productReviews.filter(r => r._id !== reviewId);
        state.userReviews = state.userReviews.filter(r => r._id !== reviewId);
        state.error = null;
      })
      .addCase(deleteReview.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })
      
      // Mark review as helpful
      .addCase(markReviewHelpful.fulfilled, (state, action) => {
        const { reviewId, helpfulCount, notHelpfulCount, userHelpfulVote } = action.payload;
        
        // Update in product reviews
        const productReview = state.productReviews.find(r => r._id === reviewId);
        if (productReview) {
          productReview.helpfulCount = helpfulCount;
          productReview.notHelpfulCount = notHelpfulCount;
          productReview.userHelpfulVote = userHelpfulVote;
        }
        
        // Update in user reviews
        const userReview = state.userReviews.find(r => r._id === reviewId);
        if (userReview) {
          userReview.helpfulCount = helpfulCount;
          userReview.notHelpfulCount = notHelpfulCount;
          userReview.userHelpfulVote = userHelpfulVote;
        }
      })
      .addCase(markReviewHelpful.rejected, (state, action) => {
        state.error = action.payload;
      })
      
      // Add vendor response
      .addCase(addVendorResponse.fulfilled, (state, action) => {
        const { reviewId, vendorResponse } = action.payload;
        
        // Update in product reviews
        const productReview = state.productReviews.find(r => r._id === reviewId);
        if (productReview) {
          productReview.vendorResponse = vendorResponse;
        }
        
        // Update in user reviews
        const userReview = state.userReviews.find(r => r._id === reviewId);
        if (userReview) {
          userReview.vendorResponse = vendorResponse;
        }
      })
      .addCase(addVendorResponse.rejected, (state, action) => {
        state.error = action.payload;
      })
      
      // Report review
      .addCase(reportReview.rejected, (state, action) => {
        state.error = action.payload;
      });
  },
});

// Export actions
export const {
  setReviewFilters,
  clearReviewFilters,
  setReviewCurrentPage,
  setReviewSortOptions,
  clearCurrentReview,
  clearProductReviews,
  clearReviewError,
  updateReviewInList,
  removeReviewFromList,
  addReviewToList,
  resetReviews,
  updateHelpfulVotes,
} = reviewSlice.actions;

// Selectors
export const selectReviews = (state) => state.reviews.reviews;
export const selectProductReviews = (state) => state.reviews.productReviews;
export const selectUserReviews = (state) => state.reviews.userReviews;
export const selectCurrentReview = (state) => state.reviews.currentReview;
export const selectReviewStats = (state) => state.reviews.reviewStats;
export const selectReviewPagination = (state) => state.reviews.pagination;
export const selectReviewFilters = (state) => state.reviews.filters;
export const selectReviewsLoading = (state) => state.reviews.loading;
export const selectReviewLoading = (state) => state.reviews.reviewLoading;
export const selectReviewsError = (state) => state.reviews.error;

// Complex selectors
export const selectReviewsByRating = (state) => {
  const reviews = state.reviews.productReviews;
  const grouped = { 1: [], 2: [], 3: [], 4: [], 5: [] };
  
  reviews.forEach(review => {
    if (grouped[review.rating]) {
      grouped[review.rating].push(review);
    }
  });
  
  return grouped;
};

export const selectAverageRating = (state) => {
  const reviews = state.reviews.productReviews;
  if (reviews.length === 0) return 0;
  
  const totalRating = reviews.reduce((sum, review) => sum + review.rating, 0);
  return (totalRating / reviews.length).toFixed(1);
};

export const selectRatingDistribution = (state) => {
  const reviews = state.reviews.productReviews;
  const distribution = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 };
  
  reviews.forEach(review => {
    distribution[review.rating]++;
  });
  
  const total = reviews.length;
  Object.keys(distribution).forEach(rating => {
    distribution[rating] = total > 0 ? (distribution[rating] / total) * 100 : 0;
  });
  
  return distribution;
};

export const selectVerifiedReviews = (state) => {
  return state.reviews.productReviews.filter(review => review.verified);
};

export const selectRecentReviews = (state) => {
  return state.reviews.productReviews
    .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
    .slice(0, 5);
};

export default reviewSlice.reducer;