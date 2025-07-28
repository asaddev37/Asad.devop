import React from 'react';
import { View, Text, StyleSheet, ScrollView, Linking } from 'react-native';
import { useTheme } from '../../contexts/ThemeContext';

const PrivacyPolicyScreen = () => {
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
      <View style={[styles.card, localStyles.section]}>
        <Text style={[styles.heading, { color: colors.primary }]}>
          Privacy Policy
        </Text>
        <Text style={[localStyles.lastUpdated, { color: colors.text + '80' }]}>
          Last updated: {new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })}
        </Text>

        <Text style={[localStyles.intro, { color: colors.text }]}>
          This Privacy Policy describes how your personal information is collected, used, and shared when you use the Weather App.
        </Text>
      </View>

      <View style={[styles.card, localStyles.section]}>
        <Text style={[styles.subheading, { color: colors.text }]}>
          Information We Collect
        </Text>
        <Text style={[localStyles.paragraph, { color: colors.text }]}>
          When you use the Weather App, we may collect the following information:
        </Text>
        <View style={localStyles.list}>
          <Text style={[localStyles.listItem, { color: colors.text }]}>
            • <Text style={localStyles.listText}>Location Data:</Text> We collect your device's location to provide accurate weather information for your area. This data is only used to fetch weather data and is not stored on our servers.
          </Text>
          <Text style={[localStyles.listItem, { color: colors.text }]}>
            • <Text style={localStyles.listText}>Usage Data:</Text> We collect information about how you interact with the app, such as the features you use and the time spent on the app. This helps us improve our services.
          </Text>
          <Text style={[localStyles.listItem, { color: colors.text }]}>
            • <Text style={localStyles.listText}>Device Information:</Text> We may collect information about your device, including the device model, operating system, and unique device identifiers.
          </Text>
        </View>
      </View>

      <View style={[styles.card, localStyles.section]}>
        <Text style={[styles.subheading, { color: colors.text }]}>
          How We Use Your Information
        </Text>
        <Text style={[localStyles.paragraph, { color: colors.text }]}>
          We use the information we collect to:
        </Text>
        <View style={localStyles.list}>
          <Text style={[localStyles.listItem, { color: colors.text }]}>
            • Provide and maintain our services
          </Text>
          <Text style={[localStyles.listItem, { color: colors.text }]}>
            • Notify you about changes to our services
          </Text>
          <Text style={[localStyles.listItem, { color: colors.text }]}>
            • Allow you to participate in interactive features of our app
          </Text>
          <Text style={[localStyles.listItem, { color: colors.text }]}>
            • Provide customer support
          </Text>
          <Text style={[localStyles.listItem, { color: colors.text }]}>
            • Gather analysis or valuable information to improve our app
          </Text>
          <Text style={[localStyles.listItem, { color: colors.text }]}>
            • Monitor the usage of our app
          </Text>
          <Text style={[localStyles.listItem, { color: colors.text }]}>
            • Detect, prevent, and address technical issues
          </Text>
        </View>
      </View>

      <View style={[styles.card, localStyles.section]}>
        <Text style={[styles.subheading, { color: colors.text }]}>
          Data Security
        </Text>
        <Text style={[localStyles.paragraph, { color: colors.text }]}>
          The security of your data is important to us. We implement appropriate technical and organizational measures to protect your personal information. However, please be aware that no method of transmission over the Internet or method of electronic storage is 100% secure.
        </Text>
      </View>

      <View style={[styles.card, localStyles.section]}>
        <Text style={[styles.subheading, { color: colors.text }]}>
          Third-Party Services
        </Text>
        <Text style={[localStyles.paragraph, { color: colors.text }]}>
          We use third-party services to provide and improve our services. These third parties have access to your personal information only to perform specific tasks on our behalf and are obligated not to disclose or use it for any other purpose.
        </Text>
        <Text style={[localStyles.paragraph, { color: colors.text }]}>
          Our app uses the following third-party services:
        </Text>
        <View style={localStyles.list}>
          <Text style={[localStyles.listItem, { color: colors.text }]}>
            • <Text style={localStyles.listText}>OpenWeatherMap:</Text> We use OpenWeatherMap API to provide weather data. You can review their privacy policy at{' '}
            <Text 
              style={{color: colors.primary, textDecorationLine: 'underline'}}
              onPress={() => openLink('https://openweathermap.org/privacy-policy')}
            >
              openweathermap.org/privacy-policy
            </Text>
          </Text>
          <Text style={[localStyles.listItem, { color: colors.text }]}>
            • <Text style={localStyles.listText}>Google Analytics:</Text> We use Google Analytics to help us understand how our customers use the app. You can read more about how Google uses your personal information at{' '}
            <Text 
              style={{color: colors.primary, textDecorationLine: 'underline'}}
              onPress={() => openLink('https://policies.google.com/privacy')}
            >
              policies.google.com/privacy
            </Text>
          </Text>
        </View>
      </View>

      <View style={[styles.card, localStyles.section]}>
        <Text style={[styles.subheading, { color: colors.text }]}>
          Your Data Protection Rights
        </Text>
        <Text style={[localStyles.paragraph, { color: colors.text }]}>
          Depending on your location, you may have certain rights regarding your personal information, including:
        </Text>
        <View style={localStyles.list}>
          <Text style={[localStyles.listItem, { color: colors.text }]}>
            • The right to access, update, or delete your information
          </Text>
          <Text style={[localStyles.listItem, { color: colors.text }]}>
            • The right to rectification
          </Text>
          <Text style={[localStyles.listItem, { color: colors.text }]}>
            • The right to object
          </Text>
          <Text style={[localStyles.listItem, { color: colors.text }]}>
            • The right to data portability
          </Text>
          <Text style={[localStyles.listItem, { color: colors.text }]}>
            • The right to withdraw consent
          </Text>
        </View>
        <Text style={[localStyles.paragraph, { color: colors.text, marginTop: 12 }]}>
          To exercise any of these rights, please contact us using the information below.
        </Text>
      </View>

      <View style={[styles.card, localStyles.section]}>
        <Text style={[styles.subheading, { color: colors.text }]}>
          Children's Privacy
        </Text>
        <Text style={[localStyles.paragraph, { color: colors.text }]}>
          Our app is not intended for use by children under the age of 13. We do not knowingly collect personally identifiable information from children under 13. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact us.
        </Text>
      </View>

      <View style={[styles.card, localStyles.section]}>
        <Text style={[styles.subheading, { color: colors.text }]}>
          Changes to This Privacy Policy
        </Text>
        <Text style={[localStyles.paragraph, { color: colors.text }]}>
          We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date at the top of this Privacy Policy.
        </Text>
        <Text style={[localStyles.paragraph, { color: colors.text, marginTop: 12 }]}>
          You are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted on this page.
        </Text>
      </View>

      <View style={[styles.card, localStyles.section, { marginBottom: 40 }]}>
        <Text style={[styles.subheading, { color: colors.text }]}>
          Contact Us
        </Text>
        <Text style={[localStyles.paragraph, { color: colors.text }]}>
          If you have any questions about this Privacy Policy, please contact us:
        </Text>
        <View style={localStyles.contactInfo}>
          <Text style={[localStyles.contactLabel, { color: colors.text }]}>Email:</Text>
          <Text 
            style={[localStyles.contactValue, { color: colors.primary }]}
            onPress={() => openLink('mailto:privacy@weatherapp.com')}
          >
            privacy@weatherapp.com
          </Text>
        </View>
        <View style={localStyles.contactInfo}>
          <Text style={[localStyles.contactLabel, { color: colors.text }]}>Website:</Text>
          <Text 
            style={[localStyles.contactValue, { color: colors.primary }]}
            onPress={() => openLink('https://weatherapp.com/contact')}
          >
            weatherapp.com/contact
          </Text>
        </View>
      </View>
    </ScrollView>
  );
};

const localStyles = StyleSheet.create({
  scrollContent: {
    padding: 16,
    paddingBottom: 40,
  },
  section: {
    marginBottom: 16,
    padding: 16,
  },
  lastUpdated: {
    fontSize: 12,
    marginBottom: 16,
    textAlign: 'center',
  },
  intro: {
    fontSize: 16,
    lineHeight: 24,
    marginBottom: 8,
  },
  paragraph: {
    fontSize: 15,
    lineHeight: 22,
    marginBottom: 12,
  },
  list: {
    marginLeft: 8,
  },
  listItem: {
    marginBottom: 8,
    lineHeight: 22,
  },
  listText: {
    fontWeight: '600',
  },
  contactInfo: {
    flexDirection: 'row',
    marginTop: 8,
  },
  contactLabel: {
    width: 70,
    fontWeight: '600',
  },
  contactValue: {
    flex: 1,
    textDecorationLine: 'underline',
  },
});

export default PrivacyPolicyScreen;
