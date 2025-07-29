import React, { useEffect, useRef } from 'react';
import { 
  View, 
  Text, 
  StyleSheet, 
  Image, 
  Animated, 
  Easing, 
  Dimensions, 
  StatusBar,
  SafeAreaView
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { useNavigation } from '@react-navigation/native';
import { useTheme } from '../../contexts/ThemeContext';
import { images } from '../../utils/assets';

const { width, height } = Dimensions.get('window');

const styles = StyleSheet.create({
  gradient: {
    ...StyleSheet.absoluteFillObject,
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  logoContainer: {
    marginBottom: 40,
    alignItems: 'center',
  },
  logo: {
    width: 120,
    height: 120,
    marginBottom: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 10,
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 16,
    textAlign: 'center',
    marginBottom: 30,
    opacity: 0.8,
  },
  progressContainer: {
    width: '80%',
    height: 8,
    backgroundColor: 'rgba(0,0,0,0.1)',
    borderRadius: 4,
    marginTop: 30,
    overflow: 'hidden',
  },
  progressBar: {
    height: '100%',
    backgroundColor: '#4A90E2',
    borderRadius: 4,
  },
  loadingText: {
    marginTop: 20,
    fontSize: 14,
    color: '#666',
  },
});

const LoadingScreen = () => {
  const { colors, isDark } = useTheme();
  const navigation = useNavigation();
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const progressAnim = useRef(new Animated.Value(0)).current;
  const scaleAnim = useRef(new Animated.Value(0.9)).current;
  
  // Create styles inside component to access theme colors
  const dynamicStyles = StyleSheet.create({
    container: {
      flex: 1,
      backgroundColor: colors.background || '#fff',
    },
    title: {
      fontSize: 28,
      fontWeight: 'bold',
      marginBottom: 10,
      textAlign: 'center',
      color: colors.text || '#000',
    },
    subtitle: {
      fontSize: 16,
      textAlign: 'center',
      marginBottom: 30,
      opacity: 0.8,
      color: colors.text || '#666',
    },
    loadingText: {
      marginTop: 20,
      fontSize: 14,
      color: colors.text || '#666',
    },
  });

  // Animation for the loading screen
  useEffect(() => {
    // Parallel animations
    Animated.parallel([
      // Fade in animation
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 1000,
        useNativeDriver: true,
      }),
      // Scale animation
      Animated.spring(scaleAnim, {
        toValue: 1,
        friction: 5,
        useNativeDriver: true,
      }),
      // Progress bar animation
      Animated.timing(progressAnim, {
        toValue: 1,
        duration: 3000, // Match the loading time in _layout.js
        easing: Easing.out(Easing.ease),
        useNativeDriver: false,
      })
    ]).start();
  }, []); 

  const progressWidth = progressAnim.interpolate({
    inputRange: [0, 1],
    outputRange: ['0%', '100%'],
  });

  // Gradient colors based on theme
  const gradientColors = isDark 
    ? ['#1a237e', '#283593', '#3949ab'] 
    : ['#2196F3', '#1976D2', '#0D47A1'];

  return (
    <SafeAreaView style={dynamicStyles.container}>
      <StatusBar 
        barStyle={isDark ? 'light-content' : 'dark-content'} 
        backgroundColor="transparent" 
        translucent 
      />
      <LinearGradient
        colors={isDark 
          ? ['#1a237e', '#283593', '#3949ab']
          : ['#4A90E2', '#6BB9F0', '#8ED1FC']
        }
        style={styles.gradient}
      />
      <View style={styles.content}>
        <Animated.View 
          style={[
            styles.logoContainer,
            {
              opacity: fadeAnim,
              transform: [{ scale: scaleAnim }]
            }
          ]}
        >
          <Image 
            source={images.logo} 
            style={styles.logo} 
            resizeMode="contain"
          />
          <Text style={dynamicStyles.title}>Weather App</Text>
          <Text style={[dynamicStyles.subtitle, { color: 'rgba(255,255,255,0.9)' }]}>
            Loading your weather information...
          </Text>
        </Animated.View>
        
        <View style={styles.progressContainer}>
          <Animated.View 
            style={[
              styles.progressBar,
              {
                width: progressWidth,
                backgroundColor: isDark ? '#90caf9' : '#1565c0'
              }
            ]} 
          />
        </View>
        
        <Text style={[dynamicStyles.loadingText, { color: 'rgba(255,255,255,0.9)' }]}>
          Preparing your forecast...
        </Text>
      </View>
    </SafeAreaView>
  );
};

export default LoadingScreen;
