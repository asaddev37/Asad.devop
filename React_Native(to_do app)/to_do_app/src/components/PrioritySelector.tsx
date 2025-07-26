import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';

type Priority = 'low' | 'medium' | 'high';

type PriorityOption = {
  value: Priority;
  label: string;
  color: string;
  icon: React.ComponentProps<typeof MaterialIcons>['name'];
};

const priorityOptions: PriorityOption[] = [
  { value: 'low', label: 'Low', color: '#10B981', icon: 'arrow-downward' },
  { value: 'medium', label: 'Medium', color: '#F59E0B', icon: 'remove' },
  { value: 'high', label: 'High', color: '#EF4444', icon: 'arrow-upward' },
];

type PrioritySelectorProps = {
  selectedPriority: Priority;
  onPriorityChange: (priority: Priority) => void;
};

export const PrioritySelector: React.FC<PrioritySelectorProps> = ({
  selectedPriority,
  onPriorityChange,
}) => {
  return (
    <View style={styles.container}>
      <Text style={styles.label}>Priority</Text>
      <View style={styles.buttonsContainer}>
        {priorityOptions.map((option) => (
          <TouchableOpacity
            key={option.value}
            style={[
              styles.button,
              selectedPriority === option.value && {
                backgroundColor: `${option.color}20`,
                borderColor: option.color,
              },
            ]}
            onPress={() => onPriorityChange(option.value)}
            activeOpacity={0.7}
          >
            <MaterialIcons
              name={option.icon}
              size={20}
              color={selectedPriority === option.value ? option.color : '#6B7280'}
            />
            <Text
              style={[
                styles.buttonText,
                selectedPriority === option.value && { color: option.color },
              ]}
            >
              {option.label}
            </Text>
          </TouchableOpacity>
        ))}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginBottom: 20,
  },
  label: {
    fontSize: 16,
    fontWeight: '600',
    color: '#374151',
    marginBottom: 8,
  },
  buttonsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  button: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 12,
    paddingHorizontal: 8,
    marginHorizontal: 4,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#E5E7EB',
    backgroundColor: '#F9FAFB',
  },
  buttonText: {
    marginLeft: 8,
    fontSize: 14,
    fontWeight: '500',
    color: '#6B7280',
  },
});
