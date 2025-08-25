import { createSlice } from '@reduxjs/toolkit';

// Initial state
const initialState = {
  // Modal states
  modals: {
    authModal: {
      isOpen: false,
      mode: 'login', // 'login' | 'register' | 'forgot-password'
    },
    cartModal: {
      isOpen: false,
    },
    productModal: {
      isOpen: false,
      productId: null,
    },
    confirmModal: {
      isOpen: false,
      title: '',
      message: '',
      onConfirm: null,
      onCancel: null,
      confirmText: 'Confirm',
      cancelText: 'Cancel',
      type: 'default', // 'default' | 'danger' | 'warning'
    },
    imageModal: {
      isOpen: false,
      images: [],
      currentIndex: 0,
    },
    reviewModal: {
      isOpen: false,
      productId: null,
      orderId: null,
      review: null, // For editing existing review
    },
    addressModal: {
      isOpen: false,
      address: null, // For editing existing address
    },
    vendorApplicationModal: {
      isOpen: false,
    },
  },
  
  // Sidebar states
  sidebar: {
    isOpen: false,
    type: 'menu', // 'menu' | 'cart' | 'filters'
  },
  
  // Mobile menu
  mobileMenu: {
    isOpen: false,
  },
  
  // Search
  search: {
    isOpen: false,
    query: '',
    suggestions: [],
    recentSearches: [],
  },
  
  // Notifications
  notifications: [],
  
  // Loading states
  globalLoading: false,
  pageLoading: false,
  
  // Theme
  theme: 'light', // 'light' | 'dark' | 'system'
  
  // Layout
  layout: {
    headerHeight: 80,
    footerHeight: 200,
    sidebarWidth: 280,
  },
  
  // Scroll position
  scrollPosition: 0,
  
  // Page metadata
  pageTitle: 'ArtisanMart',
  pageDescription: 'Discover unique handcrafted products from talented artisans',
  
  // Filters panel (for mobile)
  filtersPanel: {
    isOpen: false,
  },
  
  // Toast notifications
  toasts: [],
  
  // Breadcrumbs
  breadcrumbs: [],
};

