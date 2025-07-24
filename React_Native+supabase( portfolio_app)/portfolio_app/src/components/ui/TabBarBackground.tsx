import { BlurView } from 'expo-blur';
import { StyleSheet } from 'react-native';

export default function TabBarBackground() {
  return (
    <BlurView
      intensity={80}
      tint="light"
      style={StyleSheet.absoluteFill}
    />
  );
}
