import { View, StyleSheet, Switch, TextInput, TouchableOpacity, Alert } from 'react-native';
import { ThemedView } from '@/components/ThemedView';
import { ThemedText } from '@/components/ThemedText';
import { useColorScheme } from 'react-native';
import { useTheme } from '@/contexts/ThemeContext';
import { useUser } from '@/contexts/UserContext';
import { useState, useEffect } from 'react';
import { Ionicons } from '@expo/vector-icons';

export default function SettingsScreen() {
  const { theme, toggleTheme } = useTheme();
  const { userName, updateUserName } = useUser();
  const colorScheme = useColorScheme();
  const isDark = theme === 'dark' || (theme === 'system' && colorScheme === 'dark');
  const [editingName, setEditingName] = useState(false);
  const [newName, setNewName] = useState('');
  const [isUpdating, setIsUpdating] = useState(false);

  // Sync with context when userName changes
  useEffect(() => {
    console.log('SettingsScreen: userName changed to:', userName);
    setNewName(userName);
  }, [userName]);

  // Initialize newName after first render
  useEffect(() => {
    if (userName) {
      setNewName(userName);
    }
  }, []);

  const handleThemeToggle = (value: boolean) => {
    toggleTheme(value ? 'dark' : 'light');
  };

  const handleNameSave = async () => {
    const trimmedName = newName.trim();
    console.log('Saving name:', trimmedName);
    
    if (trimmedName === '') {
      Alert.alert('Error', 'Please enter a valid name');
      return;
    }

    if (trimmedName === userName) {
      console.log('Name unchanged, skipping update');
      setEditingName(false);
      return;
    }

    try {
      setIsUpdating(true);
      console.log('Calling updateUserName with:', trimmedName);
      await updateUserName(trimmedName);
      console.log('Name update successful');
      setEditingName(false);
    } catch (error) {
      console.error('Failed to update name:', error);
      Alert.alert('Error', 'Failed to update name. Please try again.');
    } finally {
      setIsUpdating(false);
    }
  };

  return (
    <ThemedView style={styles.container}>
      <View style={styles.section}>
        <ThemedText style={styles.sectionTitle}>Profile</ThemedText>
        <View style={styles.settingItem}>
          <ThemedText style={styles.settingText}>Your Name</ThemedText>
          {editingName ? (
            <View style={styles.nameEditContainer}>
              <TextInput
                style={[styles.nameInput, { color: isDark ? '#fff' : '#000' }]}
                value={newName}
                onChangeText={setNewName}
                autoFocus
                onSubmitEditing={handleNameSave}
                placeholder="Enter your name"
                placeholderTextColor={isDark ? '#888' : '#999'}
                returnKeyType="done"
                editable={!isUpdating}
              />
              <TouchableOpacity 
                onPress={handleNameSave} 
                style={[styles.saveButton, isUpdating && styles.saveButtonDisabled]}
                disabled={isUpdating}
              >
                <Ionicons 
                  name={isUpdating ? 'hourglass-outline' : 'checkmark'} 
                  size={20} 
                  color={isUpdating ? '#888' : '#4F46E5'} 
                />
              </TouchableOpacity>
            </View>
          ) : (
            <TouchableOpacity 
              style={styles.nameContainer}
              onPress={() => setEditingName(true)}
            >
              <ThemedText style={styles.nameText}>{userName}</ThemedText>
              <Ionicons name="pencil" size={16} color="#6B7280" />
            </TouchableOpacity>
          )}
        </View>
      </View>

      <View style={styles.section}>
        <ThemedText style={styles.sectionTitle}>Appearance</ThemedText>
        <View style={styles.settingItem}>
          <ThemedText style={styles.settingText}>Dark Mode</ThemedText>
          <Switch
            value={isDark}
            onValueChange={handleThemeToggle}
            trackColor={{ false: '#767577', true: '#4F46E5' }}
            thumbColor={isDark ? '#f5dd4b' : '#f4f3f4'}
          />
        </View>
      </View>
      
      <View style={styles.section}>
        <ThemedText style={styles.sectionTitle}>Notifications</ThemedText>
        <View style={styles.settingItem}>
          <ThemedText style={styles.settingText}>Push Notifications</ThemedText>
          <Switch
            value={true}
            onValueChange={() => {}}
            trackColor={{ false: '#767577', true: '#4F46E5' }}
          />
        </View>
      </View>
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
  },
  section: {
    marginTop: 20,
    marginBottom: 10,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 15,
    color: '#6B7280',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  settingItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 15,
    borderBottomWidth: 1,
    borderBottomColor: '#E5E7EB',
  },
  settingText: {
    fontSize: 16,
    color: '#111827',
  },
  nameContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  nameText: {
    fontSize: 16,
    marginRight: 8,
    color: '#111827',
  },
  nameEditContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  nameInput: {
    borderWidth: 1,
    borderColor: '#E5E7EB',
    borderRadius: 8,
    padding: 8,
    minWidth: 150,
    marginRight: 8,
    backgroundColor: '#fff',
  },
  saveButton: {
    padding: 8,
    opacity: 1,
  },
  saveButtonDisabled: {
    opacity: 0.5,
  },
});