// UI slice
const uiSlice = createSlice({
  name: 'ui',
  initialState,
  reducers: {
    // Modal actions
    openAuthModal: (state, action) => {
      state.modals.authModal.isOpen = true;
      state.modals.authModal.mode = action.payload?.mode || 'login';
    },
    
    closeAuthModal: (state) => {
      state.modals.authModal.isOpen = false;
    },
    
    setAuthModalMode: (state, action) => {
      state.modals.authModal.mode = action.payload;
    },
    
    openCartModal: (state) => {
      state.modals.cartModal.isOpen = true;
    },
    
    closeCartModal: (state) => {
      state.modals.cartModal.isOpen = false;
    },
    
    openProductModal: (state, action) => {
      state.modals.productModal.isOpen = true;
      state.modals.productModal.productId = action.payload;
    },
    
    closeProductModal: (state) => {
      state.modals.productModal.isOpen = false;
      state.modals.productModal.productId = null;
    },
    
    openConfirmModal: (state, action) => {
      state.modals.confirmModal = {
        isOpen: true,
        title: action.payload.title || 'Confirm Action',
        message: action.payload.message || 'Are you sure?',
        onConfirm: action.payload.onConfirm || null,
        onCancel: action.payload.onCancel || null,
        confirmText: action.payload.confirmText || 'Confirm',
        cancelText: action.payload.cancelText || 'Cancel',
        type: action.payload.type || 'default',
      };
    },
    
    closeConfirmModal: (state) => {
      state.modals.confirmModal.isOpen = false;
    },
    
    openImageModal: (state, action) => {
      state.modals.imageModal = {
        isOpen: true,
        images: action.payload.images || [],
        currentIndex: action.payload.currentIndex || 0,
      };
    },
    
    closeImageModal: (state) => {
      state.modals.imageModal.isOpen = false;
      state.modals.imageModal.images = [];
      state.modals.imageModal.currentIndex = 0;
    },
    
    setImageModalIndex: (state, action) => {
      state.modals.imageModal.currentIndex = action.payload;
    },
    
    openReviewModal: (state, action) => {
      state.modals.reviewModal = {
        isOpen: true,
        productId: action.payload.productId || null,
        orderId: action.payload.orderId || null,
        review: action.payload.review || null,
      };
    },
    
    closeReviewModal: (state) => {
      state.modals.reviewModal.isOpen = false;
      state.modals.reviewModal.productId = null;
      state.modals.reviewModal.orderId = null;
      state.modals.reviewModal.review = null;
    },
    
    openAddressModal: (state, action) => {
      state.modals.addressModal = {
        isOpen: true,
        address: action.payload?.address || null,
      };
    },
    
    closeAddressModal: (state) => {
      state.modals.addressModal.isOpen = false;
      state.modals.addressModal.address = null;
    },
    
    openVendorApplicationModal: (state) => {
      state.modals.vendorApplicationModal.isOpen = true;
    },
    
    closeVendorApplicationModal: (state) => {
      state.modals.vendorApplicationModal.isOpen = false;
    },
    
    // Sidebar actions
    openSidebar: (state, action) => {
      state.sidebar.isOpen = true;
      state.sidebar.type = action.payload?.type || 'menu';
    },
    
    closeSidebar: (state) => {
      state.sidebar.isOpen = false;
    },
    
    toggleSidebar: (state, action) => {
      state.sidebar.isOpen = !state.sidebar.isOpen;
      if (action.payload?.type) {
        state.sidebar.type = action.payload.type;
      }
    },
    
    // Mobile menu actions
    openMobileMenu: (state) => {
      state.mobileMenu.isOpen = true;
    },
    
    closeMobileMenu: (state) => {
      state.mobileMenu.isOpen = false;
    },
    
    toggleMobileMenu: (state) => {
      state.mobileMenu.isOpen = !state.mobileMenu.isOpen;
    },
    
    // Search actions
    openSearch: (state) => {
      state.search.isOpen = true;
    },
    
    closeSearch: (state) => {
      state.search.isOpen = false;
      state.search.query = '';
      state.search.suggestions = [];
    },
    
    setSearchQuery: (state, action) => {
      state.search.query = action.payload;
    },
    
    setSearchSuggestions: (state, action) => {
      state.search.suggestions = action.payload;
    },
    
    addRecentSearch: (state, action) => {
      const query = action.payload;
      // Remove if already exists
      state.search.recentSearches = state.search.recentSearches.filter(s => s !== query);
      // Add to beginning
      state.search.recentSearches.unshift(query);
      // Keep only last 10
      state.search.recentSearches = state.search.recentSearches.slice(0, 10);
    },
    
    clearRecentSearches: (state) => {
      state.search.recentSearches = [];
    },
    
    // Notification actions
    addNotification: (state, action) => {
      const notification = {
        id: Date.now() + Math.random(),
        type: action.payload.type || 'info', // 'success' | 'error' | 'warning' | 'info'
        title: action.payload.title,
        message: action.payload.message,
        duration: action.payload.duration || 5000,
        timestamp: Date.now(),
      };
      state.notifications.push(notification);
    },
    
    removeNotification: (state, action) => {
      state.notifications = state.notifications.filter(n => n.id !== action.payload);
    },
    
    clearNotifications: (state) => {
      state.notifications = [];
    },
    
    // Loading actions
    setGlobalLoading: (state, action) => {
      state.globalLoading = action.payload;
    },
    
    setPageLoading: (state, action) => {
      state.pageLoading = action.payload;
    },
    
    // Theme actions
    setTheme: (state, action) => {
      state.theme = action.payload;
    },
    
    toggleTheme: (state) => {
      state.theme = state.theme === 'light' ? 'dark' : 'light';
    },
    
    // Layout actions
    setLayoutDimensions: (state, action) => {
      state.layout = { ...state.layout, ...action.payload };
    },
    
    // Scroll position
    setScrollPosition: (state, action) => {
      state.scrollPosition = action.payload;
    },
    
    // Page metadata
    setPageMetadata: (state, action) => {
      state.pageTitle = action.payload.title || state.pageTitle;
      state.pageDescription = action.payload.description || state.pageDescription;
    },
    
    // Filters panel
    openFiltersPanel: (state) => {
      state.filtersPanel.isOpen = true;
    },
    
    closeFiltersPanel: (state) => {
      state.filtersPanel.isOpen = false;
    },
    
    toggleFiltersPanel: (state) => {
      state.filtersPanel.isOpen = !state.filtersPanel.isOpen;
    },
    
    // Toast actions
    addToast: (state, action) => {
      const toast = {
        id: Date.now() + Math.random(),
        type: action.payload.type || 'info',
        message: action.payload.message,
        duration: action.payload.duration || 3000,
        timestamp: Date.now(),
      };
      state.toasts.push(toast);
    },
    
    removeToast: (state, action) => {
      state.toasts = state.toasts.filter(t => t.id !== action.payload);
    },
    
    clearToasts: (state) => {
      state.toasts = [];
    },
    
    // Breadcrumbs
    setBreadcrumbs: (state, action) => {
      state.breadcrumbs = action.payload;
    },
    
    addBreadcrumb: (state, action) => {
      state.breadcrumbs.push(action.payload);
    },
    
    clearBreadcrumbs: (state) => {
      state.breadcrumbs = [];
    },
    
    // Close all modals
    closeAllModals: (state) => {
      Object.keys(state.modals).forEach(modalKey => {
        if (typeof state.modals[modalKey] === 'object' && state.modals[modalKey].isOpen !== undefined) {
          state.modals[modalKey].isOpen = false;
        }
      });
    },
    
    // Reset UI state
    resetUIState: (state) => {
      return {
        ...initialState,
        theme: state.theme, // Preserve theme
        search: {
          ...initialState.search,
          recentSearches: state.search.recentSearches, // Preserve recent searches
        },
      };
    },
  },
});

