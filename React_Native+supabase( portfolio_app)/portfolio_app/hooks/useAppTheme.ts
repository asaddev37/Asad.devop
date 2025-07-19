import { useColorScheme } from 'react-native';
import { 
  MD3LightTheme, 
  MD3DarkTheme,
  adaptNavigationTheme,
  MD3Theme,
} from 'react-native-paper';
import { 
  DarkTheme as NavigationDarkTheme, 
  DefaultTheme as NavigationDefaultTheme,
  Theme as NavigationTheme,
} from '@react-navigation/native';

// Define the custom colors we want to add to the theme
type NavigationColors = {
  card: string;
  border: string;
  notification: string;
  text: string;
  background: string;
  primary: string;
};

// Create a type that combines MD3Colors with our custom navigation colors
type CustomColors = MD3Theme['colors'] & NavigationColors;

// Extend the MD3Theme type to include our custom colors
interface AppTheme extends MD3Theme {
  colors: CustomColors;
}

// Extend the React Navigation theme type
declare global {
  namespace ReactNavigation {
    interface RootParamList {}
    
    interface Theme extends NavigationTheme {
      colors: NavigationTheme['colors'] & {
        card: string;
        border: string;
        notification: string;
      };
    }
  }
}

// Create base themes with navigation theming
const { LightTheme: AdaptedLightTheme, DarkTheme: AdaptedDarkTheme } = adaptNavigationTheme({
  reactNavigationLight: NavigationDefaultTheme,
  reactNavigationDark: NavigationDarkTheme,
});

// Create light theme with navigation colors
const LightTheme = {
  ...MD3LightTheme,
  colors: {
    ...MD3LightTheme.colors,
    ...AdaptedLightTheme.colors,
    primary: '#6200ee',
    background: '#ffffff',
    card: '#ffffff',
    text: '#000000',
    border: '#e0e0e0',
    notification: '#f44336',
  } as CustomColors,
} as const;

// Create dark theme with navigation colors
const DarkTheme = {
  ...MD3DarkTheme,
  colors: {
    ...MD3DarkTheme.colors,
    ...AdaptedDarkTheme.colors,
    primary: '#bb86fc',
    background: '#121212',
    card: '#1e1e1e',
    text: '#ffffff',
    border: '#444444',
    notification: '#cf6679',
  } as CustomColors,
} as const;

export const useAppTheme = () => {
  const colorScheme = useColorScheme();
  const theme = (colorScheme === 'dark' ? DarkTheme : LightTheme) as unknown as AppTheme;
  
  return {
    theme,
    isDark: colorScheme === 'dark',
  };
};
