import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity, Switch, Alert } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { ThemedText } from '@/components/ThemedText';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/useColorScheme';
import { router } from 'expo-router';

interface SettingItem {
  id: string;
  title: string;
  subtitle?: string;
  icon: string;
  type: 'toggle' | 'select' | 'action';
  value?: boolean;
  action?: () => void;
}

export default function SettingsScreen() {
  const colorScheme = useColorScheme();
  const colors = Colors[colorScheme ?? 'light'];
  
  const [settings, setSettings] = useState({
    darkMode: colorScheme === 'dark',
    notifications: true,
    hapticFeedback: true,
    autoSave: false,
    dataUsage: 'medium',
  });

  const handleToggle = (key: keyof typeof settings) => {
    setSettings(prev => ({ ...prev, [key]: !prev[key] }));
  };

  const handleAction = (action: string) => {
    switch (action) {
      case 'privacy':
        router.push('/privacy-policy');
        break;
      case 'about':
        router.push('/about');
        break;
      case 'contact':
        router.push('/contact');
        break;
      case 'logout':
        Alert.alert(
          'Logout',
          'Are you sure you want to logout?',
          [
            { text: 'Cancel', style: 'cancel' },
            { text: 'Logout', style: 'destructive', onPress: () => console.log('Logout') },
          ]
        );
        break;
      case 'clearCache':
        Alert.alert(
          'Clear Cache',
          'This will clear all cached data. Are you sure?',
          [
            { text: 'Cancel', style: 'cancel' },
            { text: 'Clear', style: 'destructive', onPress: () => console.log('Clear cache') },
          ]
        );
        break;
      case 'exportData':
        Alert.alert('Export Data', 'Data export started...');
        break;
      default:
        break;
    }
  };

  const settingItems: SettingItem[] = [
    // Appearance
    {
      id: '1',
      title: 'Dark Mode',
      subtitle: 'Switch between light and dark themes',
      icon: '🌙',
      type: 'toggle',
      value: settings.darkMode,
      action: () => handleToggle('darkMode'),
    },
    {
      id: '2',
      title: 'Language',
      subtitle: 'English (US)',
      icon: '🌐',
      type: 'select',
      action: () => Alert.alert('Language', 'Language selection coming soon...'),
    },

    // Notifications
    {
      id: '3',
      title: 'Push Notifications',
      subtitle: 'Receive updates and messages',
      icon: '🔔',
      type: 'toggle',
      value: settings.notifications,
      action: () => handleToggle('notifications'),
    },
    {
      id: '4',
      title: 'Haptic Feedback',
      subtitle: 'Vibrate on interactions',
      icon: '📳',
      type: 'toggle',
      value: settings.hapticFeedback,
      action: () => handleToggle('hapticFeedback'),
    },

    // Data & Storage
    {
      id: '5',
      title: 'Auto Save',
      subtitle: 'Automatically save your changes',
      icon: '💾',
      type: 'toggle',
      value: settings.autoSave,
      action: () => handleToggle('autoSave'),
    },
    {
      id: '6',
      title: 'Data Usage',
      subtitle: 'Medium (Recommended)',
      icon: '📊',
      type: 'select',
      action: () => Alert.alert('Data Usage', 'Data usage settings coming soon...'),
    },
    {
      id: '7',
      title: 'Clear Cache',
      subtitle: 'Free up storage space',
      icon: '🗑️',
      type: 'action',
      action: () => handleAction('clearCache'),
    },
    {
      id: '8',
      title: 'Export Data',
      subtitle: 'Download your portfolio data',
      icon: '📤',
      type: 'action',
      action: () => handleAction('exportData'),
    },

    // Support
    {
      id: '9',
      title: 'Help & Support',
      subtitle: 'Get help and contact support',
      icon: '❓',
      type: 'action',
      action: () => Alert.alert('Help', 'Help and support coming soon...'),
    },
    {
      id: '10',
      title: 'Privacy Policy',
      subtitle: 'Read our privacy policy',
      icon: '🔒',
      type: 'action',
      action: () => handleAction('privacy'),
    },
    {
      id: '11',
      title: 'About',
      subtitle: 'App version and information',
      icon: 'ℹ️',
      type: 'action',
      action: () => handleAction('about'),
    },
    {
      id: '12',
      title: 'Contact Us',
      subtitle: 'Get in touch with us',
      icon: '📞',
      type: 'action',
      action: () => handleAction('contact'),
    },

    // Account
    {
      id: '13',
      title: 'Logout',
      subtitle: 'Sign out of your account',
      icon: '🚪',
      type: 'action',
      action: () => handleAction('logout'),
    },
  ];

  const renderSettingItem = (item: SettingItem) => (
    <TouchableOpacity
      key={item.id}
      style={[styles.settingItem, { backgroundColor: colors.background }]}
      onPress={item.action}
    >
      <View style={styles.settingLeft}>
        <ThemedText style={styles.settingIcon}>{item.icon}</ThemedText>
        <View style={styles.settingInfo}>
          <ThemedText style={[styles.settingTitle, { color: colors.text }]}>
            {item.title}
          </ThemedText>
          {item.subtitle && (
            <ThemedText style={[styles.settingSubtitle, { color: colors.text }]}>
              {item.subtitle}
            </ThemedText>
          )}
        </View>
      </View>
      
      <View style={styles.settingRight}>
        {item.type === 'toggle' && (
          <Switch
            value={item.value}
            onValueChange={item.action}
            trackColor={{ false: '#767577', true: colors.tint }}
            thumbColor={item.value ? colors.background : '#f4f3f4'}
          />
        )}
        {item.type === 'select' && (
          <ThemedText style={styles.settingArrow}>→</ThemedText>
        )}
        {item.type === 'action' && (
          <ThemedText style={styles.settingArrow}>→</ThemedText>
        )}
      </View>
    </TouchableOpacity>
  );

  const groupSettings = (items: SettingItem[]) => {
    const groups = [
      { title: 'Appearance', items: items.slice(0, 2) },
      { title: 'Notifications', items: items.slice(2, 4) },
      { title: 'Data & Storage', items: items.slice(4, 8) },
      { title: 'Support', items: items.slice(8, 12) },
      { title: 'Account', items: items.slice(12) },
    ];
    return groups;
  };

  return (
    <View style={[styles.container, { backgroundColor: colors.background }]}>
      {/* Header */}
      <LinearGradient
        colors={
          colorScheme === 'dark'
            ? ['#1a1a2e', '#16213e']
            : ['#667eea', '#764ba2']
        }
        style={styles.header}
      >
        <View style={styles.headerContent}>
          <TouchableOpacity
            style={styles.backButton}
            onPress={() => router.back()}
          >
            <ThemedText style={[styles.backButtonText, { color: colors.text }]}>
              ← Back
            </ThemedText>
          </TouchableOpacity>
          <ThemedText style={[styles.headerTitle, { color: colors.text }]}>
            Settings
          </ThemedText>
        </View>
      </LinearGradient>

      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        {groupSettings(settingItems).map((group, groupIndex) => (
          <View key={groupIndex} style={styles.settingGroup}>
            <ThemedText style={[styles.groupTitle, { color: colors.text }]}>
              {group.title}
            </ThemedText>
            <View style={styles.settingItemsContainer}>
              {group.items.map(renderSettingItem)}
            </View>
          </View>
        ))}

        {/* App Info */}
        <View style={styles.appInfoContainer}>
          <ThemedText style={[styles.appInfoText, { color: colors.text }]}>
            Portfolio App v1.0.0
          </ThemedText>
          <ThemedText style={[styles.appInfoText, { color: colors.text }]}>
            Built with React Native & Expo
          </ThemedText>
        </View>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    paddingTop: 60,
    paddingBottom: 20,
    paddingHorizontal: 20,
  },
  headerContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  backButton: {
    marginRight: 20,
  },
  backButtonText: {
    fontSize: 16,
    fontWeight: '600',
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: 'bold',
  },
  content: {
    flex: 1,
    padding: 20,
  },
  settingGroup: {
    marginBottom: 30,
  },
  groupTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 15,
    marginLeft: 5,
  },
  settingItemsContainer: {
    borderRadius: 12,
    overflow: 'hidden',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  settingItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: 20,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(0,0,0,0.1)',
  },
  settingLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  settingIcon: {
    fontSize: 24,
    marginRight: 15,
  },
  settingInfo: {
    flex: 1,
  },
  settingTitle: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 2,
  },
  settingSubtitle: {
    fontSize: 14,
    opacity: 0.7,
  },
  settingRight: {
    alignItems: 'center',
  },
  settingArrow: {
    fontSize: 18,
    color: '#666',
  },
  appInfoContainer: {
    alignItems: 'center',
    paddingVertical: 30,
    opacity: 0.6,
  },
  appInfoText: {
    fontSize: 14,
    marginBottom: 5,
  },
}); 