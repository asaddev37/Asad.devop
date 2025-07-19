import { createClient, type User as SupabaseUser } from '@supabase/supabase-js';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Create a custom storage adapter that works with AsyncStorage
const storageAdapter = {
  getItem: (key: string) => AsyncStorage.getItem(key),
  setItem: (key: string, value: string) => AsyncStorage.setItem(key, value),
  removeItem: (key: string) => AsyncStorage.removeItem(key),
};

const supabaseUrl = 'https://dgfvklchhlqqlqkylxla.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRnZnZrbGNoaGxxcWxxa3lseGxhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI4NTc2NTEsImV4cCI6MjA2ODQzMzY1MX0.Mv1i-JYqhvVZYIEVi2pDB-hX3qtjCbdHkQS2yyhIe4w';

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    storage: storageAdapter,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
});

export type AuthError = {
  message: string;
  status?: number;
};

// Transform Supabase user to our User type
function transformUser(user: SupabaseUser | null, fullName?: string): User | null {
  if (!user) return null;
  
  const userData: User = {
    ...user,
    email: user.email,  
    full_name: fullName || user.user_metadata?.full_name,
    avatar_url: (user as any).avatar_url || user.user_metadata?.avatar_url,
    user_metadata: {
      ...user.user_metadata,
      full_name: fullName || user.user_metadata?.full_name,
      avatar_url: (user as any).avatar_url || user.user_metadata?.avatar_url,
    },
  };
  
  return userData;
};

export type User = Omit<SupabaseUser, 'user_metadata'> & {
  email?: string;  
  full_name?: string;
  avatar_url?: string;
  user_metadata?: {
    full_name?: string;
    avatar_url?: string;
    [key: string]: any; // Allow additional metadata properties
  };
};

export type AuthResponse = {
  user: User | null;
  session: any;
  error: AuthError | null;
};

export const signUp = async (email: string, password: string, fullName: string): Promise<AuthResponse> => {
  try {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          full_name: fullName,
        },
      },
    });

    return {
      user: transformUser(data.user, fullName),
      session: data.session,
      error: error ? { message: error.message, status: error.status } : null,
    };
  } catch (error: any) {
    return {
      user: null,
      session: null,
      error: { message: error.message || 'Failed to sign up' },
    };
  }
};

export const signIn = async (email: string, password: string): Promise<AuthResponse> => {
  try {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    return {
      user: transformUser(data.user),
      session: data.session,
      error: error ? { message: error.message, status: error.status } : null,
    };
  } catch (error: any) {
    return {
      user: null,
      session: null,
      error: { message: error.message || 'Failed to sign in' },
    };
  }
};

export const signOut = async (): Promise<{ error: AuthError | null }> => {
  try {
    const { error } = await supabase.auth.signOut();
    return { error: error ? { message: error.message } : null };
  } catch (error: any) {
    return { error: { message: error.message || 'Failed to sign out' } };
  }
};

export const getCurrentUser = async (): Promise<User | null> => {
  try {
    const { data: { user } } = await supabase.auth.getUser();
    return transformUser(user);
  } catch (error) {
    console.error('Error getting current user:', error);
    return null;
  }
};

export const resetPassword = async (email: string): Promise<{ error: AuthError | null }> => {
  try {
    const { error } = await supabase.auth.resetPasswordForEmail(email);
    return { error: error ? { message: error.message } : null };
  } catch (error: any) {
    return { error: { message: error.message || 'Failed to send password reset email' } };
  }
};
