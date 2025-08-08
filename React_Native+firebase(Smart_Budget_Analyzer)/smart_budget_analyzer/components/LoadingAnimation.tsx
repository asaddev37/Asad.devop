import React from 'react';
import { View, StyleSheet, Text, ViewStyle, TextStyle, useColorScheme } from 'react-native';
import LottieView from 'lottie-react-native';

interface LoadingAnimationProps {
  style?: ViewStyle;
  textStyle?: TextStyle;
  message?: string;
  size?: 'small' | 'medium' | 'large';
  type?: 'circular' | 'dots';
  color?: string;
  autoPlay?: boolean;
  loop?: boolean;
  fullScreen?: boolean;
  visible?: boolean;
}

/**
 * A reusable loading animation component using Lottie animations
 */
export function LoadingAnimation({
  style,
  textStyle,
  message = 'Loading...',
  size = 'medium',
  type = 'circular',
  color,
  autoPlay = true,
  loop = true,
  fullScreen = false,
  visible = true,
}: LoadingAnimationProps) {
  // Safely get color scheme with a default value
  const colorScheme = useColorScheme?.() || 'light';
  const isDarkMode = colorScheme === 'dark';

  // Determine animation size based on prop
  const getAnimationSize = () => {
    switch (size) {
      case 'small':
        return 60;
      case 'large':
        return 150;
      case 'medium':
      default:
        return 100;
    }
  };

  // Import animations directly from the assets folder
  const dotsLoading = require('../assets/animations/dots-loading.json');
  const loadingBlueGreen = require('../assets/animations/loading-blue-green.json');

  // Determine which animation to use
  const getAnimationSource = () => {
    if (type === 'dots') {
      return dotsLoading;
    }
    return loadingBlueGreen;
  };

  const containerStyle = [
    styles.container,
    fullScreen && styles.fullScreenContainer,
    style
  ];

  if (!visible) return null;

  return (
    <View style={containerStyle}>
      <LottieView
        source={getAnimationSource()}
        style={[styles.animation, { width: getAnimationSize(), height: getAnimationSize() }]}
        autoPlay={autoPlay}
        loop={loop}
      />
      {message ? (
        <Text style={[
          styles.text, 
          isDarkMode && styles.textDark,
          fullScreen && styles.fullScreenText,
          textStyle
        ]}>
          {message}
        </Text>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: 16,
  },
  fullScreenContainer: {
    flex: 1,
    backgroundColor: '#fff',
  },
  fullScreenText: {
    fontSize: 18,
    marginTop: 20,
    fontWeight: '500',
  },
  animation: {
    alignSelf: 'center',
  },
  text: {
    marginTop: 12,
    fontSize: 16,
    color: '#4A90E2',
    textAlign: 'center',
  },
  textDark: {
    color: '#6AB7FF',
  },
});