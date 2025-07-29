import React, { createContext, useState, useEffect } from 'react';
import { useColorScheme } from 'react-native';

export const ThemeContext = createContext();

export const ThemeProvider = ({ children }) => {
  const systemColorScheme = useColorScheme();
  const [theme, setTheme] = useState(systemColorScheme || 'light');
  const [userThemePreference, setUserThemePreference] = useState(null);

  // Update theme when user preferences or system theme changes
  useEffect(() => {
    if (userThemePreference === 'system' || !userThemePreference) {
      setTheme(systemColorScheme || 'light');
    } else {
      setTheme(userThemePreference);
    }
  }, [userThemePreference, systemColorScheme]);

  // Light theme colors
  const lightColors = {
    primary: '#4A90E2',
    secondary: '#FFFFFF',
    accent: '#FF7E5F',
    background: '#F5F7FA',
    card: '#FFFFFF',
    text: '#333333',
    border: '#E0E0E0',
    notification: '#FF3B30',
    success: '#34C759',
    warning: '#FF9500',
    error: '#FF3B30',
    info: '#007AFF',
    gradient: ['#4A90E2', '#6BB9F0', '#89CFF0'],
  };

  // Dark theme colors
  const darkColors = {
    primary: '#5DA8FF',
    secondary: '#1E1E1E',
    accent: '#FF8A65',
    background: '#121212',
    card: '#1E1E1E',
    text: '#F5F5F5',
    border: '#333333',
    notification: '#FF453A',
    success: '#30D158',
    warning: '#FF9F0A',
    error: '#FF453A',
    info: '#0A84FF',
    gradient: ['#1E3C72', '#2A5298', '#7DB9E8'],
  };

  const colors = theme === 'dark' ? darkColors : lightColors;

  // Common styles
  const commonStyles = {
    container: {
      flex: 1,
      backgroundColor: colors.background,
      padding: 16,
    },
    text: {
      color: colors.text,
      fontSize: 16,
    },
    heading: {
      color: colors.text,
      fontSize: 24,
      fontWeight: 'bold',
      marginBottom: 16,
    },
    subheading: {
      color: colors.text,
      fontSize: 18,
      fontWeight: '600',
      marginBottom: 12,
    },
    card: {
      backgroundColor: colors.card,
      borderRadius: 12,
      padding: 16,
      marginBottom: 16,
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 2 },
      shadowOpacity: 0.1,
      shadowRadius: 4,
      elevation: 2,
    },
    button: {
      backgroundColor: colors.primary,
      paddingVertical: 12,
      paddingHorizontal: 24,
      borderRadius: 8,
      alignItems: 'center',
      justifyContent: 'center',
    },
    buttonText: {
      color: '#FFFFFF',
      fontSize: 16,
      fontWeight: '600',
    },
    input: {
      backgroundColor: colors.card,
      borderColor: colors.border,
      borderWidth: 1,
      borderRadius: 8,
      padding: 12,
      color: colors.text,
      marginBottom: 16,
    },
  };

  // Current theme colors
  const currentColors = theme === 'dark' ? darkColors : lightColors;
  
  // For backward compatibility
  const contextValue = {
    // New structure
    theme,
    colors: currentColors,
    isDark: theme === 'dark',
    setThemePreference: setUserThemePreference,
    
    // Legacy structure (for backward compatibility)
    styles: commonStyles,
    toggleTheme: () => {
      setUserThemePreference(theme === 'dark' ? 'light' : 'dark');
    }
  };

  return (
    <ThemeContext.Provider value={contextValue}>
      {children}
    </ThemeContext.Provider>
  );
};

export const useTheme = () => {
  const context = React.useContext(ThemeContext);
  if (context === undefined) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  
  // Return colors, theme, and the setter function
  return {
    colors: context.colors,
    theme: context.theme,
    setThemePreference: context.setUserThemePreference
  };
};

export default ThemeContext;
