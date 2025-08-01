import React from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { ThemedText } from '@/components/ThemedText';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/useColorScheme';
import { router } from 'expo-router';

export default function PrivacyPolicyScreen() {
  const colorScheme = useColorScheme();
  const colors = Colors[colorScheme ?? 'light'];

  return (
    <View style={[styles.container, { backgroundColor: colors.background }]}>
      {/* Header */}
      <LinearGradient
        colors={
          colorScheme === 'dark'
            ? ['#1a1a2e', '#16213e']
            : ['#667eea', '#764ba2']
        }
        style={styles.header}
      >
        <View style={styles.headerContent}>
          <TouchableOpacity
            style={styles.backButton}
            onPress={() => router.back()}
          >
            <ThemedText style={[styles.backButtonText, { color: colors.text }]}>
              ← Back
            </ThemedText>
          </TouchableOpacity>
          <ThemedText style={[styles.headerTitle, { color: colors.text }]}>
            Privacy Policy
          </ThemedText>
        </View>
      </LinearGradient>

      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        {/* Last Updated */}
        <View style={styles.lastUpdatedContainer}>
          <ThemedText style={[styles.lastUpdatedText, { color: colors.text }]}>
            Last updated: December 15, 2024
          </ThemedText>
        </View>

        {/* Introduction */}
        <View style={styles.section}>
          <ThemedText style={[styles.sectionTitle, { color: colors.text }]}>
            Introduction
          </ThemedText>
          <View style={[styles.sectionCard, { backgroundColor: colors.background }]}>
            <ThemedText style={[styles.paragraph, { color: colors.text }]}>
              Welcome to Portfolio App. We respect your privacy and are committed to protecting your personal data. This privacy policy will inform you how we look after your personal data when you visit our application and tell you about your privacy rights and how the law protects you.
            </ThemedText>
            <ThemedText style={[styles.paragraph, { color: colors.text }]}>
              This privacy policy applies to the Portfolio App mobile application and any related services. By using our app, you agree to the collection and use of information in accordance with this policy.
            </ThemedText>
          </View>
        </View>

        {/* Information We Collect */}
        <View style={styles.section}>
          <ThemedText style={[styles.sectionTitle, { color: colors.text }]}>
            Information We Collect
          </ThemedText>
          <View style={[styles.sectionCard, { backgroundColor: colors.background }]}>
            <ThemedText style={[styles.subsectionTitle, { color: colors.text }]}>
              Personal Information
            </ThemedText>
            <ThemedText style={[styles.paragraph, { color: colors.text }]}>
              We may collect personal information that you voluntarily provide to us when you:
            </ThemedText>
            <View style={styles.bulletList}>
              <View style={styles.bulletItem}>
                <ThemedText style={styles.bullet}>•</ThemedText>
                <ThemedText style={[styles.bulletText, { color: colors.text }]}>
                  Create an account or profile
                </ThemedText>
              </View>
              <View style={styles.bulletItem}>
                <ThemedText style={styles.bullet}>•</ThemedText>
                <ThemedText style={[styles.bulletText, { color: colors.text }]}>
                  Update your portfolio information
                </ThemedText>
              </View>
              <View style={styles.bulletItem}>
                <ThemedText style={styles.bullet}>•</ThemedText>
                <ThemedText style={[styles.bulletText, { color: colors.text }]}>
                  Contact us through the app
                </ThemedText>
              </View>
              <View style={styles.bulletItem}>
                <ThemedText style={styles.bullet}>•</ThemedText>
                <ThemedText style={[styles.bulletText, { color: colors.text }]}>
                  Subscribe to our newsletter
                </ThemedText>
              </View>
            </View>

            <ThemedText style={[styles.subsectionTitle, { color: colors.text }]}>
              Usage Information
            </ThemedText>
            <ThemedText style={[styles.paragraph, { color: colors.text }]}>
              We automatically collect certain information about your device and how you interact with our app, including:
            </ThemedText>
            <View style={styles.bulletList}>
              <View style={styles.bulletItem}>
                <ThemedText style={styles.bullet}>•</ThemedText>
                <ThemedText style={[styles.bulletText, { color: colors.text }]}>
                  Device information (model, operating system)
                </ThemedText>
              </View>
              <View style={styles.bulletItem}>
                <ThemedText style={styles.bullet}>•</ThemedText>
                <ThemedText style={[styles.bulletText, { color: colors.text }]}>
                  App usage statistics
                </ThemedText>
              </View>
              <View style={styles.bulletItem}>
                <ThemedText style={styles.bullet}>•</ThemedText>
                <ThemedText style={[styles.bulletText, { color: colors.text }]}>
                  Performance and error data
                </ThemedText>
              </View>
            </View>
          </View>
        </View>

        {/* How We Use Your Information */}
        <View style={styles.section}>
          <ThemedText style={[styles.sectionTitle, { color: colors.text }]}>
            How We Use Your Information
          </ThemedText>
          <View style={[styles.sectionCard, { backgroundColor: colors.background }]}>
            <ThemedText style={[styles.paragraph, { color: colors.text }]}>
              We use the information we collect to:
            </ThemedText>
            <View style={styles.bulletList}>
              <View style={styles.bulletItem}>
                <ThemedText style={styles.bullet}>•</ThemedText>
                <ThemedText style={[styles.bulletText, { color: colors.text }]}>
                  Provide and maintain our services
                </ThemedText>
              </View>
              <View style={styles.bulletItem}>
                <ThemedText style={styles.bullet}>•</ThemedText>
                <ThemedText style={[styles.bulletText, { color: colors.text }]}>
                  Improve and personalize your experience
                </ThemedText>
              </View>
              <View style={styles.bulletItem}>
                <ThemedText style={styles.bullet}>•</ThemedText>
                <ThemedText style={[styles.bulletText, { color: colors.text }]}>
                  Communicate with you about updates and features
                </ThemedText>
              </View>
              <View style={styles.bulletItem}>
                <ThemedText style={styles.bullet}>•</ThemedText>
                <ThemedText style={[styles.bulletText, { color: colors.text }]}>
                  Ensure the security and integrity of our app
                </ThemedText>
              </View>
              <View style={styles.bulletItem}>
                <ThemedText style={styles.bullet}>•</ThemedText>
                <ThemedText style={[styles.bulletText, { color: colors.text }]}>
                  Comply with legal obligations
                </ThemedText>
              </View>
            </View>
          </View>
        </View>

        {/* Data Sharing */}
        <View style={styles.section}>
          <ThemedText style={[styles.sectionTitle, { color: colors.text }]}>
            Data Sharing and Disclosure
          </ThemedText>
          <View style={[styles.sectionCard, { backgroundColor: colors.background }]}>
            <ThemedText style={[styles.paragraph, { color: colors.text }]}>
              We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except in the following circumstances:
            </ThemedText>
            <View style={styles.bulletList}>
              <View style={styles.bulletItem}>
                <ThemedText style={styles.bullet}>•</ThemedText>
                <ThemedText style={[styles.bulletText, { color: colors.text }]}>
                  With your explicit consent
                </ThemedText>
              </View>
              <View style={styles.bulletItem}>
                <ThemedText style={styles.bullet}>•</ThemedText>
                <ThemedText style={[styles.bulletText, { color: colors.text }]}>
                  To comply with legal requirements
                </ThemedText>
              </View>
              <View style={styles.bulletItem}>
                <ThemedText style={styles.bullet}>•</ThemedText>
                <ThemedText style={[styles.bulletText, { color: colors.text }]}>
                  To protect our rights and safety
                </ThemedText>
              </View>
              <View style={styles.bulletItem}>
                <ThemedText style={styles.bullet}>•</ThemedText>
                <ThemedText style={[styles.bulletText, { color: colors.text }]}>
                  With trusted service providers who assist in app operations
                </ThemedText>
              </View>
            </View>
          </View>
        </View>

        {/* Data Security */}
        <View style={styles.section}>
          <ThemedText style={[styles.sectionTitle, { color: colors.text }]}>
            Data Security
          </ThemedText>
          <View style={[styles.sectionCard, { backgroundColor: colors.background }]}>
            <ThemedText style={[styles.paragraph, { color: colors.text }]}>
              We implement appropriate technical and organizational security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. These measures include:
            </ThemedText>
            <View style={styles.bulletList}>
              <View style={styles.bulletItem}>
                <ThemedText style={styles.bullet}>•</ThemedText>
                <ThemedText style={[styles.bulletText, { color: colors.text }]}>
                  Encryption of data in transit and at rest
                </ThemedText>
              </View>
              <View style={styles.bulletItem}>
                <ThemedText style={styles.bullet}>•</ThemedText>
                <ThemedText style={[styles.bulletText, { color: colors.text }]}>
                  Regular security assessments and updates
                </ThemedText>
              </View>
              <View style={styles.bulletItem}>
                <ThemedText style={styles.bullet}>•</ThemedText>
                <ThemedText style={[styles.bulletText, { color: colors.text }]}>
                  Access controls and authentication measures
                </ThemedText>
              </View>
              <View style={styles.bulletItem}>
                <ThemedText style={styles.bullet}>•</ThemedText>
                <ThemedText style={[styles.bulletText, { color: colors.text }]}>
                  Secure data storage and backup procedures
                </ThemedText>
              </View>
            </View>
          </View>
        </View>

        {/* Your Rights */}
        <View style={styles.section}>
          <ThemedText style={[styles.sectionTitle, { color: colors.text }]}>
            Your Privacy Rights
          </ThemedText>
          <View style={[styles.sectionCard, { backgroundColor: colors.background }]}>
            <ThemedText style={[styles.paragraph, { color: colors.text }]}>
              You have the following rights regarding your personal information:
            </ThemedText>
            <View style={styles.bulletList}>
              <View style={styles.bulletItem}>
                <ThemedText style={styles.bullet}>•</ThemedText>
                <ThemedText style={[styles.bulletText, { color: colors.text }]}>
                  Access and review your personal data
                </ThemedText>
              </View>
              <View style={styles.bulletItem}>
                <ThemedText style={styles.bullet}>•</ThemedText>
                <ThemedText style={[styles.bulletText, { color: colors.text }]}>
                  Update or correct inaccurate information
                </ThemedText>
              </View>
              <View style={styles.bulletItem}>
                <ThemedText style={styles.bullet}>•</ThemedText>
                <ThemedText style={[styles.bulletText, { color: colors.text }]}>
                  Request deletion of your personal data
                </ThemedText>
              </View>
              <View style={styles.bulletItem}>
                <ThemedText style={styles.bullet}>•</ThemedText>
                <ThemedText style={[styles.bulletText, { color: colors.text }]}>
                  Opt-out of marketing communications
                </ThemedText>
              </View>
              <View style={styles.bulletItem}>
                <ThemedText style={styles.bullet}>•</ThemedText>
                <ThemedText style={[styles.bulletText, { color: colors.text }]}>
                  Lodge a complaint with supervisory authorities
                </ThemedText>
              </View>
            </View>
          </View>
        </View>

        {/* Contact Information */}
        <View style={styles.section}>
          <ThemedText style={[styles.sectionTitle, { color: colors.text }]}>
            Contact Us
          </ThemedText>
          <View style={[styles.sectionCard, { backgroundColor: colors.background }]}>
            <ThemedText style={[styles.paragraph, { color: colors.text }]}>
              If you have any questions about this Privacy Policy or our data practices, please contact us:
            </ThemedText>
            <View style={styles.contactInfo}>
              <ThemedText style={[styles.contactLabel, { color: colors.text }]}>
                Email:
              </ThemedText>
              <ThemedText style={[styles.contactValue, { color: colors.tint }]}>
                privacy@portfolioapp.com
              </ThemedText>
            </View>
            <View style={styles.contactInfo}>
              <ThemedText style={[styles.contactLabel, { color: colors.text }]}>
                Address:
              </ThemedText>
              <ThemedText style={[styles.contactValue, { color: colors.tint }]}>
                123 Tech Street, San Francisco, CA 94105
              </ThemedText>
            </View>
            <View style={styles.contactInfo}>
              <ThemedText style={[styles.contactLabel, { color: colors.text }]}>
                Phone:
              </ThemedText>
              <ThemedText style={[styles.contactValue, { color: colors.tint }]}>
                +1 (555) 123-4567
              </ThemedText>
            </View>
          </View>
        </View>

        {/* Changes to Policy */}
        <View style={styles.section}>
          <ThemedText style={[styles.sectionTitle, { color: colors.text }]}>
            Changes to This Policy
          </ThemedText>
          <View style={[styles.sectionCard, { backgroundColor: colors.background }]}>
            <ThemedText style={[styles.paragraph, { color: colors.text }]}>
              We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date at the top of this policy.
            </ThemedText>
            <ThemedText style={[styles.paragraph, { color: colors.text }]}>
              We encourage you to review this Privacy Policy periodically for any changes. Your continued use of the app after any changes constitutes acceptance of the updated policy.
            </ThemedText>
          </View>
        </View>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    paddingTop: 60,
    paddingBottom: 20,
    paddingHorizontal: 20,
  },
  headerContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  backButton: {
    marginRight: 20,
  },
  backButtonText: {
    fontSize: 16,
    fontWeight: '600',
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: 'bold',
  },
  content: {
    flex: 1,
    padding: 20,
  },
  lastUpdatedContainer: {
    alignItems: 'center',
    marginBottom: 20,
  },
  lastUpdatedText: {
    fontSize: 14,
    opacity: 0.7,
    fontStyle: 'italic',
  },
  section: {
    marginBottom: 25,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 15,
  },
  sectionCard: {
    borderRadius: 16,
    padding: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 4,
  },
  subsectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 10,
    marginTop: 15,
  },
  paragraph: {
    fontSize: 16,
    lineHeight: 24,
    marginBottom: 15,
    opacity: 0.8,
  },
  bulletList: {
    marginLeft: 10,
  },
  bulletItem: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    marginBottom: 8,
  },
  bullet: {
    fontSize: 16,
    marginRight: 10,
    marginTop: 2,
    color: '#667eea',
  },
  bulletText: {
    fontSize: 16,
    lineHeight: 24,
    flex: 1,
    opacity: 0.8,
  },
  contactInfo: {
    marginBottom: 10,
  },
  contactLabel: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 2,
  },
  contactValue: {
    fontSize: 16,
    marginBottom: 10,
  },
}); 