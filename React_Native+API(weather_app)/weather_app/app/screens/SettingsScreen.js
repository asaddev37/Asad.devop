import React, { useState, useContext } from 'react';
import { View, Text, StyleSheet, Switch, TouchableOpacity, Image, ScrollView, TextInput } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../../contexts/ThemeContext';
import { UserContext } from '../../contexts/UserContext';
import * as ImagePicker from 'expo-image-picker';

const SettingsScreen = ({ navigation }) => {
  const { colors, styles, theme } = useTheme();
  const { user, updateProfile, updatePreferences } = useContext(UserContext);
  const [name, setName] = useState(user?.name || '');
  const [email, setEmail] = useState(user?.email || '');
  const [profilePic, setProfilePic] = useState(user?.profilePicture || null);
  const [isDarkMode, setIsDarkMode] = useState(theme === 'dark');
  const [temperatureUnit, setTemperatureUnit] = useState(user?.preferences?.temperatureUnit || 'celsius');
  const [windSpeedUnit, setWindSpeedUnit] = useState(user?.preferences?.windSpeedUnit || 'kmh');
  const [timeFormat, setTimeFormat] = useState(user?.preferences?.timeFormat || '24h');

  // Save profile changes
  const saveProfile = async () => {
    try {
      await updateProfile({
        name,
        email,
        profilePicture: profilePic,
      });
      // Show success message or navigate back
      navigation.goBack();
    } catch (error) {
      console.error('Error saving profile:', error);
    }
  };

  // Handle profile picture selection
  const pickImage = async () => {
    try {
      const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
      if (status !== 'granted') {
        alert('Sorry, we need camera roll permissions to make this work!');
        return;
      }

      const result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ImagePicker.MediaTypeOptions.Images,
        allowsEditing: true,
        aspect: [1, 1],
        quality: 0.8,
      });

      if (!result.canceled) {
        setProfilePic(result.assets[0].uri);
      }
    } catch (error) {
      console.error('Error picking image:', error);
    }
  };

  // Toggle dark mode
  const toggleDarkMode = (value) => {
    setIsDarkMode(value);
    updatePreferences({ theme: value ? 'dark' : 'light' });
  };

  // Handle temperature unit change
  const handleTemperatureUnitChange = (unit) => {
    setTemperatureUnit(unit);
    updatePreferences({ temperatureUnit: unit });
  };

  // Handle wind speed unit change
  const handleWindSpeedUnitChange = (unit) => {
    setWindSpeedUnit(unit);
    updatePreferences({ windSpeedUnit: unit });
  };

  // Handle time format change
  const handleTimeFormatChange = (format) => {
    setTimeFormat(format);
    updatePreferences({ timeFormat: format });
  };

  // Render a settings item with a switch
  const renderSwitchItem = ({ label, value, onValueChange }) => (
    <View style={[localStyles.settingItem, { borderBottomColor: colors.border }]}>
      <Text style={[localStyles.settingLabel, { color: colors.text }]}>{label}</Text>
      <Switch
        value={value}
        onValueChange={onValueChange}
        trackColor={{ false: '#767577', true: colors.primary }}
        thumbColor="white"
      />
    </View>
  );

  // Render a settings item with options
  const renderOptionsItem = ({ label, value, options, onSelect }) => (
    <View style={[localStyles.settingItem, { borderBottomColor: colors.border }]}>
      <Text style={[localStyles.settingLabel, { color: colors.text }]}>{label}</Text>
      <View style={localStyles.optionsContainer}>
        {options.map((option) => (
          <TouchableOpacity
            key={option.value}
            style={[
              localStyles.optionButton,
              value === option.value && { backgroundColor: colors.primary },
            ]}
            onPress={() => onSelect(option.value)}
          >
            <Text
              style={[
                localStyles.optionText,
                { color: value === option.value ? 'white' : colors.text },
              ]}
            >
              {option.label}
            </Text>
          </TouchableOpacity>
        ))}
      </View>
    </View>
  );

  // Render a section header
  const renderSectionHeader = (title) => (
    <Text style={[localStyles.sectionHeader, { color: colors.primary }]}>{title}</Text>
  );

  return (
    <ScrollView 
      style={[styles.container, { backgroundColor: colors.background }]}
      contentContainerStyle={localStyles.scrollContent}
    >
      {/* Profile Section */}
      <View style={[styles.card, localStyles.profileSection]}>
        <TouchableOpacity onPress={pickImage} style={localStyles.avatarContainer}>
          {profilePic ? (
            <Image source={{ uri: profilePic }} style={localStyles.avatar} />
          ) : (
            <View style={[localStyles.avatar, { backgroundColor: colors.primary + '40' }]}>
              <Ionicons name="person" size={40} color={colors.primary} />
            </View>
          )}
          <View style={[localStyles.cameraIcon, { backgroundColor: colors.primary }]}>
            <Ionicons name="camera" size={16} color="white" />
          </View>
        </TouchableOpacity>

        <View style={localStyles.profileInfo}>
          <TextInput
            style={[localStyles.nameInput, { color: colors.text }]}
            value={name}
            onChangeText={setName}
            placeholder="Your Name"
            placeholderTextColor={colors.text + '80'}
          />
          <TextInput
            style={[localStyles.emailText, { color: colors.text + '80' }]}
            value={email}
            onChangeText={setEmail}
            placeholder="your.email@example.com"
            placeholderTextColor={colors.text + '60'}
            keyboardType="email-address"
            autoCapitalize="none"
          />
        </View>
      </View>

      {/* Preferences Section */}
      <View style={[styles.card, localStyles.section]}>
        {renderSectionHeader('Preferences')}
        
        {renderSwitchItem({
          label: 'Dark Mode',
          value: isDarkMode,
          onValueChange: toggleDarkMode,
        })}

        {renderOptionsItem({
          label: 'Temperature Unit',
          value: temperatureUnit,
          options: [
            { label: '°C', value: 'celsius' },
            { label: '°F', value: 'fahrenheit' },
          ],
          onSelect: handleTemperatureUnitChange,
        })}

        {renderOptionsItem({
          label: 'Wind Speed Unit',
          value: windSpeedUnit,
          options: [
            { label: 'km/h', value: 'kmh' },
            { label: 'mph', value: 'mph' },
            { label: 'm/s', value: 'ms' },
          ],
          onSelect: handleWindSpeedUnitChange,
        })}

        {renderOptionsItem({
          label: 'Time Format',
          value: timeFormat,
          options: [
            { label: '24-hour', value: '24h' },
            { label: '12-hour', value: '12h' },
          ],
          onSelect: handleTimeFormatChange,
        })}
      </View>

      {/* App Info Section */}
      <View style={[styles.card, localStyles.section]}>
        {renderSectionHeader('App Information')}
        
        <TouchableOpacity 
          style={[localStyles.infoItem, { borderBottomColor: colors.border }]}
          onPress={() => navigation.navigate('About')}
        >
          <View style={localStyles.infoLeft}>
            <Ionicons name="information-circle-outline" size={24} color={colors.primary} />
            <Text style={[localStyles.infoText, { color: colors.text }]}>About</Text>
          </View>
          <Ionicons name="chevron-forward" size={20} color={colors.text + '80'} />
        </TouchableOpacity>

        <TouchableOpacity 
          style={[localStyles.infoItem, { borderBottomColor: colors.border }]}
          onPress={() => navigation.navigate('PrivacyPolicy')}
        >
          <View style={localStyles.infoLeft}>
            <Ionicons name="shield-checkmark-outline" size={24} color={colors.primary} />
            <Text style={[localStyles.infoText, { color: colors.text }]}>Privacy Policy</Text>
          </View>
          <Ionicons name="chevron-forward" size={20} color={colors.text + '80'} />
        </TouchableOpacity>

        <View style={localStyles.infoItem}>
          <View style={localStyles.infoLeft}>
            <Ionicons name="logo-github" size={24} color={colors.primary} />
            <Text style={[localStyles.infoText, { color: colors.text }]}>Version</Text>
          </View>
          <Text style={[localStyles.infoValue, { color: colors.text + '80' }]}>1.0.0</Text>
        </View>
      </View>

      {/* Save Button */}
      <TouchableOpacity 
        style={[localStyles.saveButton, { backgroundColor: colors.primary }]}
        onPress={saveProfile}
      >
        <Text style={localStyles.saveButtonText}>Save Changes</Text>
      </TouchableOpacity>
    </ScrollView>
  );
};

