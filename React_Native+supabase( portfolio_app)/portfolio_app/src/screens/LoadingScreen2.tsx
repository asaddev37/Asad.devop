import React, { useEffect } from 'react';
import { View, Text, StyleSheet, StatusBar } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { useNavigation } from '@react-navigation/native';
import * as Animatable from 'react-native-animatable';
import { MaterialIcons } from '@expo/vector-icons';
import { NavigationProps } from '../types/navigation';

const LoadingScreen2 = () => {
  const navigation = useNavigation<NavigationProps>();

  useEffect(() => {
    // Simulate loading time
    const timer = setTimeout(() => {
      // Navigate to Home screen after loading
      navigation.navigate('Home');
    }, 2000);

    return () => clearTimeout(timer);
  }, [navigation]);

  return (
    <LinearGradient colors={['#1a1a2e', '#16213e']} style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor="#1a1a2e" />
      <View style={styles.logoContainer}>
        <Animatable.View
          animation="bounceIn"
          duration={1500}
          iterationCount={1}
        >
          <MaterialIcons name="code" size={80} color="#4cc9f0" />
        </Animatable.View>
        <Animatable.Text 
          animation="fadeInUp" 
          duration={1500}
          style={styles.title}
        >
          Portfolio App
        </Animatable.Text>
        <Animatable.Text 
          animation="fadeInUp" 
          duration={1500}
          delay={500}
          style={styles.subtitle}
        >
          Showcase Your Work
        </Animatable.Text>
      </View>
    </LinearGradient>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  logoContainer: {
    alignItems: 'center',
  },
  title: {
    color: '#fff',
    fontSize: 32,
    fontWeight: 'bold',
    marginTop: 20,
  },
  subtitle: {
    color: 'rgba(255, 255, 255, 0.8)',
    fontSize: 18,
    marginTop: 10,
  },
});

export default LoadingScreen2;
