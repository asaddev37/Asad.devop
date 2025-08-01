import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity, TextInput, Alert } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { ThemedText } from '@/components/ThemedText';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/useColorScheme';

interface ContactMethod {
  id: string;
  type: string;
  value: string;
  icon: string;
  action: string;
}

const contactMethods: ContactMethod[] = [
  {
    id: '1',
    type: 'Email',
    value: 'john.doe@example.com',
    icon: '📧',
    action: 'mailto:john.doe@example.com',
  },
  {
    id: '2',
    type: 'Phone',
    value: '+1 (555) 123-4567',
    icon: '📞',
    action: 'tel:+15551234567',
  },
  {
    id: '3',
    type: 'LinkedIn',
    value: 'linkedin.com/in/johndoe',
    icon: '💼',
    action: 'https://linkedin.com/in/johndoe',
  },
  {
    id: '4',
    type: 'GitHub',
    value: 'github.com/johndoe',
    icon: '🐙',
    action: 'https://github.com/johndoe',
  },
  {
    id: '5',
    type: 'Twitter',
    value: '@johndoe',
    icon: '🐦',
    action: 'https://twitter.com/johndoe',
  },
  {
    id: '6',
    type: 'Portfolio',
    value: 'johndoe.dev',
    icon: '🌐',
    action: 'https://johndoe.dev',
  },
];

