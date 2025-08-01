import React from 'react';
import { View, StyleSheet } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/useColorScheme';

export default function TabBarBackground() {
  const colorScheme = useColorScheme();
  const colors = Colors[colorScheme ?? 'light'];

  return (
    <View style={[styles.container, { backgroundColor: colors.cardBackground }]}>
      <LinearGradient
        colors={
          colorScheme === 'dark'
            ? ['rgba(30, 64, 175, 0.1)', 'rgba(124, 58, 237, 0.1)', 'rgba(30, 41, 55, 0.95)']
            : ['rgba(102, 126, 234, 0.05)', 'rgba(118, 75, 162, 0.05)', 'rgba(255, 255, 255, 0.95)']
        }
        style={styles.gradient}
      />
      <View style={[styles.border, { borderTopColor: colors.border }]} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    height: 90,
  },
  gradient: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  border: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: 1,
    borderTopWidth: 1,
  },
});
