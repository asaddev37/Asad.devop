import React from 'react';
import { View, TouchableOpacity, Text, StyleSheet, Animated } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { IconSymbol } from '@/components/ui/IconSymbol';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/useColorScheme';

interface TabItem {
  name: string;
  icon: string;
  label: string;
}

interface CustomTabBarProps {
  state: any;
  descriptors: any;
  navigation: any;
}

const tabs: TabItem[] = [
  { name: 'index', icon: 'house.fill', label: 'Home' },
  { name: 'portfolio', icon: 'folder.fill', label: 'Portfolio' },
  { name: 'skills', icon: 'star.fill', label: 'Skills' },
  { name: 'experience', icon: 'briefcase.fill', label: 'Experience' },
  { name: 'contact', icon: 'envelope.fill', label: 'Contact' },
  { name: 'profile', icon: 'person.fill', label: 'Profile' },
];

export default function CustomTabBar({ state, descriptors, navigation }: CustomTabBarProps) {
  const colorScheme = useColorScheme();
  const colors = Colors[colorScheme ?? 'light'];

  return (
    <View style={[styles.container, { backgroundColor: colors.cardBackground }]}>
      <LinearGradient
        colors={
          colorScheme === 'dark'
            ? ['rgba(30, 64, 175, 0.1)', 'rgba(124, 58, 237, 0.1)']
            : ['rgba(102, 126, 234, 0.05)', 'rgba(118, 75, 162, 0.05)']
        }
        style={styles.gradientBackground}
      />
      
      <View style={styles.tabContainer}>
        {state.routes.map((route: any, index: number) => {
          const { options } = descriptors[route.key];
          const label = options.tabBarLabel ?? options.title ?? route.name;
          const isFocused = state.index === index;

          const onPress = () => {
            const event = navigation.emit({
              type: 'tabPress',
              target: route.key,
              canPreventDefault: true,
            });

            if (!isFocused && !event.defaultPrevented) {
              navigation.navigate(route.name);
            }
          };

          const tab = tabs.find(t => t.name === route.name);

          return (
            <TouchableOpacity
              key={route.key}
              onPress={onPress}
              style={styles.tabButton}
              activeOpacity={0.7}
            >
              <View style={[
                styles.tabContent,
                isFocused && { backgroundColor: colors.tint + '20' }
              ]}>
                <View style={[
                  styles.iconContainer,
                  isFocused && { backgroundColor: colors.tint }
                ]}>
                  <IconSymbol
                    name={tab?.icon as any}
                    size={24}
                    color={isFocused ? colors.cardBackground : colors.tabIconDefault}
                  />
                </View>
                <Text style={[
                  styles.tabLabel,
                  { color: isFocused ? colors.tint : colors.tabIconDefault }
                ]}>
                  {tab?.label}
                </Text>
              </View>
            </TouchableOpacity>
          );
        })}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    height: 90,
    borderTopWidth: 1,
    borderTopColor: 'rgba(0,0,0,0.1)',
    position: 'relative',
  },
  gradientBackground: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  tabContainer: {
    flexDirection: 'row',
    flex: 1,
    paddingHorizontal: 10,
    paddingTop: 8,
    paddingBottom: 20,
  },
  tabButton: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  tabContent: {
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 12,
    minWidth: 60,
  },
  iconContainer: {
    width: 40,
    height: 40,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 4,
  },
  tabLabel: {
    fontSize: 10,
    fontWeight: '600',
    textAlign: 'center',
  },
}); 