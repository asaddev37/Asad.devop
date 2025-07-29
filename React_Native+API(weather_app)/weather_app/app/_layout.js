import { useRouter } from 'expo-router';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import { ThemeProvider, useTheme } from '../contexts/ThemeContext';
import { UserProvider, useUser } from '../contexts/UserContext';
import { useEffect, useState } from 'react';
import LoadingScreen from './screens/LoadingScreen';
import HomeScreen from './screens/HomeScreen';
import { View, StyleSheet } from 'react-native';

// Wrapper component to ensure theme is available
function ThemedApp() {
  const { colors } = useTheme();
  
  return (
    <View style={[styles.container, { backgroundColor: colors.background }]}>
      <StatusBar style="auto" />
      <AppContent />
    </View>
  );
}

// Main app content with loading logic
function AppContent() {
  const { user, isLoading } = useUser();
  const [isAppReady, setIsAppReady] = useState(false);

  // Initial app loading
  useEffect(() => {
    const timer = setTimeout(() => {
      setIsAppReady(true);
    }, 3000); // Show loading screen for 3 seconds

    return () => clearTimeout(timer);
  }, []);

  // Show loading screen while app is loading
  if (!isAppReady || isLoading) {
    return <LoadingScreen />;
  }

  // After loading, show the HomeScreen
  return <HomeScreen />;
}

// Root layout with providers
export default function RootLayout() {
  return (
    <SafeAreaProvider>
      <ThemeProvider>
        <UserProvider>
          <ThemedApp />
        </UserProvider>
      </ThemeProvider>
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});
