import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import LoadingScreen2 from '../screens/LoadingScreen2.js';
import HomeScreen from '../screens/HomeScreen';
import LoginScreen from '../screens/LoginScreen.js';
import SignupScreen from '../screens/SignupScreen.js';
import { RootStackParamList } from '../types/navigation';

const Stack = createNativeStackNavigator<RootStackParamList>();

const AppNavigator = () => {
  return (
    <NavigationContainer>
      <Stack.Navigator
        screenOptions={{
          headerShown: false,
          contentStyle: { backgroundColor: '#fff' },
        }}
      >
        <Stack.Screen name="Loading" component={LoadingScreen2} />
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="Login" component={LoginScreen} />
        <Stack.Screen name="Signup" component={SignupScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
};

export default AppNavigator;
