import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, Switch, TouchableOpacity, Platform } from 'react-native';
import DateTimePicker from '@react-native-community/datetimepicker';
import { MaterialIcons } from '@expo/vector-icons';

export type NotificationSettings = {
  enabled: boolean;
  timeBefore: number; // in minutes
  customTime?: Date;
  type: 'default' | 'custom';
};

type NotificationSettingsNativeProps = {
  settings: NotificationSettings | undefined;
  onSettingsChange: (settings: NotificationSettings) => void;
};

export const NotificationSettingsNative: React.FC<NotificationSettingsNativeProps> = ({
  settings = {
    enabled: false,
    timeBefore: 30, // 30 minutes
    type: 'default',
  },
  onSettingsChange,
}) => {
  const [showTimePicker, setShowTimePicker] = useState(false);
  const [localSettings, setLocalSettings] = useState<NotificationSettings>(settings);

  useEffect(() => {
    setLocalSettings(settings);
  }, [settings]);

  const handleToggleNotifications = (enabled: boolean) => {
    const newSettings = { ...localSettings, enabled };
    setLocalSettings(newSettings);
    onSettingsChange(newSettings);
  };

  const handleTimeBeforeChange = (minutes: number) => {
    const newSettings = { ...localSettings, timeBefore: minutes, type: 'default' as const };
    setLocalSettings(newSettings);
    onSettingsChange(newSettings);
  };

  const handleCustomTimeChange = (event: any, selectedDate?: Date) => {
    setShowTimePicker(Platform.OS === 'ios');
    
    if (selectedDate) {
      const newSettings = { 
        ...localSettings, 
        customTime: selectedDate,
        type: 'custom' as const,
      };
      setLocalSettings(newSettings);
      onSettingsChange(newSettings);
    }
  };

  const handleCustomTimePress = () => {
    if (Platform.OS === 'android') {
      setShowTimePicker(true);
    }
    
    // Initialize with current time + 1 hour if not set
    if (!localSettings.customTime) {
      const now = new Date();
      now.setHours(now.getHours() + 1);
      now.setMinutes(0);
      now.setSeconds(0);
      
      const newSettings = { 
        ...localSettings, 
        customTime: now,
        type: 'custom' as const,
      };
      setLocalSettings(newSettings);
      onSettingsChange(newSettings);
    }
  };

  const timeOptions = [
    { label: 'At time of task', value: 0 },
    { label: '5 min before', value: 5 },
    { label: '15 min before', value: 15 },
    { label: '30 min before', value: 30 },
    { label: '1 hour before', value: 60 },
    { label: '1 day before', value: 1440 },
  ];

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.label}>Notifications</Text>
        <Switch
          value={localSettings.enabled}
          onValueChange={handleToggleNotifications}
          trackColor={{ false: '#D1D5DB', true: '#3B82F6' }}
          thumbColor="#FFFFFF"
        />
      </View>

      {localSettings.enabled && (
        <View style={styles.optionsContainer}>
          <Text style={styles.optionLabel}>Remind me</Text>
          
          <View style={styles.timeOptions}>
            {timeOptions.map((option) => (
              <TouchableOpacity
                key={option.value}
                style={[
                  styles.timeOption,
                  localSettings.type === 'default' && 
                  localSettings.timeBefore === option.value && 
                  styles.timeOptionActive,
                ]}
                onPress={() => handleTimeBeforeChange(option.value)}
              >
                <Text
                  style={[
                    styles.timeOptionText,
                    localSettings.type === 'default' && 
                    localSettings.timeBefore === option.value && 
                    styles.timeOptionTextActive,
                  ]}
                >
                  {option.label}
                </Text>
              </TouchableOpacity>
            ))}
            
            <TouchableOpacity
              style={[
                styles.timeOption,
                localSettings.type === 'custom' && styles.timeOptionActive,
              ]}
              onPress={handleCustomTimePress}
            >
              <Text
                style={[
                  styles.timeOptionText,
                  localSettings.type === 'custom' && styles.timeOptionTextActive,
                ]}
              >
                Custom time
              </Text>
            </TouchableOpacity>
          </View>

          {localSettings.type === 'custom' && localSettings.customTime && (
            <View style={styles.customTimeContainer}>
              <Text style={styles.customTimeLabel}>Custom notification time:</Text>
              <TouchableOpacity
                style={styles.customTimeButton}
                onPress={() => setShowTimePicker(true)}
              >
                <Text style={styles.customTimeText}>
                  {localSettings.customTime.toLocaleTimeString([], {
                    hour: '2-digit',
                    minute: '2-digit',
                    hour12: true,
                  })}
                </Text>
                <MaterialIcons name="access-time" size={20} color="#3B82F6" />
              </TouchableOpacity>
            </View>
          )}

          {showTimePicker && (
            <DateTimePicker
              value={localSettings.customTime || new Date()}
              mode="time"
              display={Platform.OS === 'ios' ? 'spinner' : 'default'}
              onChange={handleCustomTimeChange}
              minuteInterval={5}
            />
          )}
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginBottom: 20,
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  label: {
    fontSize: 16,
    fontWeight: '600',
    color: '#374151',
  },
  optionsContainer: {
    marginTop: 12,
    borderTopWidth: 1,
    borderTopColor: '#F3F4F6',
    paddingTop: 12,
  },
  optionLabel: {
    fontSize: 14,
    color: '#6B7280',
    marginBottom: 8,
  },
  timeOptions: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginHorizontal: -4,
    marginBottom: 8,
  },
  timeOption: {
    paddingVertical: 8,
    paddingHorizontal: 12,
    margin: 4,
    borderRadius: 6,
    borderWidth: 1,
    borderColor: '#E5E7EB',
    backgroundColor: '#F9FAFB',
  },
  timeOptionActive: {
    backgroundColor: '#EFF6FF',
    borderColor: '#3B82F6',
  },
  timeOptionText: {
    fontSize: 14,
    color: '#6B7280',
  },
  timeOptionTextActive: {
    color: '#3B82F6',
    fontWeight: '500',
  },
  customTimeContainer: {
    marginTop: 12,
    paddingTop: 12,
    borderTopWidth: 1,
    borderTopColor: '#F3F4F6',
  },
  customTimeLabel: {
    fontSize: 14,
    color: '#6B7280',
    marginBottom: 8,
  },
  customTimeButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: 12,
    backgroundColor: '#F3F4F6',
    borderRadius: 8,
  },
  customTimeText: {
    fontSize: 16,
    color: '#111827',
    fontWeight: '500',
  },
});
