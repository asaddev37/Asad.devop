import React, { useState, useRef, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Animated,
  Dimensions,
  StatusBar,
  Modal,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { router } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';

const { width, height } = Dimensions.get('window');

const HomeScreen = () => {
  const [isDarkMode, setIsDarkMode] = useState(false);
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);
  const [currentSlide, setCurrentSlide] = useState(0);
  const slideAnim = useRef(new Animated.Value(0)).current;
  const fadeAnim = useRef(new Animated.Value(0)).current;

  const carouselData = [
    {
      icon: '📊',
      title: 'Smart Analytics',
      description: 'Get AI-powered insights into your spending patterns.',
      color: '#1e90ff',
    },
    {
      icon: '🎯',
      title: 'Budget Goals',
      description: 'Set personalized budgets and track your progress.',
      color: '#32cd32',
    },
    {
      icon: '💰',
      title: 'Expense Tracking',
      description: 'Easily log and categorize all your transactions.',
      color: '#ff6b35',
    },
  ];

  useEffect(() => {
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 800,
        useNativeDriver: true,
      }),
      Animated.timing(slideAnim, {
        toValue: 0,
        duration: 800,
        useNativeDriver: true,
      }),
    ]).start();

    const interval = setInterval(() => {
      setCurrentSlide((prev) => (prev + 1) % carouselData.length);
    }, 3000);

    return () => clearInterval(interval);
  }, []);

  const toggleTheme = () => setIsDarkMode(!isDarkMode);
  const openDrawer = () => setIsDrawerOpen(true);
  const closeDrawer = () => setIsDrawerOpen(false);
  const navigateToAuth = (type: 'login' | 'signup') => {
    if (type === 'login') {
      router.push('/auth/login');
    } else {
      router.push('/auth/signup');
    }
  };

  return (
    <View style={[styles.container, isDarkMode && styles.darkContainer]}>
      <StatusBar 
        barStyle={isDarkMode ? "light-content" : "dark-content"} 
        backgroundColor="transparent" 
        translucent 
      />
      
      {/* App Bar */}
      <LinearGradient
        colors={['#1e90ff', '#32cd32']}
        style={styles.appBar}
      >
        <TouchableOpacity onPress={openDrawer} style={styles.menuButton}>
          <Ionicons name="menu" size={24} color="white" />
        </TouchableOpacity>
        
        <Text style={styles.appTitle}>SmartBudget Analyzer</Text>
        
        <TouchableOpacity onPress={toggleTheme} style={styles.themeButton}>
          <Ionicons 
            name={isDarkMode ? "sunny" : "moon"} 
            size={24} 
            color="white" 
          />
        </TouchableOpacity>
      </LinearGradient>

      {/* Main Content */}
      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        <Animated.View
          style={[
            styles.contentContainer,
            {
              opacity: fadeAnim,
              transform: [{ translateY: slideAnim }],
            },
          ]}
        >
          {/* Welcome Section */}
          <View style={styles.welcomeSection}>
            <Text style={[styles.welcomeTitle, isDarkMode && styles.darkText]}>
              Welcome to SmartBudget! 🎉
            </Text>
            <Text style={[styles.welcomeSubtitle, isDarkMode && styles.darkSubtext]}>
              Your personal finance companion powered by AI
            </Text>
          </View>

          {/* Carousel Section */}
          <View style={styles.carouselContainer}>
            <View style={styles.carousel}>
              {carouselData.map((item, index) => (
                <Animated.View
                  key={index}
                  style={[
                    styles.carouselItem,
                    {
                      backgroundColor: item.color,
                      transform: [{ scale: currentSlide === index ? 1 : 0.9 }],
                      opacity: currentSlide === index ? 1 : 0.7,
                    },
                  ]}
                >
                  <Text style={styles.carouselIcon}>{item.icon}</Text>
                  <Text style={styles.carouselTitle}>{item.title}</Text>
                  <Text style={styles.carouselDescription}>{item.description}</Text>
                </Animated.View>
              ))}
            </View>
            
            <View style={styles.indicators}>
              {carouselData.map((_, index) => (
                <View
                  key={index}
                  style={[
                    styles.indicator,
                    currentSlide === index && styles.activeIndicator,
                  ]}
                />
              ))}
            </View>
          </View>

          {/* CTA Section */}
          <View style={styles.ctaSection}>
            <Text style={[styles.ctaTitle, isDarkMode && styles.darkText]}>
              Ready to take control? 🚀
            </Text>
            
            <View style={styles.buttonContainer}>
              <TouchableOpacity
                style={[styles.button, styles.signupButton]}
                onPress={() => navigateToAuth('signup')}
              >
                <Text style={styles.buttonText}>Get Started</Text>
                <Ionicons name="arrow-forward" size={20} color="white" />
              </TouchableOpacity>
              
              <TouchableOpacity
                style={[styles.button, styles.loginButton]}
                onPress={() => navigateToAuth('login')}
              >
                <Text style={styles.loginButtonText}>I already have an account</Text>
              </TouchableOpacity>
            </View>
          </View>
        </Animated.View>
      </ScrollView>

      {/* Drawer Modal */}
      <Modal
        visible={isDrawerOpen}
        transparent={true}
        animationType="slide"
        onRequestClose={closeDrawer}
      >
        <View style={styles.drawerOverlay}>
          <TouchableOpacity
            style={styles.drawerBackdrop}
            onPress={closeDrawer}
            activeOpacity={1}
          />
          <View style={[styles.drawer, isDarkMode && styles.darkDrawer]}>
            <LinearGradient
              colors={['#1e90ff', '#32cd32']}
              style={styles.drawerHeader}
            >
              <Text style={styles.drawerTitle}>SmartBudget</Text>
              <Text style={styles.drawerSubtitle}>Menu</Text>
            </LinearGradient>
            
            <View style={styles.drawerContent}>
              <TouchableOpacity style={styles.drawerItem}>
                <Ionicons name="information-circle" size={24} color="#1e90ff" />
                <Text style={[styles.drawerItemText, isDarkMode && styles.darkText]}>
                  About
                </Text>
              </TouchableOpacity>
              
              <TouchableOpacity style={styles.drawerItem}>
                <Ionicons name="shield-checkmark" size={24} color="#1e90ff" />
                <Text style={[styles.drawerItemText, isDarkMode && styles.darkText]}>
                  Privacy Policy
                </Text>
              </TouchableOpacity>
              
              <TouchableOpacity style={styles.drawerItem}>
                <Ionicons name="mail" size={24} color="#1e90ff" />
                <Text style={[styles.drawerItemText, isDarkMode && styles.darkText]}>
                  Contact
                </Text>
              </TouchableOpacity>
            </View>
            
            <View style={styles.drawerFooter}>
              <Text style={[styles.footerText, isDarkMode && styles.darkSubtext]}>
                Made with ❤️ by AK~~37
              </Text>
            </View>
          </View>
        </View>
      </Modal>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  darkContainer: {
    backgroundColor: '#1a1a1a',
  },
  appBar: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 20,
    paddingTop: 50,
    paddingBottom: 15,
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
  },
  menuButton: {
    padding: 8,
  },
  appTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: 'white',
  },
  themeButton: {
    padding: 8,
  },
  content: {
    flex: 1,
  },
  contentContainer: {
    padding: 20,
  },
  welcomeSection: {
    alignItems: 'center',
    marginBottom: 30,
  },
  welcomeTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#333',
    textAlign: 'center',
    marginBottom: 10,
  },
  darkText: {
    color: '#fff',
  },
  welcomeSubtitle: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    lineHeight: 22,
  },
  darkSubtext: {
    color: '#ccc',
  },
  carouselContainer: {
    marginBottom: 40,
  },
  carousel: {
    height: 200,
    position: 'relative',
  },
  carouselItem: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    borderRadius: 20,
    padding: 30,
    justifyContent: 'center',
    alignItems: 'center',
    elevation: 5,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
  },
  carouselIcon: {
    fontSize: 40,
    marginBottom: 15,
  },
  carouselTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: 'white',
    marginBottom: 10,
    textAlign: 'center',
  },
  carouselDescription: {
    fontSize: 14,
    color: 'rgba(255, 255, 255, 0.9)',
    textAlign: 'center',
    lineHeight: 20,
  },
  indicators: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginTop: 20,
  },
  indicator: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: '#ddd',
    marginHorizontal: 4,
  },
  activeIndicator: {
    backgroundColor: '#1e90ff',
    width: 20,
  },
  ctaSection: {
    alignItems: 'center',
    marginBottom: 30,
  },
  ctaTitle: {
    fontSize: 22,
    fontWeight: 'bold',
    color: '#333',
    textAlign: 'center',
    marginBottom: 25,
  },
  buttonContainer: {
    width: '100%',
  },
  button: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 15,
    paddingHorizontal: 30,
    borderRadius: 25,
    marginBottom: 15,
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
  },
  signupButton: {
    backgroundColor: '#1e90ff',
  },
  loginButton: {
    backgroundColor: 'transparent',
    borderWidth: 2,
    borderColor: '#1e90ff',
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
    marginRight: 8,
  },
  loginButtonText: {
    color: '#1e90ff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  drawerOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
  },
  drawerBackdrop: {
    flex: 1,
  },
  drawer: {
    position: 'absolute',
    left: 0,
    top: 0,
    bottom: 0,
    width: 280,
    backgroundColor: 'white',
    elevation: 10,
    shadowColor: '#000',
    shadowOffset: { width: 2, height: 0 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
  },
  darkDrawer: {
    backgroundColor: '#2a2a2a',
  },
  drawerHeader: {
    paddingTop: 50,
    paddingBottom: 30,
    paddingHorizontal: 20,
  },
  drawerTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: 'white',
    marginBottom: 5,
  },
  drawerSubtitle: {
    fontSize: 16,
    color: 'rgba(255, 255, 255, 0.8)',
  },
  drawerContent: {
    flex: 1,
    paddingTop: 20,
  },
  drawerItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 15,
    paddingHorizontal: 20,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  drawerItemText: {
    fontSize: 16,
    color: '#333',
    marginLeft: 15,
  },
  drawerFooter: {
    padding: 20,
    borderTopWidth: 1,
    borderTopColor: '#f0f0f0',
  },
  footerText: {
    fontSize: 12,
    color: '#666',
    textAlign: 'center',
  },
});

export default HomeScreen; 