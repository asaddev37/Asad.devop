import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ImageBackground } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { useNavigation } from '@react-navigation/native';
import { MaterialIcons } from '@expo/vector-icons';

const HomeScreen = () => {
  const navigation = useNavigation();

  return (
    <View style={styles.container}>
      <ImageBackground
        source={require('../assets/images/background.jpg')}
        style={styles.backgroundImage}
        resizeMode="cover"
      >
        <LinearGradient
          colors={['rgba(0,0,0,0.7)', 'rgba(0,0,0,0.9)']}
          style={styles.overlay}
        >
          <View style={styles.content}>
            <Text style={styles.title}>Welcome to Portfolio Pro</Text>
            <Text style={styles.subtitle}>
              Create and showcase your professional portfolio with ease
            </Text>
            
            <View style={styles.featuresContainer}>
              {[
                { icon: 'person', text: 'Professional Profiles' },
                { icon: 'work', text: 'Project Showcase' },
                { icon: 'school', text: 'Education & Skills' },
                { icon: 'share', text: 'Share with the World' },
              ].map((feature, index) => (
                <View key={index} style={styles.featureItem}>
                  <MaterialIcons name={feature.icon} size={24} color="#4caf50" />
                  <Text style={styles.featureText}>{feature.text}</Text>
                </View>
              ))}
            </View>

            <View style={styles.buttonContainer}>
              <TouchableOpacity
                style={[styles.button, styles.loginButton]}
                // @ts-ignore
                onPress={() => navigation.navigate('Login')}
              >
                <Text style={styles.buttonText}>Login</Text>
              </TouchableOpacity>
              
              <TouchableOpacity
                style={[styles.button, styles.signupButton]}
                // @ts-ignore
                onPress={() => navigation.navigate('Signup')}
              >
                <Text style={[styles.buttonText, styles.signupButtonText]}>Sign Up</Text>
              </TouchableOpacity>
            </View>
          </View>
        </LinearGradient>
      </ImageBackground>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  backgroundImage: {
    flex: 1,
    width: '100%',
  },
  overlay: {
    flex: 1,
    padding: 20,
    justifyContent: 'center',
  },
  content: {
    alignItems: 'center',
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 15,
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 16,
    color: 'rgba(255, 255, 255, 0.8)',
    textAlign: 'center',
    marginBottom: 40,
    paddingHorizontal: 20,
  },
  featuresContainer: {
    width: '100%',
    marginBottom: 40,
  },
  featureItem: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    padding: 15,
    borderRadius: 10,
    marginBottom: 10,
  },
  featureText: {
    color: '#fff',
    marginLeft: 15,
    fontSize: 16,
  },
  buttonContainer: {
    width: '100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: 20,
  },
  button: {
    flex: 1,
    padding: 15,
    borderRadius: 30,
    alignItems: 'center',
    marginHorizontal: 5,
  },
  loginButton: {
    backgroundColor: '#4caf50',
  },
  signupButton: {
    backgroundColor: 'transparent',
    borderWidth: 1,
    borderColor: '#4caf50',
  },
  buttonText: {
    color: '#fff',
    fontWeight: 'bold',
    fontSize: 16,
  },
  signupButtonText: {
    color: '#4caf50',
  },
});

export default HomeScreen;
