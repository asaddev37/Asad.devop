import React, { useState, useRef, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Animated,
  StatusBar,
  Dimensions,
  Alert,
  RefreshControl,
  Image,
  Modal,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { useAuth } from '../../src/contexts/AuthContext';
import { FirestoreService, Transaction, Budget, DashboardStats } from '../../src/services/firestoreService';
import * as SecureStore from 'expo-secure-store';
import { router } from 'expo-router';
import { Timestamp } from 'firebase/firestore';
import { DashboardCharts } from '../../components/charts/DashboardCharts';
import { LoadingOverlay } from '../../components/LoadingOverlay';
import { LoadingAnimation } from '../../components/LoadingAnimation';
import LottieView from 'lottie-react-native';
import { ExportService } from '../../src/services/exportService';

// Import loading animation
const loadingAnimation = require('../../assets/animations/loading-blue-green.json');

const { width } = Dimensions.get('window');
const { width: screenWidth, height: screenHeight } = Dimensions.get('window');

const BIOMETRIC_CREDENTIALS_KEY = 'biometric_credentials';
const BIOMETRIC_ENABLED_KEY = 'biometric_enabled';

export default function DashboardScreen() {
  const { signOut, user, userProfile, togglePrivacyMode } = useAuth();
  const [isDarkMode, setIsDarkMode] = useState(false);
  const [dashboardStats, setDashboardStats] = useState<DashboardStats | null>(null);
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [budgets, setBudgets] = useState<Budget[]>([]);
  const [loading, setLoading] = useState(true);
  const [isInitialLoad, setIsInitialLoad] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [showProfileModal, setShowProfileModal] = useState(false);
  const lottieRef = useRef<LottieView>(null);
  
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const slideAnim = useRef(new Animated.Value(30)).current;

  // Load dashboard data
  const loadDashboardData = async () => {
    if (!user?.uid) {
      setLoading(false);
      setIsInitialLoad(false);
      return;
    }
    
    try {
      setLoading(true);
      setRefreshing(true);
      
      // Load dashboard stats
      const stats = await FirestoreService.getDashboardStats(user.uid);
      if (stats) {
        setDashboardStats(stats);
        setTransactions(stats.recentTransactions || []);
      } else {
        console.log('No dashboard stats found');
        setDashboardStats(null);
        setTransactions([]);
      }
      
      // Load budgets
      const userBudgets = await FirestoreService.getBudgets(user.uid);
      setBudgets(userBudgets || []);
      
    } catch (error) {
      console.error('Error loading dashboard data:', error);
      Alert.alert('Error', 'Failed to load dashboard data. Please try again.');
      setDashboardStats(null);
      setTransactions([]);
      setBudgets([]);
    } finally {
      setLoading(false);
      setRefreshing(false);
      setIsInitialLoad(false);
    }
  };

  // Set initial load state when component mounts
  useEffect(() => {
    setIsInitialLoad(true);
    
    return () => {
      // Cleanup function if needed
    };
  }, []);
  
  // Calculate loading state
  const isLoading = loading || isInitialLoad || refreshing;

  // Real-time listeners
  useEffect(() => {
    let isMounted = true;
    
    const setupListeners = async () => {
      if (!user?.uid) {
        setLoading(false);
        return;
      }

      try {
        // Set up real-time dashboard stats listener
        const unsubscribeDashboardStats = FirestoreService.onDashboardStatsChange(user.uid, (newStats) => {
          if (isMounted) {
            setDashboardStats(newStats);
            setTransactions(newStats?.recentTransactions || []);
          }
        });

        // Set up real-time budgets listener
        const unsubscribeBudgets = FirestoreService.onBudgetsChange(user.uid, (newBudgets) => {
          if (isMounted) {
            setBudgets(newBudgets || []);
          }
        });

        // Initial data load
        await loadDashboardData();

        // Return cleanup function
        return () => {
          isMounted = false;
          unsubscribeDashboardStats();
          unsubscribeBudgets();
        };
      } catch (error) {
        console.error('Error setting up listeners:', error);
        if (isMounted) {
          setLoading(false);
          setRefreshing(false);
        }
      }
    };

    setupListeners();

    return () => {
      isMounted = false;
    };
  }, [user?.uid]);

  const handleLogout = async () => {
    try {
      await signOut();
      await SecureStore.deleteItemAsync(BIOMETRIC_CREDENTIALS_KEY);
      await SecureStore.deleteItemAsync(BIOMETRIC_ENABLED_KEY);
      router.replace('/home');
    } catch (error) {
      console.error('Error during logout:', error);
    }
  };

  const toggleTheme = () => {
    setIsDarkMode(!isDarkMode);
  };

  const handlePrivacyToggle = async () => {
    try {
      await togglePrivacyMode();
    } catch (error) {
      console.error('Error toggling privacy mode:', error);
    }
  };

  const shouldShowFinancialInfo = () => {
    return !userProfile?.privacyMode;
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await loadDashboardData();
    setRefreshing(false);
  };

  const quickActions = [
    { 
      icon: 'add-circle', 
      title: 'Add Transaction', 
      color: '#1e90ff',
      onPress: () => router.push('/dashboard/transactions')
    },
    { 
      icon: 'pie-chart', 
      title: 'View Budgets', 
      color: '#32cd32',
      onPress: () => router.push('/dashboard/budgets')
    },
    { 
      icon: 'analytics', 
      title: 'Analytics', 
      color: '#ff6b35',
      onPress: () => Alert.alert('Coming Soon', 'AI-powered analytics will be available in future updates!')
    },
    { 
      icon: 'settings', 
      title: 'Settings', 
      color: '#9c27b0',
      onPress: () => router.push('/dashboard/profile')
    }
  ];

  const formatCurrency = (amount: number) => {
    const currency = userProfile?.currency || 'USD';
    const symbol = currency === 'USD' ? '$' : currency === 'PKR' ? '₨' : currency === 'EUR' ? '€' : currency === 'GBP' ? '£' : '$';
    return `${symbol}${Math.abs(amount).toFixed(2)}`;
  };

  const formatDate = (timestamp: Timestamp) => {
    const date = timestamp.toDate();
    const now = new Date();
    const diffTime = Math.abs(now.getTime() - date.getTime());
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    
    if (diffDays === 1) return 'Today';
    if (diffDays === 2) return 'Yesterday';
    if (diffDays <= 7) return `${diffDays - 1} days ago`;
    return date.toLocaleDateString();
  };

  const getGreeting = () => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Good Morning! 👋';
    if (hour < 17) return 'Good Afternoon! 👋';
    return 'Good Evening! 👋';
  };

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
  }, []);

  const handleProfilePicturePress = () => {
    if (userProfile?.profilePicture) {
      setShowProfileModal(true);
    }
  };

  const closeProfileModal = () => {
    setShowProfileModal(false);
  };

  if (isLoading) {
    return (
      <View style={styles.dashboardLoadingContainer}>
        <LoadingAnimation
          type="dots"
          size="large"
          style={styles.loadingAnimation}
        />
      </View>
    );
  }

  return (
    <View style={[styles.container, isDarkMode && styles.darkContainer]}>
      <StatusBar 
        barStyle={isDarkMode ? "light-content" : "dark-content"} 
        backgroundColor="transparent" 
        translucent 
      />
      
      {/* Loading Overlay */}
      <LoadingOverlay 
        visible={loading && !refreshing} 
        message="Loading your financial dashboard..." 
        transparent={true}
        animationType="dots"
      />
      
      {/* Header */}
      <LinearGradient
        colors={isDarkMode ? ['#1a1a1a', '#2d2d2d'] : ['#4A90E2', '#357ABD']}
        style={styles.header}
      >
        <View style={styles.headerContent}>
          <View style={styles.userInfoContainer}>
            <TouchableOpacity 
              style={styles.userAvatarContainer}
              onPress={handleProfilePicturePress}
              activeOpacity={0.8}
            >
              {userProfile?.profilePicture ? (
                <Image source={{ uri: userProfile.profilePicture }} style={styles.userAvatar} />
              ) : (
                <View style={styles.userAvatarPlaceholder}>
                  <Text style={styles.userAvatarText}>
                    {userProfile?.fullName?.charAt(0)?.toUpperCase() || 'U'}
                  </Text>
                </View>
              )}
            </TouchableOpacity>
            <View style={styles.userTextContainer}>
              <Text style={styles.greeting}>{getGreeting()}</Text>
              <Text style={styles.userName}>{userProfile?.fullName || 'User'}</Text>
            </View>
          </View>
          <View style={styles.headerIcons}>
            <TouchableOpacity onPress={toggleTheme} style={styles.iconButton}>
              <Ionicons 
                name={isDarkMode ? "sunny" : "moon"} 
                size={24} 
                color="white" 
              />
            </TouchableOpacity>
            <TouchableOpacity onPress={handleLogout} style={styles.iconButton}>
              <Ionicons 
                name="log-out-outline" 
                size={24} 
                color="white" 
              />
            </TouchableOpacity>
          </View>
        </View>
      </LinearGradient>

      <ScrollView 
        style={styles.content}
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
      >
        <Animated.View
          style={[
            styles.contentContainer,
            {
              opacity: fadeAnim,
              transform: [{ translateY: slideAnim }],
            },
          ]}
        >
          {/* Balance Card */}
          <LinearGradient
            colors={['#4A90E2', '#357ABD']}
            style={styles.balanceCard}
          >
            <View style={styles.balanceHeader}>
              <Text style={styles.balanceLabel}>Total Balance</Text>
              <TouchableOpacity onPress={handlePrivacyToggle} style={styles.privacyButton}>
                <Ionicons 
                  name={shouldShowFinancialInfo() ? "eye" : "eye-off"} 
                  size={20} 
                  color="rgba(255, 255, 255, 0.8)" 
                />
              </TouchableOpacity>
            </View>
            
            {shouldShowFinancialInfo() ? (
              <>
                <Text style={styles.balanceAmount}>
                  {dashboardStats ? formatCurrency(dashboardStats.totalBalance) : '$0.00'}
                </Text>
                <View style={styles.balanceStats}>
                  <View style={styles.statItem}>
                    <Text style={styles.statLabel}>Income</Text>
                    <Text style={styles.statAmount}>
                      {dashboardStats ? formatCurrency(dashboardStats.totalIncome) : '$0.00'}
                    </Text>
                  </View>
                  <View style={styles.statDivider} />
                  <View style={styles.statItem}>
                    <Text style={styles.statLabel}>Expenses</Text>
                    <Text style={styles.statAmount}>
                      {dashboardStats ? formatCurrency(dashboardStats.totalExpenses) : '$0.00'}
                    </Text>
                  </View>
                </View>
              </>
            ) : (
              <>
                <Text style={styles.balanceAmount}>••••••</Text>
                <View style={styles.balanceStats}>
                  <View style={styles.statItem}>
                    <Text style={styles.statLabel}>Income</Text>
                    <Text style={styles.statAmount}>••••••</Text>
                  </View>
                  <View style={styles.statDivider} />
                  <View style={styles.statItem}>
                    <Text style={styles.statLabel}>Expenses</Text>
                    <Text style={styles.statAmount}>••••••</Text>
                  </View>
                </View>
                <Text style={styles.privacyMessage}>Tap the eye icon to show financial information</Text>
              </>
            )}
          </LinearGradient>

          {/* Quick Actions */}
          <View style={styles.section}>
            <Text style={[styles.sectionTitle, isDarkMode && styles.darkText]}>
              Quick Actions
            </Text>
            <View style={styles.quickActionsGrid}>
              {quickActions.map((action, index) => (
                <TouchableOpacity
                  key={index}
                  style={[styles.actionCard, { backgroundColor: action.color }]}
                  onPress={action.onPress}
                >
                  <Ionicons name={action.icon as any} size={24} color="white" />
                  <Text style={styles.actionTitle}>{action.title}</Text>
                </TouchableOpacity>
              ))}
            </View>
          </View>

          {/* Recent Transactions */}
          <View style={styles.section}>
            <View style={styles.sectionHeader}>
              <Text style={[styles.sectionTitle, isDarkMode && styles.darkText]}>
                Recent Transactions
              </Text>
              <TouchableOpacity onPress={() => router.push('/dashboard/transactions')}>
                <Text style={styles.viewAllText}>View All</Text>
              </TouchableOpacity>
            </View>
            
            <View style={styles.transactionsList}>
              {transactions.length > 0 ? (
                transactions.map((transaction) => (
                  <View key={transaction.id} style={[styles.transactionItem, isDarkMode && styles.darkTransactionItem]}>
                    <View style={styles.transactionIcon}>
                      <Ionicons 
                        name={transaction.amount > 0 ? "arrow-up-circle" : "arrow-down-circle"} 
                        size={24} 
                        color={transaction.amount > 0 ? "#32cd32" : "#ff6b35"} 
                      />
                    </View>
                    <View style={styles.transactionDetails}>
                      <Text style={[styles.transactionTitle, isDarkMode && styles.darkText]}>
                        {transaction.description}
                      </Text>
                      <Text style={[styles.transactionCategory, isDarkMode && styles.darkSubtext]}>
                        {transaction.category} • {formatDate(transaction.date)}
                      </Text>
                    </View>
                    <Text style={[
                      styles.transactionAmount,
                      { color: transaction.amount > 0 ? "#32cd32" : "#ff6b35" }
                    ]}>
                      {transaction.amount > 0 ? '+' : ''}{formatCurrency(transaction.amount)}
                    </Text>
                  </View>
                ))
              ) : (
                <View style={styles.emptyState}>
                  <Ionicons name="receipt-outline" size={48} color="#ccc" />
                  <Text style={[styles.emptyText, isDarkMode && styles.darkSubtext]}>
                    No transactions yet
                  </Text>
                  <Text style={[styles.emptySubtext, isDarkMode && styles.darkSubtext]}>
                    Add your first transaction to get started
                  </Text>
                </View>
              )}
            </View>
          </View>

          {/* Budget Progress */}
          {dashboardStats && dashboardStats.budgetProgress.length > 0 && (
            <View style={styles.section}>
              <Text style={[styles.sectionTitle, isDarkMode && styles.darkText]}>
                Budget Progress
              </Text>
              {dashboardStats.budgetProgress.map((budget, index) => (
                <View key={index} style={[styles.budgetCard, isDarkMode && styles.darkBudgetCard]}>
                  <View style={styles.budgetHeader}>
                    <Text style={[styles.budgetTitle, isDarkMode && styles.darkText]}>{budget.category}</Text>
                    <Text style={[styles.budgetAmount, isDarkMode && styles.darkText]}>
                      {formatCurrency(budget.spent)} / {formatCurrency(budget.budget)}
                    </Text>
                  </View>
                  <View style={[styles.progressBar, isDarkMode && { backgroundColor: '#444' }]}>
                    <View 
                      style={[
                        styles.progressFill, 
                        { 
                          width: `${Math.min(budget.percentage, 100)}%`,
                          backgroundColor: budget.percentage > 90 ? '#ff6b35' : 
                                          budget.percentage > 75 ? '#ffa726' : 
                                          budget.percentage > 50 ? '#4A90E2' : '#32cd32'
                        }
                      ]} 
                    />
                  </View>
                  <Text style={[styles.budgetStatus, isDarkMode && styles.darkSubtext]}>
                    {budget.percentage.toFixed(0)}% used • {formatCurrency(budget.budget - budget.spent)} remaining
                  </Text>
                </View>
              ))}
            </View>
          )}

          {/* Data Visualization Charts */}
          <DashboardCharts 
            transactions={transactions}
            dashboardStats={dashboardStats}
            isDarkMode={isDarkMode}
            shouldShowFinancialInfo={shouldShowFinancialInfo()}
          />

          {/* AI Features Coming Soon */}
          <View style={styles.section}>
            <Text style={[styles.sectionTitle, isDarkMode && styles.darkText]}>
              AI-Powered Insights
            </Text>
            <View style={[styles.aiCard, isDarkMode && styles.darkAiCard]}>
              <Ionicons name="sparkles" size={32} color="#1e90ff" />
              <Text style={[styles.aiTitle, isDarkMode && styles.darkText]}>
                Smart Analytics Coming Soon
              </Text>
              <Text style={[styles.aiDescription, isDarkMode && styles.darkSubtext]}>
                AI-powered spending insights, predictive alerts, and smart categorization will be available in future updates!
              </Text>
            </View>
          </View>
        </Animated.View>
      </ScrollView>

      {/* Profile Picture Full Screen Modal */}
      <Modal
        visible={showProfileModal}
        transparent={true}
        animationType="fade"
        onRequestClose={closeProfileModal}
      >
        <View style={styles.modalOverlay}>
          <TouchableOpacity 
            style={styles.modalBackground} 
            onPress={closeProfileModal}
            activeOpacity={1}
          >
            <View style={styles.modalContent}>
              <TouchableOpacity 
                style={styles.closeButton}
                onPress={closeProfileModal}
              >
                <Ionicons name="close" size={30} color="#fff" />
              </TouchableOpacity>
              <Image 
                source={{ uri: userProfile?.profilePicture }} 
                style={styles.fullScreenImage}
                resizeMode="contain"
              />
            </View>
          </TouchableOpacity>
        </View>
      </Modal>
    </View>
  );
};

