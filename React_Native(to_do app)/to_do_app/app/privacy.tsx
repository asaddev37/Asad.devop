import { View, StyleSheet, ScrollView, Linking } from 'react-native';
import { ThemedView } from '@/components/ThemedView';
import { ThemedText } from '@/components/ThemedText';
import { Ionicons } from '@expo/vector-icons';

export default function PrivacyScreen() {
  const openLink = (url: string) => {
    Linking.openURL(url).catch(err => 
      console.error('Failed to open URL:', err)
    );
  };

  return (
    <ThemedView style={styles.container}>
      <ScrollView showsVerticalScrollIndicator={false}>
        <View style={styles.header}>
          <Ionicons name="shield-checkmark" size={48} color="#4F46E5" />
          <ThemedText style={styles.title}>Privacy Policy</ThemedText>
          <ThemedText style={styles.lastUpdated}>
            Last updated: {new Date().toLocaleDateString()}
          </ThemedText>
        </View>

        <View style={styles.section}>
          <ThemedText style={styles.sectionTitle}>1. Information We Collect</ThemedText>
          <ThemedText style={styles.paragraph}>
            We collect information that you provide directly to us, such as when you create an account, 
            update your profile, or communicate with us. This may include your name, email address, 
            and any other information you choose to provide.
          </ThemedText>
        </View>

        <View style={styles.section}>
          <ThemedText style={styles.sectionTitle}>2. How We Use Your Information</ThemedText>
          <ThemedText style={styles.paragraph}>
            We use the information we collect to:
          </ThemedText>
          <View style={styles.listItem}>
            <Ionicons name="ellipse" size={8} color="#4F46E5" style={styles.bullet} />
            <ThemedText style={styles.listText}>Provide, maintain, and improve our services</ThemedText>
          </View>
          <View style={styles.listItem}>
            <Ionicons name="ellipse" size={8} color="#4F46E5" style={styles.bullet} />
            <ThemedText style={styles.listText}>Send you technical notices and support messages</ThemedText>
          </View>
          <View style={styles.listItem}>
            <Ionicons name="ellipse" size={8} color="#4F46E5" style={styles.bullet} />
            <ThemedText style={styles.listText}>Respond to your comments and questions</ThemedText>
          </View>
        </View>

        <View style={styles.section}>
          <ThemedText style={styles.sectionTitle}>3. Data Security</ThemedText>
          <ThemedText style={styles.paragraph}>
            We take reasonable measures to help protect your personal information from loss, theft, 
            misuse, and unauthorized access, disclosure, alteration, and destruction.
          </ThemedText>
        </View>

        <View style={styles.section}>
          <ThemedText style={styles.sectionTitle}>4. Your Choices</ThemedText>
          <ThemedText style={styles.paragraph}>
            You have the following choices regarding your information:
          </ThemedText>
          <View style={styles.listItem}>
            <Ionicons name="ellipse" size={8} color="#4F46E5" style={styles.bullet} />
            <ThemedText style={styles.listText}>Update or correct your account information</ThemedText>
          </View>
          <View style={styles.listItem}>
            <Ionicons name="ellipse" size={8} color="#4F46E5" style={styles.bullet} />
            <ThemedText style={styles.listText}>Opt-out of promotional communications</ThemedText>
          </View>
          <View style={styles.listItem}>
            <Ionicons name="ellipse" size={8} color="#4F46E5" style={styles.bullet} />
            <ThemedText style={styles.listText}>Delete your account</ThemedText>
          </View>
        </View>

        <View style={styles.section}>
          <ThemedText style={styles.sectionTitle}>5. Contact Us</ThemedText>
          <ThemedText style={[styles.paragraph, styles.contactText]} 
                     onPress={() => openLink('mailto:privacy@taskmaster.com')}>
            privacy@taskmaster.com
          </ThemedText>
        </View>

        <View style={styles.footer}>
          <ThemedText style={styles.footerText}>
            By using our app, you agree to our Terms of Service and Privacy Policy.
          </ThemedText>
        </View>
      </ScrollView>
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
  },
  header: {
    alignItems: 'center',
    marginBottom: 30,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    marginTop: 15,
    marginBottom: 5,
    textAlign: 'center',
  },
  lastUpdated: {
    color: '#6B7280',
    fontSize: 14,
  },
  section: {
    marginBottom: 25,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 10,
    color: '#111827',
  },
  paragraph: {
    fontSize: 15,
    lineHeight: 24,
    color: '#4B5563',
    marginBottom: 10,
  },
  listItem: {
    flexDirection: 'row',
    marginBottom: 8,
    alignItems: 'flex-start',
  },
  bullet: {
    marginTop: 9,
    marginRight: 10,
  },
  listText: {
    flex: 1,
    fontSize: 15,
    lineHeight: 24,
    color: '#4B5563',
  },
  contactText: {
    color: '#4F46E5',
    textDecorationLine: 'underline',
  },
  footer: {
    marginTop: 20,
    paddingTop: 20,
    borderTopWidth: 1,
    borderTopColor: '#E5E7EB',
  },
  footerText: {
    textAlign: 'center',
    color: '#6B7280',
    fontSize: 14,
    lineHeight: 20,
  },
});
