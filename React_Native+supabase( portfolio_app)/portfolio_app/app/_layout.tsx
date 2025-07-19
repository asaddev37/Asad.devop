import React, { useState, useEffect } from 'react';
import { View, StyleSheet, LogBox, useColorScheme, Text } from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { Stack, useRouter } from 'expo-router';
import { PaperProvider } from 'react-native-paper';
import { ThemeProvider as NavigationThemeProvider, DarkTheme as NavigationDarkTheme, DefaultTheme as NavigationDefaultTheme } from '@react-navigation/native';

import LoadingScreen from '@/components/LoadingScreen';
import { useAppTheme } from '@/hooks/useAppTheme';
import { AuthProvider, useAuth } from '@/contexts/AuthContext';

// Ignore specific warnings
LogBox.ignoreLogs([
  'Require cycle:',
  'Non-serializable values were found in the navigation state',
]);

// Simple error boundary component
class ErrorBoundary extends React.Component<{children: React.ReactNode}, {hasError: boolean, error?: Error}> {
  constructor(props: {children: React.ReactNode}) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('Error caught by ErrorBoundary:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <View style={styles.errorContainer}>
          <Text style={styles.errorTitle}>⚠️ App Crashed</Text>
          <Text style={styles.errorText}>
            {this.state.error?.message || 'An unexpected error occurred'}
          </Text>
          <Text style={styles.errorHelp}>
            Please close and reopen the app. If the problem continues, reinstall the app.
          </Text>
        </View>
      );
    }

    return this.props.children;
  }
}

// Main App Component
function App() {
  const [isLoading, setIsLoading] = useState(true);
  const router = useRouter();
  const colorScheme = useColorScheme();
  const { theme } = useAppTheme();
  const { initializing, user } = useAuth();
  const navigationTheme = colorScheme === 'dark' ? NavigationDarkTheme : NavigationDefaultTheme;

  useEffect(() => {
    if (!initializing) {
      // The navigation will now be handled by the LoadingScreen's onLoadingComplete callback
      // This effect will still handle the case where initializing becomes false before the loading screen completes
      const timer = setTimeout(() => {
        setIsLoading(false);
        if (!user) {
          router.replace('/(auth)/sign-in');
        } else {
          router.replace('/(tabs)');
        }
      }, 6000); // Slightly longer as a fallback

      return () => clearTimeout(timer);
    }
  }, [initializing, user]);

  if (isLoading || initializing) {
    return (
      <View style={styles.container}>
        <StatusBar style="auto" />
        <LoadingScreen onLoadingComplete={() => {
          setIsLoading(false);
          // Use a small timeout to ensure state updates are processed
          setTimeout(() => {
            if (!user) {
              // Navigate to sign-in screen
              router.replace('/(auth)/sign-in');
            } else {
              // Navigate to home tab
              router.replace('/(tabs)');
            }
          }, 100);
        }} />
      </View>
    );
  }

  // Use a simpler approach for the root layout
  return (
    <PaperProvider theme={theme}>
      <NavigationThemeProvider value={navigationTheme}>
        <Stack screenOptions={{
          headerShown: false,
          animation: 'fade',
          contentStyle: { backgroundColor: theme.colors.background },
        }}>
          {/* Use direct routes instead of route groups */}
          <Stack.Screen name="index" options={{ headerShown: false }} />
          <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
          <Stack.Screen name="(auth)/sign-in" options={{ headerShown: false }} />
          <Stack.Screen name="(auth)/sign-up" options={{ headerShown: false }} />
          <Stack.Screen name="(auth)/forgot-password" options={{ headerShown: false }} />
          <Stack.Screen name="+not-found" options={{ headerShown: false }} />
        </Stack>
        <StatusBar style={colorScheme === 'dark' ? 'light' : 'dark'} />
      </NavigationThemeProvider>
    </PaperProvider>
  );
}

// Styles
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  mainContent: {
    flex: 1,
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
    backgroundColor: '#fff',
  },
  errorTitle: {
    fontSize: 22,
    fontWeight: 'bold',
    marginBottom: 16,
    color: '#d32f2f',
  },
  errorText: {
    fontSize: 16,
    marginBottom: 24,
    textAlign: 'center',
    color: '#333',
    lineHeight: 24,
  },
  errorHelp: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
    lineHeight: 20,
  },
});

// Add a global error handler
if (typeof ErrorUtils !== 'undefined') {
  const originalErrorHandler = ErrorUtils.getGlobalHandler();
  ErrorUtils.setGlobalHandler((error: Error, isFatal?: boolean) => {
    console.error('Global Error Handler:', error, 'Fatal:', isFatal);
    if (originalErrorHandler) {
      originalErrorHandler(error, isFatal);
    }
  });
}

// Wrap the app with AuthProvider
export default function RootLayout() {
  return (
    <ErrorBoundary>
      <AuthProvider>
        <App />
      </AuthProvider>
    </ErrorBoundary>
  );
}
