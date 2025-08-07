import React, { useState, useRef, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Animated,
  StatusBar,
  Alert,
  TextInput,
  Modal,
  RefreshControl,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { useAuth } from '../../src/contexts/AuthContext';
import { FirestoreService, Budget, Category, Transaction } from '../../src/services/firestoreService';
import { router } from 'expo-router';
import { Timestamp } from 'firebase/firestore';

interface BudgetFormData {
  category: string;
  amount: string;
  startDate: Date;
  endDate: Date;
  alertThreshold: string;
}

const BudgetsScreen = () => {
  const { user, userProfile } = useAuth();
  const [budgets, setBudgets] = useState<Budget[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [showAddModal, setShowAddModal] = useState(false);
  const [editingBudget, setEditingBudget] = useState<Budget | null>(null);
  
  const [formData, setFormData] = useState<BudgetFormData>({
    category: '',
    amount: '',
    startDate: new Date(),
    endDate: new Date(new Date().setMonth(new Date().getMonth() + 1)),
    alertThreshold: '80',
  });

  const fadeAnim = useRef(new Animated.Value(0)).current;
  const slideAnim = useRef(new Animated.Value(50)).current;

  // Load budgets, categories, and transactions
  const loadData = async () => {
    if (!user?.uid) return;
    
    try {
      setLoading(true);
      
      // Load budgets
      const userBudgets = await FirestoreService.getBudgets(user.uid);
      setBudgets(userBudgets);
      
      // Load categories with fallback
      try {
        const userCategories = await FirestoreService.getCategories(user.uid);
        setCategories(userCategories);
      } catch (categoryError) {
        console.warn('Error loading categories, using defaults:', categoryError);
        // Use default categories as fallback
        setCategories(FirestoreService.getDefaultCategories());
      }
      
      // Load transactions for budget calculations
      const userTransactions = await FirestoreService.getTransactions(user.uid, 1000);
      setTransactions(userTransactions);
      
    } catch (error) {
      console.error('Error loading data:', error);
      Alert.alert('Error', 'Failed to load budgets');
    } finally {
      setLoading(false);
    }
  };

  // Real-time listeners
  useEffect(() => {
    if (!user?.uid) return;

    const unsubscribeBudgets = FirestoreService.onBudgetsChange(user.uid, (newBudgets) => {
      setBudgets(newBudgets);
    });

    const unsubscribeTransactions = FirestoreService.onTransactionsChange(user.uid, (newTransactions) => {
      setTransactions(newTransactions);
    });

    // Initial load
    loadData();

    return () => {
      unsubscribeBudgets();
      unsubscribeTransactions();
    };
  }, [user?.uid]);

  const onRefresh = async () => {
    setRefreshing(true);
    await loadData();
    setRefreshing(false);
  };

  const handleAddBudget = async () => {
    if (!user?.uid || !formData.category || !formData.amount) {
      Alert.alert('Error', 'Please fill in all required fields');
      return;
    }

    try {
      const amount = parseFloat(formData.amount);
      const alertThreshold = parseFloat(formData.alertThreshold);
      
      if (isNaN(amount) || amount <= 0) {
        Alert.alert('Error', 'Please enter a valid amount');
        return;
      }

      if (isNaN(alertThreshold) || alertThreshold < 0 || alertThreshold > 100) {
        Alert.alert('Error', 'Alert threshold must be between 0 and 100');
        return;
      }

      const budgetData = {
        userId: user.uid,
        category: formData.category,
        amount: amount,
        startDate: Timestamp.fromDate(formData.startDate),
        endDate: Timestamp.fromDate(formData.endDate),
        alertThreshold: alertThreshold,
      };

      if (editingBudget) {
        await FirestoreService.updateBudget(editingBudget.id!, budgetData);
      } else {
        await FirestoreService.createBudget(budgetData);
      }

      setShowAddModal(false);
      resetForm();
    } catch (error) {
      console.error('Error saving budget:', error);
      Alert.alert('Error', 'Failed to save budget');
    }
  };

  const handleDeleteBudget = async (budgetId: string) => {
    Alert.alert(
      'Delete Budget',
      'Are you sure you want to delete this budget?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            try {
              await FirestoreService.deleteBudget(budgetId);
            } catch (error) {
              console.error('Error deleting budget:', error);
              Alert.alert('Error', 'Failed to delete budget');
            }
          },
        },
      ]
    );
  };

  const handleEditBudget = (budget: Budget) => {
    setEditingBudget(budget);
    setFormData({
      category: budget.category,
      amount: budget.amount.toString(),
      startDate: budget.startDate.toDate(),
      endDate: budget.endDate.toDate(),
      alertThreshold: budget.alertThreshold.toString(),
    });
    setShowAddModal(true);
  };

  const resetForm = () => {
    setFormData({
      category: '',
      amount: '',
      startDate: new Date(),
      endDate: new Date(new Date().setMonth(new Date().getMonth() + 1)),
      alertThreshold: '80',
    });
    setEditingBudget(null);
  };

  const formatCurrency = (amount: number) => {
    const currency = userProfile?.currency || 'USD';
    const symbol = currency === 'USD' ? '$' : currency === 'PKR' ? '₨' : currency === 'EUR' ? '€' : currency === 'GBP' ? '£' : '$';
    return `${symbol}${Math.abs(amount).toFixed(2)}`;
  };

  const formatDate = (timestamp: Timestamp) => {
    const date = timestamp.toDate();
    return date.toLocaleDateString();
  };

  const calculateBudgetProgress = (budget: Budget) => {
    const budgetTransactions = transactions.filter(t => 
      t.category === budget.category && 
      t.amount < 0 && 
      t.date >= budget.startDate && 
      t.date <= budget.endDate
    );
    
    const spent = budgetTransactions.reduce((sum, t) => sum + Math.abs(t.amount), 0);
    const percentage = budget.amount > 0 ? (spent / budget.amount) * 100 : 0;
    
    return {
      spent,
      percentage: Math.min(percentage, 100),
      remaining: Math.max(budget.amount - spent, 0),
    };
  };

  const getProgressColor = (percentage: number, alertThreshold: number) => {
    if (percentage >= alertThreshold) return '#ff6b35';
    if (percentage >= 60) return '#ffa726';
    return '#32cd32';
  };

  const totalBudgeted = budgets.reduce((sum, budget) => sum + budget.amount, 0);
  const totalSpent = budgets.reduce((sum, budget) => {
    const progress = calculateBudgetProgress(budget);
    return sum + progress.spent;
  }, 0);

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

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <Text style={styles.loadingText}>Loading budgets...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <StatusBar barStyle="dark-content" backgroundColor="transparent" translucent />
      
      {/* Header */}
      <LinearGradient colors={['#4A90E2', '#357ABD']} style={styles.header}>
        <View style={styles.headerContent}>
          <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
            <Ionicons name="arrow-back" size={24} color="white" />
          </TouchableOpacity>
          <Text style={styles.headerTitle}>Budgets</Text>
          <TouchableOpacity onPress={() => setShowAddModal(true)} style={styles.addButton}>
            <Ionicons name="add" size={24} color="white" />
          </TouchableOpacity>
        </View>
      </LinearGradient>

      <ScrollView 
        style={styles.content}
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
          {/* Summary Cards */}
          <View style={styles.summaryContainer}>
            <View style={styles.summaryCard}>
              <Text style={styles.summaryLabel}>Total Budgeted</Text>
              <Text style={[styles.summaryAmount, { color: '#1e90ff' }]}>
                {formatCurrency(totalBudgeted)}
              </Text>
            </View>
            <View style={styles.summaryCard}>
              <Text style={styles.summaryLabel}>Total Spent</Text>
              <Text style={[styles.summaryAmount, { color: '#ff6b35' }]}>
                {formatCurrency(totalSpent)}
              </Text>
            </View>
          </View>

          {/* Budgets List */}
          <View style={styles.budgetsContainer}>
            <Text style={styles.sectionTitle}>Your Budgets</Text>
            
            {budgets.length > 0 ? (
              budgets.map((budget) => {
                const progress = calculateBudgetProgress(budget);
                const progressColor = getProgressColor(progress.percentage, budget.alertThreshold);
                
                return (
                  <View key={budget.id} style={styles.budgetCard}>
                    <View style={styles.budgetHeader}>
                      <View style={styles.budgetInfo}>
                        <View style={styles.budgetTitleContainer}>
                          {(() => {
                            const category = categories.find(cat => cat.name === budget.category);
                            if (category) {
                              return (
                                <View style={[
                                  styles.categoryIconContainer,
                                  { backgroundColor: category.color + '20' }
                                ]}>
                                  <Ionicons
                                    name={category.icon as any}
                                    size={18}
                                    color={category.color}
                                  />
                                </View>
                              );
                            }
                            return null;
                          })()}
                          <Text style={styles.budgetTitle}>{budget.category}</Text>
                        </View>
                        <Text style={styles.budgetPeriod}>
                          {formatDate(budget.startDate)} - {formatDate(budget.endDate)}
                        </Text>
                      </View>
                      <View style={styles.budgetActions}>
                        <TouchableOpacity
                          onPress={() => handleEditBudget(budget)}
                          style={styles.actionButton}
                        >
                          <Ionicons name="pencil" size={16} color="#1e90ff" />
                        </TouchableOpacity>
                        <TouchableOpacity
                          onPress={() => handleDeleteBudget(budget.id!)}
                          style={styles.actionButton}
                        >
                          <Ionicons name="trash" size={16} color="#ff6b35" />
                        </TouchableOpacity>
                      </View>
                    </View>

                    <View style={styles.budgetProgress}>
                      <View style={styles.progressHeader}>
                        <Text style={styles.progressLabel}>
                          {formatCurrency(progress.spent)} / {formatCurrency(budget.amount)}
                        </Text>
                        <Text style={[styles.progressPercentage, { color: progressColor }]}>
                          {progress.percentage.toFixed(0)}%
                        </Text>
                      </View>
                      
                      <View style={styles.progressBar}>
                        <View 
                          style={[
                            styles.progressFill, 
                            { 
                              width: `${progress.percentage}%`,
                              backgroundColor: progressColor
                            }
                          ]} 
                        />
                      </View>
                      
                      <Text style={styles.progressStatus}>
                        {progress.remaining > 0 
                          ? `${formatCurrency(progress.remaining)} remaining`
                          : 'Budget exceeded'
                        }
                      </Text>
                    </View>

                    {progress.percentage >= budget.alertThreshold && (
                      <View style={styles.alertContainer}>
                        <Ionicons name="warning" size={16} color="#ff6b35" />
                        <Text style={styles.alertText}>
                          Budget alert: {progress.percentage.toFixed(0)}% used
                        </Text>
                      </View>
                    )}
                  </View>
                );
              })
            ) : (
              <View style={styles.emptyState}>
                <Ionicons name="pie-chart-outline" size={64} color="#ccc" />
                <Text style={styles.emptyText}>No budgets found</Text>
                <Text style={styles.emptySubtext}>
                  Create your first budget to start tracking your spending
                </Text>
              </View>
            )}
          </View>

          {/* AI Features Coming Soon */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Smart Budgeting</Text>
            <View style={styles.aiCard}>
              <Ionicons name="sparkles" size={32} color="#1e90ff" />
              <Text style={styles.aiTitle}>
                AI-Powered Budget Insights Coming Soon
              </Text>
              <Text style={styles.aiDescription}>
                Smart budget recommendations, spending predictions, and automated budget adjustments will be available in future updates!
              </Text>
            </View>
          </View>
        </Animated.View>
      </ScrollView>

      {/* Add/Edit Budget Modal */}
      <Modal
        visible={showAddModal}
        animationType="slide"
        presentationStyle="pageSheet"
      >
        <View style={styles.modalContainer}>
          <View style={styles.modalHeader}>
            <TouchableOpacity onPress={() => { setShowAddModal(false); resetForm(); }}>
              <Text style={styles.cancelButton}>Cancel</Text>
            </TouchableOpacity>
            <Text style={styles.modalTitle}>
              {editingBudget ? 'Edit Budget' : 'Add Budget'}
            </Text>
            <TouchableOpacity onPress={handleAddBudget}>
              <Text style={styles.saveButton}>Save</Text>
            </TouchableOpacity>
          </View>

          <ScrollView style={styles.modalContent}>
            {/* Category */}
            <View style={styles.inputGroup}>
              <Text style={styles.inputLabel}>Category *</Text>
              <ScrollView horizontal showsHorizontalScrollIndicator={false}>
                <View style={styles.categoryContainer}>
                  {categories.map((category) => (
                    <TouchableOpacity
                      key={category.id}
                      style={[
                        styles.categoryButton,
                        formData.category === category.name && styles.activeCategoryButton,
                      ]}
                      onPress={() => setFormData({ ...formData, category: category.name })}
                    >
                      <View style={styles.categoryContent}>
                        <View style={[
                          styles.categoryIconContainer,
                          { backgroundColor: category.color + '20' }
                        ]}>
                          <Ionicons 
                            name={category.icon as any} 
                            size={20} 
                            color={category.color} 
                          />
                        </View>
                        <Text
                          style={[
                            styles.categoryText,
                            formData.category === category.name && styles.activeCategoryText,
                          ]}
                        >
                          {category.name}
                        </Text>
                      </View>
                    </TouchableOpacity>
                  ))}
                </View>
              </ScrollView>
            </View>

            {/* Amount */}
            <View style={styles.inputGroup}>
              <Text style={styles.inputLabel}>Budget Amount *</Text>
              <TextInput
                style={styles.textInput}
                value={formData.amount}
                onChangeText={(text) => setFormData({ ...formData, amount: text })}
                placeholder="0.00"
                keyboardType="numeric"
              />
            </View>

            {/* Alert Threshold */}
            <View style={styles.inputGroup}>
              <Text style={styles.inputLabel}>Alert Threshold (%)</Text>
              <TextInput
                style={styles.textInput}
                value={formData.alertThreshold}
                onChangeText={(text) => setFormData({ ...formData, alertThreshold: text })}
                placeholder="80"
                keyboardType="numeric"
              />
              <Text style={styles.inputHint}>
                You'll be notified when {formData.alertThreshold || '80'}% of your budget is used
              </Text>
            </View>

            {/* Date Range */}
            <View style={styles.inputGroup}>
              <Text style={styles.inputLabel}>Budget Period</Text>
              <View style={styles.dateContainer}>
                <View style={styles.dateInput}>
                  <Text style={styles.dateLabel}>Start Date</Text>
                  <Text style={styles.dateValue}>
                    {formData.startDate.toLocaleDateString()}
                  </Text>
                </View>
                <View style={styles.dateInput}>
                  <Text style={styles.dateLabel}>End Date</Text>
                  <Text style={styles.dateValue}>
                    {formData.endDate.toLocaleDateString()}
                  </Text>
                </View>
              </View>
            </View>
          </ScrollView>
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
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f8f9fa',
  },
  loadingText: {
    fontSize: 16,
    color: '#666',
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
  backButton: {
    padding: 8,
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: 'white',
  },
  addButton: {
    padding: 8,
  },
  content: {
    flex: 1,
  },
  contentContainer: {
    padding: 20,
  },
  summaryContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 20,
  },
  summaryCard: {
    flex: 1,
    backgroundColor: 'white',
    borderRadius: 15,
    padding: 20,
    marginHorizontal: 5,
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
  },
  summaryLabel: {
    fontSize: 14,
    color: '#666',
    marginBottom: 5,
  },
  summaryAmount: {
    fontSize: 18,
    fontWeight: 'bold',
  },
  budgetsContainer: {
    flex: 1,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 15,
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
  budgetHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 15,
  },
  budgetInfo: {
    flex: 1,
  },
  budgetTitleContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginBottom: 5,
  },
  budgetTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  budgetPeriod: {
    fontSize: 14,
    color: '#666',
  },
  budgetActions: {
    flexDirection: 'row',
    gap: 10,
  },
  actionButton: {
    padding: 5,
  },
  budgetProgress: {
    marginBottom: 10,
  },
  progressHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  progressLabel: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
  },
  progressPercentage: {
    fontSize: 16,
    fontWeight: 'bold',
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
  progressStatus: {
    fontSize: 12,
    color: '#666',
  },
  alertContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff3e0',
    padding: 10,
    borderRadius: 8,
    marginTop: 10,
  },
  alertText: {
    fontSize: 12,
    color: '#ff6b35',
    marginLeft: 5,
    fontWeight: '500',
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
  section: {
    marginTop: 20,
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
  modalContainer: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 20,
    paddingTop: 60,
    backgroundColor: 'white',
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  cancelButton: {
    fontSize: 16,
    color: '#666',
  },
  modalTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  saveButton: {
    fontSize: 16,
    color: '#1e90ff',
    fontWeight: '600',
  },
  modalContent: {
    flex: 1,
    padding: 20,
  },
  inputGroup: {
    marginBottom: 20,
  },
  inputLabel: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginBottom: 8,
  },
  textInput: {
    backgroundColor: 'white',
    borderRadius: 10,
    padding: 15,
    fontSize: 16,
    borderWidth: 1,
    borderColor: '#e0e0e0',
  },
  inputHint: {
    fontSize: 12,
    color: '#666',
    marginTop: 5,
  },
  categoryContainer: {
    flexDirection: 'row',
    gap: 10,
  },
  categoryButton: {
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderRadius: 20,
    backgroundColor: '#f0f0f0',
    minWidth: 100,
  },
  activeCategoryButton: {
    backgroundColor: '#1e90ff',
  },
  categoryContent: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  categoryIconContainer: {
    width: 32,
    height: 32,
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center',
  },
  categoryText: {
    fontSize: 14,
    color: '#666',
    fontWeight: '500',
  },
  activeCategoryText: {
    color: 'white',
  },
  dateContainer: {
    flexDirection: 'row',
    gap: 15,
  },
  dateInput: {
    flex: 1,
    backgroundColor: 'white',
    borderRadius: 10,
    padding: 15,
    borderWidth: 1,
    borderColor: '#e0e0e0',
  },
  dateLabel: {
    fontSize: 12,
    color: '#666',
    marginBottom: 5,
  },
  dateValue: {
    fontSize: 16,
    color: '#333',
    fontWeight: '500',
  },
});

export default BudgetsScreen; 