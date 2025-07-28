import React, { useContext } from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createDrawerNavigator, DrawerContentScrollView, DrawerItemList, DrawerItem } from '@react-navigation/drawer';
import { Ionicons, MaterialIcons } from '@expo/vector-icons';
import { View, Text, StyleSheet, Image, TouchableOpacity } from 'react-native';
import { useTheme } from '../../contexts/ThemeContext';
import { UserContext } from '../../contexts/UserContext';

// Import screens
import HomeScreen from '../screens/HomeScreen';
import SearchScreen from '../screens/SearchScreen';
import SettingsScreen from '../screens/SettingsScreen';
import AboutScreen from '../screens/AboutScreen';
import PrivacyPolicyScreen from '../screens/PrivacyPolicyScreen';
import LoadingScreen from '../screens/LoadingScreen';

const Tab = createBottomTabNavigator();
const Stack = createNativeStackNavigator();
const Drawer = createDrawerNavigator();

// Custom Drawer Content
const CustomDrawerContent = (props) => {
  const { colors } = useTheme();
  const { user } = useContext(UserContext);
  
  return (
    <View style={[styles.drawerContainer, { backgroundColor: colors.background }]}>
      <View style={[styles.drawerHeader, { backgroundColor: colors.primary }]}>
        <View style={styles.avatarContainer}>
          <Ionicons name="person-circle" size={60} color="white" />
        </View>
        <Text style={styles.userName}>
          {user?.name ? `Hi, ${user.name}` : 'Welcome'}
        </Text>
        <Text style={styles.userEmail}>{user?.email || ''}</Text>
      </View>
      
      <DrawerContentScrollView {...props}>
        <DrawerItemList {...props} />
      </DrawerContentScrollView>
      
      <View style={[styles.drawerFooter, { borderTopColor: colors.border }]}>
        <Text style={[styles.versionText, { color: colors.textSecondary }]}>
          Weather App v1.0.0
        </Text>
      </View>
    </View>
  );
};

// Drawer Navigator
const DrawerNavigator = () => {
  const { colors } = useTheme();
  
  return (
    <Drawer.Navigator
      drawerContent={props => <CustomDrawerContent {...props} />}
      screenOptions={{
        drawerActiveTintColor: colors.primary,
        drawerInactiveTintColor: colors.text,
        drawerLabelStyle: {
          marginLeft: -20,
          fontSize: 15,
        },
        drawerStyle: {
          width: '75%',
        },
      }}
    >
      <Drawer.Screen 
        name="Home" 
        component={HomeScreen}
        options={{
          drawerIcon: ({ color }) => (
            <Ionicons name="home-outline" size={22} color={color} />
          ),
        }}
      />
      <Drawer.Screen 
        name="Search" 
        component={SearchScreen}
        options={{
          drawerIcon: ({ color }) => (
            <Ionicons name="search-outline" size={22} color={color} />
          ),
        }}
      />
      <Drawer.Screen 
        name="Settings" 
        component={SettingsScreen}
        options={{
          drawerIcon: ({ color }) => (
            <Ionicons name="settings-outline" size={22} color={color} />
          ),
        }}
      />
      <Drawer.Screen 
        name="About" 
        component={AboutScreen} 
        options={{
          drawerIcon: ({ color }) => (
            <Ionicons name="information-circle-outline" size={22} color={color} />
          ),
        }}
      />
      <Drawer.Screen 
        name="Privacy Policy" 
        component={PrivacyPolicyScreen} 
        options={{
          drawerIcon: ({ color }) => (
            <Ionicons name="shield-checkmark-outline" size={22} color={color} />
          ),
        }}
      />
    </Drawer.Navigator>
  );
};

// Main App Tabs - Removed in favor of drawer navigation

// Main App Navigator
const AppNavigator = () => {
  return (
    <Stack.Navigator 
      initialRouteName="Loading"
      screenOptions={{
        headerShown: false,
      }}
    >
      <Stack.Screen 
        name="Loading" 
        component={LoadingScreen}
        options={{
          animationEnabled: false,
        }}
      />
      <Stack.Screen 
        name="Main" 
        component={DrawerNavigator}
        options={{
          animationEnabled: false,
        }}
      />
    </Stack.Navigator>
  );
};

const styles = StyleSheet.create({
  drawerContainer: {
    flex: 1,
  },
  drawerHeader: {
    padding: 20,
    paddingTop: 60,
    paddingBottom: 30,
  },
  avatarContainer: {
    alignItems: 'center',
    marginBottom: 10,
  },
  userName: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
    marginTop: 10,
    textAlign: 'center',
  },
  userEmail: {
    color: 'rgba(255, 255, 255, 0.8)',
    fontSize: 14,
    textAlign: 'center',
  },
  drawerFooter: {
    padding: 20,
    borderTopWidth: 1,
  },
  versionText: {
    fontSize: 12,
    textAlign: 'center',
  },
});

export default AppNavigator;
