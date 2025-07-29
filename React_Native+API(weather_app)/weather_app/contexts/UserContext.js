import React, { createContext, useState, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';

export const UserContext = createContext();

export const UserProvider = ({ children }) => {
  const [user, setUser] = useState({
    name: 'Guest',
    email: '',
    profilePicture: null,
    locations: [],
    preferences: {
      temperatureUnit: 'celsius',
      windSpeedUnit: 'kmh',
      timeFormat: '24h',
      theme: 'light',
    },
  });
  const [isLoading, setIsLoading] = useState(true);

  // Load user data from storage on app start
  useEffect(() => {
    const loadUserData = async () => {
      try {
        const userData = await AsyncStorage.getItem('userData');
        if (userData) {
          setUser(JSON.parse(userData));
        }
      } catch (error) {
        console.error('Error loading user data:', error);
      } finally {
        setIsLoading(false);
      }
    };

    loadUserData();
  }, []);

  // Save user data to storage whenever it changes
  const saveUserData = async (newUserData) => {
    try {
      const updatedUser = { ...user, ...newUserData };
      setUser(updatedUser);
      await AsyncStorage.setItem('userData', JSON.stringify(updatedUser));
    } catch (error) {
      console.error('Error saving user data:', error);
    }
  };

  // Update user profile
  const updateProfile = async (profileData) => {
    await saveUserData({ ...user, ...profileData });
  };

  // Update user preferences
  const updatePreferences = async (preferences) => {
    await saveUserData({
      ...user,
      preferences: { ...user.preferences, ...preferences },
    });
  };

  // Add a new location to user's saved locations
  const addLocation = async (location) => {
    if (!user.locations.some((loc) => loc.id === location.id)) {
      const updatedLocations = [...user.locations, location];
      await saveUserData({ ...user, locations: updatedLocations });
    }
  };

  // Remove a location from user's saved locations
  const removeLocation = async (locationId) => {
    const updatedLocations = user.locations.filter((loc) => loc.id !== locationId);
    await saveUserData({ ...user, locations: updatedLocations });
  };

  return (
    <UserContext.Provider
      value={{
        user,
        isLoading,
        updateProfile,
        updatePreferences,
        addLocation,
        removeLocation,
      }}
    >
      {children}
    </UserContext.Provider>
  );
};

// Custom hook to use the user context
export const useUser = () => {
  const context = React.useContext(UserContext);
  if (context === undefined) {
    throw new Error('useUser must be used within a UserProvider');
  }
  return context;
};

export default UserContext;
