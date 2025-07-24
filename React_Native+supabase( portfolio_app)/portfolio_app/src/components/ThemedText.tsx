import { Text, TextProps, StyleSheet } from 'react-native';
import { useColorScheme } from 'react-native';
import { Colors } from '@/constants/Colors';

type TextType = 'title' | 'subtitle' | 'body' | 'link';

type ThemedTextProps = TextProps & {
  type?: TextType;
  lightColor?: string;
  darkColor?: string;
};

export function ThemedText({
  style,
  type = 'body',
  lightColor,
  darkColor,
  ...otherProps
}: ThemedTextProps) {
  const colorScheme = useColorScheme() ?? 'light';
  const color = colorScheme === 'dark' 
    ? darkColor || Colors.dark.text 
    : lightColor || Colors.light.text;

  const textStyles = [
    styles.base,
    type === 'title' && styles.title,
    type === 'subtitle' && styles.subtitle,
    type === 'link' && styles.link,
    { color },
    style,
  ];

  return <Text style={textStyles} {...otherProps} />;
}

const styles = StyleSheet.create({
  base: {
    fontSize: 16,
    lineHeight: 24,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    lineHeight: 40,
    marginVertical: 8,
  },
  subtitle: {
    fontSize: 20,
    fontWeight: '600',
    lineHeight: 28,
    marginVertical: 4,
  },
  link: {
    color: '#2f95dc',
    textDecorationLine: 'underline',
  },
});
