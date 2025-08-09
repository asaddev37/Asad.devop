import { 
  collection, 
  doc, 
  addDoc, 
  setDoc,
  updateDoc,
  deleteDoc, 
  getDoc, 
  getDocs, 
  query, 
  where, 
  orderBy, 
  limit,
  serverTimestamp,
  DocumentData,
  QueryDocumentSnapshot,
  Timestamp,
  onSnapshot,
  writeBatch,
  runTransaction
} from 'firebase/firestore';
import { db } from '../config/firebase';

// Types
export interface User {
  uid: string;
  email: string;
  fullName: string;
  currency: string;
  budgetPreferences: any;
  biometricEnabled: boolean;
  profilePicture?: string; // URL to profile picture
  privacyMode: boolean; // New field for privacy
  createdAt: Timestamp;
  lastLogin: Timestamp;
}

export interface Category {
  id?: string;
  userId?: string;
  name: string;
  isDefault: boolean;
  parentCategory: string;
  keywords: string[];
  color: string;
  icon: string;
  createdAt: Timestamp;
}

export interface Transaction {
  id?: string;
  userId: string;
  amount: number;
  category: string;
  description: string;
  date: Timestamp;
  notes?: string;
  isDeleted: boolean;
  deletedAt?: Timestamp;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface Budget {
  id?: string;
  userId: string;
  category: string;
  amount: number;
  startDate: Timestamp;
  endDate: Timestamp;
  alertThreshold: number;
  createdAt: Timestamp;
}

export interface DashboardStats {
  totalBalance: number;
  totalIncome: number;
  totalExpenses: number;
  recentTransactions: Transaction[];
  budgetProgress: Array<{
    category: string;
    spent: number;
    budget: number;
    percentage: number;
  }>;
}

export class FirestoreService {
  // User operations
  static async createUser(userData: Omit<User, 'createdAt' | 'lastLogin'>): Promise<void> {
    try {
      const userRef = doc(db, 'users', userData.uid);
      await setDoc(
        userRef,
        {
          ...userData,
          privacyMode: false, // Default to showing financial info
          createdAt: serverTimestamp(),
          lastLogin: serverTimestamp()
        },
        { merge: true }
      );
    } catch (error) {
      console.error('Error creating/updating user:', error);
      throw error;
    }
  }

  static async getUser(uid: string): Promise<User | null> {
    try {
      const userRef = doc(db, 'users', uid);
      const userSnap = await getDoc(userRef);
      
      if (userSnap.exists()) {
        return { uid, ...userSnap.data() } as User;
      }
      return null;
    } catch (error) {
      console.error('Error getting user:', error);
      throw error;
    }
  }

  static async updateUser(uid: string, updates: Partial<User>): Promise<void> {
    try {
      const userRef = doc(db, 'users', uid);
      await updateDoc(userRef, {
        ...updates,
        lastLogin: serverTimestamp()
      });
    } catch (error) {
      console.error('Error updating user:', error);
      throw error;
    }
  }

  // Real-time user listener
  static onUserChange(uid: string, callback: (user: User | null) => void) {
    const userRef = doc(db, 'users', uid);
    return onSnapshot(userRef, (doc) => {
      if (doc.exists()) {
        callback({ uid, ...doc.data() } as User);
      } else {
        callback(null);
      }
    });
  }

  // Category operations
  static async createCategory(categoryData: Omit<Category, 'id' | 'createdAt'>): Promise<string> {
    try {
      const categoryRef = await addDoc(collection(db, 'categories'), {
        ...categoryData,
        createdAt: serverTimestamp()
      });
      return categoryRef.id;
    } catch (error) {
      console.error('Error creating category:', error);
      throw error;
    }
  }

