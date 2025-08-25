import axios from 'axios';
import { toast } from 'react-hot-toast';

// Create axios instance
const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:5000/api',
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    // Get token from localStorage
    const token = localStorage.getItem('token');
    
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    
    // Add timestamp to prevent caching for GET requests
    if (config.method === 'get') {
      config.params = {
        ...config.params,
        _t: Date.now(),
      };
    }
    
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle errors
api.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    const { response, request, message } = error;
    
    // Network error
    if (!response) {
      if (request) {
        toast.error('Network error. Please check your connection.');
      } else {
        toast.error('Request failed. Please try again.');
      }
      return Promise.reject(error);
    }
    
    const { status, data } = response;
    
    // Handle different error status codes
    switch (status) {
      case 400:
        // Bad request - usually validation errors
        if (data?.message) {
          toast.error(data.message);
        } else if (data?.errors && Array.isArray(data.errors)) {
          // Handle validation errors
          data.errors.forEach(err => {
            toast.error(err.message || err.msg || 'Validation error');
          });
        } else {
          toast.error('Invalid request. Please check your input.');
        }
        break;
        
      case 401:
        // Unauthorized - token expired or invalid
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        
        // Only show toast if not already on login page
        if (!window.location.pathname.includes('/login')) {
          toast.error('Session expired. Please login again.');
          // Redirect to login page
          window.location.href = '/login';
        }
        break;
        
      case 403:
        // Forbidden - insufficient permissions
        toast.error('Access denied. You don\'t have permission to perform this action.');
        break;
        
      case 404:
        // Not found
        if (data?.message) {
          toast.error(data.message);
        } else {
          toast.error('Resource not found.');
        }
        break;
        
      case 409:
        // Conflict - usually duplicate data
        if (data?.message) {
          toast.error(data.message);
        } else {
          toast.error('Conflict. Resource already exists.');
        }
        break;
        
      case 422:
        // Unprocessable entity - validation errors
        if (data?.message) {
          toast.error(data.message);
        } else if (data?.errors) {
          Object.values(data.errors).forEach(err => {
            if (typeof err === 'string') {
              toast.error(err);
            } else if (err.message) {
              toast.error(err.message);
            }
          });
        } else {
          toast.error('Validation failed. Please check your input.');
        }
        break;
        
      case 429:
        // Too many requests
        toast.error('Too many requests. Please try again later.');
        break;
        
      case 500:
        // Internal server error
        toast.error('Server error. Please try again later.');
        break;
        
      case 502:
      case 503:
      case 504:
        // Server unavailable
        toast.error('Service temporarily unavailable. Please try again later.');
        break;
        
      default:
        // Generic error
        if (data?.message) {
          toast.error(data.message);
        } else {
          toast.error('An unexpected error occurred. Please try again.');
        }
    }
    
    return Promise.reject(error);
  }
);

// Helper functions for common API patterns

// Upload file with progress
export const uploadFile = async (file, onProgress = null) => {
  const formData = new FormData();
  formData.append('file', file);
  
  const config = {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  };
  
  if (onProgress) {
    config.onUploadProgress = (progressEvent) => {
      const percentCompleted = Math.round(
        (progressEvent.loaded * 100) / progressEvent.total
      );
      onProgress(percentCompleted);
    };
  }
  
  return api.post('/upload', formData, config);
};

// Upload multiple files
export const uploadFiles = async (files, onProgress = null) => {
  const formData = new FormData();
  
  files.forEach((file, index) => {
    formData.append(`files`, file);
  });
  
  const config = {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  };
  
  if (onProgress) {
    config.onUploadProgress = (progressEvent) => {
      const percentCompleted = Math.round(
        (progressEvent.loaded * 100) / progressEvent.total
      );
      onProgress(percentCompleted);
    };
  }
  
  return api.post('/upload/multiple', formData, config);
};

// Download file
export const downloadFile = async (url, filename) => {
  try {
    const response = await api.get(url, {
      responseType: 'blob',
    });
    
    // Create blob link to download
    const blob = new Blob([response.data]);
    const link = document.createElement('a');
    link.href = window.URL.createObjectURL(blob);
    link.download = filename;
    
    // Trigger download
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    
    // Clean up
    window.URL.revokeObjectURL(link.href);
    
    return response;
  } catch (error) {
    toast.error('Failed to download file');
    throw error;
  }
};

// Retry failed requests
export const retryRequest = async (requestConfig, maxRetries = 3, delay = 1000) => {
  let lastError;
  
  for (let i = 0; i <= maxRetries; i++) {
    try {
      return await api(requestConfig);
    } catch (error) {
      lastError = error;
      
      // Don't retry on client errors (4xx)
      if (error.response && error.response.status >= 400 && error.response.status < 500) {
        throw error;
      }
      
      // Don't retry on last attempt
      if (i === maxRetries) {
        break;
      }
      
      // Wait before retrying
      await new Promise(resolve => setTimeout(resolve, delay * Math.pow(2, i)));
    }
  }
  
  throw lastError;
};

