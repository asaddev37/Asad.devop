import React, { useEffect } from 'react';
import { View, Text, StyleSheet, StatusBar } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { useNavigation } from '@react-navigation/native';
import * as Animatable from 'react-native-animatable';
import { MaterialIcons } from '@expo/vector-icons';

const LoadingScreen = () => {
  const navigation = useNavigation();

  useEffect(() => {
    const timer = setTimeout(() => {
      // @ts-ignore
      navigation.navigate('Home');
    }, 5000);

    return () => clearTimeout(timer);
  }, [navigation]);

  return (
    <LinearGradient
      colors={['#4c669f', '#3b5998', '#192f6a']}
      style={styles.container}
    >
      <StatusBar barStyle="light-content" />
      <View style={styles.logoContainer}>
        <Animatable.View
          animation="pulse"
          iterationCount="infinite"
          duration={2000}
        >
          <MaterialIcons name="person" size={80} color="#fff" />
        </Animatable.View>
        <Animatable.Text 
          animation="fadeIn" 
          style={styles.title}
        >
          Portfolio Pro
        </Animatable.Text>
        <Animatable.Text 
          animation="fadeIn" 
          delay={1000}
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

export default LoadingScreen;
