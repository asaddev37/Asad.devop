import { Redirect } from 'expo-router';
import { useAuth } from '@/contexts/AuthContext';

export default function Index() {
  const { user } = useAuth();
  
  // This will be replaced by the actual loading screen in _layout.tsx
  // This is just a fallback
  if (user === undefined) {
    return null; // or a loading indicator
  }

  // Redirect to the appropriate screen based on auth state
  if (!user) {
    return <Redirect href="/(auth)/sign-in" />;
  }
  
  return <Redirect href="/(tabs)" />;
}
