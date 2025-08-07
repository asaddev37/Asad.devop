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
  Timestamp 
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

export class FirestoreService {
  // User operations
  static async createUser(userData: Omit<User, 'createdAt' | 'lastLogin'>): Promise<void> {
    try {
      const userRef = doc(db, 'users', userData.uid);
      await setDoc(
        userRef,
        {
          ...userData,
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
        return userSnap.data() as User;
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
      let q;
      if (userId) {
        q = query(
          collection(db, 'categories'),
          where('userId', 'in', [userId, null])
        );
      } else {
        q = query(collection(db, 'categories'));
      }
      
      const querySnapshot = await getDocs(q);
      const categories: Category[] = [];
      
      querySnapshot.forEach((doc) => {
        categories.push({
          id: doc.id,
          ...doc.data()
        } as Category);
      });
      
      return categories;
    } catch (error) {
      console.error('Error getting categories:', error);
      throw error;
    }
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
    } catch (error) {
      console.error('Error getting transactions:', error);
      throw error;
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
    } catch (error) {
      console.error('Error getting budgets:', error);
      throw error;
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
} 