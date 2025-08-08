import React from 'react';
import { View, StyleSheet, Text, ViewStyle, TextStyle } from 'react-native';
import LottieView from 'lottie-react-native';
import { useColorScheme } from '../hooks/useColorScheme';

interface LoadingAnimationProps {
  style?: ViewStyle;
  textStyle?: TextStyle;
  message?: string;
  size?: 'small' | 'medium' | 'large';
  type?: 'circular' | 'dots';
  color?: string;
  autoPlay?: boolean;
  loop?: boolean;
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
}: LoadingAnimationProps) {
  const colorScheme = useColorScheme();
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

  // Determine which animation to use
  const getAnimationSource = () => {
    if (type === 'dots') {
      return require('../assets/animations/dots-loading.json');
    }
    return require('../assets/animations/loading-blue-green.json');
  };

  return (
    <View style={[styles.container, style]}>
      <LottieView
        source={getAnimationSource()}
        style={[styles.animation, { width: getAnimationSize(), height: getAnimationSize() }]}
        autoPlay={autoPlay}
        loop={loop}
      />
      {message ? <Text style={[styles.text, isDarkMode && styles.textDark, textStyle]}>{message}</Text> : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: 16,
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