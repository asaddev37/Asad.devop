import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { useTheme } from '../../contexts/ThemeContext';

export default function PrivacyPolicyScreen() {
  const { colors } = useTheme();
  
  return (
    <ScrollView style={[styles.container, { backgroundColor: colors.background }]}>
      <View style={styles.content}>
        <Text style={[styles.title, { color: colors.text }]}>Privacy Policy</Text>
        <Text style={[styles.text, { color: colors.text }]}>
          Your privacy is important to us. This privacy policy explains what personal data we collect and how we use it.
        </Text>
        
        <Text style={[styles.sectionTitle, { color: colors.text, marginTop: 20 }]}>
          Information We Collect
        </Text>
        <Text style={[styles.text, { color: colors.text }]}>
          We may collect information about you in a variety of ways, including:
          • Location data (to provide weather information)
          • Device information
          • Usage data
        </Text>
        
        <Text style={[styles.sectionTitle, { color: colors.text, marginTop: 20 }]}>
          How We Use Your Information
        </Text>
        <Text style={[styles.text, { color: colors.text }]}>
          We use the information we collect to:
          • Provide and maintain our service
          • Improve user experience
          • Analyze usage of our service
        </Text>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  content: {
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
    textAlign: 'center',
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginTop: 10,
    marginBottom: 10,
  },
  text: {
    fontSize: 16,
    lineHeight: 24,
  },
});
