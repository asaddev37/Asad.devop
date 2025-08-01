import React, { useEffect, useRef } from 'react';
import { View, StyleSheet, Animated, Dimensions } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { router } from 'expo-router';
import { ThemedText } from '@/components/ThemedText';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/useColorScheme';

const { width, height } = Dimensions.get('window');

export default function LoadingScreen() {
  const colorScheme = useColorScheme();
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const scaleAnim = useRef(new Animated.Value(0.8)).current;
  const rotateAnim = useRef(new Animated.Value(0)).current;
  const progressAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    // Start animations
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 1000,
        useNativeDriver: true,
      }),
      Animated.timing(scaleAnim, {
        toValue: 1,
        duration: 1000,
        useNativeDriver: true,
      }),
      Animated.timing(progressAnim, {
        toValue: 1,
        duration: 3000,
        useNativeDriver: false,
      }),
    ]).start();

    // Rotating animation for the icon
    Animated.loop(
      Animated.timing(rotateAnim, {
        toValue: 1,
        duration: 2000,
        useNativeDriver: true,
      })
    ).start();

    // Navigate to home after 3.5 seconds
    const timer = setTimeout(() => {
      router.replace('/(tabs)');
    }, 3500);

    return () => clearTimeout(timer);
  }, []);

  const spin = rotateAnim.interpolate({
    inputRange: [0, 1],
    outputRange: ['0deg', '360deg'],
  });

  const progressWidth = progressAnim.interpolate({
    inputRange: [0, 1],
    outputRange: ['0%', '100%'],
  });

  const colors = Colors[colorScheme ?? 'light'];

  return (
    <LinearGradient
      colors={
        colorScheme === 'dark'
          ? ['#1e40af', '#7c3aed', '#1e2937'] // Dark blue to purple to dark gray
          : ['#667eea', '#764ba2', '#f0f9ff'] // Light blue to purple to very light blue
      }
      style={styles.container}
    >
      <Animated.View
        style={[
          styles.content,
          {
            opacity: fadeAnim,
            transform: [{ scale: scaleAnim }],
          },
        ]}
      >
        {/* Logo/Icon */}
        <Animated.View
          style={[
            styles.iconContainer,
            {
              transform: [{ rotate: spin }],
            },
          ]}
        >
          <ThemedText style={styles.icon}>🚀</ThemedText>
        </Animated.View>

        {/* App Title */}
        <ThemedText style={[styles.title, { color: '#ffffff' }]}>
          Portfolio App
        </ThemedText>

        {/* Subtitle */}
        <ThemedText style={[styles.subtitle, { color: '#ffffff' }]}>
          Professional Developer Portfolio
        </ThemedText>

        {/* Loading Text */}
        <ThemedText style={[styles.loadingText, { color: '#ffffff' }]}>
          Loading amazing content...
        </ThemedText>

        {/* Progress Bar */}
        <View style={styles.progressContainer}>
          <View style={[styles.progressBar, { backgroundColor: 'rgba(255,255,255,0.3)' }]}>
            <Animated.View
              style={[
                styles.progressFill,
                {
                  width: progressWidth,
                  backgroundColor: '#ffffff',
                },
              ]}
            />
          </View>
        </View>

        {/* Loading Dots */}
        <View style={styles.dotsContainer}>
          <ThemedText style={[styles.dot, { color: '#ffffff' }]}>●</ThemedText>
          <ThemedText style={[styles.dot, { color: '#ffffff' }]}>●</ThemedText>
          <ThemedText style={[styles.dot, { color: '#ffffff' }]}>●</ThemedText>
        </View>
      </Animated.View>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  content: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  iconContainer: {
    marginBottom: 30,
  },
  icon: {
    fontSize: 80,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    marginBottom: 10,
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 18,
    marginBottom: 40,
    textAlign: 'center',
    opacity: 0.9,
  },
  loadingText: {
    fontSize: 16,
    marginBottom: 30,
    textAlign: 'center',
    opacity: 0.8,
  },
  progressContainer: {
    width: width * 0.7,
    marginBottom: 30,
  },
  progressBar: {
    height: 6,
    borderRadius: 3,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    borderRadius: 3,
  },
  dotsContainer: {
    flexDirection: 'row',
    gap: 8,
  },
  dot: {
    fontSize: 20,
    opacity: 0.7,
  },
}); 