export default function ContactScreen() {
  const colorScheme = useColorScheme();
  const colors = Colors[colorScheme ?? 'light'];
  
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    subject: '',
    message: '',
  });

  const handleContactMethod = (method: ContactMethod) => {
    // In a real app, you would use Linking.openURL(method.action)
    Alert.alert(
      'Contact Method',
      `Would you like to open ${method.type}?`,
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Open', onPress: () => console.log(`Opening ${method.action}`) },
      ]
    );
  };

  const handleSubmitForm = () => {
    if (!formData.name || !formData.email || !formData.message) {
      Alert.alert('Error', 'Please fill in all required fields');
      return;
    }
    
    // In a real app, you would send this data to your backend
    Alert.alert(
      'Success',
      'Thank you for your message! I will get back to you soon.',
      [{ text: 'OK', onPress: () => setFormData({ name: '', email: '', subject: '', message: '' }) }]
    );
  };

  const renderContactCard = (method: ContactMethod) => (
    <TouchableOpacity
      key={method.id}
      style={[styles.contactCard, { backgroundColor: colors.background }]}
      onPress={() => handleContactMethod(method)}
    >
      <ThemedText style={styles.contactIcon}>{method.icon}</ThemedText>
      <View style={styles.contactInfo}>
        <ThemedText style={[styles.contactType, { color: colors.text }]}>
          {method.type}
        </ThemedText>
        <ThemedText style={[styles.contactValue, { color: colors.tint }]}>
          {method.value}
        </ThemedText>
      </View>
      <ThemedText style={styles.contactArrow}>→</ThemedText>
    </TouchableOpacity>
  );

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
          <ThemedText style={[styles.headerTitle, { color: colors.text }]}>
            Get In Touch
          </ThemedText>
          <ThemedText style={[styles.headerSubtitle, { color: colors.text }]}>
            Let's work together on your next project
          </ThemedText>
        </View>
      </LinearGradient>

      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        {/* Contact Form */}
        <View style={styles.section}>
          <ThemedText style={[styles.sectionTitle, { color: colors.text }]}>
            Send Message
          </ThemedText>
          <View style={[styles.formContainer, { backgroundColor: colors.background }]}>
            <View style={styles.inputGroup}>
              <ThemedText style={[styles.inputLabel, { color: colors.text }]}>
                Name *
              </ThemedText>
              <TextInput
                style={[styles.textInput, { 
                  backgroundColor: colorScheme === 'dark' ? '#2a2a2a' : '#f5f5f5',
                  color: colors.text,
                  borderColor: colors.tint,
                }]}
                value={formData.name}
                onChangeText={(text) => setFormData({ ...formData, name: text })}
                placeholder="Your name"
                placeholderTextColor={colors.text + '80'}
              />
            </View>

            <View style={styles.inputGroup}>
              <ThemedText style={[styles.inputLabel, { color: colors.text }]}>
                Email *
              </ThemedText>
              <TextInput
                style={[styles.textInput, { 
                  backgroundColor: colorScheme === 'dark' ? '#2a2a2a' : '#f5f5f5',
                  color: colors.text,
                  borderColor: colors.tint,
                }]}
                value={formData.email}
                onChangeText={(text) => setFormData({ ...formData, email: text })}
                placeholder="your.email@example.com"
                placeholderTextColor={colors.text + '80'}
                keyboardType="email-address"
              />
            </View>

            <View style={styles.inputGroup}>
              <ThemedText style={[styles.inputLabel, { color: colors.text }]}>
                Subject
              </ThemedText>
              <TextInput
                style={[styles.textInput, { 
                  backgroundColor: colorScheme === 'dark' ? '#2a2a2a' : '#f5f5f5',
                  color: colors.text,
                  borderColor: colors.tint,
                }]}
                value={formData.subject}
                onChangeText={(text) => setFormData({ ...formData, subject: text })}
                placeholder="Project inquiry"
                placeholderTextColor={colors.text + '80'}
              />
            </View>

            <View style={styles.inputGroup}>
              <ThemedText style={[styles.inputLabel, { color: colors.text }]}>
                Message *
              </ThemedText>
              <TextInput
                style={[styles.textArea, { 
                  backgroundColor: colorScheme === 'dark' ? '#2a2a2a' : '#f5f5f5',
                  color: colors.text,
                  borderColor: colors.tint,
                }]}
                value={formData.message}
                onChangeText={(text) => setFormData({ ...formData, message: text })}
                placeholder="Tell me about your project..."
                placeholderTextColor={colors.text + '80'}
                multiline
                numberOfLines={4}
                textAlignVertical="top"
              />
            </View>

            <TouchableOpacity
              style={[styles.submitButton, { backgroundColor: colors.tint }]}
              onPress={handleSubmitForm}
            >
              <ThemedText style={[styles.submitButtonText, { color: colors.background }]}>
                Send Message
              </ThemedText>
            </TouchableOpacity>
          </View>
        </View>

        {/* Contact Methods */}
        <View style={styles.section}>
          <ThemedText style={[styles.sectionTitle, { color: colors.text }]}>
            Contact Information
          </ThemedText>
          <View style={styles.contactMethodsContainer}>
            {contactMethods.map(renderContactCard)}
          </View>
        </View>

        {/* Quick Contact */}
        <View style={styles.section}>
          <ThemedText style={[styles.sectionTitle, { color: colors.text }]}>
            Quick Contact
          </ThemedText>
          <View style={styles.quickContactContainer}>
            <TouchableOpacity
              style={[styles.quickContactButton, { backgroundColor: colors.tint }]}
              onPress={() => handleContactMethod(contactMethods[0])}
            >
              <ThemedText style={styles.quickContactIcon}>📧</ThemedText>
              <ThemedText style={[styles.quickContactText, { color: colors.background }]}>
                Email Me
              </ThemedText>
            </TouchableOpacity>

            <TouchableOpacity
              style={[styles.quickContactButton, { backgroundColor: colors.tint }]}
              onPress={() => handleContactMethod(contactMethods[1])}
            >
              <ThemedText style={styles.quickContactIcon}>📞</ThemedText>
              <ThemedText style={[styles.quickContactText, { color: colors.background }]}>
                Call Me
              </ThemedText>
            </TouchableOpacity>
          </View>
        </View>

        {/* Location Info */}
        <View style={styles.section}>
          <ThemedText style={[styles.sectionTitle, { color: colors.text }]}>
            Location
          </ThemedText>
          <View style={[styles.locationCard, { backgroundColor: colors.background }]}>
            <ThemedText style={styles.locationIcon}>📍</ThemedText>
            <View style={styles.locationInfo}>
              <ThemedText style={[styles.locationTitle, { color: colors.text }]}>
                San Francisco, CA
              </ThemedText>
              <ThemedText style={[styles.locationSubtitle, { color: colors.text }]}>
                Available for remote work worldwide
              </ThemedText>
            </View>
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
    alignItems: 'center',
  },
  headerTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 5,
  },
  headerSubtitle: {
    fontSize: 16,
    opacity: 0.8,
  },
  content: {
    flex: 1,
    padding: 20,
  },
  section: {
    marginBottom: 30,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 15,
  },
  formContainer: {
    borderRadius: 16,
    padding: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 4,
  },
  inputGroup: {
    marginBottom: 20,
  },
  inputLabel: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 8,
  },
  textInput: {
    height: 50,
    borderWidth: 1,
    borderRadius: 8,
    paddingHorizontal: 15,
    fontSize: 16,
  },
  textArea: {
    height: 120,
    borderWidth: 1,
    borderRadius: 8,
    paddingHorizontal: 15,
    paddingTop: 15,
    fontSize: 16,
  },
  submitButton: {
    height: 50,
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 10,
  },
  submitButtonText: {
    fontSize: 16,
    fontWeight: '600',
  },
  contactMethodsContainer: {
    gap: 15,
  },
  contactCard: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 20,
    borderRadius: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  contactIcon: {
    fontSize: 24,
    marginRight: 15,
  },
  contactInfo: {
    flex: 1,
  },
  contactType: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 2,
  },
  contactValue: {
    fontSize: 14,
  },
  contactArrow: {
    fontSize: 18,
    color: '#666',
  },
  quickContactContainer: {
    flexDirection: 'row',
    gap: 15,
  },
  quickContactButton: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 15,
    borderRadius: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  quickContactIcon: {
    fontSize: 20,
    marginRight: 8,
  },
  quickContactText: {
    fontSize: 16,
    fontWeight: '600',
  },
  locationCard: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 20,
    borderRadius: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  locationIcon: {
    fontSize: 24,
    marginRight: 15,
  },
  locationInfo: {
    flex: 1,
  },
  locationTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 2,
  },
  locationSubtitle: {
    fontSize: 14,
    opacity: 0.7,
  },
}); 