  static async getCategories(userId?: string): Promise<Category[]> {
    try {
      // First try to get user-specific categories
      let userCategories: Category[] = [];
      if (userId) {
        try {
          const userQuery = query(
            collection(db, 'categories'),
            where('userId', '==', userId)
          );
          const userSnapshot = await getDocs(userQuery);
          userSnapshot.forEach((doc) => {
            userCategories.push({
              id: doc.id,
              ...doc.data()
            } as Category);
          });
        } catch (error) {
          console.warn('Error fetching user categories:', error);
        }
      }

      // Then get default categories (shared)
      let defaultCategories: Category[] = [];
      try {
        const defaultQuery = query(
          collection(db, 'categories'),
          where('isDefault', '==', true)
        );
        const defaultSnapshot = await getDocs(defaultQuery);
        defaultSnapshot.forEach((doc) => {
          defaultCategories.push({
            id: doc.id,
            ...doc.data()
          } as Category);
        });
      } catch (error) {
        console.warn('Error fetching default categories:', error);
      }

      // Combine and remove duplicates
      const allCategories = [...userCategories, ...defaultCategories];
      const uniqueCategories = allCategories.filter((category, index, self) => 
        index === self.findIndex(c => c.name === category.name)
      );

      return uniqueCategories;
    } catch (error) {
      console.error('Error getting categories:', error);
      // Return default categories if everything fails
      return this.getDefaultCategories();
    }
  }

  // Get default categories (fallback)
  static getDefaultCategories(): Category[] {
    return [
      {
        id: 'income',
        name: 'Income',
        isDefault: true,
        parentCategory: 'Income',
        keywords: ['salary', 'wage', 'payment', 'income', 'earnings'],
        color: '#4CAF50',
        icon: 'trending-up',
        createdAt: Timestamp.now()
      },
      {
        id: 'food',
        name: 'Food & Dining',
        isDefault: true,
        parentCategory: 'Expenses',
        keywords: ['food', 'restaurant', 'grocery', 'grocery', 'dining', 'meal'],
        color: '#FF6B6B',
        icon: 'restaurant',
        createdAt: Timestamp.now()
      },
      {
        id: 'utilities',
        name: 'Utilities',
        isDefault: true,
        parentCategory: 'Expenses',
        keywords: ['electricity', 'water', 'gas', 'internet', 'phone'],
        color: '#4ECDC4',
        icon: 'flash',
        createdAt: Timestamp.now()
      },
      {
        id: 'transportation',
        name: 'Transportation',
        isDefault: true,
        parentCategory: 'Expenses',
        keywords: ['gas', 'fuel', 'uber', 'taxi', 'bus', 'train'],
        color: '#45B7D1',
        icon: 'car',
        createdAt: Timestamp.now()
      },
      {
        id: 'education',
        name: 'Education',
        isDefault: true,
        parentCategory: 'Expenses',
        keywords: ['books', 'tuition', 'course', 'school', 'college'],
        color: '#96CEB4',
        icon: 'school',
        createdAt: Timestamp.now()
      },
      {
        id: 'healthcare',
        name: 'Healthcare',
        isDefault: true,
        parentCategory: 'Expenses',
        keywords: ['medical', 'doctor', 'pharmacy', 'health', 'medicine'],
        color: '#FFEAA7',
        icon: 'medical',
        createdAt: Timestamp.now()
      },
      {
        id: 'entertainment',
        name: 'Entertainment',
        isDefault: true,
        parentCategory: 'Expenses',
        keywords: ['movie', 'game', 'concert', 'show', 'entertainment'],
        color: '#A78BFA',
        icon: 'game-controller',
        createdAt: Timestamp.now()
      },
      {
        id: 'shopping',
        name: 'Shopping',
        isDefault: true,
        parentCategory: 'Expenses',
        keywords: ['clothes', 'shoes', 'accessories', 'shopping', 'retail'],
        color: '#FF9F43',
        icon: 'bag',
        createdAt: Timestamp.now()
      },
      {
        id: 'housing',
        name: 'Housing',
        isDefault: true,
        parentCategory: 'Expenses',
        keywords: ['rent', 'mortgage', 'home', 'apartment', 'housing'],
        color: '#6C5CE7',
        icon: 'home',
        createdAt: Timestamp.now()
      },
      {
        id: 'insurance',
        name: 'Insurance',
        isDefault: true,
        parentCategory: 'Expenses',
        keywords: ['insurance', 'policy', 'coverage', 'protection'],
        color: '#00B894',
        icon: 'shield-checkmark',
        createdAt: Timestamp.now()
      },
      {
        id: 'investment',
        name: 'Investment',
        isDefault: true,
        parentCategory: 'Income',
        keywords: ['investment', 'dividend', 'interest', 'profit', 'return'],
        color: '#FDCB6E',
        icon: 'trending-up',
        createdAt: Timestamp.now()
      },
      {
        id: 'gifts',
        name: 'Gifts',
        isDefault: true,
        parentCategory: 'Expenses',
        keywords: ['gift', 'present', 'donation', 'charity'],
        color: '#E84393',
        icon: 'gift',
        createdAt: Timestamp.now()
      },
      {
        id: 'travel',
        name: 'Travel',
        isDefault: true,
        parentCategory: 'Expenses',
        keywords: ['travel', 'vacation', 'trip', 'hotel', 'flight'],
        color: '#74B9FF',
        icon: 'airplane',
        createdAt: Timestamp.now()
      },
      {
        id: 'personal',
        name: 'Personal Care',
        isDefault: true,
        parentCategory: 'Expenses',
        keywords: ['beauty', 'spa', 'salon', 'personal', 'care'],
        color: '#FD79A8',
        icon: 'cut',
        createdAt: Timestamp.now()
      },
      {
        id: 'business',
        name: 'Business',
        isDefault: true,
        parentCategory: 'Expenses',
        keywords: ['business', 'office', 'work', 'professional'],
        color: '#636E72',
        icon: 'briefcase',
        createdAt: Timestamp.now()
      }
    ];
  }

