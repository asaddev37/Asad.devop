import { configureStore } from '@reduxjs/toolkit';
import { persistStore, persistReducer } from 'redux-persist';
import storage from 'redux-persist/lib/storage';
import { combineReducers } from '@reduxjs/toolkit';

// Import slices
import authSlice from './slices/authSlice';
import cartSlice from './slices/cartSlice';
import productSlice from './slices/productSlice';
import orderSlice from './slices/orderSlice';
import vendorSlice from './slices/vendorSlice';
import reviewSlice from './slices/reviewSlice';
import adminSlice from './slices/adminSlice';
import uiSlice from './slices/uiSlice';

// Persist config
const persistConfig = {
  key: 'root',
  storage,
  whitelist: ['auth', 'cart'], // Only persist auth and cart
  blacklist: ['ui'], // Don't persist UI state
};

// Auth persist config (separate for sensitive data)
const authPersistConfig = {
  key: 'auth',
  storage,
  whitelist: ['user', 'token', 'isAuthenticated'], // Only persist essential auth data
};

// Cart persist config
const cartPersistConfig = {
  key: 'cart',
  storage,
  whitelist: ['items', 'totalItems', 'totalPrice'], // Persist cart items
};

// Root reducer
const rootReducer = combineReducers({
  auth: persistReducer(authPersistConfig, authSlice),
  cart: persistReducer(cartPersistConfig, cartSlice),
  products: productSlice,
  orders: orderSlice,
  vendors: vendorSlice,
  reviews: reviewSlice,
  admin: adminSlice,
  ui: uiSlice,
});

// Persisted reducer
const persistedReducer = persistReducer(persistConfig, rootReducer);

// Configure store
export const store = configureStore({
  reducer: persistedReducer,
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: {
        ignoredActions: [
          'persist/PERSIST',
          'persist/REHYDRATE',
          'persist/PAUSE',
          'persist/PURGE',
          'persist/REGISTER',
          'persist/FLUSH',
        ],
        ignoredActionsPaths: ['meta.arg', 'payload.timestamp'],
        ignoredPaths: ['items.dates'],
      },
      immutableCheck: {
        ignoredPaths: ['items.dates'],
      },
    }),
  devTools: process.env.NODE_ENV !== 'production',
});

// Persistor
export const persistor = persistStore(store);

// Types for TypeScript (if needed) - uncomment if converting to TypeScript
// export type RootState = ReturnType<typeof store.getState>;
// export type AppDispatch = typeof store.dispatch;

// Helper function to reset store
export const resetStore = () => {
  persistor.purge();
  store.dispatch({ type: 'RESET_STORE' });
};

// Helper function to get current state
export const getCurrentState = () => store.getState();

// Helper function to check if user is authenticated
export const isAuthenticated = () => {
  const state = store.getState();
  return state.auth.isAuthenticated && state.auth.token;
};

// Helper function to get user role
export const getUserRole = () => {
  const state = store.getState();
  return state.auth.user?.role || null;
};

// Helper function to get cart items count
export const getCartItemsCount = () => {
  const state = store.getState();
  return state.cart.totalItems || 0;
};

export default store;