import React from 'react';
import { View, StyleSheet, Modal, ActivityIndicator, Text, Dimensions } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { LoadingAnimation } from './LoadingAnimation';

interface LoadingOverlayProps {
  visible: boolean;
  message?: string;
  transparent?: boolean;
  animationType?: 'circular' | 'dots';
}

/**
 * A full-screen loading overlay with a Lottie animation
 */
export function LoadingOverlay({
  visible,
  message = 'Loading...',
  transparent = false,
  animationType = 'circular',
}: LoadingOverlayProps) {
  if (!visible) return null;

  return (
    <Modal visible={visible} transparent animationType="fade">
      {transparent ? (
        <View style={styles.transparentContainer}>
          <View style={styles.contentContainer}>
            <LoadingAnimation 
              message={message} 
              type={animationType} 
              size="medium" 
            />
          </View>
        </View>
      ) : (
        <LinearGradient colors={['#4A90E2', '#357ABD']} style={styles.gradientContainer}>
          <LoadingAnimation 
            message={message} 
            type={animationType} 
            size="large" 
            textStyle={styles.gradientText} 
          />
        </LinearGradient>
      )}
    </Modal>
  );
}

const { width, height } = Dimensions.get('window');

const styles = StyleSheet.create({
  transparentContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
  },
  contentContainer: {
    padding: 20,
    borderRadius: 10,
    backgroundColor: 'white',
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
    minWidth: width * 0.7,
  },
  gradientContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  gradientText: {
    color: 'white',
    fontSize: 18,
    fontWeight: '500',
  },
});