  // Transaction operations
  static async createTransaction(transactionData: Omit<Transaction, 'id' | 'createdAt' | 'updatedAt'>): Promise<string> {
    try {
      const transactionRef = await addDoc(collection(db, 'transactions'), {
        ...transactionData,
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp()
      });
      return transactionRef.id;
    } catch (error) {
      console.error('Error creating transaction:', error);
      throw error;
    }
  }

  static async getTransactions(userId: string, limitCount: number = 50): Promise<Transaction[]> {
    try {
      // Try the optimized query first
      const q = query(
        collection(db, 'transactions'),
        where('userId', '==', userId),
        where('isDeleted', '==', false),
        orderBy('date', 'desc'),
        limit(limitCount)
      );
      
      const querySnapshot = await getDocs(q);
      const transactions: Transaction[] = [];
      
      querySnapshot.forEach((doc) => {
        transactions.push({
          id: doc.id,
          ...doc.data()
        } as Transaction);
      });
      
      return transactions;
    } catch (error: any) {
      // If the error is about missing index, try a simpler query
      if (error.code === 'failed-precondition' && error.message.includes('index')) {
        console.warn('Index not found, using fallback query. Please create the required index.');
        
        // Fallback query without orderBy
        const fallbackQuery = query(
          collection(db, 'transactions'),
          where('userId', '==', userId),
          where('isDeleted', '==', false),
          limit(limitCount)
        );
        
        const querySnapshot = await getDocs(fallbackQuery);
        const transactions: Transaction[] = [];
        
        querySnapshot.forEach((doc) => {
          transactions.push({
            id: doc.id,
            ...doc.data()
          } as Transaction);
        });
        
        // Sort in memory, handling null dates
        transactions.sort((a, b) => {
          const aTime = a.date ? a.date.toMillis() : 0;
          const bTime = b.date ? b.date.toMillis() : 0;
          return bTime - aTime;
        });
        
        return transactions;
      }
      
      console.error('Error getting transactions:', error);
      throw error;
    }
  }

