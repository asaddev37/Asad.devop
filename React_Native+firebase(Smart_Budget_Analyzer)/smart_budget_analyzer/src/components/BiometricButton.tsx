import React from 'react';
import { TouchableOpacity, StyleSheet, View, Text } from 'react-native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import * as LocalAuthentication from 'expo-local-authentication';

type BiometricButtonProps = {
  onPress: () => void;
  type?: 'login' | 'toggle';
  isEnabled?: boolean;
};

const BiometricButton: React.FC<BiometricButtonProps> = ({ 
  onPress, 
  type = 'login',
  isEnabled = false
}) => {
  const [biometricType, setBiometricType] = React.useState<string | null>(null);

  React.useEffect(() => {
    const checkBiometricSupport = async () => {
      const compatible = await LocalAuthentication.hasHardwareAsync();
      if (compatible) {
        const enrolled = await LocalAuthentication.isEnrolledAsync();
        if (enrolled) {
          const supportedTypes = await LocalAuthentication.supportedAuthenticationTypesAsync();
          if (supportedTypes.includes(LocalAuthentication.AuthenticationType.FACIAL_RECOGNITION)) {
            setBiometricType('face');
          } else if (supportedTypes.includes(LocalAuthentication.AuthenticationType.FINGERPRINT)) {
            setBiometricType('fingerprint');
          }
        }
      }
    };

    checkBiometricSupport();
  }, []);

  if (!biometricType) {
    return null;
  }

  const getIconName = () => {
    if (biometricType === 'face') {
      return 'face-recognition'; // Material Community Icons face recognition
    }
    return 'fingerprint'; // Material Community Icons fingerprint
  };

  const getButtonText = () => {
    if (type === 'toggle') {
      return isEnabled ? 'Disable Biometric Login' : 'Enable Biometric Login';
    }
    return `Sign in with ${biometricType === 'face' ? 'Face ID' : 'Touch ID'}`;
  };

  return (
    <TouchableOpacity 
      style={[styles.button, type === 'toggle' ? styles.toggleButton : null]}
      onPress={onPress}
    >
      <View style={styles.buttonContent}>
        <MaterialCommunityIcons 
          name={getIconName()} 
          size={24} 
          color={type === 'toggle' ? (isEnabled ? '#ff4444' : '#1e90ff') : '#1e90ff'}
        />
        <Text style={[styles.buttonText, type === 'toggle' && styles.toggleText]}>
          {getButtonText()}
        </Text>
      </View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  button: {
    marginTop: 20,
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
    backgroundColor: 'rgba(30, 144, 255, 0.1)',
  },
  toggleButton: {
    backgroundColor: 'transparent',
    padding: 10,
  },
  buttonContent: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  buttonText: {
    color: '#1e90ff',
    marginLeft: 10,
    fontWeight: '600',
  },
  toggleText: {
    fontSize: 14,
  },
});

export default BiometricButton;
