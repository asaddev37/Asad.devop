import { useColorScheme } from 'react-native';

type ThemeProps = {
  lightColor?: string;
  darkColor?: string;
};

export type ColorName = 'text' | 'background' | 'card' | 'primary' | 'secondary' | 'accent' | 'border' | 'error' | 'success' | 'warning';

export function useThemeColor(colorName: ColorName, isDarkMode?: boolean): string;
export function useThemeColor(props: ThemeProps, colorName: ColorName, isDarkMode?: boolean): string;

export function useThemeColor(
  propsOrColorName: ThemeProps | ColorName,
  colorNameOrIsDarkMode?: ColorName | boolean,
  maybeIsDarkMode?: boolean
): string {
  const theme = useColorScheme() ?? 'light';
  
  let colorName: ColorName;
  let props: ThemeProps;
  let isDarkMode: boolean;

  if (typeof propsOrColorName === 'string') {
    colorName = propsOrColorName;
    props = {};
    isDarkMode = typeof colorNameOrIsDarkMode === 'boolean' ? colorNameOrIsDarkMode : theme === 'dark';
  } else {
    props = propsOrColorName;
    colorName = colorNameOrIsDarkMode as ColorName;
    isDarkMode = typeof maybeIsDarkMode === 'boolean' ? maybeIsDarkMode : theme === 'dark';
  }

  const Colors = {
    light: {
      text: '#000',
      background: '#f8f9fa',
      card: '#ffffff',
      primary: '#4A90E2',
      secondary: '#357ABD',
      accent: '#ff6b35',
      border: '#e1e1e1',
      error: '#ff3b30',
      success: '#32cd32',
      warning: '#ffcc00',
    },
    dark: {
      text: '#fff',
      background: '#1a1a1a',
      card: '#2c2c2c',
      primary: '#4A90E2',
      secondary: '#357ABD',
      accent: '#ff6b35',
      border: '#444444',
      error: '#ff453a',
      success: '#32cd32',
      warning: '#ffcc00',
    },
  };

  const colorFromProps = isDarkMode ? props.darkColor : props.lightColor;
  
  if (colorFromProps) {
    return colorFromProps;
  }
  
  return isDarkMode ? Colors.dark[colorName] : Colors.light[colorName];
}