  // Real-time transactions listener
  static onTransactionsChange(userId: string, callback: (transactions: Transaction[]) => void) {
    try {
      const q = query(
        collection(db, 'transactions'),
        where('userId', '==', userId),
        where('isDeleted', '==', false),
        orderBy('date', 'desc'),
        limit(50)
      );
      
      return onSnapshot(q, (querySnapshot) => {
        const transactions: Transaction[] = [];
        querySnapshot.forEach((doc) => {
          transactions.push({
            id: doc.id,
            ...doc.data()
          } as Transaction);
        });
        callback(transactions);
      }, (error: any) => {
        // If the error is about missing index, use a simpler query
        if (error.code === 'failed-precondition' && error.message.includes('index')) {
          console.warn('Index not found, using fallback query for real-time updates. Please create the required index.');
          
          const fallbackQuery = query(
            collection(db, 'transactions'),
            where('userId', '==', userId),
            where('isDeleted', '==', false),
            limit(50)
          );
          
          return onSnapshot(fallbackQuery, (querySnapshot) => {
            const transactions: Transaction[] = [];
            querySnapshot.forEach((doc) => {
              transactions.push({
                id: doc.id,
                ...doc.data()
              } as Transaction);
            });
            
            // Sort in memory, handling null dates
            transactions.sort((a, b) => {
              const aTime = a.date ? a.date.toMillis() : 0;
              const bTime = b.date ? b.date.toMillis() : 0;
              return bTime - aTime;
            });
            callback(transactions);
          });
        }
        
        console.error('Error in transactions listener:', error);
      });
    } catch (error: any) {
      console.error('Error setting up transactions listener:', error);
      
      // Fallback to simple query
      const fallbackQuery = query(
        collection(db, 'transactions'),
        where('userId', '==', userId),
        where('isDeleted', '==', false),
        limit(50)
      );
      
      return onSnapshot(fallbackQuery, (querySnapshot) => {
        const transactions: Transaction[] = [];
        querySnapshot.forEach((doc) => {
          transactions.push({
            id: doc.id,
            ...doc.data()
          } as Transaction);
        });
        
        // Sort in memory, handling null dates
        transactions.sort((a, b) => {
          const aTime = a.date ? a.date.toMillis() : 0;
          const bTime = b.date ? b.date.toMillis() : 0;
          return bTime - aTime;
        });
        callback(transactions);
      });
    }
  }

  static async updateTransaction(transactionId: string, updates: Partial<Transaction>): Promise<void> {
    try {
      const transactionRef = doc(db, 'transactions', transactionId);
      await updateDoc(transactionRef, {
        ...updates,
        updatedAt: serverTimestamp()
      });
    } catch (error) {
      console.error('Error updating transaction:', error);
      throw error;
    }
  }

  static async deleteTransaction(transactionId: string): Promise<void> {
    try {
      const transactionRef = doc(db, 'transactions', transactionId);
      await updateDoc(transactionRef, {
        isDeleted: true,
        deletedAt: serverTimestamp(),
        updatedAt: serverTimestamp()
      });
    } catch (error) {
      console.error('Error deleting transaction:', error);
      throw error;
    }
  }

  // Budget operations
  static async createBudget(budgetData: Omit<Budget, 'id' | 'createdAt'>): Promise<string> {
    try {
      const budgetRef = await addDoc(collection(db, 'budgets'), {
        ...budgetData,
        createdAt: serverTimestamp()
      });
      return budgetRef.id;
    } catch (error) {
      console.error('Error creating budget:', error);
      throw error;
    }
  }

  static async getBudgets(userId: string): Promise<Budget[]> {
    try {
      const q = query(
        collection(db, 'budgets'),
        where('userId', '==', userId),
        orderBy('createdAt', 'desc')
      );
      
      const querySnapshot = await getDocs(q);
      const budgets: Budget[] = [];
      
      querySnapshot.forEach((doc) => {
        budgets.push({
          id: doc.id,
          ...doc.data()
        } as Budget);
      });
      
      return budgets;
    } catch (error: any) {
      // If the error is about missing index, try a simpler query
      if (error.code === 'failed-precondition' && error.message.includes('index')) {
        console.warn('Index not found for budgets, using fallback query. Please create the required index.');
        
        // Fallback query without orderBy
        const fallbackQuery = query(
          collection(db, 'budgets'),
          where('userId', '==', userId)
        );
        
        const querySnapshot = await getDocs(fallbackQuery);
        const budgets: Budget[] = [];
        
        querySnapshot.forEach((doc) => {
          budgets.push({
            id: doc.id,
            ...doc.data()
          } as Budget);
        });
        
        // Sort in memory, handling null createdAt
        budgets.sort((a, b) => {
          const aTime = a.createdAt ? a.createdAt.toMillis() : 0;
          const bTime = b.createdAt ? b.createdAt.toMillis() : 0;
          return bTime - aTime;
        });
        
        return budgets;
      }
      
      console.error('Error getting budgets:', error);
      throw error;
    }
  }

