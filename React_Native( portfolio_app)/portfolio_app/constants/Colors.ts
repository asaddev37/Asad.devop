/**
 * Below are the colors that are used in the app. The colors are defined in the light and dark mode.
 * There are many other ways to style your app. For example, [Nativewind](https://www.nativewind.dev/), [Tamagui](https://tamagui.dev/), [unistyles](https://reactnativeunistyles.vercel.app), etc.
 */

const tintColorLight = '#6366f1'; // Modern indigo
const tintColorDark = '#fff';

export const Colors = {
  light: {
    text: '#1f2937', // Dark gray for better readability
    background: '#f9fafb', // Very light gray background
    tint: tintColorLight,
    tabIconDefault: '#9ca3af',
    tabIconSelected: tintColorLight,
    cardBackground: '#ffffff', // Pure white cards
    headerBackground: '#ffffff', // Clean white header
    gradientStart: '#667eea', // Beautiful blue
    gradientEnd: '#764ba2', // Purple
    accent: '#f59e0b', // Warm amber
    success: '#10b981', // Emerald green
    warning: '#f59e0b', // Amber
    error: '#ef4444', // Red
    border: '#e5e7eb', // Light gray border
    shadow: '#374151', // Dark gray shadow
    primary: '#6366f1', // Indigo primary
    secondary: '#8b5cf6', // Purple secondary
    tertiary: '#06b6d4', // Cyan tertiary
  },
  dark: {
    text: '#f9fafb',
    background: '#111827',
    tint: tintColorDark,
    tabIconDefault: '#6b7280',
    tabIconSelected: tintColorDark,
    cardBackground: '#1f2937',
    headerBackground: '#1f2937',
    gradientStart: '#1e40af',
    gradientEnd: '#7c3aed',
    accent: '#f59e0b',
    success: '#10b981',
    warning: '#f59e0b',
    error: '#ef4444',
    border: '#374151',
    shadow: '#000000',
    primary: '#6366f1',
    secondary: '#8b5cf6',
    tertiary: '#06b6d4',
  },
};
