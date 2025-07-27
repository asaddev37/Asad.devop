import { View, StyleSheet, Image, Linking, TouchableOpacity } from 'react-native';
import { ThemedView } from '@/components/ThemedView';
import { ThemedText } from '@/components/ThemedText';
import { Ionicons } from '@expo/vector-icons';

export default function AboutScreen() {
  const openWebsite = (url: string) => {
    Linking.openURL(url).catch(err => 
      console.error('Failed to open URL:', err)
    );
  };

  return (
    <ThemedView style={styles.container}>
      <View style={styles.header}>
        <Image 
          source={require('@/assets/images/icon.png')} 
          style={styles.logo}
          resizeMode="contain"
        />
        <ThemedText style={styles.appName}>TaskMaster</ThemedText>
        <ThemedText style={styles.version}>Version 1.0.0</ThemedText>
      </View>

      <View style={styles.content}>
        <ThemedText style={styles.description}>
          TaskMaster helps you organize your tasks and boost your productivity. 
          Built with ❤️ using React Native and Expo.
        </ThemedText>

        <View style={styles.section}>
          <ThemedText style={styles.sectionTitle}>Features</ThemedText>
          <View style={styles.featureItem}>
            <Ionicons name="checkmark-circle" size={20} color="#4F46E5" />
            <ThemedText style={styles.featureText}>Task Management</ThemedText>
          </View>
          <View style={styles.featureItem}>
            <Ionicons name="checkmark-circle" size={20} color="#4F46E5" />
            <ThemedText style={styles.featureText}>Dark Mode</ThemedText>
          </View>
          <View style={styles.featureItem}>
            <Ionicons name="checkmark-circle" size={20} color="#4F46E5" />
            <ThemedText style={styles.featureText}>Offline Support</ThemedText>
          </View>
        </View>

        <View style={styles.section}>
          <ThemedText style={styles.sectionTitle}>Connect With Us</ThemedText>
          <View style={styles.socialLinks}>
            <TouchableOpacity 
              style={styles.socialIcon}
              onPress={() => openWebsite('https://twitter.com')}
            >
              <Ionicons name="logo-twitter" size={28} color="#1DA1F2" />
            </TouchableOpacity>
            <TouchableOpacity 
              style={styles.socialIcon}
              onPress={() => openWebsite('https://github.com')}
            >
              <Ionicons name="logo-github" size={28} color="#333" />
            </TouchableOpacity>
            <TouchableOpacity 
              style={styles.socialIcon}
              onPress={() => openWebsite('mailto:support@taskmaster.com')}
            >
              <Ionicons name="mail" size={28} color="#EA4335" />
            </TouchableOpacity>
          </View>
        </View>
      </View>

      <View style={styles.footer}>
        <ThemedText style={styles.copyright}>
          © {new Date().getFullYear()} TaskMaster. All rights reserved.
        </ThemedText>
      </View>
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
    marginTop: 30,
    marginBottom: 20,
  },
  logo: {
    width: 100,
    height: 100,
    marginBottom: 15,
  },
  appName: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 5,
  },
  version: {
    color: '#6B7280',
    marginBottom: 20,
  },
  content: {
    flex: 1,
  },
  description: {
    fontSize: 16,
    lineHeight: 24,
    textAlign: 'center',
    marginBottom: 30,
    color: '#4B5563',
  },
  section: {
    marginBottom: 30,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 15,
    color: '#111827',
  },
  featureItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  featureText: {
    marginLeft: 10,
    fontSize: 16,
    color: '#374151',
  },
  socialLinks: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginTop: 10,
  },
  socialIcon: {
    marginHorizontal: 15,
    padding: 10,
  },
  footer: {
    marginTop: 'auto',
    paddingVertical: 20,
    borderTopWidth: 1,
    borderTopColor: '#E5E7EB',
  },
  copyright: {
    textAlign: 'center',
    color: '#6B7280',
    fontSize: 14,
  },
});
