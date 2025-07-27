import { useEffect, useState } from 'react';
import { View, StyleSheet, StatusBar as RNStatusBar } from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { useFonts, SpaceMono_400Regular } from '@expo-google-fonts/space-mono';
import { Drawer } from 'expo-router/drawer';
import { TaskProvider } from '@/contexts/TaskContext';
import { ThemeProvider, useTheme } from '@/contexts/ThemeContext';
import { UserProvider } from '@/contexts/UserContext';
import { DrawerContent } from '@/components/DrawerContent';
import { ThemedView } from '@/components/ThemedView';
import { ThemedText } from '@/components/ThemedText';
import { Ionicons } from '@expo/vector-icons';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { useColorScheme } from 'react-native';

// Main content will be rendered by the Slot component in the Drawer

function LoadingScreen({ onAnimationComplete }: { onAnimationComplete: () => void }) {
  useEffect(() => {
    const timer = setTimeout(() => {
      onAnimationComplete();
    }, 5000);

    return () => clearTimeout(timer);
  }, []);

  return (
    <ThemedView style={styles.loadingContainer}>
      <StatusBar style="light" />
      <ThemedText style={styles.loadingText}>Loading...</ThemedText>
    </ThemedView>
  );
}

function AppContent() {
  const [isLoadingComplete, setIsLoadingComplete] = useState(false);
  const [fontsLoaded] = useFonts({
    SpaceMono: SpaceMono_400Regular,
  });

  if (!fontsLoaded) {
    return null;
  }

  if (!isLoadingComplete) {
    return <LoadingScreen onAnimationComplete={() => setIsLoadingComplete(true)} />;
  }

  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <ThemeProvider>
        <UserProvider>
        <TaskProvider>
          <Drawer
            drawerContent={DrawerContent}
            screenOptions={{
              headerShown: true,
              headerStyle: {
                backgroundColor: '#4F46E5',
              },
              headerTintColor: '#fff',
              headerTitleStyle: {
                fontWeight: 'bold',
              },
              drawerActiveTintColor: '#4F46E5',
              drawerInactiveTintColor: '#333',
              drawerActiveBackgroundColor: '#EEF2FF',
              drawerInactiveBackgroundColor: 'transparent',
              drawerLabelStyle: {
                marginLeft: -20,
                fontSize: 15,
              },
              drawerType: 'front',
              overlayColor: 'rgba(0,0,0,0.3)'
            }}
          >
            <Drawer.Screen
              name="(tabs)"
              options={{
                title: 'TaskMaster',
                headerTitle: 'TaskMaster',
                drawerIcon: ({ color, size }) => (
                  <Ionicons name="home-outline" size={size} color={color} style={styles.drawerIcon} />
                ),
              }}
            />
            <Drawer.Screen
              name="settings"
              options={{
                title: 'Settings',
                drawerIcon: ({ color, size }) => (
                  <Ionicons name="settings-outline" size={size} color={color} style={styles.drawerIcon} />
                ),
              }}
            />
            <Drawer.Screen
              name="about"
              options={{
                title: 'About',
                drawerIcon: ({ color, size }) => (
                  <Ionicons name="information-circle-outline" size={size} color={color} style={styles.drawerIcon} />
                ),
              }}
            />
            <Drawer.Screen
              name="privacy"
              options={{
                title: 'Privacy Policy',
                drawerIcon: ({ color, size }) => (
                  <Ionicons name="shield-checkmark-outline" size={size} color={color} style={styles.drawerIcon} />
                ),
              }}
            />
          </Drawer>
        </TaskProvider>
        </UserProvider>
      </ThemeProvider>
    </GestureHandlerRootView>
  );
}

export default function RootLayout() {
  return (
    <>
      <StatusBar style="light" />
      <RNStatusBar barStyle="light-content" backgroundColor="#4F46E5" />
      <AppContent />
    </>
  );
}

const styles = StyleSheet.create({
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#4F46E5',
  },
  loadingText: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#fff',
  },
  screenContainer: {
    flex: 1,
    padding: 20,
    paddingTop: 40,
  },
  screenTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 20,
    color: '#1e293b',
  },
  aboutText: {
    fontSize: 16,
    lineHeight: 24,
    marginBottom: 20,
    color: '#475569',
  },
  versionText: {
    fontSize: 14,
    color: '#94a3b8',
    marginTop: 10,
  },
  privacyText: {
    fontSize: 16,
    lineHeight: 24,
    color: '#475569',
  },
  drawerIcon: {
    marginRight: -20,
  },
});
