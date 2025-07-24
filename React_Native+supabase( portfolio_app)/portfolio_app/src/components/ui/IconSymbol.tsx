import { Ionicons } from '@expo/vector-icons';
import { ComponentProps } from 'react';
import { StyleSheet, View } from 'react-native';

type IconSymbolProps = {
  name: ComponentProps<typeof Ionicons>['name'];
  size?: number;
  color?: string;
};

export function IconSymbol({ name, size = 24, color = '#000' }: IconSymbolProps) {
  return (
    <View style={styles.container}>
      <Ionicons name={name} size={size} color={color} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
  },
});
