import { View, StyleSheet, Animated, Dimensions, Image } from 'react-native';
import { useEffect, useRef } from 'react';
import { router } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { ThemedText } from '@/components/ThemedText';

const { width, height } = Dimensions.get('window');

export default function LoadingScreen() {
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const slideUp = useRef(new Animated.Value(50)).current;
  const pulseAnim = useRef(new Animated.Value(1)).current;

  useEffect(() => {
    // Pulse animation
    Animated.loop(
      Animated.sequence([
        Animated.timing(pulseAnim, {
          toValue: 1.1,
          duration: 800,
          useNativeDriver: true,
        }),
        Animated.timing(pulseAnim, {
          toValue: 1,
          duration: 800,
          useNativeDriver: true,
        }),
      ])
    ).start();

    // Fade in and slide up animation
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 1000,
        useNativeDriver: true,
      }),
      Animated.timing(slideUp, {
        toValue: 0,
        duration: 1000,
        useNativeDriver: true,
      }),
    ]).start(() => {
      // After animations complete, navigate to home
      setTimeout(() => {
        router.replace('/(tabs)');
      }, 1500);
    });
  }, []);

  return (
    <LinearGradient
      colors={['#4F46E5', '#7C3AED', '#A855F7']}
      style={styles.container}
      start={{ x: 0, y: 0 }}
      end={{ x: 1, y: 1 }}
    >
      <StatusBar style="light" />
      <Animated.View 
        style={[
          styles.logoContainer, 
          { 
            opacity: fadeAnim,
            transform: [{ translateY: slideUp }]
          }
        ]}
      >
        <Animated.View style={[styles.iconContainer, { transform: [{ scale: pulseAnim }] }]}>
          <Ionicons name="checkmark-done" size={80} color="white" />
        </Animated.View>
        
        <ThemedText style={styles.title}>TaskMaster</ThemedText>
        <ThemedText style={styles.subtitle}>Organize Your Life, One Task at a Time</ThemedText>
        
        <View style={styles.loadingContainer}>
          <View style={styles.loadingDots}>
            {[...Array(3)].map((_, i) => (
              <Animated.View
                key={i}
                style={[
                  styles.dot,
                  {
                    transform: [
                      {
                        scale: pulseAnim.interpolate({
                          inputRange: [1, 1.1],
                          outputRange: [1, 1.2],
                        }),
                      },
                    ],
                    opacity: pulseAnim.interpolate({
                      inputRange: [1, 1.1],
                      outputRange: [0.5, 1],
                    }),
                  },
                ]}
              />
            ))}
          </View>
          <ThemedText style={styles.loadingText}>Loading your tasks...</ThemedText>
        </View>
      </Animated.View>
      
      <View style={styles.footer}>
        <ThemedText style={styles.footerText}>© 2025 TaskMaster Pro</ThemedText>
        <View style={styles.socialIcons}>
          <Ionicons name="logo-twitter" size={20} color="rgba(255,255,255,0.7)" style={styles.icon} />
          <Ionicons name="logo-facebook" size={20} color="rgba(255,255,255,0.7)" style={styles.icon} />
          <Ionicons name="logo-instagram" size={20} color="rgba(255,255,255,0.7)" style={styles.icon} />
        </View>
      </View>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  logoContainer: {
    alignItems: 'center',
    width: '100%',
  },
  iconContainer: {
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    width: 120,
    height: 120,
    borderRadius: 60,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 20,
  },
  title: {
    fontSize: 36,
    fontWeight: 'bold',
    color: 'white',
    marginBottom: 8,
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 18,
    color: 'rgba(255, 255, 255, 0.9)',
    textAlign: 'center',
    marginBottom: 40,
    maxWidth: '80%',
  },
  loadingContainer: {
    alignItems: 'center',
    marginTop: 40,
  },
  loadingDots: {
    flexDirection: 'row',
    marginBottom: 10,
  },
  dot: {
    width: 10,
    height: 10,
    borderRadius: 5,
    backgroundColor: 'white',
    marginHorizontal: 5,
  },
  loadingText: {
    color: 'rgba(255, 255, 255, 0.8)',
    fontSize: 14,
    marginTop: 10,
  },
  footer: {
    position: 'absolute',
    bottom: 30,
    alignItems: 'center',
  },
  footerText: {
    color: 'rgba(255, 255, 255, 0.6)',
    fontSize: 12,
    marginBottom: 10,
  },
  socialIcons: {
    flexDirection: 'row',
  },
  icon: {
    marginHorizontal: 8,
  },
});
