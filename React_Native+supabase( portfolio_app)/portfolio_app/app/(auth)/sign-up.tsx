import React, { useState } from 'react';
import { View, StyleSheet, TouchableOpacity, KeyboardAvoidingView, Platform, ScrollView } from 'react-native';
import { Button, Text, useTheme } from 'react-native-paper';
import { useForm } from 'react-hook-form';
import { yupResolver } from '@hookform/resolvers/yup';
import { useRouter } from 'expo-router';

import { FormInput } from '../../components/forms/FormInput';
import { signUpSchema, type SignUpFormData } from '../../schemas/auth';
import { useAuth } from '../../contexts/AuthContext';
import { showToast } from '../../utils/toast';

export default function SignUpScreen() {
  const theme = useTheme();
  const router = useRouter();
  const { signUp, loading } = useAuth();
  const [secureTextEntry, setSecureTextEntry] = useState(true);
  const [confirmSecureTextEntry, setConfirmSecureTextEntry] = useState(true);

  const {
    control,
    handleSubmit,
    formState: { errors },
  } = useForm<SignUpFormData>({
    resolver: yupResolver(signUpSchema),
    defaultValues: {
      fullName: '',
      email: '',
      password: '',
      confirmPassword: '',
    },
  });

  const toggleSecureEntry = (field: 'password' | 'confirmPassword') => {
    if (field === 'password') {
      setSecureTextEntry(!secureTextEntry);
    } else {
      setConfirmSecureTextEntry(!confirmSecureTextEntry);
    }
  };

  const onSubmit = async (data: SignUpFormData) => {
    try {
      const { error } = await signUp(data.email, data.password, data.fullName);
      
      if (error) {
        showToast({
          type: 'error',
          text1: 'Sign Up Failed',
          text2: error.message || 'Failed to create account. Please try again.',
        });
        return;
      }
      
      showToast({
        type: 'success',
        text1: 'Account Created!',
        text2: 'Please check your email to verify your account.',
      });
      
      router.replace('/(tabs)');
    } catch (error) {
      showToast({
        type: 'error',
        text1: 'Error',
        text2: 'An unexpected error occurred. Please try again.',
      });
    }
  };

  return (
    <KeyboardAvoidingView
      style={[styles.container, { backgroundColor: theme.colors.background }]}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      keyboardVerticalOffset={Platform.OS === 'ios' ? 100 : 0}
    >
      <ScrollView contentContainerStyle={styles.scrollContainer}>
        <View style={styles.header}>
          <Text variant="headlineMedium" style={[styles.title, { color: theme.colors.primary }]}>
            Create Account
          </Text>
          <Text variant="bodyMedium" style={{ color: theme.colors.onSurfaceVariant, textAlign: 'center' }}>
            Fill in your details to create your portfolio
          </Text>
        </View>

        <View style={styles.form}>
          <FormInput
            control={control}
            name="fullName"
            label="Full Name"
            placeholder="Enter your full name"
            autoCapitalize="words"
            error={errors.fullName?.message}
            touched={!!errors.fullName}
          />

          <FormInput
            control={control}
            name="email"
            label="Email"
            placeholder="Enter your email"
            keyboardType="email-address"
            autoCapitalize="none"
            autoCorrect={false}
            error={errors.email?.message}
            touched={!!errors.email}
          />

          <FormInput
            control={control}
            name="password"
            label="Password"
            placeholder="Create a password"
            secureTextEntry={secureTextEntry}
            showEyeIcon
            onTogglePasswordVisibility={() => toggleSecureEntry('password')}
            error={errors.password?.message}
            touched={!!errors.password}
          />

          <FormInput
            control={control}
            name="confirmPassword"
            label="Confirm Password"
            placeholder="Confirm your password"
            secureTextEntry={confirmSecureTextEntry}
            showEyeIcon
            onTogglePasswordVisibility={() => toggleSecureEntry('confirmPassword')}
            error={errors.confirmPassword?.message}
            touched={!!errors.confirmPassword}
            returnKeyType="done"
            onSubmitEditing={handleSubmit(onSubmit)}
          />

          <View style={styles.requirements}>
            <Text variant="labelSmall" style={{ color: theme.colors.onSurfaceVariant }}>
              Password must contain:
            </Text>
            <Text variant="labelSmall" style={{ color: theme.colors.onSurfaceVariant }}>
              • At least 8 characters
            </Text>
            <Text variant="labelSmall" style={{ color: theme.colors.onSurfaceVariant }}>
              • Uppercase and lowercase letters
            </Text>
            <Text variant="labelSmall" style={{ color: theme.colors.onSurfaceVariant }}>
              • At least one number and special character
            </Text>
          </View>

          <Button
            mode="contained"
            onPress={handleSubmit(onSubmit)}
            loading={loading}
            disabled={loading}
            style={styles.button}
            contentStyle={styles.buttonContent}
          >
            Create Account
          </Button>

          <View style={styles.footer}>
            <Text style={{ color: theme.colors.onSurfaceVariant }}>
              Already have an account?{' '}
            </Text>
            <TouchableOpacity onPress={() => router.back()}>
              <Text style={{ color: theme.colors.primary, fontWeight: 'bold' }}>Sign In</Text>
            </TouchableOpacity>
          </View>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scrollContainer: {
    flexGrow: 1,
    padding: 20,
    paddingTop: 40,
  },
  header: {
    marginBottom: 32,
    alignItems: 'center',
  },
  title: {
    fontWeight: 'bold',
    marginBottom: 8,
  },
  form: {
    width: '100%',
    maxWidth: 400,
    alignSelf: 'center',
  },
  requirements: {
    marginBottom: 24,
    padding: 12,
    borderRadius: 8,
    backgroundColor: 'rgba(0, 0, 0, 0.03)',
  },
  button: {
    marginTop: 8,
    paddingVertical: 8,
  },
  buttonContent: {
    height: 48,
  },
  footer: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginTop: 24,
  },
});
