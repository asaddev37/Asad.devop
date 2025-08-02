import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

const BudgetsScreen = () => {
  return (
    <View style={styles.container}>
      <Text style={styles.text}>Budgets Screen</Text>
      <Text style={styles.subtext}>Coming Soon...</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f8f9fa',
  },
  text: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 10,
  },
  subtext: {
    fontSize: 16,
    color: '#666',
  },
});

export default BudgetsScreen; 