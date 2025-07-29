import { Drawer } from 'expo-router/drawer';
import { useTheme } from '../../contexts/ThemeContext';
import { Ionicons } from '@expo/vector-icons';

// Import screens from app/screens
import HomeScreen from '../screens/HomeScreen';
import SearchScreen from '../screens/SearchScreen';
import SettingsScreen from '../screens/SettingsScreen';
import AboutScreen from '../screens/AboutScreen';
import PrivacyPolicyScreen from '../screens/PrivacyPolicyScreen';

// This is a layout component that sets up the drawer navigation
// All screen components are now imported from app/screens
export default function DrawerLayout() {
  const { colors } = useTheme();
  
  return (
    <Drawer
      screenOptions={{
        headerShown: true,
        headerStyle: {
          backgroundColor: colors.background,
        },
        headerTintColor: colors.text,
        drawerActiveTintColor: colors.primary,
        drawerInactiveTintColor: colors.text,
        drawerLabelStyle: {
          marginLeft: -20,
          fontSize: 16,
        },
        drawerStyle: {
          backgroundColor: colors.background,
          width: '75%',
        },
      }}
    >
      {/* Home Screen */}
      <Drawer.Screen
        name="home"
        options={{
          title: 'Home',
          headerTitle: 'Weather App',
          drawerIcon: ({ color }) => (
            <Ionicons name="home-outline" size={22} color={color} />
          ),
        }}
      >
        {() => <HomeScreen />}
      </Drawer.Screen>

      {/* Search Screen */}
      <Drawer.Screen
        name="search"
        options={{
          title: 'Search',
          headerTitle: 'Search',
          drawerIcon: ({ color }) => (
            <Ionicons name="search-outline" size={22} color={color} />
          ),
        }}
      >
        {() => <SearchScreen />}
      </Drawer.Screen>

      {/* Settings Screen */}
      <Drawer.Screen
        name="settings"
        options={{
          title: 'Settings',
          headerTitle: 'Settings',
          drawerIcon: ({ color }) => (
            <Ionicons name="settings-outline" size={22} color={color} />
          ),
        }}
      >
        {() => <SettingsScreen />}
      </Drawer.Screen>

      {/* About Screen */}
      <Drawer.Screen
        name="about"
        options={{
          title: 'About',
          headerTitle: 'About',
          drawerIcon: ({ color }) => (
            <Ionicons name="information-circle-outline" size={22} color={color} />
          ),
        }}
      >
        {() => <AboutScreen />}
      </Drawer.Screen>

      {/* Privacy Policy Screen */}
      <Drawer.Screen
        name="privacy"
        options={{
          title: 'Privacy Policy',
          headerTitle: 'Privacy Policy',
          drawerIcon: ({ color }) => (
            <Ionicons name="shield-checkmark-outline" size={22} color={color} />
          ),
        }}
      >
        {() => <PrivacyPolicyScreen />}
      </Drawer.Screen>
    </Drawer>
  );
}