const localStyles = StyleSheet.create({
  scrollContent: {
    padding: 16,
    paddingBottom: 40,
  },
  profileSection: {
    alignItems: 'center',
    padding: 20,
    marginBottom: 16,
  },
  avatarContainer: {
    position: 'relative',
    marginBottom: 16,
  },
  avatar: {
    width: 100,
    height: 100,
    borderRadius: 50,
    justifyContent: 'center',
    alignItems: 'center',
  },
  cameraIcon: {
    position: 'absolute',
    bottom: 0,
    right: 0,
    width: 32,
    height: 32,
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: 'white',
  },
  profileInfo: {
    alignItems: 'center',
    width: '100%',
  },
  nameInput: {
    fontSize: 22,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 4,
    width: '100%',
  },
  emailText: {
    fontSize: 16,
    textAlign: 'center',
    marginBottom: 8,
    width: '100%',
  },
  section: {
    marginBottom: 16,
    padding: 0,
    overflow: 'hidden',
  },
  sectionHeader: {
    fontSize: 16,
    fontWeight: '600',
    padding: 16,
    paddingBottom: 8,
  },
  settingItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: 16,
    borderBottomWidth: 1,
  },
  settingLabel: {
    fontSize: 16,
  },
  optionsContainer: {
    flexDirection: 'row',
    borderRadius: 8,
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: '#E0E0E0',
  },
  optionButton: {
    paddingVertical: 6,
    paddingHorizontal: 12,
  },
  optionText: {
    fontSize: 14,
    fontWeight: '500',
  },
  infoItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: 16,
    borderBottomWidth: 1,
  },
  infoLeft: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  infoText: {
    fontSize: 16,
    marginLeft: 16,
  },
  infoValue: {
    fontSize: 14,
  },
  saveButton: {
    marginTop: 8,
    padding: 16,
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
    elevation: 2,
  },
  saveButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
});

export default SettingsScreen;
