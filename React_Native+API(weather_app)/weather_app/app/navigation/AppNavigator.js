import React from 'react';
import { Link, useRouter } from 'expo-router';
import { Drawer } from 'expo-router/drawer';
import { DrawerContentScrollView, DrawerItemList } from '@react-navigation/drawer';
import { Ionicons, MaterialIcons } from '@expo/vector-icons';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { useTheme } from '../../contexts/ThemeContext';
import { useUser } from '../../contexts/UserContext';

function CustomDrawerContent(props) {
  const { colors } = useTheme();
  const { user } = useUser();
  const router = useRouter();
  
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
}

export default function AppNavigator() {
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
      drawerContent={(props) => <CustomDrawerContent {...props} />}
    >
      <Drawer.Screen
        name="home/index"
        options={{
          title: 'Home',
          headerTitle: 'Weather App',
          drawerIcon: ({ color }) => (
            <Ionicons name="home-outline" size={22} color={color} />
          ),
        }}
      >
        {() => (
          <Stack.Screen
            name="index"
            options={{
              headerShown: false,
            }}
          />
        )}
      </Drawer.Screen>
      <Drawer.Screen
        name="search"
        options={{
          title: 'Search',
          headerTitle: 'Search',
          drawerIcon: ({ color }) => (
            <Ionicons name="search-outline" size={22} color={color} />
          ),
        }}
      />
      <Drawer.Screen
        name="settings"
        options={{
          title: 'Settings',
          headerTitle: 'Settings',
          drawerIcon: ({ color }) => (
            <Ionicons name="settings-outline" size={22} color={color} />
          ),
        }}
      />
      <Drawer.Screen
        name="about"
        options={{
          title: 'About',
          headerTitle: 'About',
          drawerIcon: ({ color }) => (
            <Ionicons name="information-circle-outline" size={22} color={color} />
          ),
        }}
      />
      <Drawer.Screen
        name="privacy"
        options={{
          title: 'Privacy Policy',
          headerTitle: 'Privacy Policy',
          drawerIcon: ({ color }) => (
            <Ionicons name="shield-checkmark-outline" size={22} color={color} />
          ),
        }}
      />
    </Drawer>
  );
}

// Tabs Navigator (for the home screen)
function TabsLayout() {
  return (
    <Stack>
      <Stack.Screen name="index" options={{ headerShown: false }} />
      <Stack.Screen name="loading" options={{ headerShown: false }} />
    </Stack>
  );
}

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
