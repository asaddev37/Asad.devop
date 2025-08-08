import React, { createContext, useContext, useEffect, useState } from 'react';
import { User } from 'firebase/auth';
import { AuthService } from '../services/authService';
import { FirestoreService, User as FirestoreUser } from '../services/firestoreService';

interface AuthContextType {
  user: User | null;
  userProfile: FirestoreUser | null;
  loading: boolean;
  signUp: (email: string, password: string, fullName: string) => Promise<void>;
  signIn: (email: string, password: string) => Promise<void>;
  signOut: () => Promise<void>;
  resetPassword: (email: string) => Promise<void>;
  updateProfile: (updates: Partial<FirestoreUser>) => Promise<void>;
  refreshUserProfile: () => Promise<void>;
  togglePrivacyMode: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

interface AuthProviderProps {
  children: React.ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [userProfile, setUserProfile] = useState<FirestoreUser | null>(null);
  const [loading, setLoading] = useState(true);

  // Fetch user profile from Firestore
  const fetchUserProfile = async (uid: string) => {
    try {
      const profile = await FirestoreService.getUser(uid);
      setUserProfile(profile);
    } catch (error) {
      console.error('Error fetching user profile:', error);
    }
  };

  // Real-time user profile listener
  useEffect(() => {
    if (!user?.uid) return;

    const unsubscribe = FirestoreService.onUserChange(user.uid, (profile) => {
      setUserProfile(profile);
    });

    return unsubscribe;
  }, [user?.uid]);

  useEffect(() => {
    const unsubscribe = AuthService.onAuthStateChanged(async (user) => {
      setUser(user);
      
      if (user) {
        // Check if user exists in Firestore, if not create user document
        try {
          const userData = await FirestoreService.getUser(user.uid);
          if (!userData) {
            // Create user document in Firestore
            await FirestoreService.createUser({
              uid: user.uid,
              email: user.email || '',
              fullName: user.displayName || '',
              currency: 'USD',
              budgetPreferences: {},
              biometricEnabled: false,
              privacyMode: false
            });
            
            // Initialize default categories for new user
            await FirestoreService.initializeDefaultCategories(user.uid);
          }
          
          // Fetch user profile
          await fetchUserProfile(user.uid);
        } catch (error) {
          console.error('Error handling user state change:', error);
        }
      } else {
        setUserProfile(null);
      }
      
      setLoading(false);
    });

    return unsubscribe;
  }, []);

  const signUp = async (email: string, password: string, fullName: string) => {
    try {
      const userCredential = await AuthService.signUp(email, password);
      
      // Create user document in Firestore
      if (userCredential.user) {
        await FirestoreService.createUser({
          uid: userCredential.user.uid,
          email: userCredential.user.email || '',
          fullName: fullName,
          currency: 'USD',
          budgetPreferences: {},
          biometricEnabled: false,
          privacyMode: false
        });
        
        // Initialize default categories for new user
        await FirestoreService.initializeDefaultCategories(userCredential.user.uid);
      }
    } catch (error) {
      console.error('Error in signUp:', error);
      throw error;
    }
  };

  const signIn = async (email: string, password: string) => {
    try {
      await AuthService.signIn(email, password);
    } catch (error) {
      console.error('Error in signIn:', error);
      throw error;
    }
  };

  const signOut = async () => {
    try {
      await AuthService.signOut();
      setUserProfile(null);
    } catch (error) {
      console.error('Error in signOut:', error);
      throw error;
    }
  };

  const resetPassword = async (email: string) => {
    try {
      await AuthService.resetPassword(email);
    } catch (error) {
      console.error('Error in resetPassword:', error);
      throw error;
    }
  };

  const updateProfile = async (updates: Partial<FirestoreUser>) => {
    if (!user?.uid) throw new Error('No user logged in');
    
    try {
      await FirestoreService.updateUser(user.uid, updates);
      // Force refresh the user profile to ensure immediate updates
      await fetchUserProfile(user.uid);
    } catch (error) {
      console.error('Error updating profile:', error);
      throw error;
    }
  };

  const refreshUserProfile = async () => {
    if (!user?.uid) return;
    
    try {
      await fetchUserProfile(user.uid);
    } catch (error) {
      console.error('Error refreshing user profile:', error);
    }
  };

  const togglePrivacyMode = async () => {
    if (user?.uid && userProfile) {
      const newPrivacyMode = !userProfile.privacyMode;
      await updateProfile({ privacyMode: newPrivacyMode });
    }
  };

  const value = {
    user,
    userProfile,
    loading,
    signUp,
    signIn,
    signOut,
    resetPassword,
    updateProfile,
    refreshUserProfile,
    togglePrivacyMode,
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};