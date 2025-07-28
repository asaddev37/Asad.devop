import React from 'react';
import { View, ActivityIndicator, StyleSheet, Image } from 'react-native';
import { useTheme } from '../contexts/ThemeContext';

const LoadingScreen = () => {
  const { colors, styles } = useTheme();

  return (
    <View style={[localStyles.container, { backgroundColor: colors.background }]}>
      <Image 
        source={require('../assets/logo.png')} 
        style={localStyles.logo}
        resizeMode="contain"
      />
      <ActivityIndicator 
        size="large" 
        color={colors.primary} 
        style={localStyles.loader}
      />
    </View>
  );
};

const localStyles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  logo: {
    width: 150,
    height: 150,
    marginBottom: 30,
  },
  loader: {
    marginTop: 20,
  },
});

export default LoadingScreen;
