import React, { useEffect, useRef } from 'react';
import { View, Text, StyleSheet, Image, Animated, Easing } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { useTheme } from '../contexts/ThemeContext';

const LoadingScreen = () => {
  const { colors } = useTheme();
  const spinValue = useRef(new Animated.Value(0)).current;
  const progress = useRef(new Animated.Value(0)).current;
  const messages = [
    'Fetching weather data...',
    'Almost there...',
    'Preparing your forecast...',
  ];
  const [currentMessage, setCurrentMessage] = React.useState(messages[0]);
  const messageIndex = useRef(0);

  // Spin animation
  useEffect(() => {
    const spin = Animated.loop(
      Animated.timing(spinValue, {
        toValue: 1,
        duration: 2000,
        easing: Easing.linear,
        useNativeDriver: true,
      })
    );
    spin.start();

    // Progress animation
    Animated.timing(progress, {
      toValue: 1,
      duration: 10000, // Total loading time
      useNativeDriver: false,
    }).start();

    // Rotate messages
    const messageInterval = setInterval(() => {
      messageIndex.current = (messageIndex.current + 1) % messages.length;
      setCurrentMessage(messages[messageIndex.current]);
    }, 3000);

    return () => {
      spin.stop();
      clearInterval(messageInterval);
    };
  }, []);

  const spin = spinValue.interpolate({
    inputRange: [0, 1],
    outputRange: ['0deg', '360deg'],
  });

  const width = progress.interpolate({
    inputRange: [0, 1],
    outputRange: ['0%', '100%'],
  });

  return (
    <LinearGradient
      colors={[colors.background, colors.primary + '20']}
      style={[styles.container, { backgroundColor: colors.background }]}
      start={{ x: 0, y: 0 }}
      end={{ x: 1, y: 1 }}
    >
      <View style={[styles.content, { backgroundColor: colors.card || '#ffffff' }]}>
        <View style={styles.overlay} />
        <Animated.Image
          source={require('../assets/logo.png')}
          style={[
            styles.logo,
            {
              transform: [{ rotate: spin }],
            },
          ]}
          resizeMode="contain"
        />
        
        <Text style={[styles.title, { color: colors.primary }]}>
          Weather App
        </Text>
        
        <Text style={[styles.message, { color: colors.text }]}>
          {currentMessage}
        </Text>
        
        <View style={styles.progressBarContainer}>
          <Animated.View
            style={[
              styles.progressBar,
              { width, backgroundColor: colors.primary },
            ]}
          />
        </View>
        
        <View style={styles.footer}>
          <Text style={[styles.footerText, { color: colors.textSecondary }]}>
            Loading your weather data...
          </Text>
        </View>
      </View>
      <View style={styles.backgroundPattern} />
    </LinearGradient>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  content: {
    width: '85%',
    maxWidth: 400,
    alignItems: 'center',
    padding: 30,
    borderRadius: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.2,
    shadowRadius: 20,
    elevation: 10,
    zIndex: 2,
    position: 'relative',
    overflow: 'hidden',
  },
  overlay: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: 'rgba(255, 255, 255, 0.8)',
    zIndex: -1,
  },
  backgroundPattern: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: colors.primary + '10',
    opacity: 0.5,
    zIndex: 1,
  },
  logo: {
    width: 120,
    height: 120,
    marginBottom: 20,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    marginBottom: 20,
    textAlign: 'center',
    color: colors.primary,
    textShadowColor: 'rgba(0, 0, 0, 0.1)',
    textShadowOffset: { width: 1, height: 1 },
    textShadowRadius: 2,
  },
  message: {
    fontSize: 18,
    marginBottom: 30,
    textAlign: 'center',
    fontWeight: '500',
    color: colors.text,
  },
  progressBarContainer: {
    height: 6,
    width: '100%',
    backgroundColor: 'rgba(0, 0, 0, 0.1)',
    borderRadius: 3,
    overflow: 'hidden',
    marginBottom: 30,
  },
  progressBar: {
    height: '100%',
    borderRadius: 3,
  },
  footer: {
    marginTop: 20,
  },
  footerText: {
    fontSize: 14,
    fontWeight: '500',
    opacity: 0.9,
    color: colors.text,
  },
});

export default LoadingScreen;
