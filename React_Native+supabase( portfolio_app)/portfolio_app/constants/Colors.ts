/**
 * Below are the colors that are used in the app. The colors are defined in the light and dark mode.
 * There are many other ways to style your app. For example, [Nativewind](https://www.nativewind.dev/), [Tamagui](https://tamagui.dev/), [unistyles](https://reactnativeunistyles.vercel.app), etc.
 */

const tintColorLight = '#667eea';
const tintColorDark = '#fff';

export const Colors = {
  light: {
    text: '#2c3e50',
    background: '#f8fafc',
    tint: tintColorLight,
    tabIconDefault: '#94a3b8',
    tabIconSelected: tintColorLight,
    cardBackground: '#ffffff',
    headerBackground: '#667eea',
    gradientStart: '#667eea',
    gradientEnd: '#764ba2',
    accent: '#f093fb',
    success: '#10b981',
    warning: '#f59e0b',
    error: '#ef4444',
    border: '#e2e8f0',
    shadow: '#1e293b',
  },
  dark: {
    text: '#f1f5f9',
    background: '#0f172a',
    tint: tintColorDark,
    tabIconDefault: '#64748b',
    tabIconSelected: tintColorDark,
    cardBackground: '#1e293b',
    headerBackground: '#1e293b',
    gradientStart: '#1a1a2e',
    gradientEnd: '#16213e',
    accent: '#f093fb',
    success: '#10b981',
    warning: '#f59e0b',
    error: '#ef4444',
    border: '#334155',
    shadow: '#000000',
  },
};
