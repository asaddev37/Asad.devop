import React, { useEffect } from 'react';
import { View, Text, StyleSheet, Image, Animated, Easing } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { useNavigation } from '@react-navigation/native';
import { useTheme } from '../../contexts/ThemeContext';
import { images } from '../../utils/assets';

const LoadingScreen = () => {
  const { colors } = useTheme();
  const navigation = useNavigation();
  const fadeAnim = new Animated.Value(0);
  const progressAnim = new Animated.Value(0);

  // Animation for the loading screen
  useEffect(() => {
    // Fade in animation
    Animated.timing(fadeAnim, {
      toValue: 1,
      duration: 1000,
      useNativeDriver: true,
    }).start();

    // Progress bar animation
    Animated.timing(progressAnim, {
      toValue: 1,
      duration: 4000,
      useNativeDriver: false, // Must be false for width animation
    }).start();

    // Auto-navigate to MainTabs after 5 seconds
    const timer = setTimeout(() => {
      navigation.replace('MainTabs');
    }, 5000);

    return () => clearTimeout(timer);
  }, []); 

  const progressWidth = progressAnim.interpolate({
    inputRange: [0, 1],
    outputRange: ['0%', '100%'],
  });

  return (
    <View style={styles.container}>
      <LinearGradient
        colors={['#4c669f', '#3b5998', '#192f6a']}
        style={styles.gradient}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
      >
        <Animated.View style={[styles.content, { opacity: fadeAnim }]}>
          <Image 
            source={images.logo} 
            style={styles.logo}
            resizeMode="contain"
          />
          
          <Text style={styles.title}>Weather Forecast</Text>
          <Text style={styles.subtitle}>Loading your weather data...</Text>
          
          <View style={styles.loadingContainer}>
            <View style={styles.loadingBar}>
              <Animated.View 
                style={[styles.loadingProgress, { width: progressWidth }]} 
              />
            </View>
            <Text style={styles.loadingText}>Preparing your weather experience...</Text>
          </View>
        </Animated.View>
      </LinearGradient>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#4c669f', // Fallback color
  },
  gradient: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
    opacity: 1, // Ensure full opacity
  },
  content: {
    alignItems: 'center',
    width: '100%',
    maxWidth: 300,
  },
  logo: {
    width: 120,
    height: 120,
    marginBottom: 20,
    tintColor: '#fff',
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 15,
    textAlign: 'center',
    textShadowColor: 'rgba(0, 0, 0, 0.3)',
    textShadowOffset: { width: 1, height: 1 },
    textShadowRadius: 2,
  },
  subtitle: {
    fontSize: 18,
    color: 'rgba(255, 255, 255, 0.9)',
    marginBottom: 40,
    textAlign: 'center',
    fontWeight: '500',
  },
  loadingContainer: {
    width: '100%',
    alignItems: 'center',
    marginTop: 30,
  },
  loadingBar: {
    height: 8,
    width: '100%',
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    borderRadius: 4,
    overflow: 'hidden',
    marginBottom: 15,
  },
  loadingProgress: {
    height: '100%',
    backgroundColor: '#4CAF50',
    borderRadius: 4,
  },
  loadingText: {
    color: 'rgba(255, 255, 255, 0.7)',
    fontSize: 14,
  },
});

export default LoadingScreen;
