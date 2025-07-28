import React from 'react';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import { ThemeProvider } from '../contexts/ThemeContext';
import { UserProvider } from '../contexts/UserContext';
import AppNavigator from './navigation/AppNavigator';

export default function RootLayout() {
  return (
    <SafeAreaProvider>
      <UserProvider>
        <ThemeProvider>
          <StatusBar style="auto" />
          <AppNavigator />
        </ThemeProvider>
      </UserProvider>
    </SafeAreaProvider>
  );
}
