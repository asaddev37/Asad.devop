import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';

interface CategoryStatsCardProps {
  title: string;
  value: number | string;
  color: string;
  icon?: React.ReactNode;
}

const CategoryStatsCard: React.FC<CategoryStatsCardProps> = ({
  title,
  value,
  color,
  icon,
}) => {
  return (
    <View style={[styles.container, { backgroundColor: color + '20' }]}>
      <LinearGradient
        colors={[color + '80', color + '40']}
        style={styles.gradient}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
      >
        {icon && <View style={styles.iconContainer}>{icon}</View>}
        <Text style={styles.value}>{value}</Text>
        <Text style={styles.title}>{title}</Text>
      </LinearGradient>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    borderRadius: 12,
    overflow: 'hidden',
    margin: 8,
    flex: 1,
    minWidth: 140,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  gradient: {
    padding: 16,
    alignItems: 'center',
  },
  iconContainer: {
    marginBottom: 8,
  },
  value: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1F2937',
    marginBottom: 4,
  },
  title: {
    fontSize: 14,
    color: '#4B5563',
    textAlign: 'center',
  },
});

export default CategoryStatsCard;
