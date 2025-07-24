import React from 'react';
import { StyleSheet, View, Text } from 'react-native';

export function HelloWave() {
  return (
    <View style={styles.container}>
      <Text style={styles.text}>👋 Hello, World!</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: 16,
  },
  text: {
    fontSize: 16,
    fontWeight: 'bold',
  },
});
