/**
 * Learn more about light and dark modes:
 * https://docs.expo.dev/guides/color-schemes/
 */

import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/useColorScheme';

export type ColorName = keyof typeof Colors.light & keyof typeof Colors.dark;
export type ThemeProps = { light?: string; dark?: string; [key: string]: string | undefined };

export function useThemeColor(
  propsOrColorName: ThemeProps | ColorName,
  colorNameOrIsDarkMode?: ColorName | boolean,
  isDarkModeParam?: boolean
): string {
  const theme = useColorScheme() ?? 'light';
  let isDarkMode = theme === 'dark';
  let colorName: ColorName;
  let props: ThemeProps = {};

  // Handle different overloads
  if (typeof propsOrColorName === 'string') {
    // First overload: useThemeColor('text', isDarkMode?)
    colorName = propsOrColorName;
    if (typeof colorNameOrIsDarkMode === 'boolean') {
      isDarkMode = colorNameOrIsDarkMode;
    }
  } else {
    // Second overload: useThemeColor({light, dark}, 'text', isDarkMode?)
    props = propsOrColorName;
    colorName = colorNameOrIsDarkMode as ColorName;
    if (typeof isDarkModeParam === 'boolean') {
      isDarkMode = isDarkModeParam;
    }
  }

  const currentTheme = isDarkMode ? 'dark' : 'light';
  const colorFromProps = props[currentTheme];

  if (colorFromProps) {
    return colorFromProps;
  } else {
    return Colors[currentTheme][colorName];
  }
}
