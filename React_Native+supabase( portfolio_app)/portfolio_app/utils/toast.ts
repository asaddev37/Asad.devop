import Toast from 'react-native-toast-message';

type ToastType = 'success' | 'error' | 'info' | 'default';

interface ShowToastParams {
  type?: ToastType;
  text1: string;
  text2?: string;
  position?: 'top' | 'bottom';
  visibilityTime?: number;
}

// Simple toast configuration
export const toastConfig = {
  success: (props: any) => ({
    style: { borderLeftColor: '#4CAF50', borderLeftWidth: 6 },
    contentContainerStyle: { paddingHorizontal: 15 },
    text1Style: {
      fontSize: 16,
      fontWeight: '600',
    },
    text2Style: {
      fontSize: 14,
      color: '#666',
    },
    ...props
  }),
  error: (props: any) => ({
    style: { borderLeftColor: '#F44336', borderLeftWidth: 6 },
    contentContainerStyle: { paddingHorizontal: 15 },
    text1Style: {
      fontSize: 16,
      fontWeight: '600',
    },
    text2Style: {
      fontSize: 14,
      color: '#666',
    },
    ...props
  }),
  info: (props: any) => ({
    style: { borderLeftColor: '#2196F3', borderLeftWidth: 6 },
    contentContainerStyle: { paddingHorizontal: 15 },
    text1Style: {
      fontSize: 16,
      fontWeight: '600',
    },
    text2Style: {
      fontSize: 14,
      color: '#666',
    },
    ...props
  })
};

/**
 * Helper function to show toast messages throughout the app
 * @param params - Toast configuration parameters
 */
export const showToast = (params: ShowToastParams) => {
  const {
    type = 'info',
    text1,
    text2,
    position = 'top',
    visibilityTime = 3000,
  } = params;

  Toast.show({
    type,
    text1,
    text2,
    position,
    visibilityTime,
    autoHide: true,
    topOffset: position === 'top' ? 50 : undefined,
    bottomOffset: position === 'bottom' ? 40 : undefined,
  });
};