// Export actions
export const {
  // Modal actions
  openAuthModal,
  closeAuthModal,
  setAuthModalMode,
  openCartModal,
  closeCartModal,
  openProductModal,
  closeProductModal,
  openConfirmModal,
  closeConfirmModal,
  openImageModal,
  closeImageModal,
  setImageModalIndex,
  openReviewModal,
  closeReviewModal,
  openAddressModal,
  closeAddressModal,
  openVendorApplicationModal,
  closeVendorApplicationModal,
  
  // Sidebar actions
  openSidebar,
  closeSidebar,
  toggleSidebar,
  
  // Mobile menu actions
  openMobileMenu,
  closeMobileMenu,
  toggleMobileMenu,
  
  // Search actions
  openSearch,
  closeSearch,
  setSearchQuery,
  setSearchSuggestions,
  addRecentSearch,
  clearRecentSearches,
  
  // Notification actions
  addNotification,
  removeNotification,
  clearNotifications,
  
  // Loading actions
  setGlobalLoading,
  setPageLoading,
  
  // Theme actions
  setTheme,
  toggleTheme,
  
  // Layout actions
  setLayoutDimensions,
  
  // Scroll position
  setScrollPosition,
  
  // Page metadata
  setPageMetadata,
  
  // Filters panel
  openFiltersPanel,
  closeFiltersPanel,
  toggleFiltersPanel,
  
  // Toast actions
  addToast,
  removeToast,
  clearToasts,
  
  // Breadcrumbs
  setBreadcrumbs,
  addBreadcrumb,
  clearBreadcrumbs,
  
  // Utility actions
  closeAllModals,
  resetUIState,
} = uiSlice.actions;

// Selectors

// Modal selectors
export const selectAuthModal = (state) => state.ui.modals.authModal;
export const selectCartModal = (state) => state.ui.modals.cartModal;
export const selectProductModal = (state) => state.ui.modals.productModal;
export const selectConfirmModal = (state) => state.ui.modals.confirmModal;
export const selectImageModal = (state) => state.ui.modals.imageModal;
export const selectReviewModal = (state) => state.ui.modals.reviewModal;
export const selectAddressModal = (state) => state.ui.modals.addressModal;
export const selectVendorApplicationModal = (state) => state.ui.modals.vendorApplicationModal;

// Sidebar selectors
export const selectSidebar = (state) => state.ui.sidebar;
export const selectMobileMenu = (state) => state.ui.mobileMenu;

// Search selectors
export const selectSearch = (state) => state.ui.search;
export const selectSearchQuery = (state) => state.ui.search.query;
export const selectSearchSuggestions = (state) => state.ui.search.suggestions;
export const selectRecentSearches = (state) => state.ui.search.recentSearches;

// Notification selectors
export const selectNotifications = (state) => state.ui.notifications;

// Loading selectors
export const selectGlobalLoading = (state) => state.ui.globalLoading;
export const selectPageLoading = (state) => state.ui.pageLoading;

// Theme selectors
export const selectTheme = (state) => state.ui.theme;

// Layout selectors
export const selectLayout = (state) => state.ui.layout;
export const selectScrollPosition = (state) => state.ui.scrollPosition;

// Page metadata selectors
export const selectPageTitle = (state) => state.ui.pageTitle;
export const selectPageDescription = (state) => state.ui.pageDescription;

// Filters panel selectors
export const selectFiltersPanel = (state) => state.ui.filtersPanel;

// Toast selectors
export const selectToasts = (state) => state.ui.toasts;

// Breadcrumbs selectors
export const selectBreadcrumbs = (state) => state.ui.breadcrumbs;

// Complex selectors
export const selectIsAnyModalOpen = (state) => {
  return Object.values(state.ui.modals).some(modal => 
    typeof modal === 'object' && modal.isOpen === true
  );
};

export const selectActiveModals = (state) => {
  const activeModals = [];
  Object.entries(state.ui.modals).forEach(([key, modal]) => {
    if (typeof modal === 'object' && modal.isOpen === true) {
      activeModals.push(key);
    }
  });
  return activeModals;
};

export const selectUnreadNotifications = (state) => {
  return state.ui.notifications.filter(notification => !notification.read);
};

export const selectRecentToasts = (state) => {
  const now = Date.now();
  return state.ui.toasts.filter(toast => 
    now - toast.timestamp < toast.duration
  );
};

export default uiSlice.reducer;