  // Real-time budgets listener
  static onBudgetsChange(userId: string, callback: (budgets: Budget[]) => void) {
    try {
      const q = query(
        collection(db, 'budgets'),
        where('userId', '==', userId),
        orderBy('createdAt', 'desc')
      );
      
      return onSnapshot(q, (querySnapshot) => {
        const budgets: Budget[] = [];
        querySnapshot.forEach((doc) => {
          budgets.push({
            id: doc.id,
            ...doc.data()
          } as Budget);
        });
        callback(budgets);
      }, (error: any) => {
        // If the error is about missing index, use a simpler query
        if (error.code === 'failed-precondition' && error.message.includes('index')) {
          console.warn('Index not found for budgets, using fallback query for real-time updates. Please create the required index.');
          
          const fallbackQuery = query(
            collection(db, 'budgets'),
            where('userId', '==', userId)
          );
          
          return onSnapshot(fallbackQuery, (querySnapshot) => {
            const budgets: Budget[] = [];
            querySnapshot.forEach((doc) => {
              budgets.push({
                id: doc.id,
                ...doc.data()
              } as Budget);
            });
            
            // Sort in memory, handling null createdAt
            budgets.sort((a, b) => {
              const aTime = a.createdAt ? a.createdAt.toMillis() : 0;
              const bTime = b.createdAt ? b.createdAt.toMillis() : 0;
              return bTime - aTime;
            });
            callback(budgets);
          });
        }
        
        console.error('Error in budgets listener:', error);
      });
    } catch (error: any) {
      console.error('Error setting up budgets listener:', error);
      
      // Fallback to simple query
      const fallbackQuery = query(
        collection(db, 'budgets'),
        where('userId', '==', userId)
      );
      
      return onSnapshot(fallbackQuery, (querySnapshot) => {
        const budgets: Budget[] = [];
        querySnapshot.forEach((doc) => {
          budgets.push({
            id: doc.id,
            ...doc.data()
          } as Budget);
        });
        
        // Sort in memory, handling null createdAt
        budgets.sort((a, b) => {
          const aTime = a.createdAt ? a.createdAt.toMillis() : 0;
          const bTime = b.createdAt ? b.createdAt.toMillis() : 0;
          return bTime - aTime;
        });
        callback(budgets);
      });
    }
  }

  static async updateBudget(budgetId: string, updates: Partial<Budget>): Promise<void> {
    try {
      const budgetRef = doc(db, 'budgets', budgetId);
      await updateDoc(budgetRef, updates);
    } catch (error) {
      console.error('Error updating budget:', error);
      throw error;
    }
  }

  static async deleteBudget(budgetId: string): Promise<void> {
    try {
      const budgetRef = doc(db, 'budgets', budgetId);
      await deleteDoc(budgetRef);
    } catch (error) {
      console.error('Error deleting budget:', error);
      throw error;
    }
  }

