import React from 'react';
import { Tabs } from 'expo-router';
import { Platform } from 'react-native';
import { useColorScheme } from '@/hooks/useColorScheme';
import { Colors } from '@/constants/Colors';
import { IconSymbol } from '@/components/ui/IconSymbol';

/**
 * You can explore the built-in icon families and icons on the web at https://icons.expo.fyi/
 */
function TabBarIcon(props: {
  name: React.ComponentProps<typeof IconSymbol>['name'];
  color: string;
}) {
  return <IconSymbol size={24} style={{ marginBottom: -3 }} {...props} />;
}

export default function TabLayout() {
  const colorScheme = useColorScheme();
  const colors = Colors[colorScheme ?? 'light'];

  return (
    <Tabs
      screenOptions={{
        tabBarActiveTintColor: colors.tint,
        tabBarInactiveTintColor: colors.tabIconDefault,
        tabBarStyle: {
          backgroundColor: colors.cardBackground,
          borderTopWidth: 1,
          borderTopColor: colors.border,
          height: Platform.OS === 'ios' ? 88 : 70,
          paddingBottom: Platform.OS === 'ios' ? 30 : 15,
          paddingTop: 8,
          shadowColor: colors.shadow,
          shadowOffset: { width: 0, height: -2 },
          shadowOpacity: 0.1,
          shadowRadius: 8,
          elevation: 8,
        },
        tabBarLabelStyle: {
          fontSize: 11,
          fontWeight: '600',
          marginTop: 4,
        },
        tabBarIconStyle: {
          marginBottom: 2,
        },
        headerShown: false,
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: 'Home',
          tabBarIcon: ({ color, focused }) => (
            <TabBarIcon 
              name={focused ? "house.fill" : "house"} 
              color={color} 
            />
          ),
        }}
      />
      <Tabs.Screen
        name="portfolio"
        options={{
          title: 'Portfolio',
          tabBarIcon: ({ color, focused }) => (
            <TabBarIcon 
              name={focused ? "folder.fill" : "folder"} 
              color={color} 
            />
          ),
        }}
      />
      <Tabs.Screen
        name="skills"
        options={{
          title: 'Skills',
          tabBarIcon: ({ color, focused }) => (
            <TabBarIcon 
              name={focused ? "star.fill" : "star"} 
              color={color} 
            />
          ),
        }}
      />
      <Tabs.Screen
        name="experience"
        options={{
          title: 'Experience',
          tabBarIcon: ({ color, focused }) => (
            <TabBarIcon 
              name={focused ? "briefcase.fill" : "briefcase"} 
              color={color} 
            />
          ),
        }}
      />
      <Tabs.Screen
        name="contact"
        options={{
          title: 'Contact',
          tabBarIcon: ({ color, focused }) => (
            <TabBarIcon 
              name={focused ? "envelope.fill" : "envelope"} 
              color={color} 
            />
          ),
        }}
      />
      <Tabs.Screen
        name="profile"
        options={{
          title: 'Profile',
          tabBarIcon: ({ color, focused }) => (
            <TabBarIcon 
              name={focused ? "person.fill" : "person"} 
              color={color} 
            />
          ),
        }}
      />
    </Tabs>
  );
}
