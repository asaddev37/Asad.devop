import { 
  createUserWithEmailAndPassword, 
  signInWithEmailAndPassword, 
  signOut, 
  sendPasswordResetEmail,
  User,
  UserCredential,
  AuthError as FirebaseAuthError,
  onAuthStateChanged
} from 'firebase/auth';
import * as LocalAuthentication from 'expo-local-authentication';
import * as SecureStore from 'expo-secure-store';
import { auth } from '../config/firebase';

// Storage keys
const BIOMETRIC_CREDENTIALS_KEY = 'biometric_credentials';
const BIOMETRIC_ENABLED_KEY = 'biometric_enabled';

export interface AuthError {
  code: string;
  message: string;
}

interface BiometricCredentials {
  email: string;
  password: string;
}

export class AuthService {
  // Sign up with email and password
  static async signUp(email: string, password: string): Promise<UserCredential> {
    try {
      return await createUserWithEmailAndPassword(auth, email, password);
    } catch (error: any) {
      console.error('Error in signUp:', error);
      throw this.handleAuthError(error);
    }
  }

  // Sign in with email and password
  static async signIn(email: string, password: string): Promise<UserCredential> {
    try {
      return await signInWithEmailAndPassword(auth, email, password);
    } catch (error: any) {
      console.error('Error in signIn:', error);
      throw this.handleAuthError(error);
    }
  }

  // Sign out
  static async signOut(): Promise<void> {
    try {
      await signOut(auth);
      // Clear biometric credentials on sign out
      await SecureStore.deleteItemAsync(BIOMETRIC_CREDENTIALS_KEY);
      await SecureStore.deleteItemAsync(BIOMETRIC_ENABLED_KEY);
    } catch (error: any) {
      console.error('Error in signOut:', error);
      throw this.handleAuthError(error);
    }
  }

  // Reset password
  static async resetPassword(email: string): Promise<void> {
    try {
      await sendPasswordResetEmail(auth, email);
    } catch (error: any) {
      console.error('Error in resetPassword:', error);
      throw this.handleAuthError(error);
    }
  }

  // Get current user
  static getCurrentUser(): User | null {
    return auth.currentUser;
  }

  // Listen to auth state changes
  static onAuthStateChanged(callback: (user: User | null) => void) {
    return onAuthStateChanged(auth, callback);
  }

  // Handle authentication errors
  private static handleAuthError(error: FirebaseAuthError): AuthError {
    let message = 'An error occurred. Please try again.';
    
    switch (error.code) {
      case 'auth/email-already-in-use':
        message = 'An account with this email already exists.';
        break;
      case 'auth/invalid-email':
        message = 'Please enter a valid email address.';
        break;
      case 'auth/weak-password':
        message = 'Password should be at least 6 characters.';
        break;
      case 'auth/user-not-found':
      case 'auth/wrong-password':
        message = 'Invalid email or password.';
        break;
      case 'auth/too-many-requests':
        message = 'Too many attempts. Please try again later.';
        break;
      default:
        console.error('Auth error:', error);
    }

    return {
      code: error.code,
      message
    };
  }

  // Check if biometric authentication is available
  static async isBiometricAvailable(): Promise<boolean> {
    const compatible = await LocalAuthentication.hasHardwareAsync();
    if (!compatible) return false;
    
    const enrolled = await LocalAuthentication.isEnrolledAsync();
    return enrolled;
  }

  // Enable biometric authentication for the current user
  static async enableBiometric(email: string, password: string): Promise<void> {
    try {
      const credentials: BiometricCredentials = { email, password };
      await SecureStore.setItemAsync(BIOMETRIC_CREDENTIALS_KEY, JSON.stringify(credentials));
      await SecureStore.setItemAsync(BIOMETRIC_ENABLED_KEY, 'true');
    } catch (error) {
      console.error('Error enabling biometric authentication:', error);
      throw new Error('Failed to enable biometric authentication');
    }
  }

  // Disable biometric authentication
  static async disableBiometric(): Promise<void> {
    try {
      await SecureStore.deleteItemAsync(BIOMETRIC_CREDENTIALS_KEY);
      await SecureStore.deleteItemAsync(BIOMETRIC_ENABLED_KEY);
    } catch (error) {
      console.error('Error disabling biometric authentication:', error);
      throw new Error('Failed to disable biometric authentication');
    }
  }

  // Check if biometric is enabled
  static async isBiometricEnabled(): Promise<boolean> {
    try {
      const enabled = await SecureStore.getItemAsync(BIOMETRIC_ENABLED_KEY);
      return enabled === 'true';
    } catch (error) {
      console.error('Error checking biometric status:', error);
      return false;
    }
  }

  // Authenticate with biometrics
  static async authenticateWithBiometrics(): Promise<UserCredential | null> {
    try {
      // First check if biometric auth is available and enabled
      const isAvailable = await this.isBiometricAvailable();
      const isEnabled = await this.isBiometricEnabled();
      
      if (!isAvailable || !isEnabled) {
        return null;
      }

      // Get stored credentials
      const credentialsJson = await SecureStore.getItemAsync(BIOMETRIC_CREDENTIALS_KEY);
      if (!credentialsJson) return null;
      
      const credentials: BiometricCredentials = JSON.parse(credentialsJson);
      
      // Authenticate with biometrics
      const result = await LocalAuthentication.authenticateAsync({
        promptMessage: 'Authenticate to access your account',
        fallbackLabel: 'Enter password instead',
        disableDeviceFallback: false,
      });

      if (result.success) {
        // If biometric authentication is successful, sign in with stored credentials
        return await this.signIn(credentials.email, credentials.password);
      }
      
      return null;
    } catch (error) {
      console.error('Biometric authentication error:', error);
      return null;
    }
  }
}