  // Dashboard statistics
  static async getDashboardStats(userId: string): Promise<DashboardStats> {
    try {
      // Get all transactions (not just current month for better accuracy)
      const transactionsQuery = query(
        collection(db, 'transactions'),
        where('userId', '==', userId),
        where('isDeleted', '==', false)
      );

      const transactionsSnapshot = await getDocs(transactionsQuery);
      const transactions: Transaction[] = [];
      let totalIncome = 0;
      let totalExpenses = 0;

      transactionsSnapshot.forEach((doc) => {
        const transaction = { id: doc.id, ...doc.data() } as Transaction;
        transactions.push(transaction);
        
        if (transaction.amount > 0) {
          totalIncome += transaction.amount;
        } else {
          totalExpenses += Math.abs(transaction.amount);
        }
      });

      // Get budgets
      const budgetsQuery = query(
        collection(db, 'budgets'),
        where('userId', '==', userId)
      );
      const budgetsSnapshot = await getDocs(budgetsQuery);
      const budgets: Budget[] = [];
      
      budgetsSnapshot.forEach((doc) => {
        budgets.push({ id: doc.id, ...doc.data() } as Budget);
      });

      // Calculate budget progress
      const budgetProgress = budgets.map(budget => {
        const categoryTransactions = transactions.filter(t => 
          t.category === budget.category && t.amount < 0
        );
        const spent = categoryTransactions.reduce((sum, t) => sum + Math.abs(t.amount), 0);
        const percentage = budget.amount > 0 ? (spent / budget.amount) * 100 : 0;
        
        return {
          category: budget.category,
          spent,
          budget: budget.amount,
          percentage: Math.min(percentage, 100)
        };
      });

      const totalBalance = totalIncome - totalExpenses;
      const recentTransactions = transactions
        .sort((a, b) => {
          const aTime = a.date ? a.date.toMillis() : 0;
          const bTime = b.date ? b.date.toMillis() : 0;
          return bTime - aTime;
        })
        .slice(0, 5);

      return {
        totalBalance,
        totalIncome,
        totalExpenses,
        recentTransactions,
        budgetProgress
      };
    } catch (error: any) {
      // If the error is about missing index, try a simpler approach
      if (error.code === 'failed-precondition' && error.message.includes('index')) {
        console.warn('Index not found for dashboard stats, using fallback query. Please create the required index.');
        
        // Fallback: get all transactions without date filtering
        const fallbackQuery = query(
          collection(db, 'transactions'),
          where('userId', '==', userId),
          where('isDeleted', '==', false)
        );
        
        const transactionsSnapshot = await getDocs(fallbackQuery);
        const transactions: Transaction[] = [];
        let totalIncome = 0;
        let totalExpenses = 0;

        transactionsSnapshot.forEach((doc) => {
          const transaction = { id: doc.id, ...doc.data() } as Transaction;
          transactions.push(transaction);
          
          if (transaction.amount > 0) {
            totalIncome += transaction.amount;
          } else {
            totalExpenses += Math.abs(transaction.amount);
          }
        });

        const totalBalance = totalIncome - totalExpenses;
        
        // Filter out transactions with invalid or missing dates before sorting
        const validTransactions = transactions.filter(t => 
          t && t.date && typeof t.date.toMillis === 'function'
        );
        
        const recentTransactions = validTransactions
          .sort((a, b) => {
            try {
              const aTime = a.date?.toMillis?.() || 0;
              const bTime = b.date?.toMillis?.() || 0;
              return bTime - aTime;
            } catch (error) {
              console.warn('Error sorting transactions by date:', error);
              return 0;
            }
          })
          .slice(0, 5);

        return {
          totalBalance,
          totalIncome,
          totalExpenses,
          recentTransactions,
          budgetProgress: []
        };
      }
      
      console.error('Error getting dashboard stats:', error);
      throw error;
    }
  }

  // Real-time dashboard stats listener
  static onDashboardStatsChange(userId: string, callback: (stats: DashboardStats) => void) {
    // Listen to both transactions and budgets changes
    const transactionsQuery = query(
      collection(db, 'transactions'),
      where('userId', '==', userId),
      where('isDeleted', '==', false)
    );

    const budgetsQuery = query(
      collection(db, 'budgets'),
      where('userId', '==', userId)
    );

    let transactions: Transaction[] = [];
    let budgets: Budget[] = [];
    let transactionsLoaded = false;
    let budgetsLoaded = false;

    const calculateAndCallback = () => {
      // Only calculate stats when both transactions and budgets have been loaded
      if (transactionsLoaded && budgetsLoaded) {
        try {
          const stats = FirestoreService.calculateDashboardStats(transactions, budgets);
          callback(stats);
        } catch (error) {
          console.error('Error calculating dashboard stats:', error);
        }
      }
    };

    const unsubscribeTransactions = onSnapshot(transactionsQuery, (snapshot) => {
      transactions = [];
      snapshot.forEach((doc) => {
        transactions.push({ id: doc.id, ...doc.data() } as Transaction);
      });
      transactionsLoaded = true;
      calculateAndCallback();
    }, (error) => {
      console.error('Error listening to transactions:', error);
      transactionsLoaded = true;
      calculateAndCallback();
    });

    const unsubscribeBudgets = onSnapshot(budgetsQuery, (snapshot) => {
      budgets = [];
      snapshot.forEach((doc) => {
        budgets.push({ id: doc.id, ...doc.data() } as Budget);
      });
      budgetsLoaded = true;
      calculateAndCallback();
    }, (error) => {
      console.error('Error listening to budgets:', error);
      budgetsLoaded = true;
      calculateAndCallback();
    });

    return () => {
      unsubscribeTransactions();
      unsubscribeBudgets();
    };
  }

