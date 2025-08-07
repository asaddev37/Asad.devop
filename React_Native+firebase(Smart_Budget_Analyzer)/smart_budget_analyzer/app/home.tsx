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
  FlatList,
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
  const flatListRef = useRef<FlatList>(null);

  const carouselData = [
    {
      id: '1',
      icon: 'analytics',
      title: 'AI-Powered Analytics',
      description: 'Get intelligent insights into your spending patterns with machine learning algorithms that identify trends and provide personalized recommendations.',
      color: '#4A90E2',
      gradient: ['#4A90E2', '#357ABD'],
    },
    {
      id: '2',
      icon: 'shield-checkmark',
      title: 'Secure & Private',
      description: 'Bank-level security with end-to-end encryption. Your financial data is protected with biometric authentication and secure cloud storage.',
      color: '#50C878',
      gradient: ['#50C878', '#3CB371'],
    },
    {
      id: '3',
      icon: 'trending-up',
      title: 'Smart Budgeting',
      description: 'Set personalized budgets with AI-driven suggestions. Track your progress in real-time and receive smart alerts when you approach limits.',
      color: '#FF6B35',
      gradient: ['#FF6B35', '#E55A2B'],
    },
    {
      id: '4',
      icon: 'sync',
      title: 'Real-Time Sync',
      description: 'Access your financial data anywhere, anytime. Automatic synchronization across all your devices with offline support.',
      color: '#9C27B0',
      gradient: ['#9C27B0', '#7B1FA2'],
    },
    {
      id: '5',
      icon: 'people',
      title: 'Multi-User Support',
      description: 'Perfect for families and roommates. Share budgets, track shared expenses, and manage household finances together.',
      color: '#FF9800',
      gradient: ['#FF9800', '#F57C00'],
    },
  ];

  const flashCards = [
    {
      id: '1',
      icon: 'calculator',
      title: 'Expense Tracking',
      description: 'Log transactions with smart categorization and detailed analytics',
      color: '#2196F3',
    },
    {
      id: '2',
      icon: 'pie-chart',
      title: 'Visual Reports',
      description: 'Beautiful charts and graphs to understand your spending habits',
      color: '#4CAF50',
    },
    {
      id: '3',
      icon: 'notifications',
      title: 'Smart Alerts',
      description: 'Get notified about budget limits, unusual spending, and savings opportunities',
      color: '#FF5722',
    },
    {
      id: '4',
      icon: 'download',
      title: 'Export Data',
      description: 'Export your financial data in multiple formats for tax and analysis',
      color: '#9C27B0',
    },
    {
      id: '5',
      icon: 'lock-closed',
      title: 'Privacy Mode',
      description: 'Hide sensitive financial information with a single tap',
      color: '#607D8B',
    },
    {
      id: '6',
      icon: 'cloud-upload',
      title: 'Cloud Backup',
      description: 'Automatic backup to secure cloud storage with version history',
      color: '#00BCD4',
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
      setCurrentSlide((prev) => {
        const next = (prev + 1) % carouselData.length;
        flatListRef.current?.scrollToIndex({
          index: next,
          animated: true,
        });
        return next;
      });
    }, 4000);

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

  const renderCarouselItem = ({ item, index }: { item: any; index: number }) => (
    <View style={styles.carouselItemContainer}>
      <LinearGradient
        colors={item.gradient}
        style={styles.carouselItem}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
      >
        <View style={styles.carouselIconContainer}>
          <Ionicons name={item.icon as any} size={48} color="white" />
        </View>
        <Text style={styles.carouselTitle}>{item.title}</Text>
        <Text style={styles.carouselDescription}>{item.description}</Text>
      </LinearGradient>
    </View>
  );

  const renderFlashCard = ({ item }: { item: any }) => (
    <View style={[styles.flashCard, { borderLeftColor: item.color }]}>
      <View style={[styles.flashCardIcon, { backgroundColor: item.color + '20' }]}>
        <Ionicons name={item.icon as any} size={24} color={item.color} />
      </View>
      <View style={styles.flashCardContent}>
        <Text style={styles.flashCardTitle}>{item.title}</Text>
        <Text style={styles.flashCardDescription}>{item.description}</Text>
      </View>
    </View>
  );

  return (
    <View style={[styles.container, isDarkMode && styles.darkContainer]}>
      <StatusBar 
        barStyle={isDarkMode ? "light-content" : "dark-content"} 
        backgroundColor="transparent" 
        translucent 
      />
      
      {/* App Bar */}
      <LinearGradient
        colors={['#4A90E2', '#357ABD']}
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
              Welcome to SmartBudget Analyzer
            </Text>
            <Text style={[styles.welcomeSubtitle, isDarkMode && styles.darkSubtext]}>
              Your intelligent personal finance companion
            </Text>
          </View>

          {/* Professional Carousel */}
          <View style={styles.carouselSection}>
            <Text style={[styles.sectionTitle, isDarkMode && styles.darkText]}>
              Why Choose SmartBudget?
            </Text>
            
            <View style={styles.carouselContainer}>
              <FlatList
                ref={flatListRef}
                data={carouselData}
                renderItem={renderCarouselItem}
                keyExtractor={(item) => item.id}
                horizontal
                pagingEnabled
                showsHorizontalScrollIndicator={false}
                onMomentumScrollEnd={(event) => {
                  const index = Math.round(event.nativeEvent.contentOffset.x / width);
                  setCurrentSlide(index);
                }}
                style={styles.carousel}
              />
              
              <View style={styles.indicators}>
                {carouselData.map((_, index) => (
                  <TouchableOpacity
                    key={index}
                    style={[
                      styles.indicator,
                      currentSlide === index && styles.activeIndicator,
                    ]}
                    onPress={() => {
                      setCurrentSlide(index);
                      flatListRef.current?.scrollToIndex({
                        index,
                        animated: true,
                      });
                    }}
                  />
                ))}
              </View>
            </View>
          </View>

          {/* Flash Cards Section */}
          <View style={styles.flashCardsSection}>
            <Text style={[styles.sectionTitle, isDarkMode && styles.darkText]}>
              Powerful Features
            </Text>
            
            <View style={styles.flashCardsGrid}>
              {flashCards.map((card) => (
                <View key={card.id} style={styles.flashCardWrapper}>
                  {renderFlashCard({ item: card })}
                </View>
              ))}
            </View>
          </View>

          {/* CTA Section */}
          <View style={styles.ctaSection}>
            <View style={styles.ctaCard}>
              <Ionicons name="rocket" size={48} color="#4A90E2" />
              <Text style={[styles.ctaTitle, isDarkMode && styles.darkText]}>
                Ready to Transform Your Finances?
              </Text>
              <Text style={[styles.ctaSubtitle, isDarkMode && styles.darkSubtext]}>
                Join thousands of users who have taken control of their financial future
              </Text>
              
              <View style={styles.buttonContainer}>
                <TouchableOpacity
                  style={[styles.button, styles.signupButton]}
                  onPress={() => navigateToAuth('signup')}
                >
                  <Text style={styles.buttonText}>Get Started Free</Text>
                  <Ionicons name="arrow-forward" size={20} color="white" />
                </TouchableOpacity>
                
                <TouchableOpacity
                  style={[styles.button, styles.loginButton]}
                  onPress={() => navigateToAuth('login')}
                >
                  <Text style={styles.loginButtonText}>Sign In</Text>
                </TouchableOpacity>
              </View>
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
          <Animated.View style={styles.drawer}>
            <View style={styles.drawerHeader}>
              <Text style={styles.drawerTitle}>Menu</Text>
              <TouchableOpacity onPress={closeDrawer}>
                <Ionicons name="close" size={24} color="#333" />
              </TouchableOpacity>
            </View>
            
            <View style={styles.drawerContent}>
              <TouchableOpacity 
                style={styles.drawerItem}
                onPress={() => {
                  closeDrawer();
                  router.push('/drawer/about');
                }}
              >
                <Ionicons name="information-circle" size={20} color="#666" />
                <Text style={styles.drawerItemText}>About</Text>
              </TouchableOpacity>
              
              <TouchableOpacity 
                style={styles.drawerItem}
                onPress={() => {
                  closeDrawer();
                  router.push('/drawer/privacy-policy');
                }}
              >
                <Ionicons name="shield-checkmark" size={20} color="#666" />
                <Text style={styles.drawerItemText}>Privacy Policy</Text>
              </TouchableOpacity>
              
              <TouchableOpacity 
                style={styles.drawerItem}
                onPress={() => {
                  closeDrawer();
                  router.push('/drawer/contact');
                }}
              >
                <Ionicons name="mail" size={20} color="#666" />
                <Text style={styles.drawerItemText}>Contact</Text>
              </TouchableOpacity>
              
              <TouchableOpacity 
                style={styles.drawerItem}
                onPress={() => {
                  closeDrawer();
                  router.push('/drawer/help');
                }}
              >
                <Ionicons name="help-circle" size={20} color="#666" />
                <Text style={styles.drawerItemText}>Help & Support</Text>
              </TouchableOpacity>
            </View>
            
            <View style={styles.drawerFooter}>
              <Text style={styles.drawerFooterText}>Made with ❤️ by AK~~37</Text>
            </View>
          </Animated.View>
        </View>
      </Modal>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F8F9FA',
  },
  darkContainer: {
    backgroundColor: '#1A1A1A',
  },
  appBar: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingTop: 60,
    paddingBottom: 20,
    paddingHorizontal: 20,
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
    color: '#FFFFFF',
  },
  welcomeSubtitle: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
  },
  darkSubtext: {
    color: '#CCCCCC',
  },
  carouselSection: {
    marginBottom: 40,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 20,
    textAlign: 'center',
  },
  carouselContainer: {
    height: 280,
  },
  carousel: {
    flex: 1,
  },
  carouselItemContainer: {
    width: width - 40,
    paddingHorizontal: 10,
  },
  carouselItem: {
    flex: 1,
    borderRadius: 20,
    padding: 30,
    justifyContent: 'center',
    alignItems: 'center',
    elevation: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
  },
  carouselIconContainer: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 20,
  },
  carouselTitle: {
    fontSize: 22,
    fontWeight: 'bold',
    color: 'white',
    textAlign: 'center',
    marginBottom: 15,
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
    backgroundColor: '#DDD',
    marginHorizontal: 4,
  },
  activeIndicator: {
    backgroundColor: '#4A90E2',
    width: 24,
  },
  flashCardsSection: {
    marginBottom: 40,
  },
  flashCardsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  flashCardWrapper: {
    width: '48%',
    marginBottom: 15,
  },
  flashCard: {
    backgroundColor: 'white',
    borderRadius: 15,
    padding: 20,
    borderLeftWidth: 4,
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  flashCardIcon: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  flashCardContent: {
    flex: 1,
  },
  flashCardTitle: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 6,
  },
  flashCardDescription: {
    fontSize: 12,
    color: '#666',
    lineHeight: 16,
  },
  ctaSection: {
    marginBottom: 30,
  },
  ctaCard: {
    backgroundColor: 'white',
    borderRadius: 20,
    padding: 30,
    alignItems: 'center',
    elevation: 6,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.2,
    shadowRadius: 6,
  },
  ctaTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    textAlign: 'center',
    marginTop: 15,
    marginBottom: 10,
  },
  ctaSubtitle: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    marginBottom: 25,
    lineHeight: 22,
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
    borderRadius: 12,
    marginBottom: 12,
  },
  signupButton: {
    backgroundColor: '#4A90E2',
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
    marginRight: 8,
  },
  loginButton: {
    backgroundColor: 'transparent',
    borderWidth: 2,
    borderColor: '#4A90E2',
  },
  loginButtonText: {
    color: '#4A90E2',
    fontSize: 16,
    fontWeight: '600',
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
    top: 0,
    left: 0,
    width: width * 0.8,
    height: height,
    backgroundColor: 'white',
    elevation: 10,
    shadowColor: '#000',
    shadowOffset: { width: 2, height: 0 },
    shadowOpacity: 0.3,
    shadowRadius: 10,
  },
  drawerHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 20,
    paddingTop: 60,
    borderBottomWidth: 1,
    borderBottomColor: '#F0F0F0',
  },
  drawerTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
  },
  drawerContent: {
    flex: 1,
    padding: 20,
  },
  drawerItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 15,
    borderBottomWidth: 1,
    borderBottomColor: '#F0F0F0',
  },
  drawerItemText: {
    fontSize: 16,
    color: '#333',
    marginLeft: 15,
  },
  drawerFooter: {
    padding: 20,
    borderTopWidth: 1,
    borderTopColor: '#F0F0F0',
  },
  drawerFooterText: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
  },
});

export default HomeScreen; 