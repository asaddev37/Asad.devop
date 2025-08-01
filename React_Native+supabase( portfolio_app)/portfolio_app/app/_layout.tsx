import { Stack } from 'expo-router';
import { useColorScheme } from '@/hooks/useColorScheme';
import { ThemeProvider } from '@react-navigation/native';
import { DarkTheme, DefaultTheme } from '@react-navigation/native';
import { StatusBar } from 'expo-status-bar';
import { ProfileProvider } from '@/contexts/ProfileContext';

export default function RootLayout() {
  const colorScheme = useColorScheme();

  return (
    <ProfileProvider>
      <ThemeProvider value={colorScheme === 'dark' ? DarkTheme : DefaultTheme}>
        <Stack>
          <Stack.Screen name="loading" options={{ headerShown: false }} />
          <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
          <Stack.Screen name="about" options={{ headerShown: false }} />
          <Stack.Screen name="privacy-policy" options={{ headerShown: false }} />
          <Stack.Screen name="settings" options={{ headerShown: false }} />
          <Stack.Screen name="contact" options={{ headerShown: false }} />
          <Stack.Screen name="portfolio" options={{ headerShown: false }} />
          <Stack.Screen name="skills" options={{ headerShown: false }} />
          <Stack.Screen name="experience" options={{ headerShown: false }} />
          <Stack.Screen name="profile" options={{ headerShown: false }} />
          <Stack.Screen name="+not-found" />
        </Stack>
        <StatusBar style="auto" />
      </ThemeProvider>
    </ProfileProvider>
  );
}
