import React, { useState, useRef, useEffect, useMemo } from 'react';
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
  FlatList,
  Platform,
} from 'react-native';
import DateTimePicker from '@react-native-community/datetimepicker';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { useAuth } from '../../src/contexts/AuthContext';
import { FirestoreService, Budget, Category, Transaction } from '../../src/services/firestoreService';
import { router } from 'expo-router';
import { Timestamp } from 'firebase/firestore';
import { LoadingOverlay } from '../../components/LoadingOverlay';
import { LoadingAnimation } from '../../components/LoadingAnimation';
import CategorySelector from '../../components/CategorySelector';
import DateRangePicker from '../../components/DateRangePicker';

interface BudgetFormData {
  category: string;
  amount: string;
  startDate: Date;
  endDate: Date;
  alertThreshold: string;
}

interface CategoryFormData {
  name: string;
  color: string;
  icon: string;
  parentCategory: string;
  keywords: string[];
}

interface BudgetProgress {
  spent: number;
  percentage: number;
  remaining: number;
}

const BudgetsScreen = () => {
  const { user, userProfile } = useAuth();
  const [budgets, setBudgets] = useState<Budget[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [showAddModal, setShowAddModal] = useState(false);
  const [showCategoryModal, setShowCategoryModal] = useState(false);
  const [editingBudget, setEditingBudget] = useState<Budget | null>(null);
  const [showStartDatePicker, setShowStartDatePicker] = useState(false);
  const [showEndDatePicker, setShowEndDatePicker] = useState(false);
  const [showErrorModal, setShowErrorModal] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const slideAnim = useRef(new Animated.Value(50)).current;
  
  const [formData, setFormData] = useState<BudgetFormData>({
    category: '',
    amount: '',
    startDate: new Date(),
    endDate: new Date(new Date().setMonth(new Date().getMonth() + 1)),
    alertThreshold: '80',
  });
  
  const [categoryFormData, setCategoryFormData] = useState<CategoryFormData>({
    name: '',
    color: '#4CAF50',
    icon: 'restaurant',
    parentCategory: 'Expenses',
    keywords: [],
  });
  
  const [keywordInput, setKeywordInput] = useState('');
  
  const handleAddKeyword = () => {
    if (keywordInput.trim() && !categoryFormData.keywords.includes(keywordInput.trim())) {
      setCategoryFormData({
        ...categoryFormData,
        keywords: [...categoryFormData.keywords, keywordInput.trim()]
      });
      setKeywordInput('');
    }
  };

  const handleRemoveKeyword = (keywordToRemove: string) => {
    setCategoryFormData({
      ...categoryFormData,
      keywords: categoryFormData.keywords.filter(keyword => keyword !== keywordToRemove)
    });
  };
  const [availableIcons, setAvailableIcons] = useState<string[]>([
    'restaurant', 'flash', 'car', 'school', 'medical', 'trending-up', 'game-controller',
    'bag', 'home', 'shield-checkmark', 'gift', 'airplane', 'cut', 'briefcase', 'cart',
    'cash', 'card', 'wallet', 'pricetag', 'fitness', 'book', 'film', 'musical-notes',
    'beer', 'wine', 'cafe', 'pizza', 'basketball', 'football', 'bicycle', 'bus',
    'train', 'boat', 'paw', 'heart', 'flower', 'leaf', 'planet', 'cloud', 'snow',
    'umbrella', 'hammer', 'construct', 'desktop', 'phone-portrait', 'tablet-portrait',
    'camera', 'videocam', 'headset', 'tv', 'radio', 'bluetooth', 'wifi', 'battery-full',
    'git-branch', 'code', 'terminal', 'server', 'globe', 'earth', 'language', 'mail',
    'chatbubbles', 'people', 'person', 'body', 'fitness', 'barbell', 'medkit', 'pulse',
    'bandage', 'thermometer', 'flask', 'beaker', 'egg', 'nutrition', 'ice-cream',
    'pizza', 'beer', 'wine', 'cafe', 'fast-food', 'fish', 'bonfire', 'sunny', 'moon',
    'star', 'cloudy', 'rainy', 'thunderstorm', 'snow', 'flame', 'bonfire', 'bulb',
  ]);
  
  const AVAILABLE_COLORS = [
    '#4CAF50', '#2196F3', '#FFC107', '#F44336', '#9C27B0', 
    '#00BCD4', '#FF9800', '#795548', '#607D8B', '#E91E63'
  ];

  const loadData = async () => {
    if (!user?.uid) return;
    
    try {
      setLoading(true);
      
      const userBudgets = await FirestoreService.getBudgets(user.uid);
      setBudgets(userBudgets);
      
      try {
        const userCategories = await FirestoreService.getCategories(user.uid);
        setCategories(userCategories);
      } catch (categoryError) {
        console.warn('Error loading categories, using defaults:', categoryError);
        setCategories(FirestoreService.getDefaultCategories());
      }
      
      const userTransactions = await FirestoreService.getTransactions(user.uid, 1000);
      setTransactions(userTransactions);
      
    } catch (error) {
      console.error('Error loading data:', error);
      Alert.alert('Error', 'Failed to load budgets');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (!user?.uid) return;

    const unsubscribeBudgets = FirestoreService.onBudgetsChange(user.uid, (newBudgets) => {
      setBudgets(newBudgets);
    });

    const unsubscribeTransactions = FirestoreService.onTransactionsChange(user.uid, (newTransactions) => {
      setTransactions(newTransactions);
    });

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

      const startDate = formData.startDate instanceof Date ? formData.startDate : new Date();
      const endDate = formData.endDate instanceof Date ? formData.endDate : new Date(new Date().setMonth(new Date().getMonth() + 1));

      const budgetData = {
        userId: user.uid,
        category: formData.category,
        amount: amount,
        startDate: Timestamp.fromDate(startDate),
        endDate: Timestamp.fromDate(endDate),
        alertThreshold: alertThreshold,
        spent: 0,
        createdAt: Timestamp.now()
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

  const handleCreateCategory = async () => {
    if (!user?.uid || !categoryFormData.name || !categoryFormData.color || !categoryFormData.icon) {
      Alert.alert('Error', 'Please fill in all required fields for the category');
      return;
    }

    try {
      const existingCategory = categories.find(
        cat => cat.name.toLowerCase() === categoryFormData.name.toLowerCase()
      );
      
      if (existingCategory) {
        Alert.alert('Error', 'A category with this name already exists');
        return;
      }

      const categoryData = {
        userId: user.uid,
        name: categoryFormData.name,
        isDefault: false,
        parentCategory: categoryFormData.parentCategory,
        keywords: categoryFormData.keywords,
        color: categoryFormData.color,
        icon: categoryFormData.icon,
        createdAt: new Date(),
      };

      await FirestoreService.createCategory(categoryData);

      setCategoryFormData({
        name: '',
        color: '#4CAF50',
        icon: 'restaurant',
        parentCategory: 'Expenses',
        keywords: [],
      });
      setKeywordInput('');
      setShowCategoryModal(false);
      
      const updatedCategories = await FirestoreService.getCategories(user.uid);
      setCategories(updatedCategories);
    } catch (error) {
      console.error('Error creating category:', error);
      Alert.alert('Error', 'Failed to create category');
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
    
    let startDate = new Date();
    let endDate = new Date(new Date().setMonth(new Date().getMonth() + 1));
    
    try {
      if (budget.startDate && typeof budget.startDate.toDate === 'function') {
        startDate = budget.startDate.toDate();
      }
      if (budget.endDate && typeof budget.endDate.toDate === 'function') {
        endDate = budget.endDate.toDate();
      }
    } catch (error) {
      console.error('Error converting budget dates:', error);
    }
    
    setFormData({
      category: budget.category,
      amount: budget.amount.toString(),
      startDate: startDate,
      endDate: endDate,
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

  const formatDate = (timestamp: Timestamp | null | undefined) => {
    if (!timestamp || typeof timestamp.toDate !== 'function') {
      return 'Invalid Date';
    }
    
    try {
      const date = timestamp.toDate();
      return date.toLocaleDateString();
    } catch (error) {
      console.error('Error formatting date:', error);
      return 'Invalid Date';
    }
  };

  useEffect(() => {
    const progressMap = new Map<string, BudgetProgress>();

    budgets.forEach((budget) => {
      if (!budget.id) {
        console.warn('Budget missing id', budget);
        return;
      }

      try {
        console.log(`Calculating progress for budget: ${budget.id} - ${budget.category}`);

        if (!budget.startDate) {
          console.warn('Budget missing startDate', budget);
          throw new Error('Missing startDate');
        }

        if (!budget.endDate) {
          console.warn('Budget missing endDate', budget);
          throw new Error('Missing endDate');
        }

        if (typeof budget.startDate.toMillis !== 'function' || typeof budget.endDate.toMillis !== 'function') {
          console.warn('Budget dates not Timestamps', budget);
          throw new Error('Invalid date format');
        }

        const startTime = budget.startDate.toMillis();
        const endTime = budget.endDate.toMillis();

        console.log(`Budget period: ${startTime} to ${endTime}`);

        const budgetTransactions = transactions.filter((t) => {
          if (!t.date) {
            console.warn('Transaction missing date', t);
            return false;
          }

          if (typeof t.date.toMillis !== 'function') {
            console.warn('Transaction date not Timestamp', t);
            return false;
          }

          try {
            const transactionTime = t.date.toMillis();
            return (
              t.category === budget.category &&
              t.amount < 0 &&
              transactionTime >= startTime &&
              transactionTime <= endTime
            );
          } catch (err) {
            console.error('Error in transaction date toMillis', err, t);
            return false;
          }
        });

        const spent = budgetTransactions.reduce((sum, t) => sum + Math.abs(t.amount), 0);
        const percentage = budget.amount > 0 ? (spent / budget.amount) * 100 : 0;

        progressMap.set(budget.id, {
          spent,
          percentage: Math.min(percentage, 100),
          remaining: Math.max(budget.amount - spent, 0),
        });
      } catch (error) {
        console.error('Error in calculateBudgetProgress for budget ' + budget.id, error);
        setErrorMsg('An error occurred while calculating budget progress. Please check your console logs for details.');
        setShowErrorModal(true);
        progressMap.set(budget.id, { spent: 0, percentage: 0, remaining: budget.amount });
      }
    });

    setBudgetsProgress(progressMap);
  }, [budgets, transactions]);

  const [budgetsProgress, setBudgetsProgress] = useState<Map<string, BudgetProgress>>(new Map());

  const getProgressColor = (percentage: number, alertThreshold: number) => {
    if (percentage >= alertThreshold) return '#ff6b35';
    if (percentage >= 60) return '#ffa726';
    return '#32cd32';
  };

  const totalBudgeted = budgets.reduce((sum, budget) => sum + budget.amount, 0);
  const totalSpent = Array.from(budgetsProgress.values()).reduce((sum, p) => sum + p.spent, 0);

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

  return (
    <View style={styles.container}>
      <StatusBar barStyle="dark-content" backgroundColor="transparent" translucent />
      
      <LoadingOverlay 
        visible={loading && !refreshing} 
        message="Loading your budgets..." 
        transparent={true}
        animationType="dots"
      />
      
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

          <View style={styles.budgetsContainer}>
            <Text style={styles.sectionTitle}>Your Budgets</Text>
            
            {budgets.length > 0 ? (
              budgets.map((budget) => {
                if (!budget.id) return null;
                const progress = budgetsProgress.get(budget.id) || { spent: 0, percentage: 0, remaining: budget.amount };
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
            <View style={styles.inputGroup}>
              <Text style={styles.inputLabel}>Category *</Text>
              <CategorySelector
                selectedCategory={formData.category}
                onSelectCategory={(categoryName) => setFormData({ ...formData, category: categoryName })}
              />
            </View>

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

            <View style={styles.inputGroup}>
              <Text style={styles.inputLabel}>Budget Period</Text>
              <View style={styles.dateContainer}>
                <TouchableOpacity 
                  style={styles.dateInput}
                  onPress={() => setShowStartDatePicker(true)}
                >
                  <Text style={styles.dateLabel}>Start Date</Text>
                  <Text style={styles.dateValue}>
                    {formData.startDate.toLocaleDateString()}
                  </Text>
                </TouchableOpacity>
                <TouchableOpacity 
                  style={styles.dateInput}
                  onPress={() => setShowEndDatePicker(true)}
                >
                  <Text style={styles.dateLabel}>End Date</Text>
                  <Text style={styles.dateValue}>
                    {formData.endDate.toLocaleDateString()}
                  </Text>
                </TouchableOpacity>
              </View>
              
              {showStartDatePicker && (
                <DateTimePicker
                  value={formData.startDate}
                  mode="date"
                  display="default"
                  onChange={(event: any, selectedDate?: Date) => {
                    setShowStartDatePicker(Platform.OS === 'ios');
                    if (selectedDate) {
                      setFormData({ ...formData, startDate: selectedDate });
                    }
                  }}
                />
              )}
              
              {showEndDatePicker && (
                <DateTimePicker
                  value={formData.endDate}
                  mode="date"
                  display="default"
                  onChange={(event: any, selectedDate?: Date) => {
                    setShowEndDatePicker(Platform.OS === 'ios');
                    if (selectedDate) {
                      setFormData({ ...formData, endDate: selectedDate });
                    }
                  }}
                />
              )}
            </View>
          </ScrollView>
        </View>
      </Modal>
      
      <Modal
        visible={showCategoryModal}
        animationType="slide"
        transparent={true}
        onRequestClose={() => setShowCategoryModal(false)}
      >
        <View style={styles.categoryModalOverlay}>
          <View style={styles.categoryModalContainer}>
            <View style={styles.categoryModalHeader}>
              <Text style={styles.categoryModalTitle}>Create New Category</Text>
              <TouchableOpacity onPress={() => setShowCategoryModal(false)}>
                <Ionicons name="close" size={24} color="#666" />
              </TouchableOpacity>
            </View>

            <ScrollView style={styles.categoryModalContent}>
              <View style={styles.inputGroup}>
                <Text style={styles.inputLabel}>Category Name *</Text>
                <TextInput
                  style={styles.textInput}
                  value={categoryFormData.name}
                  onChangeText={(text) => setCategoryFormData({...categoryFormData, name: text})}
                  placeholder="Enter category name"
                  maxLength={20}
                />
              </View>

              <View style={styles.inputGroup}>
                <Text style={styles.inputLabel}>Select Icon *</Text>
                <FlatList
                  data={availableIcons}
                  horizontal
                  showsHorizontalScrollIndicator={false}
                  keyExtractor={(item) => item}
                  renderItem={({ item }) => (
                    <TouchableOpacity
                      style={[
                        styles.iconButton,
                        categoryFormData.icon === item && styles.selectedIconButton,
                      ]}
                      onPress={() => setCategoryFormData({...categoryFormData, icon: item})}
                    >
                      <Ionicons
                        name={item as any}
                        size={24}
                        color={categoryFormData.icon === item ? 'white' : '#666'}
                      />
                    </TouchableOpacity>
                  )}
                  style={styles.iconList}
                />
              </View>

              <View style={styles.inputGroup}>
                <Text style={styles.inputLabel}>Select Color *</Text>
                <FlatList
                  data={AVAILABLE_COLORS}
                  horizontal
                  showsHorizontalScrollIndicator={false}
                  keyExtractor={(item) => item}
                  renderItem={({ item }) => (
                    <TouchableOpacity
                      style={[
                        styles.colorButton,
                        { backgroundColor: item },
                        categoryFormData.color === item && styles.selectedColorButton,
                      ]}
                      onPress={() => setCategoryFormData({...categoryFormData, color: item})}
                    />
                  )}
                  style={styles.colorList}
                />
              </View>

              <View style={styles.inputGroup}>
                <Text style={styles.inputLabel}>Keywords (Optional)</Text>
                <View style={styles.keywordInputContainer}>
                  <TextInput
                    style={styles.keywordInput}
                    value={keywordInput}
                    onChangeText={setKeywordInput}
                    placeholder="Add keywords for auto-categorization"
                  />
                  <TouchableOpacity 
                    style={styles.addKeywordButton}
                    onPress={handleAddKeyword}
                  >
                    <Ionicons name="add" size={24} color="white" />
                  </TouchableOpacity>
                </View>
                
                {categoryFormData.keywords.length > 0 && (
                  <View style={styles.keywordsList}>
                    {categoryFormData.keywords.map((keyword, index) => (
                      <View key={index} style={styles.keywordChip}>
                        <Text style={styles.keywordText}>{keyword}</Text>
                        <TouchableOpacity
                          onPress={() => handleRemoveKeyword(keyword)}
                          style={styles.removeKeywordButton}
                        >
                          <Ionicons name="close-circle" size={16} color="#666" />
                        </TouchableOpacity>
                      </View>
                    ))}
                  </View>
                )}
              </View>

              <TouchableOpacity
                style={styles.createButton}
                onPress={handleCreateCategory}
              >
                <Text style={styles.createButtonText}>Create Category</Text>
              </TouchableOpacity>
            </ScrollView>
          </View>
        </View>
      </Modal>

      <Modal
        visible={showErrorModal}
        transparent={true}
        animationType="fade"
        onRequestClose={() => setShowErrorModal(false)}
      >
        <View style={styles.errorOverlay}>
          <View style={styles.errorContainer}>
            <Ionicons name="warning" size={32} color="#ff6b35" />
            <Text style={styles.errorText}>{errorMsg}</Text>
            <TouchableOpacity 
              style={styles.errorButton}
              onPress={() => setShowErrorModal(false)}
            >
              <Text style={styles.errorButtonText}>OK</Text>
            </TouchableOpacity>
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
  categoryModalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  categoryModalContainer: {
    backgroundColor: 'white',
    borderRadius: 15,
    width: '100%',
    maxHeight: '80%',
    padding: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
  },
  categoryModalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
    paddingBottom: 10,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  categoryModalTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#333',
  },
  categoryModalContent: {
    flex: 1,
  },
  iconList: {
    marginBottom: 10,
  },
  iconButton: {
    width: 44,
    height: 44,
    borderRadius: 22,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 10,
    backgroundColor: '#f0f0f0',
  },
  selectedIconButton: {
    backgroundColor: '#4A90E2',
  },
  colorList: {
    marginBottom: 10,
  },
  colorButton: {
    width: 36,
    height: 36,
    borderRadius: 18,
    marginRight: 10,
    borderWidth: 1,
    borderColor: '#ddd',
  },
  selectedColorButton: {
    borderWidth: 2,
    borderColor: '#333',
  },
  keywordInputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  keywordInput: {
    flex: 1,
    backgroundColor: 'white',
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#ddd',
    paddingHorizontal: 12,
    paddingVertical: 10,
    fontSize: 16,
    marginRight: 8,
  },
  addKeywordButton: {
    backgroundColor: '#4A90E2',
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  keywordsList: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginTop: 10,
  },
  keywordChip: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#f0f0f0',
    borderRadius: 16,
    paddingHorizontal: 12,
    paddingVertical: 6,
    marginRight: 8,
    marginBottom: 8,
  },
  keywordText: {
    fontSize: 14,
    color: '#333',
    marginRight: 4,
  },
  removeKeywordButton: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  addCategoryButton: {
    marginTop: 10,
    borderWidth: 1,
    borderColor: '#4A90E2',
    borderStyle: 'dashed',
    borderRadius: 10,
    padding: 12,
  },
  addCategoryText: {
    color: '#4A90E2',
    fontWeight: '500',
    fontSize: 14,
  },
  createButton: {
    backgroundColor: '#4A90E2',
    borderRadius: 10,
    padding: 15,
    alignItems: 'center',
    marginTop: 20,
  },
  createButtonText: {
    color: 'white',
    fontWeight: '600',
    fontSize: 16,
  },
  errorOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  errorContainer: {
    backgroundColor: 'white',
    borderRadius: 15,
    padding: 20,
    alignItems: 'center',
    width: '80%',
  },
  errorText: {
    fontSize: 16,
    color: '#333',
    textAlign: 'center',
    marginVertical: 20,
  },
  errorButton: {
    backgroundColor: '#4A90E2',
    borderRadius: 10,
    padding: 10,
    paddingHorizontal: 20,
  },
  errorButtonText: {
    color: 'white',
    fontWeight: '600',
  },
});

export default BudgetsScreen;