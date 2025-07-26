import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Switch } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';

export interface SettingsCardProps {
  title: string;
  description?: string;
  icon?: keyof typeof MaterialIcons.glyphMap;
  type?: 'switch' | 'navigate' | 'button';
  value?: boolean;
  onPress?: () => void;
  onValueChange?: (value: boolean) => void;
  iconColor?: string;
  rightComponent?: React.ReactNode;
}

const SettingsCard: React.FC<SettingsCardProps> = ({
  title,
  description,
  icon,
  type = 'navigate',
  value,
  onPress,
  onValueChange,
  iconColor = '#8B5CF6',
  rightComponent,
}) => {
  const renderRightComponent = () => {
    if (rightComponent) {
      return rightComponent;
    }

    switch (type) {
      case 'switch':
        return (
          <Switch
            value={value}
            onValueChange={onValueChange}
            trackColor={{ false: '#E5E7EB', true: '#8B5CF6' }}
            thumbColor="white"
          />
        );
      case 'navigate':
        return <MaterialIcons name="chevron-right" size={24} color="#9CA3AF" />;
      default:
        return null;
    }
  };

  return (
    <TouchableOpacity
      style={styles.container}
      onPress={onPress}
      disabled={type === 'switch'}
      activeOpacity={0.7}
    >
      <View style={styles.leftContainer}>
        {icon && (
          <View style={[styles.iconContainer, { backgroundColor: `${iconColor}20` }]}>
            <MaterialIcons name={icon} size={20} color={iconColor} />
          </View>
        )}
        <View style={styles.textContainer}>
          <Text style={styles.title}>{title}</Text>
          {description && <Text style={styles.description}>{description}</Text>}
        </View>
      </View>
      <View style={styles.rightContainer}>{renderRightComponent()}</View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: 'white',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  leftContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  iconContainer: {
    width: 40,
    height: 40,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  textContainer: {
    flex: 1,
  },
  title: {
    fontSize: 16,
    fontWeight: '500',
    color: '#1F2937',
    marginBottom: 2,
  },
  description: {
    fontSize: 13,
    color: '#6B7280',
  },
  rightContainer: {
    marginLeft: 8,
  },
});

export default SettingsCard;