// Batch requests
export const batchRequests = async (requests, batchSize = 5) => {
  const results = [];
  
  for (let i = 0; i < requests.length; i += batchSize) {
    const batch = requests.slice(i, i + batchSize);
    const batchPromises = batch.map(request => api(request));
    
    try {
      const batchResults = await Promise.allSettled(batchPromises);
      results.push(...batchResults);
    } catch (error) {
      console.error('Batch request failed:', error);
      throw error;
    }
  }
  
  return results;
};

// Cancel token for request cancellation
export const createCancelToken = () => {
  return axios.CancelToken.source();
};

// Check if error is a cancel error
export const isCancelError = (error) => {
  return axios.isCancel(error);
};

// Health check
export const healthCheck = async () => {
  try {
    const response = await api.get('/health');
    return response.data;
  } catch (error) {
    console.error('Health check failed:', error);
    throw error;
  }
};

// Get API status
export const getApiStatus = async () => {
  try {
    const response = await api.get('/status');
    return response.data;
  } catch (error) {
    console.error('Failed to get API status:', error);
    throw error;
  }
};

// Clear auth token
export const clearAuthToken = () => {
  localStorage.removeItem('token');
  localStorage.removeItem('user');
  delete api.defaults.headers.common['Authorization'];
};

// Set auth token
export const setAuthToken = (token) => {
  if (token) {
    localStorage.setItem('token', token);
    api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
  } else {
    clearAuthToken();
  }
};

// Get current auth token
export const getAuthToken = () => {
  return localStorage.getItem('token');
};

// Check if user is authenticated
export const isAuthenticated = () => {
  const token = getAuthToken();
  return !!token;
};

// API endpoints object for better organization
export const endpoints = {
  // Auth endpoints
  auth: {
    register: '/auth/register',
    login: '/auth/login',
    logout: '/auth/logout',
    profile: '/auth/profile',
    updateProfile: '/auth/profile',
    changePassword: '/auth/change-password',
    forgotPassword: '/auth/forgot-password',
    resetPassword: '/auth/reset-password',
    verifyEmail: '/auth/verify-email',
    resendVerification: '/auth/resend-verification',
    refreshToken: '/auth/refresh-token',
  },
  
  // User endpoints
  users: {
    profile: '/users/profile',
    updateProfile: '/users/profile',
    addresses: '/users/addresses',
    orders: '/users/orders',
    wishlist: '/users/wishlist',
    reviews: '/users/reviews',
  },
  
  // Product endpoints
  products: {
    list: '/products',
    single: (id) => `/products/${id}`,
    create: '/products',
    update: (id) => `/products/${id}`,
    delete: (id) => `/products/${id}`,
    search: '/products/search',
    categories: '/products/categories',
    featured: '/products/featured',
    reviews: (id) => `/products/${id}/reviews`,
  },
  
  // Cart endpoints
  cart: {
    get: '/cart',
    add: '/cart/add',
    update: '/cart/update',
    remove: '/cart/remove',
    clear: '/cart/clear',
    sync: '/cart/sync',
  },
  
  // Order endpoints
  orders: {
    create: '/orders',
    list: '/orders',
    single: (id) => `/orders/${id}`,
    update: (id) => `/orders/${id}`,
    cancel: (id) => `/orders/${id}/cancel`,
    track: (id) => `/orders/${id}/track`,
  },
  
  // Vendor endpoints
  vendors: {
    list: '/vendors',
    single: (id) => `/vendors/${id}`,
    products: (id) => `/vendors/${id}/products`,
    apply: '/vendors/apply',
    dashboard: '/vendors/dashboard',
    orders: '/vendors/orders',
    statistics: '/vendors/statistics',
  },
  
  // Review endpoints
  reviews: {
    create: '/reviews',
    update: (id) => `/reviews/${id}`,
    delete: (id) => `/reviews/${id}`,
    helpful: (id) => `/reviews/${id}/helpful`,
    report: (id) => `/reviews/${id}/report`,
    response: (id) => `/reviews/${id}/response`,
  },
  
  // Payment endpoints
  payments: {
    createIntent: '/payments/create-intent',
    confirm: '/payments/confirm',
    webhook: '/payments/webhook',
    status: (id) => `/payments/status/${id}`,
    refund: '/payments/refund',
  },
  
  // Admin endpoints
  admin: {
    dashboard: '/admin/dashboard',
    analytics: '/admin/analytics',
    users: '/admin/users',
    products: '/admin/products',
    orders: '/admin/orders',
    vendors: '/admin/vendors',
    reviews: '/admin/reviews',
  },
  
  // Upload endpoints
  upload: {
    single: '/upload',
    multiple: '/upload/multiple',
    delete: '/upload/delete',
  },
};

export default api;