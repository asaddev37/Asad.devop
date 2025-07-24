import { View, ViewProps, StyleSheet } from 'react-native';
import { useColorScheme } from 'react-native';
import { Colors } from '@/constants/Colors';

type ThemedViewProps = ViewProps & {
  lightColor?: string;
  darkColor?: string;
};

export function ThemedView({
  style,
  lightColor,
  darkColor,
  ...otherProps
}: ThemedViewProps) {
  const colorScheme = useColorScheme() ?? 'light';
  const backgroundColor = colorScheme === 'dark' 
    ? darkColor || Colors.dark.background 
    : lightColor || Colors.light.background;

  return <View style={[{ backgroundColor }, style]} {...otherProps} />;
}
