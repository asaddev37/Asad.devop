import React, { createContext, useContext, useState, useEffect, ReactNode, useCallback, useMemo } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';

type UserContextType = {
  userName: string;
  updateUserName: (newName: string) => Promise<void>;
};

const UserContext = createContext<UserContextType | undefined>(undefined);

const USER_STORAGE_KEY = '@userName';

export function UserProvider({ children }: { children: ReactNode }) {
  const [userName, setUserName] = useState<string>('User');
  const [isLoading, setIsLoading] = useState(true);

  console.log('UserProvider rendering with userName:', userName);

  // Load saved user name on initial render
  useEffect(() => {
    console.log('Loading user name from storage...');
    const loadUserName = async () => {
      try {
        const savedName = await AsyncStorage.getItem(USER_STORAGE_KEY);
        console.log('Loaded user name from storage:', savedName);
        if (savedName !== null) {
          setUserName(savedName);
        }
      } catch (error) {
        console.error('Failed to load user name', error);
      } finally {
        setIsLoading(false);
      }
    };

    loadUserName();
  }, []);

  const updateUserName = useCallback(async (newName: string) => {
    console.log('Updating user name to:', newName);
    if (!newName || newName.trim() === '') {
      console.log('Empty name provided, skipping update');
      return;
    }
    
    try {
      // Update local state immediately for instant feedback
      console.log('Setting local state to:', newName);
      setUserName(newName);
      
      // Persist to storage
      console.log('Saving to AsyncStorage...');
      await AsyncStorage.setItem(USER_STORAGE_KEY, newName);
      console.log('Successfully saved to AsyncStorage');
      
      // Verify the save
      const savedName = await AsyncStorage.getItem(USER_STORAGE_KEY);
      console.log('Verified saved name from storage:', savedName);
      
    } catch (error) {
      console.error('Failed to save user name', error);
      // Revert on error
      const savedName = await AsyncStorage.getItem(USER_STORAGE_KEY);
      console.log('Reverting to saved name:', savedName);
      setUserName(savedName || 'User');
    }
  }, []);

  // Memoize the context value to prevent unnecessary re-renders
  const contextValue = useMemo(() => ({
    userName,
    updateUserName,
  }), [userName, updateUserName]);

  // Only render children when we've finished loading the initial state
  if (isLoading) {
    console.log('UserContext still loading...');
    return null;
  }

  console.log('Rendering UserProvider with context:', contextValue);
  return (
    <UserContext.Provider value={contextValue}>
      {children}
    </UserContext.Provider>
  );
}

export function useUser() {
  const context = useContext(UserContext);
  if (context === undefined) {
    throw new Error('useUser must be used within a UserProvider');
  }
  console.log('useUser hook returning context:', context);
  return context;
}
