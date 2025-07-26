import React from 'react';
import { View, Text, StyleSheet, Switch, TouchableOpacity } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';

type SettingsRowProps = {
  icon: React.ComponentProps<typeof MaterialIcons>['name'];
  title: string;
  value?: boolean;
  onValueChange?: (value: boolean) => void;
  onPress?: () => void;
  rightComponent?: React.ReactNode;
};

export const SettingsRow: React.FC<SettingsRowProps> = ({
  icon,
  title,
  value,
  onValueChange,
  onPress,
  rightComponent,
}) => {
  return (
    <TouchableOpacity
      style={styles.container}
      onPress={onPress}
      activeOpacity={onPress ? 0.7 : 1}
    >
      <View style={styles.leftContainer}>
        <View style={styles.iconContainer}>
          <MaterialIcons name={icon} size={24} color="#4B5563" />
        </View>
        <Text style={styles.title}>{title}</Text>
      </View>
      
      <View style={styles.rightContainer}>
        {rightComponent || (
          onValueChange !== undefined && (
            <Switch
              value={value}
              onValueChange={onValueChange}
              trackColor={{ false: '#D1D5DB', true: '#3B82F6' }}
              thumbColor="#FFFFFF"
            />
          )
        )}
      </View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 16,
    paddingHorizontal: 20,
    backgroundColor: '#FFFFFF',
    borderBottomWidth: 1,
    borderBottomColor: '#F3F4F6',
  },
  leftContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  iconContainer: {
    width: 40,
    alignItems: 'center',
  },
  title: {
    fontSize: 16,
    color: '#111827',
    marginLeft: 12,
  },
  rightContainer: {
    marginLeft: 12,
  },
});