const styles = StyleSheet.create({
  dashboardLoadingContainer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.8)',
  },
  dashboardLoadingText: {
    marginTop: 10,
    fontSize: 16,
    color: '#666',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f8f9fa',
  },
  loadingAnimation: {
    width: 200,
    height: 200,
  },
  loadingText: {
    marginTop: 20,
    fontSize: 16,
    color: '#666',
    fontWeight: '500',
  },
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  darkContainer: {
    backgroundColor: '#1a1a1a',
  },
  header: {
    paddingTop: 60,
    paddingBottom: 20,
    paddingHorizontal: 20,
  },
  headerContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  userInfoContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  userAvatarContainer: {
    width: 50,
    height: 50,
    borderRadius: 25,
    marginRight: 15,
    overflow: 'hidden',
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
  },
  userAvatar: {
    width: '100%',
    height: '100%',
  },
  userAvatarPlaceholder: {
    width: '100%',
    height: '100%',
    backgroundColor: '#1e90ff',
    justifyContent: 'center',
    alignItems: 'center',
  },
  userAvatarText: {
    color: 'white',
    fontSize: 20,
    fontWeight: 'bold',
  },
  userTextContainer: {
    flex: 1,
  },
  greeting: {
    fontSize: 16,
    color: 'rgba(255, 255, 255, 0.8)',
    marginBottom: 2,
  },
  userName: {
    fontSize: 20,
    fontWeight: 'bold',
    color: 'white',
  },
  headerIcons: {
    flexDirection: 'row',
    gap: 15,
  },
  iconButton: {
    padding: 8,
  },
  content: {
    flex: 1,
  },
  contentContainer: {
    padding: 20,
  },
  balanceCard: {
    backgroundColor: 'white',
    borderRadius: 20,
    padding: 25,
    marginBottom: 25,
    elevation: 5,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
  },
  balanceHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
  },
  privacyButton: {
    padding: 5,
  },
  privacyMessage: {
    fontSize: 12,
    color: '#666',
    textAlign: 'center',
    marginTop: 10,
    fontStyle: 'italic',
  },
  balanceLabel: {
    fontSize: 16,
    color: 'rgba(255, 255, 255, 0.8)',
    marginBottom: 10,
  },
  balanceAmount: {
    fontSize: 32,
    fontWeight: 'bold',
    color: 'white',
    marginBottom: 20,
  },
  balanceStats: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  statItem: {
    flex: 1,
    alignItems: 'center',
  },
  statLabel: {
    fontSize: 14,
    color: 'rgba(255, 255, 255, 0.8)',
    marginBottom: 5,
  },
  statAmount: {
    fontSize: 18,
    fontWeight: 'bold',
    color: 'white',
  },
  statDivider: {
    width: 1,
    backgroundColor: 'rgba(255, 255, 255, 0.5)',
    marginHorizontal: 20,
  },
  section: {
    marginBottom: 25,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 15,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
  },
  darkText: {
    color: '#fff',
  },
  viewAllText: {
    fontSize: 14,
    color: '#1e90ff',
    fontWeight: '600',
  },
  quickActionsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  actionCard: {
    width: (width - 60) / 2,
    backgroundColor: '#1e90ff',
    borderRadius: 15,
    padding: 20,
    marginBottom: 15,
    alignItems: 'center',
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
  },
  actionTitle: {
    color: 'white',
    fontSize: 14,
    fontWeight: '600',
    marginTop: 10,
    textAlign: 'center',
  },
  transactionsList: {
    backgroundColor: 'white',
    borderRadius: 15,
    overflow: 'hidden',
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
  },
  transactionItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 15,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  darkTransactionItem: {
    backgroundColor: '#2a2a2a',
    borderBottomColor: '#444',
  },
  transactionIcon: {
    marginRight: 15,
  },
  transactionDetails: {
    flex: 1,
  },
  transactionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginBottom: 5,
  },
  transactionCategory: {
    fontSize: 14,
    color: '#666',
  },
  darkSubtext: {
    color: '#ccc',
  },
  transactionAmount: {
    fontSize: 16,
    fontWeight: 'bold',
  },
  emptyState: {
    alignItems: 'center',
    padding: 40,
  },
  emptyText: {
    fontSize: 18,
    fontWeight: '600',
    color: '#666',
    marginTop: 15,
  },
  emptySubtext: {
    fontSize: 14,
    color: '#999',
    marginTop: 5,
    textAlign: 'center',
  },
  budgetCard: {
    backgroundColor: 'white',
    borderRadius: 15,
    padding: 20,
    marginBottom: 15,
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
  },
  darkBudgetCard: {
    backgroundColor: '#2a2a2a',
    shadowColor: '#000',
    shadowOpacity: 0.3,
    borderColor: '#444',
    borderWidth: 1,
  },
  budgetHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 15,
  },
  budgetTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
  },
  budgetAmount: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
  },
  progressBar: {
    height: 8,
    backgroundColor: '#f0f0f0',
    borderRadius: 4,
    marginBottom: 8,
  },
  progressFill: {
    height: '100%',
    borderRadius: 4,
  },
  budgetStatus: {
    fontSize: 12,
    color: '#666',
  },
  aiCard: {
    backgroundColor: 'white',
    borderRadius: 15,
    padding: 25,
    alignItems: 'center',
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
  },
  darkAiCard: {
    backgroundColor: '#2a2a2a',
    borderColor: '#444',
    borderWidth: 1,
    shadowColor: '#000',
    shadowOpacity: 0.3,
  },
  aiTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginTop: 15,
    marginBottom: 10,
  },
  aiDescription: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
    lineHeight: 20,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.9)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalBackground: {
    flex: 1,
    width: '100%',
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalContent: {
    width: '100%',
    height: '100%',
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
  },
  closeButton: {
    position: 'absolute',
    top: 50,
    right: 20,
    zIndex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    borderRadius: 20,
    padding: 10,
  },
  fullScreenImage: {
    width: screenWidth,
    height: screenHeight * 0.8,
  },
});