import { Drawer } from 'expo-router/drawer';
import { Ionicons } from '@expo/vector-icons';
import { DrawerToggleButton } from '@react-navigation/drawer';
import { useTheme } from '@/contexts/ThemeContext';

export default function DrawerLayout() {
  const { theme } = useTheme();
  
  return (
    <Drawer
      screenOptions={{
        headerStyle: {
          backgroundColor: theme === 'dark' ? '#1F2937' : '#4F46E5',
        },
        headerTintColor: '#fff',
        headerTitleStyle: {
          fontWeight: 'bold',
        },
        drawerActiveTintColor: '#4F46E5',
        drawerInactiveTintColor: theme === 'dark' ? '#E5E7EB' : '#333',
        drawerActiveBackgroundColor: theme === 'dark' ? '#374151' : '#EEF2FF',
        drawerInactiveBackgroundColor: 'transparent',
        drawerLabelStyle: {
          marginLeft: -20,
          fontSize: 15,
        },
        drawerType: 'front',
        drawerStyle: {
          backgroundColor: theme === 'dark' ? '#111827' : '#fff',
          width: '75%',
        },
        headerLeft: () => <DrawerToggleButton tintColor="#fff" />,
      }}
    >
      <Drawer.Screen
        name="settings"
        options={{
          title: 'Settings',
          drawerIcon: ({ color, size }) => (
            <Ionicons name="settings-outline" size={size} color={color} />
          ),
        }}
      />
      <Drawer.Screen
        name="about"
        options={{
          title: 'About',
          drawerIcon: ({ color, size }) => (
            <Ionicons name="information-circle-outline" size={size} color={color} />
          ),
        }}
      />
      <Drawer.Screen
        name="privacy"
        options={{
          title: 'Privacy Policy',
          drawerIcon: ({ color, size }) => (
            <Ionicons name="shield-checkmark-outline" size={size} color={color} />
          ),
        }}
      />
    </Drawer>
  );
}
