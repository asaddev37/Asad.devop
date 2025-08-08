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
  FlatList,
  RefreshControl,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { useAuth } from '../../src/contexts/AuthContext';
import { FirestoreService, Transaction, Category } from '../../src/services/firestoreService';
import { router } from 'expo-router';
import { Timestamp } from 'firebase/firestore';
import { LoadingOverlay } from '../../components/LoadingOverlay';
import { LoadingAnimation } from '../../components/LoadingAnimation';

interface TransactionFormData {
  description: string;
  amount: string;
  category: string;
  notes: string;
  date: Date;
}

const TransactionsScreen = () => {
  const { user, userProfile } = useAuth();
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [showAddModal, setShowAddModal] = useState(false);
  const [editingTransaction, setEditingTransaction] = useState<Transaction | null>(null);
  const [filter, setFilter] = useState<'all' | 'income' | 'expense'>('all');
  
  const [formData, setFormData] = useState<TransactionFormData>({
    description: '',
    amount: '',
    category: '',
    notes: '',
    date: new Date(),
  });

  const fadeAnim = useRef(new Animated.Value(0)).current;
  const slideAnim = useRef(new Animated.Value(50)).current;

  // Load transactions and categories
  const loadData = async () => {
    if (!user?.uid) return;
    
    try {
      setLoading(true);
      
      // Load transactions
      const userTransactions = await FirestoreService.getTransactions(user.uid, 100);
      setTransactions(userTransactions);
      
      // Load categories with fallback
      try {
        const userCategories = await FirestoreService.getCategories(user.uid);
        setCategories(userCategories);
      } catch (categoryError) {
        console.warn('Error loading categories, using defaults:', categoryError);
        // Use default categories as fallback
        setCategories(FirestoreService.getDefaultCategories());
      }
      
    } catch (error) {
      console.error('Error loading data:', error);
      Alert.alert('Error', 'Failed to load transactions');
    } finally {
      setLoading(false);
    }
  };

  // Real-time listeners
  useEffect(() => {
    if (!user?.uid) return;

    const unsubscribeTransactions = FirestoreService.onTransactionsChange(user.uid, (newTransactions) => {
      setTransactions(newTransactions);
    });

    // Initial load
    loadData();

    return () => {
      unsubscribeTransactions();
    };
  }, [user?.uid]);

  const onRefresh = async () => {
    setRefreshing(true);
    await loadData();
    setRefreshing(false);
  };

  const handleAddTransaction = async () => {
    if (!user?.uid || !formData.description || !formData.amount) {
      Alert.alert('Error', 'Please fill in description and amount');
      return;
    }

    // For the first transaction, if no category is selected, use a default category
    let category = formData.category;
    if (!category) {
      if (filter === 'income') {
        category = 'Income';
      } else {
        category = 'Food & Dining'; // Default expense category
      }
    }

    try {
      const amount = parseFloat(formData.amount);
      if (isNaN(amount)) {
        Alert.alert('Error', 'Please enter a valid amount');
        return;
      }

      const transactionData = {
        userId: user.uid,
        amount: filter === 'expense' ? -Math.abs(amount) : Math.abs(amount),
        category: category,
        description: formData.description,
        date: Timestamp.fromDate(formData.date),
        notes: formData.notes,
        isDeleted: false,
      };

      if (editingTransaction) {
        await FirestoreService.updateTransaction(editingTransaction.id!, {
          ...transactionData,
          updatedAt: Timestamp.now(),
        });
      } else {
        await FirestoreService.createTransaction(transactionData);
      }

      setShowAddModal(false);
      resetForm();
    } catch (error) {
      console.error('Error saving transaction:', error);
      Alert.alert('Error', 'Failed to save transaction');
    }
  };

  const handleDeleteTransaction = async (transactionId: string) => {
    Alert.alert(
      'Delete Transaction',
      'Are you sure you want to delete this transaction?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            try {
              await FirestoreService.deleteTransaction(transactionId);
            } catch (error) {
              console.error('Error deleting transaction:', error);
              Alert.alert('Error', 'Failed to delete transaction');
            }
          },
        },
      ]
    );
  };

  const handleEditTransaction = (transaction: Transaction) => {
    setEditingTransaction(transaction);
    setFormData({
      description: transaction.description,
      amount: Math.abs(transaction.amount).toString(),
      category: transaction.category,
      notes: transaction.notes || '',
      date: transaction.date.toDate(),
    });
    setFilter(transaction.amount > 0 ? 'income' : 'expense');
    setShowAddModal(true);
  };

  const resetForm = () => {
    setFormData({
      description: '',
      amount: '',
      category: '',
      notes: '',
      date: new Date(),
    });
    setEditingTransaction(null);
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

  const filteredTransactions = transactions.filter(transaction => {
    if (filter === 'income') return transaction.amount > 0;
    if (filter === 'expense') return transaction.amount < 0;
    return true;
  });

  const totalIncome = transactions
    .filter(t => t.amount > 0)
    .reduce((sum, t) => sum + t.amount, 0);

  const totalExpenses = transactions
    .filter(t => t.amount < 0)
    .reduce((sum, t) => sum + Math.abs(t.amount), 0);

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
      
      {/* Loading Overlay */}
      <LoadingOverlay 
        visible={loading && !refreshing} 
        message="Loading your transactions..." 
        transparent={true}
        animationType="circular"
      />
      
      {/* Header */}
      <LinearGradient colors={['#4A90E2', '#357ABD']} style={styles.header}>
        <View style={styles.headerContent}>
          <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
            <Ionicons name="arrow-back" size={24} color="white" />
          </TouchableOpacity>
          <Text style={styles.headerTitle}>Transactions</Text>
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
              <Text style={styles.summaryLabel}>Total Income</Text>
              <Text style={[styles.summaryAmount, { color: '#32cd32' }]}>
                {formatCurrency(totalIncome)}
              </Text>
            </View>
            <View style={styles.summaryCard}>
              <Text style={styles.summaryLabel}>Total Expenses</Text>
              <Text style={[styles.summaryAmount, { color: '#ff6b35' }]}>
                {formatCurrency(totalExpenses)}
              </Text>
            </View>
          </View>

          {/* Filter Tabs */}
          <View style={styles.filterContainer}>
            {['all', 'income', 'expense'].map((filterType) => (
              <TouchableOpacity
                key={filterType}
                style={[
                  styles.filterTab,
                  filter === filterType && styles.activeFilterTab,
                ]}
                onPress={() => setFilter(filterType as any)}
              >
                <Text
                  style={[
                    styles.filterText,
                    filter === filterType && styles.activeFilterText,
                  ]}
                >
                  {filterType.charAt(0).toUpperCase() + filterType.slice(1)}
                </Text>
              </TouchableOpacity>
            ))}
          </View>

          {/* Transactions List */}
          <View style={styles.transactionsContainer}>
            {filteredTransactions.length > 0 ? (
              filteredTransactions.map((transaction) => (
                <View key={transaction.id} style={styles.transactionCard}>
                  <View style={styles.transactionHeader}>
                    <View style={styles.transactionIcon}>
                      {(() => {
                        const category = categories.find(cat => cat.name === transaction.category);
                        if (category) {
                          return (
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
                          );
                        }
                        return (
                          <Ionicons
                            name={transaction.amount > 0 ? "arrow-up-circle" : "arrow-down-circle"}
                            size={24}
                            color={transaction.amount > 0 ? "#32cd32" : "#ff6b35"}
                          />
                        );
                      })()}
                    </View>
                    <View style={styles.transactionDetails}>
                      <Text style={styles.transactionTitle}>{transaction.description}</Text>
                      <Text style={styles.transactionCategory}>
                        {transaction.category} • {formatDate(transaction.date)}
                      </Text>
                      {transaction.notes && (
                        <Text style={styles.transactionNotes}>{transaction.notes}</Text>
                      )}
                    </View>
                    <View style={styles.transactionActions}>
                      <Text
                        style={[
                          styles.transactionAmount,
                          { color: transaction.amount > 0 ? "#32cd32" : "#ff6b35" },
                        ]}
                      >
                        {transaction.amount > 0 ? '+' : ''}{formatCurrency(transaction.amount)}
                      </Text>
                      <View style={styles.actionButtons}>
                        <TouchableOpacity
                          onPress={() => handleEditTransaction(transaction)}
                          style={styles.actionButton}
                        >
                          <Ionicons name="pencil" size={16} color="#1e90ff" />
                        </TouchableOpacity>
                        <TouchableOpacity
                          onPress={() => handleDeleteTransaction(transaction.id!)}
                          style={styles.actionButton}
                        >
                          <Ionicons name="trash" size={16} color="#ff6b35" />
                        </TouchableOpacity>
                      </View>
                    </View>
                  </View>
                </View>
              ))
            ) : (
              <View style={styles.emptyState}>
                <Ionicons name="receipt-outline" size={64} color="#ccc" />
                <Text style={styles.emptyText}>No transactions found</Text>
                <Text style={styles.emptySubtext}>
                  {filter === 'all' 
                    ? 'Add your first transaction to get started'
                    : `No ${filter} transactions found`
                  }
                </Text>
              </View>
            )}
          </View>
        </Animated.View>
      </ScrollView>

      {/* Add/Edit Transaction Modal */}
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
              {editingTransaction ? 'Edit Transaction' : 'Add Transaction'}
            </Text>
            <TouchableOpacity onPress={handleAddTransaction}>
              <Text style={styles.saveButton}>Save</Text>
            </TouchableOpacity>
          </View>

          <ScrollView style={styles.modalContent}>
            {/* Transaction Type */}
            <View style={styles.inputGroup}>
              <Text style={styles.inputLabel}>Transaction Type</Text>
              <View style={styles.typeContainer}>
                {['income', 'expense'].map((type) => (
                  <TouchableOpacity
                    key={type}
                    style={[
                      styles.typeButton,
                      filter === type && styles.activeTypeButton,
                    ]}
                    onPress={() => setFilter(type as any)}
                  >
                    <Text
                      style={[
                        styles.typeText,
                        filter === type && styles.activeTypeText,
                      ]}
                    >
                      {type.charAt(0).toUpperCase() + type.slice(1)}
                    </Text>
                  </TouchableOpacity>
                ))}
              </View>
            </View>

            {/* Description */}
            <View style={styles.inputGroup}>
              <Text style={styles.inputLabel}>Description *</Text>
              <TextInput
                style={styles.textInput}
                value={formData.description}
                onChangeText={(text) => setFormData({ ...formData, description: text })}
                placeholder="Enter description"
              />
            </View>

            {/* Amount */}
            <View style={styles.inputGroup}>
              <Text style={styles.inputLabel}>Amount *</Text>
              <TextInput
                style={styles.textInput}
                value={formData.amount}
                onChangeText={(text) => setFormData({ ...formData, amount: text })}
                placeholder="0.00"
                keyboardType="numeric"
              />
            </View>

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

            {/* Notes */}
            <View style={styles.inputGroup}>
              <Text style={styles.inputLabel}>Notes (Optional)</Text>
              <TextInput
                style={[styles.textInput, styles.textArea]}
                value={formData.notes}
                onChangeText={(text) => setFormData({ ...formData, notes: text })}
                placeholder="Add notes..."
                multiline
                numberOfLines={3}
              />
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
  filterContainer: {
    flexDirection: 'row',
    backgroundColor: 'white',
    borderRadius: 15,
    padding: 5,
    marginBottom: 20,
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
  },
  filterTab: {
    flex: 1,
    paddingVertical: 12,
    alignItems: 'center',
    borderRadius: 10,
  },
  activeFilterTab: {
    backgroundColor: '#1e90ff',
  },
  filterText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#666',
  },
  activeFilterText: {
    color: 'white',
  },
  transactionsContainer: {
    flex: 1,
  },
  transactionCard: {
    backgroundColor: 'white',
    borderRadius: 15,
    padding: 15,
    marginBottom: 10,
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
  },
  transactionHeader: {
    flexDirection: 'row',
    alignItems: 'center',
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
    marginBottom: 3,
  },
  transactionNotes: {
    fontSize: 12,
    color: '#999',
    fontStyle: 'italic',
  },
  transactionActions: {
    alignItems: 'flex-end',
  },
  transactionAmount: {
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 5,
  },
  actionButtons: {
    flexDirection: 'row',
    gap: 10,
  },
  actionButton: {
    padding: 5,
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
  textArea: {
    height: 80,
    textAlignVertical: 'top',
  },
  typeContainer: {
    flexDirection: 'row',
    gap: 10,
  },
  typeButton: {
    flex: 1,
    paddingVertical: 12,
    paddingHorizontal: 20,
    borderRadius: 10,
    backgroundColor: '#f0f0f0',
    alignItems: 'center',
  },
  activeTypeButton: {
    backgroundColor: '#1e90ff',
  },
  typeText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#666',
  },
  activeTypeText: {
    color: 'white',
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
});

export default TransactionsScreen;