  // Helper method to calculate dashboard stats from transactions and budgets
  private static calculateDashboardStats(transactions: Transaction[], budgets: Budget[]): DashboardStats {
    let totalIncome = 0;
    let totalExpenses = 0;

    transactions.forEach((transaction) => {
      if (transaction.amount > 0) {
        totalIncome += transaction.amount;
      } else {
        totalExpenses += Math.abs(transaction.amount);
      }
    });

    // Calculate budget progress
    const budgetProgress = budgets.filter(budget => 
      budget && budget.category && typeof budget.amount === 'number'
    ).map(budget => {
      const categoryTransactions = transactions.filter(t => 
        t && t.category === budget.category && t.amount < 0 && t.date
      );
      
      const spent = categoryTransactions.reduce((sum, t) => sum + Math.abs(t.amount), 0);
      const percentage = budget.amount > 0 ? (spent / budget.amount) * 100 : 0;
      
      return {
        category: budget.category,
        spent,
        budget: budget.amount,
        percentage: Math.min(percentage, 100)
      };
    });

    const totalBalance = totalIncome - totalExpenses;
    
    // Filter out transactions with invalid or missing dates before sorting
    const validTransactions = transactions.filter(t => 
      t && t.date && typeof t.date.toMillis === 'function'
    );
    
    const recentTransactions = validTransactions
      .sort((a, b) => {
        try {
          const aTime = a.date?.toMillis?.() || 0;
          const bTime = b.date?.toMillis?.() || 0;
          return bTime - aTime;
        } catch (error) {
          console.warn('Error sorting transactions by date:', error);
          return 0;
        }
      })
      .slice(0, 5);

    return {
      totalBalance,
      totalIncome,
      totalExpenses,
      recentTransactions,
      budgetProgress
    };
  }

  // Initialize default categories for a user
  static async initializeDefaultCategories(userId: string): Promise<void> {
    try {
      // Check if default categories already exist
      const existingCategories = await this.getCategories();
      if (existingCategories.length > 0) {
        console.log('Default categories already exist, skipping initialization');
        return;
      }

      const defaultCategories = [
        {
          name: 'Food & Dining',
          isDefault: true,
          parentCategory: 'Expenses',
          keywords: ['food', 'restaurant', 'grocery', 'grocery', 'dining', 'meal'],
          color: '#FF6B6B',
          icon: 'restaurant'
        },
        {
          name: 'Utilities',
          isDefault: true,
          parentCategory: 'Expenses',
          keywords: ['electricity', 'water', 'gas', 'internet', 'phone'],
          color: '#4ECDC4',
          icon: 'flash'
        },
        {
          name: 'Transportation',
          isDefault: true,
          parentCategory: 'Expenses',
          keywords: ['gas', 'fuel', 'uber', 'taxi', 'bus', 'train'],
          color: '#45B7D1',
          icon: 'car'
        },
        {
          name: 'Education',
          isDefault: true,
          parentCategory: 'Expenses',
          keywords: ['books', 'tuition', 'course', 'school', 'college'],
          color: '#96CEB4',
          icon: 'school'
        },
        {
          name: 'Healthcare',
          isDefault: true,
          parentCategory: 'Expenses',
          keywords: ['medical', 'doctor', 'pharmacy', 'health', 'medicine'],
          color: '#FFEAA7',
          icon: 'medical'
        },
        {
          name: 'Income',
          isDefault: true,
          parentCategory: 'Income',
          keywords: ['salary', 'wage', 'payment', 'income', 'earnings'],
          color: '#55A3FF',
          icon: 'trending-up'
        }
      ];

      const batch = writeBatch(db);
      
      for (const category of defaultCategories) {
        const categoryRef = doc(collection(db, 'categories'));
        batch.set(categoryRef, {
          ...category,
          userId: null, // Default categories are shared
          createdAt: serverTimestamp()
        });
      }

      await batch.commit();
      console.log('Default categories initialized successfully');
    } catch (error) {
      console.error('Error initializing default categories:', error);
      throw error;
    }
  }
}