import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, StatusBar } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { router } from 'expo-router';

const AboutScreen = () => {
  return (
    <View style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor="transparent" translucent />
      
      <LinearGradient colors={['#4A90E2', '#357ABD']} style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
          <Ionicons name="arrow-back" size={24} color="white" />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>About</Text>
        <View style={styles.placeholder} />
      </LinearGradient>

      <ScrollView style={styles.content}>
        <View style={styles.contentContainer}>
          <View style={styles.logoContainer}>
            <Ionicons name="analytics" size={60} color="#4A90E2" />
          </View>
          
          <Text style={styles.appName}>SmartBudget Analyzer</Text>
          <Text style={styles.version}>Version 1.1</Text>
          
          <Text style={styles.description}>
            Your intelligent personal finance companion designed to help you achieve financial freedom through AI-powered insights and smart budgeting.
          </Text>

          <View style={styles.featuresContainer}>
            <Text style={styles.sectionTitle}>Key Features</Text>
            
            <View style={styles.featureItem}>
              <Ionicons name="analytics" size={24} color="#4A90E2" />
              <View style={styles.featureText}>
                <Text style={styles.featureTitle}>AI-Powered Analytics</Text>
                <Text style={styles.featureDesc}>Advanced insights and spending patterns</Text>
              </View>
            </View>

            <View style={styles.featureItem}>
              <Ionicons name="shield-checkmark" size={24} color="#50C878" />
              <View style={styles.featureText}>
                <Text style={styles.featureTitle}>Bank-Level Security</Text>
                <Text style={styles.featureDesc}>End-to-end encryption and biometric auth</Text>
              </View>
            </View>

            <View style={styles.featureItem}>
              <Ionicons name="trending-up" size={24} color="#FF6B35" />
              <View style={styles.featureText}>
                <Text style={styles.featureTitle}>Smart Budgeting</Text>
                <Text style={styles.featureDesc}>Intelligent recommendations and tracking</Text>
              </View>
            </View>
          </View>

          <View style={styles.teamSection}>
            <Text style={styles.sectionTitle}>Development Team</Text>
            <Text style={styles.teamMember}>AK~~37</Text>
            <Text style={styles.teamRole}>Lead Developer & Designer</Text>
          </View>

          <View style={styles.footer}>
            <Text style={styles.footerText}>© 2024 SmartBudget Analyzer</Text>
            <Text style={styles.footerSubtext}>Made with ❤️ for better financial management</Text>
          </View>
        </View>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F8F9FA',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingTop: 60,
    paddingBottom: 20,
    paddingHorizontal: 20,
  },
  backButton: {
    padding: 8,
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: 'white',
  },
  placeholder: {
    width: 40,
  },
  content: {
    flex: 1,
  },
  contentContainer: {
    padding: 20,
    alignItems: 'center',
  },
  logoContainer: {
    width: 100,
    height: 100,
    borderRadius: 50,
    backgroundColor: '#F0F8FF',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 20,
  },
  appName: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 5,
  },
  version: {
    fontSize: 16,
    color: '#666',
    marginBottom: 20,
  },
  description: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    lineHeight: 24,
    marginBottom: 30,
  },
  featuresContainer: {
    width: '100%',
    marginBottom: 30,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 20,
    textAlign: 'center',
  },
  featureItem: {
    flexDirection: 'row',
    backgroundColor: 'white',
    borderRadius: 15,
    padding: 20,
    marginBottom: 15,
    alignItems: 'center',
  },
  featureText: {
    marginLeft: 15,
    flex: 1,
  },
  featureTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 5,
  },
  featureDesc: {
    fontSize: 14,
    color: '#666',
  },
  teamSection: {
    alignItems: 'center',
    marginBottom: 30,
  },
  teamMember: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 5,
  },
  teamRole: {
    fontSize: 16,
    color: '#4A90E2',
    fontWeight: '600',
  },
  footer: {
    alignItems: 'center',
  },
  footerText: {
    fontSize: 14,
    color: '#666',
    marginBottom: 5,
  },
  footerSubtext: {
    fontSize: 12,
    color: '#999',
  },
});

export default AboutScreen;
