import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity, TextInput, Alert } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { ThemedText } from '@/components/ThemedText';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/useColorScheme';
import { useProfile } from '@/contexts/ProfileContext';
import ProfilePicture from '@/components/ProfilePicture';

export default function ProfileScreen() {
  const colorScheme = useColorScheme();
  const colors = Colors[colorScheme ?? 'light'];
  const { profileData, updateProfile, resetProfile } = useProfile();
  
  const [isEditing, setIsEditing] = useState(false);
  const [name, setName] = useState(profileData.name);
  const [title, setTitle] = useState(profileData.title);
  const [email, setEmail] = useState(profileData.email);

  const handleSave = () => {
    updateProfile({ name, title, email });
    Alert.alert('Success', 'Profile updated successfully!');
    setIsEditing(false);
  };

  const handleCancel = () => {
    setName(profileData.name);
    setTitle(profileData.title);
    setEmail(profileData.email);
    setIsEditing(false);
  };

  return (
    <View style={[styles.container, { backgroundColor: colors.background }]}>
      {/* Header */}
      <LinearGradient
        colors={
          colorScheme === 'dark'
            ? ['#1e40af', '#7c3aed', '#1e2937']
            : ['#667eea', '#764ba2', '#f0f9ff']
        }
        style={styles.header}
      >
        <View style={styles.headerContent}>
          <ProfilePicture 
            size={100} 
            editable={isEditing}
          />
          <ThemedText style={[styles.profileName, { color: colors.text }]}>
            {profileData.name}
          </ThemedText>
          <ThemedText style={[styles.profileTitle, { color: colors.text }]}>
            {profileData.title}
          </ThemedText>
        </View>
      </LinearGradient>

      {/* Edit Button */}
      <View style={styles.editButtonContainer}>
        {!isEditing ? (
          <TouchableOpacity
            style={[styles.editButton, { backgroundColor: colors.tint }]}
            onPress={() => setIsEditing(true)}
          >
            <ThemedText style={[styles.editButtonText, { color: colors.background }]}>
              Edit Profile
            </ThemedText>
          </TouchableOpacity>
        ) : (
          <View style={styles.editActions}>
            <TouchableOpacity
              style={[styles.actionButton, { backgroundColor: colors.tint }]}
              onPress={handleSave}
            >
              <ThemedText style={[styles.actionButtonText, { color: colors.background }]}>
                Save
              </ThemedText>
            </TouchableOpacity>
            <TouchableOpacity
              style={[styles.actionButton, { borderColor: colors.tint, borderWidth: 1 }]}
              onPress={handleCancel}
            >
              <ThemedText style={[styles.actionButtonText, { color: colors.tint }]}>
                Cancel
              </ThemedText>
            </TouchableOpacity>
          </View>
        )}
      </View>

      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        {/* Basic Information */}
        <View style={styles.section}>
          <ThemedText style={[styles.sectionTitle, { color: colors.text }]}>
            Basic Information
          </ThemedText>
          <View style={[styles.sectionCard, { backgroundColor: colors.cardBackground }]}>
            <View style={styles.inputGroup}>
              <ThemedText style={[styles.inputLabel, { color: colors.text }]}>
                Full Name *
              </ThemedText>
              <TextInput
                style={[styles.textInput, { 
                  backgroundColor: colorScheme === 'dark' ? '#2a2a2a' : '#f5f5f5',
                  color: colors.text,
                  borderColor: colors.tint,
                }]}
                value={name}
                onChangeText={setName}
                placeholder="Enter your full name"
                placeholderTextColor={colors.text + '80'}
                editable={isEditing}
              />
            </View>

            <View style={styles.inputGroup}>
              <ThemedText style={[styles.inputLabel, { color: colors.text }]}>
                Professional Title *
              </ThemedText>
              <TextInput
                style={[styles.textInput, { 
                  backgroundColor: colorScheme === 'dark' ? '#2a2a2a' : '#f5f5f5',
                  color: colors.text,
                  borderColor: colors.tint,
                }]}
                value={title}
                onChangeText={setTitle}
                placeholder="e.g., Senior Full Stack Developer"
                placeholderTextColor={colors.text + '80'}
                editable={isEditing}
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
                value={email}
                onChangeText={setEmail}
                placeholder="your.email@example.com"
                placeholderTextColor={colors.text + '80'}
                keyboardType="email-address"
                editable={isEditing}
              />
            </View>
          </View>
        </View>

        {/* Profile Stats */}
        <View style={styles.section}>
          <ThemedText style={[styles.sectionTitle, { color: colors.text }]}>
            Profile Statistics
          </ThemedText>
          <View style={styles.statsContainer}>
            <View style={[styles.statCard, { backgroundColor: colors.cardBackground }]}>
              <ThemedText style={[styles.statNumber, { color: colors.tint }]}>{profileData.stats.projects}+</ThemedText>
              <ThemedText style={[styles.statLabel, { color: colors.text }]}>Projects</ThemedText>
            </View>
            <View style={[styles.statCard, { backgroundColor: colors.cardBackground }]}>
              <ThemedText style={[styles.statNumber, { color: colors.tint }]}>{profileData.stats.experience}+</ThemedText>
              <ThemedText style={[styles.statLabel, { color: colors.text }]}>Years Experience</ThemedText>
            </View>
            <View style={[styles.statCard, { backgroundColor: colors.cardBackground }]}>
              <ThemedText style={[styles.statNumber, { color: colors.tint }]}>{profileData.stats.skills}+</ThemedText>
              <ThemedText style={[styles.statLabel, { color: colors.text }]}>Skills</ThemedText>
            </View>
          </View>
        </View>

        {/* Quick Actions */}
        <View style={styles.section}>
          <ThemedText style={[styles.sectionTitle, { color: colors.text }]}>
            Quick Actions
          </ThemedText>
          <View style={styles.quickActionsContainer}>
            <TouchableOpacity
              style={[styles.quickActionCard, { backgroundColor: colors.cardBackground }]}
              onPress={() => Alert.alert('Download', 'Resume download started...')}
            >
              <ThemedText style={styles.quickActionIcon}>📄</ThemedText>
              <ThemedText style={[styles.quickActionTitle, { color: colors.text }]}>
                Download Resume
              </ThemedText>
            </TouchableOpacity>

            <TouchableOpacity
              style={[styles.quickActionCard, { backgroundColor: colors.cardBackground }]}
              onPress={() => Alert.alert('Share', 'Sharing profile...')}
            >
              <ThemedText style={styles.quickActionIcon}>📤</ThemedText>
              <ThemedText style={[styles.quickActionTitle, { color: colors.text }]}>
                Share Profile
              </ThemedText>
            </TouchableOpacity>

            <TouchableOpacity
              style={[styles.quickActionCard, { backgroundColor: colors.cardBackground }]}
              onPress={() => Alert.alert('Reset', 'This will reset all profile data. Continue?', [
                { text: 'Cancel', style: 'cancel' },
                { text: 'Reset', style: 'destructive', onPress: resetProfile }
              ])}
            >
              <ThemedText style={styles.quickActionIcon}>🔄</ThemedText>
              <ThemedText style={[styles.quickActionTitle, { color: colors.text }]}>
                Reset Profile
              </ThemedText>
            </TouchableOpacity>
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
    paddingBottom: 30,
    paddingHorizontal: 20,
  },
  headerContent: {
    alignItems: 'center',
  },
  profileName: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 5,
    marginTop: 15,
  },
  profileTitle: {
    fontSize: 16,
    opacity: 0.8,
  },
  editButtonContainer: {
    marginBottom: 20,
    paddingHorizontal: 20,
  },
  editButton: {
    height: 50,
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
  },
  editButtonText: {
    fontSize: 16,
    fontWeight: '600',
  },
  editActions: {
    flexDirection: 'row',
    gap: 15,
  },
  actionButton: {
    flex: 1,
    height: 50,
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
  },
  actionButtonText: {
    fontSize: 16,
    fontWeight: '600',
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
  sectionCard: {
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
  statsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  statCard: {
    flex: 1,
    marginHorizontal: 5,
    padding: 15,
    borderRadius: 12,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  statNumber: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 5,
  },
  statLabel: {
    fontSize: 12,
    opacity: 0.7,
  },
  quickActionsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 15,
  },
  quickActionCard: {
    width: '47%',
    padding: 20,
    borderRadius: 12,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  quickActionIcon: {
    fontSize: 30,
    marginBottom: 10,
  },
  quickActionTitle: {
    fontSize: 14,
    fontWeight: '600',
    textAlign: 'center',
  },
}); 