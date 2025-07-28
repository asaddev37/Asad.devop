import React from 'react';
import { View, Text, StyleSheet, Linking, Image, ScrollView, TouchableOpacity } from 'react-native';
import { useTheme } from '../../contexts/ThemeContext';
import { Ionicons } from '@expo/vector-icons';
import { images } from '../../utils/assets';

const AboutScreen = () => {
  const { colors, styles } = useTheme();

  // Open external link
  const openLink = async (url) => {
    const supported = await Linking.canOpenURL(url);
    if (supported) {
      await Linking.openURL(url);
    } else {
      console.error("Don't know how to open URI: " + url);
    }
  };

  return (
    <ScrollView 
      style={[styles.container, { backgroundColor: colors.background }]}
      contentContainerStyle={localStyles.scrollContent}
    >
      <View style={localStyles.header}>
        <Image 
          source={images.logo} 
          style={localStyles.logo}
          resizeMode="contain"
        />
        <Text style={[localStyles.appName, { color: colors.primary }]}>Weather App</Text>
        <Text style={[localStyles.version, { color: colors.text + '80' }]}>Version 1.0.0</Text>
      </View>

      <View style={[styles.card, localStyles.section]}>
        <Text style={[styles.subheading, { color: colors.text }]}>About This App</Text>
        <Text style={[localStyles.description, { color: colors.text }]}>
          Weather App is a beautiful and intuitive weather application that provides accurate weather forecasts for locations around the world. 
          Stay informed about current conditions, hourly forecasts, and 5-day weather predictions.
        </Text>
      </View>

      <View style={[styles.card, localStyles.section]}>
        <Text style={[styles.subheading, { color: colors.text }]}>Features</Text>
        
        <View style={localStyles.featureItem}>
          <Ionicons name="sunny" size={20} color={colors.primary} style={localStyles.featureIcon} />
          <View>
            <Text style={[localStyles.featureTitle, { color: colors.text }]}>Current Weather</Text>
            <Text style={[localStyles.featureDescription, { color: colors.text + '80' }]}>
              Get real-time weather updates for your current location or any city worldwide.
            </Text>
          </View>
        </View>

        <View style={localStyles.featureItem}>
          <Ionicons name="calendar" size={20} color={colors.primary} style={localStyles.featureIcon} />
          <View>
            <Text style={[localStyles.featureTitle, { color: colors.text }]}>5-Day Forecast</Text>
            <Text style={[localStyles.featureDescription, { color: colors.text + '80' }]}>
              Plan ahead with detailed 5-day weather forecasts.
            </Text>
          </View>
        </View>

        <View style={localStyles.featureItem}>
          <Ionicons name="settings" size={20} color={colors.primary} style={localStyles.featureIcon} />
          <View>
            <Text style={[localStyles.featureTitle, { color: colors.text }]}>Customizable Units</Text>
            <Text style={[localStyles.featureDescription, { color: colors.text + '80' }]}>
              Choose between Celsius/Fahrenheit, km/h/mph, and 12/24 hour formats.
            </Text>
          </View>
        </View>
      </View>

      <View style={[styles.card, localStyles.section]}>
        <Text style={[styles.subheading, { color: colors.text }]}>Developer</Text>
        <Text style={[localStyles.developer, { color: colors.text }]}>
          Developed with ❤️ by Asad.devop
        </Text>
        
        <View style={localStyles.socialLinks}>
          <TouchableOpacity 
            style={localStyles.socialButton}
            onPress={() => openLink('https://github.com/yourusername')}
          >
            <Ionicons name="logo-github" size={24} color={colors.text} />
          </TouchableOpacity>
          
          <TouchableOpacity 
            style={localStyles.socialButton}
            onPress={() => openLink('https://linkedin.com/in/yourprofile')}
          >
            <Ionicons name="logo-linkedin" size={24} color={colors.text} />
          </TouchableOpacity>
          
          <TouchableOpacity 
            style={localStyles.socialButton}
            onPress={() => openLink('https://twitter.com/yourhandle')}
          >
            <Ionicons name="logo-twitter" size={24} color={colors.text} />
          </TouchableOpacity>
        </View>
      </View>

      <View style={[styles.card, localStyles.section]}>
        <Text style={[styles.subheading, { color: colors.text }]}>Attributions</Text>
        <Text style={[localStyles.attribution, { color: colors.text + '80' }]}>
          Weather data provided by OpenWeatherMap
        </Text>
        <Text style={[localStyles.attribution, { color: colors.text + '80' }]}>
          Icons by Ionicons
        </Text>
      </View>

      <Text style={[localStyles.copyright, { color: colors.text + '60' }]}>
        © {new Date().getFullYear()} Weather App. All rights reserved.
      </Text>
    </ScrollView>
  );
};

const localStyles = StyleSheet.create({
  scrollContent: {
    padding: 16,
    paddingBottom: 40,
  },
  header: {
    alignItems: 'center',
    marginBottom: 24,
    marginTop: 16,
  },
  logo: {
    width: 100,
    height: 100,
    marginBottom: 16,
  },
  appName: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 4,
  },
  version: {
    fontSize: 14,
  },
  section: {
    marginBottom: 16,
    padding: 16,
  },
  description: {
    fontSize: 16,
    lineHeight: 24,
    marginBottom: 8,
  },
  featureItem: {
    flexDirection: 'row',
    marginBottom: 20,
  },
  featureIcon: {
    marginRight: 16,
    marginTop: 4,
  },
  featureTitle: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 4,
  },
  featureDescription: {
    fontSize: 14,
    lineHeight: 20,
  },
  developer: {
    fontSize: 16,
    textAlign: 'center',
    marginBottom: 16,
  },
  socialLinks: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginTop: 8,
  },
  socialButton: {
    padding: 12,
    marginHorizontal: 8,
  },
  attribution: {
    fontSize: 14,
    marginBottom: 8,
    textAlign: 'center',
  },
  copyright: {
    textAlign: 'center',
    marginTop: 24,
    fontSize: 12,
  },
});

export default AboutScreen;
