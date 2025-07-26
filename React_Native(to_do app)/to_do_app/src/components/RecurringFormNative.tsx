import React, { useState } from 'react';
import { View, Text, StyleSheet, Switch, TouchableOpacity, Platform } from 'react-native';
import DateTimePicker from '@react-native-community/datetimepicker';
import { MaterialIcons } from '@expo/vector-icons';

type Frequency = 'daily' | 'weekly' | 'monthly' | 'yearly';
type Weekday = 'sunday' | 'monday' | 'tuesday' | 'wednesday' | 'thursday' | 'friday' | 'saturday';

export type RecurringPattern = {
  frequency: Frequency;
  interval: number;
  endDate?: Date;
  weekdays?: Weekday[];
  monthDay?: number;
};

type RecurringFormNativeProps = {
  isRecurring: boolean;
  onRecurringChange: (isRecurring: boolean) => void;
  recurringPattern: RecurringPattern | undefined;
  onRecurringPatternChange: (pattern: RecurringPattern) => void;
};

export const RecurringFormNative: React.FC<RecurringFormNativeProps> = ({
  isRecurring,
  onRecurringChange,
  recurringPattern,
  onRecurringPatternChange,
}) => {
  const [showEndDatePicker, setShowEndDatePicker] = useState(false);
  
  const defaultPattern: RecurringPattern = {
    frequency: 'weekly',
    interval: 1,
    weekdays: ['monday'],
  };
  
  const pattern = isRecurring ? { ...defaultPattern, ...recurringPattern } : defaultPattern;

  const frequencyOptions: { value: Frequency; label: string }[] = [
    { value: 'daily', label: 'Daily' },
    { value: 'weekly', label: 'Weekly' },
    { value: 'monthly', label: 'Monthly' },
    { value: 'yearly', label: 'Yearly' },
  ];

  const weekdayOptions: { value: Weekday; label: string }[] = [
    { value: 'sunday', label: 'Sun' },
    { value: 'monday', label: 'Mon' },
    { value: 'tuesday', label: 'Tue' },
    { value: 'wednesday', label: 'Wed' },
    { value: 'thursday', label: 'Thu' },
    { value: 'friday', label: 'Fri' },
    { value: 'saturday', label: 'Sat' },
  ];

  const handleFrequencyChange = (frequency: Frequency) => {
    const newPattern = { ...pattern, frequency };
    
    if (frequency !== 'weekly') {
      delete newPattern.weekdays;
    } else if (!newPattern.weekdays) {
      newPattern.weekdays = ['monday'];
    }
    
    onRecurringPatternChange(newPattern);
  };

  const handleIntervalChange = (interval: number) => {
    onRecurringPatternChange({ ...pattern, interval });
  };

  const handleEndDateChange = (event: any, selectedDate?: Date) => {
    const currentDate = selectedDate || pattern.endDate || new Date();
    setShowEndDatePicker(Platform.OS === 'ios');
    onRecurringPatternChange({ ...pattern, endDate: currentDate });
  };

  const toggleWeekday = (weekday: Weekday) => {
    if (!pattern.weekdays) return;
    
    const newWeekdays = pattern.weekdays.includes(weekday)
      ? pattern.weekdays.filter((w) => w !== weekday)
      : [...pattern.weekdays, weekday];

    onRecurringPatternChange({ ...pattern, weekdays: newWeekdays });
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.label}>Recurring Task</Text>
        <Switch
          value={isRecurring}
          onValueChange={onRecurringChange}
          trackColor={{ false: '#D1D5DB', true: '#3B82F6' }}
          thumbColor="#FFFFFF"
        />
      </View>

      {isRecurring && (
        <View style={styles.recurringOptions}>
          <View style={styles.optionGroup}>
            <Text style={styles.optionLabel}>Frequency</Text>
            <View style={styles.frequencyButtons}>
              {frequencyOptions.map((option) => (
                <TouchableOpacity
                  key={option.value}
                  style={[
                    styles.frequencyButton,
                    pattern.frequency === option.value && styles.frequencyButtonActive,
                  ]}
                  onPress={() => handleFrequencyChange(option.value)}
                >
                  <Text
                    style={[
                      styles.frequencyButtonText,
                      pattern.frequency === option.value && styles.frequencyButtonTextActive,
                    ]}
                  >
                    {option.label}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>
          </View>

          <View style={styles.optionGroup}>
            <Text style={styles.optionLabel}>Repeat every</Text>
            <View style={styles.intervalContainer}>
              <TouchableOpacity
                style={styles.intervalButton}
                onPress={() => handleIntervalChange(Math.max(1, (pattern.interval || 1) - 1))}
              >
                <MaterialIcons name="remove" size={20} color="#6B7280" />
              </TouchableOpacity>
              <Text style={styles.intervalValue}>{pattern.interval || 1}</Text>
              <TouchableOpacity
                style={styles.intervalButton}
                onPress={() => handleIntervalChange((pattern.interval || 1) + 1)}
              >
                <MaterialIcons name="add" size={20} color="#6B7280" />
              </TouchableOpacity>
              <Text style={styles.intervalLabel}>
                {pattern.interval === 1
                  ? pattern.frequency.slice(0, -1)
                  : pattern.frequency}
              </Text>
            </View>
          </View>

          {pattern.frequency === 'weekly' && (
            <View style={styles.optionGroup}>
              <Text style={styles.optionLabel}>On weekdays</Text>
              <View style={styles.weekdaysContainer}>
                {weekdayOptions.map((day) => (
                  <TouchableOpacity
                    key={day.value}
                    style={[
                      styles.weekdayButton,
                      pattern.weekdays?.includes(day.value) && styles.weekdayButtonActive,
                    ]}
                    onPress={() => toggleWeekday(day.value)}
                  >
                    <Text
                      style={[
                        styles.weekdayText,
                        pattern.weekdays?.includes(day.value) && styles.weekdayTextActive,
                      ]}
                    >
                      {day.label[0]}
                    </Text>
                  </TouchableOpacity>
                ))}
              </View>
            </View>
          )}

          <View style={styles.optionGroup}>
            <Text style={styles.optionLabel}>End Date (Optional)</Text>
            <TouchableOpacity
              style={styles.datePickerButton}
              onPress={() => setShowEndDatePicker(true)}
            >
              <Text style={styles.dateText}>
                {pattern.endDate
                  ? pattern.endDate.toLocaleDateString()
                  : 'No end date'}
              </Text>
              <MaterialIcons name="calendar-today" size={20} color="#6B7280" />
            </TouchableOpacity>
            {showEndDatePicker && (
              <DateTimePicker
                value={pattern.endDate || new Date()}
                mode="date"
                display={Platform.OS === 'ios' ? 'spinner' : 'default'}
                onChange={handleEndDateChange}
                minimumDate={new Date()}
              />
            )}
          </View>
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
  recurringOptions: {
    marginTop: 12,
    borderTopWidth: 1,
    borderTopColor: '#F3F4F6',
    paddingTop: 12,
  },
  optionGroup: {
    marginBottom: 16,
  },
  optionLabel: {
    fontSize: 14,
    color: '#6B7280',
    marginBottom: 8,
  },
  frequencyButtons: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginHorizontal: -4,
  },
  frequencyButton: {
    paddingVertical: 8,
    paddingHorizontal: 12,
    margin: 4,
    borderRadius: 6,
    borderWidth: 1,
    borderColor: '#E5E7EB',
    backgroundColor: '#F9FAFB',
  },
  frequencyButtonActive: {
    backgroundColor: '#EFF6FF',
    borderColor: '#3B82F6',
  },
  frequencyButtonText: {
    fontSize: 14,
    color: '#6B7280',
  },
  frequencyButtonTextActive: {
    color: '#3B82F6',
    fontWeight: '500',
  },
  intervalContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  intervalButton: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: '#F3F4F6',
    justifyContent: 'center',
    alignItems: 'center',
  },
  intervalValue: {
    fontSize: 18,
    fontWeight: '600',
    marginHorizontal: 12,
    minWidth: 24,
    textAlign: 'center',
  },
  intervalLabel: {
    marginLeft: 8,
    fontSize: 14,
    color: '#6B7280',
  },
  weekdaysContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 4,
  },
  weekdayButton: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: '#F3F4F6',
    justifyContent: 'center',
    alignItems: 'center',
  },
  weekdayButtonActive: {
    backgroundColor: '#3B82F6',
  },
  weekdayText: {
    fontSize: 14,
    color: '#6B7280',
    fontWeight: '500',
  },
  weekdayTextActive: {
    color: '#FFFFFF',
  },
  datePickerButton: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderWidth: 1,
    borderColor: '#E5E7EB',
    borderRadius: 8,
    backgroundColor: '#F9FAFB',
  },
  dateText: {
    fontSize: 16,
    color: '#111827',
  },
});
