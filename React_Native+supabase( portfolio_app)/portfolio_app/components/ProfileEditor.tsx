import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity, TextInput, Alert } from 'react-native';
import { ThemedText } from '@/components/ThemedText';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/useColorScheme';
import { useProfile, ProfileData } from '@/contexts/ProfileContext';

interface ProfileEditorProps {
  onSave: () => void;
  onCancel: () => void;
}

export default function ProfileEditor({ onSave, onCancel }: ProfileEditorProps) {
  const colorScheme = useColorScheme();
  const colors = Colors[colorScheme ?? 'light'];
  const { profileData, updateProfile } = useProfile();
  
  const [editingData, setEditingData] = useState<ProfileData>(profileData);
  const [activeSection, setActiveSection] = useState<'basic' | 'social' | 'stats' | 'content'>('basic');

  const handleSave = async () => {
    try {
      await updateProfile(editingData);
      Alert.alert('Success', 'Profile updated successfully!');
      onSave();
    } catch (error) {
      Alert.alert('Error', 'Failed to update profile. Please try again.');
    }
  };

  const updateField = (field: keyof ProfileData, value: any) => {
    setEditingData(prev => ({ ...prev, [field]: value }));
  };

  const updateSocialLink = (platform: keyof ProfileData['socialLinks'], value: string) => {
    setEditingData(prev => ({
      ...prev,
      socialLinks: { ...prev.socialLinks, [platform]: value }
    }));
  };

  const updateStat = (stat: keyof ProfileData['stats'], value: number) => {
    setEditingData(prev => ({
      ...prev,
      stats: { ...prev.stats, [stat]: value }
    }));
  };

  const renderBasicInfo = () => (
    <View style={styles.section}>
      <ThemedText style={[styles.sectionTitle, { color: colors.text }]}>
        Basic Information
      </ThemedText>
      
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
          value={editingData.name}
          onChangeText={(text) => updateField('name', text)}
          placeholder="Enter your full name"
          placeholderTextColor={colors.text + '80'}
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
          value={editingData.title}
          onChangeText={(text) => updateField('title', text)}
          placeholder="e.g., Senior Full Stack Developer"
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
          value={editingData.email}
          onChangeText={(text) => updateField('email', text)}
          placeholder="your.email@example.com"
          placeholderTextColor={colors.text + '80'}
          keyboardType="email-address"
        />
      </View>

      <View style={styles.inputGroup}>
        <ThemedText style={[styles.inputLabel, { color: colors.text }]}>
          Phone
        </ThemedText>
        <TextInput
          style={[styles.textInput, { 
            backgroundColor: colorScheme === 'dark' ? '#2a2a2a' : '#f5f5f5',
            color: colors.text,
            borderColor: colors.tint,
          }]}
          value={editingData.phone}
          onChangeText={(text) => updateField('phone', text)}
          placeholder="+1 (555) 123-4567"
          placeholderTextColor={colors.text + '80'}
          keyboardType="phone-pad"
        />
      </View>

      <View style={styles.inputGroup}>
        <ThemedText style={[styles.inputLabel, { color: colors.text }]}>
          Location
        </ThemedText>
        <TextInput
          style={[styles.textInput, { 
            backgroundColor: colorScheme === 'dark' ? '#2a2a2a' : '#f5f5f5',
            color: colors.text,
            borderColor: colors.tint,
          }]}
          value={editingData.location}
          onChangeText={(text) => updateField('location', text)}
          placeholder="City, State/Country"
          placeholderTextColor={colors.text + '80'}
        />
      </View>

      <View style={styles.inputGroup}>
        <ThemedText style={[styles.inputLabel, { color: colors.text }]}>
          Bio
        </ThemedText>
        <TextInput
          style={[styles.textArea, { 
            backgroundColor: colorScheme === 'dark' ? '#2a2a2a' : '#f5f5f5',
            color: colors.text,
            borderColor: colors.tint,
          }]}
          value={editingData.bio}
          onChangeText={(text) => updateField('bio', text)}
          placeholder="Tell us about yourself..."
          placeholderTextColor={colors.text + '80'}
          multiline
          numberOfLines={4}
          textAlignVertical="top"
        />
      </View>

      <View style={styles.inputGroup}>
        <ThemedText style={[styles.inputLabel, { color: colors.text }]}>
          Avatar Emoji
        </ThemedText>
        <TextInput
          style={[styles.textInput, { 
            backgroundColor: colorScheme === 'dark' ? '#2a2a2a' : '#f5f5f5',
            color: colors.text,
            borderColor: colors.tint,
          }]}
          value={editingData.avatar}
          onChangeText={(text) => updateField('avatar', text)}
          placeholder="👨‍💻"
          placeholderTextColor={colors.text + '80'}
        />
      </View>
    </View>
  );

  const renderSocialLinks = () => (
    <View style={styles.section}>
      <ThemedText style={[styles.sectionTitle, { color: colors.text }]}>
        Social Links
      </ThemedText>
      
      <View style={styles.inputGroup}>
        <ThemedText style={[styles.inputLabel, { color: colors.text }]}>
          LinkedIn
        </ThemedText>
        <TextInput
          style={[styles.textInput, { 
            backgroundColor: colorScheme === 'dark' ? '#2a2a2a' : '#f5f5f5',
            color: colors.text,
            borderColor: colors.tint,
          }]}
          value={editingData.socialLinks.linkedin}
          onChangeText={(text) => updateSocialLink('linkedin', text)}
          placeholder="linkedin.com/in/yourprofile"
          placeholderTextColor={colors.text + '80'}
        />
      </View>

      <View style={styles.inputGroup}>
        <ThemedText style={[styles.inputLabel, { color: colors.text }]}>
          GitHub
        </ThemedText>
        <TextInput
          style={[styles.textInput, { 
            backgroundColor: colorScheme === 'dark' ? '#2a2a2a' : '#f5f5f5',
            color: colors.text,
            borderColor: colors.tint,
          }]}
          value={editingData.socialLinks.github}
          onChangeText={(text) => updateSocialLink('github', text)}
          placeholder="github.com/yourusername"
          placeholderTextColor={colors.text + '80'}
        />
      </View>

      <View style={styles.inputGroup}>
        <ThemedText style={[styles.inputLabel, { color: colors.text }]}>
          Twitter
        </ThemedText>
        <TextInput
          style={[styles.textInput, { 
            backgroundColor: colorScheme === 'dark' ? '#2a2a2a' : '#f5f5f5',
            color: colors.text,
            borderColor: colors.tint,
          }]}
          value={editingData.socialLinks.twitter}
          onChangeText={(text) => updateSocialLink('twitter', text)}
          placeholder="@yourusername"
          placeholderTextColor={colors.text + '80'}
        />
      </View>

      <View style={styles.inputGroup}>
        <ThemedText style={[styles.inputLabel, { color: colors.text }]}>
          Portfolio Website
        </ThemedText>
        <TextInput
          style={[styles.textInput, { 
            backgroundColor: colorScheme === 'dark' ? '#2a2a2a' : '#f5f5f5',
            color: colors.text,
            borderColor: colors.tint,
          }]}
          value={editingData.socialLinks.portfolio}
          onChangeText={(text) => updateSocialLink('portfolio', text)}
          placeholder="your-portfolio.com"
          placeholderTextColor={colors.text + '80'}
        />
      </View>
    </View>
  );

  const renderStats = () => (
    <View style={styles.section}>
      <ThemedText style={[styles.sectionTitle, { color: colors.text }]}>
        Profile Statistics
      </ThemedText>
      
      <View style={styles.inputGroup}>
        <ThemedText style={[styles.inputLabel, { color: colors.text }]}>
          Number of Projects
        </ThemedText>
        <TextInput
          style={[styles.textInput, { 
            backgroundColor: colorScheme === 'dark' ? '#2a2a2a' : '#f5f5f5',
            color: colors.text,
            borderColor: colors.tint,
          }]}
          value={editingData.stats.projects.toString()}
          onChangeText={(text) => updateStat('projects', parseInt(text) || 0)}
          placeholder="15"
          placeholderTextColor={colors.text + '80'}
          keyboardType="numeric"
        />
      </View>

      <View style={styles.inputGroup}>
        <ThemedText style={[styles.inputLabel, { color: colors.text }]}>
          Years of Experience
        </ThemedText>
        <TextInput
          style={[styles.textInput, { 
            backgroundColor: colorScheme === 'dark' ? '#2a2a2a' : '#f5f5f5',
            color: colors.text,
            borderColor: colors.tint,
          }]}
          value={editingData.stats.experience.toString()}
          onChangeText={(text) => updateStat('experience', parseInt(text) || 0)}
          placeholder="5"
          placeholderTextColor={colors.text + '80'}
          keyboardType="numeric"
        />
      </View>

      <View style={styles.inputGroup}>
        <ThemedText style={[styles.inputLabel, { color: colors.text }]}>
          Number of Skills
        </ThemedText>
        <TextInput
          style={[styles.textInput, { 
            backgroundColor: colorScheme === 'dark' ? '#2a2a2a' : '#f5f5f5',
            color: colors.text,
            borderColor: colors.tint,
          }]}
          value={editingData.stats.skills.toString()}
          onChangeText={(text) => updateStat('skills', parseInt(text) || 0)}
          placeholder="20"
          placeholderTextColor={colors.text + '80'}
          keyboardType="numeric"
        />
      </View>

      <View style={styles.inputGroup}>
        <ThemedText style={[styles.inputLabel, { color: colors.text }]}>
          Satisfaction Rate (%)
        </ThemedText>
        <TextInput
          style={[styles.textInput, { 
            backgroundColor: colorScheme === 'dark' ? '#2a2a2a' : '#f5f5f5',
            color: colors.text,
            borderColor: colors.tint,
          }]}
          value={editingData.stats.satisfaction.toString()}
          onChangeText={(text) => updateStat('satisfaction', parseInt(text) || 0)}
          placeholder="100"
          placeholderTextColor={colors.text + '80'}
          keyboardType="numeric"
        />
      </View>
    </View>
  );

  const renderContent = () => (
    <View style={styles.section}>
      <ThemedText style={[styles.sectionTitle, { color: colors.text }]}>
        Content Lists
      </ThemedText>
      
      <View style={styles.inputGroup}>
        <ThemedText style={[styles.inputLabel, { color: colors.text }]}>
          Skills (comma separated)
        </ThemedText>
        <TextInput
          style={[styles.textArea, { 
            backgroundColor: colorScheme === 'dark' ? '#2a2a2a' : '#f5f5f5',
            color: colors.text,
            borderColor: colors.tint,
          }]}
          value={editingData.skills.join(', ')}
          onChangeText={(text) => updateField('skills', text.split(',').map(s => s.trim()).filter(s => s))}
          placeholder="React, TypeScript, Node.js, Python"
          placeholderTextColor={colors.text + '80'}
          multiline
          numberOfLines={3}
          textAlignVertical="top"
        />
      </View>

      <View style={styles.inputGroup}>
        <ThemedText style={[styles.inputLabel, { color: colors.text }]}>
          Experience Titles (comma separated)
        </ThemedText>
        <TextInput
          style={[styles.textArea, { 
            backgroundColor: colorScheme === 'dark' ? '#2a2a2a' : '#f5f5f5',
            color: colors.text,
            borderColor: colors.tint,
          }]}
          value={editingData.experience.join(', ')}
          onChangeText={(text) => updateField('experience', text.split(',').map(s => s.trim()).filter(s => s))}
          placeholder="Senior Developer, Frontend Developer, Mobile Developer"
          placeholderTextColor={colors.text + '80'}
          multiline
          numberOfLines={3}
          textAlignVertical="top"
        />
      </View>

      <View style={styles.inputGroup}>
        <ThemedText style={[styles.inputLabel, { color: colors.text }]}>
          Education (comma separated)
        </ThemedText>
        <TextInput
          style={[styles.textArea, { 
            backgroundColor: colorScheme === 'dark' ? '#2a2a2a' : '#f5f5f5',
            color: colors.text,
            borderColor: colors.tint,
          }]}
          value={editingData.education.join(', ')}
          onChangeText={(text) => updateField('education', text.split(',').map(s => s.trim()).filter(s => s))}
          placeholder="Bachelor in Computer Science, Master in Software Engineering"
          placeholderTextColor={colors.text + '80'}
          multiline
          numberOfLines={3}
          textAlignVertical="top"
        />
      </View>

      <View style={styles.inputGroup}>
        <ThemedText style={[styles.inputLabel, { color: colors.text }]}>
          Projects (comma separated)
        </ThemedText>
        <TextInput
          style={[styles.textArea, { 
            backgroundColor: colorScheme === 'dark' ? '#2a2a2a' : '#f5f5f5',
            color: colors.text,
            borderColor: colors.tint,
          }]}
          value={editingData.projects.join(', ')}
          onChangeText={(text) => updateField('projects', text.split(',').map(s => s.trim()).filter(s => s))}
          placeholder="Portfolio App, E-commerce Platform, AI Chat Assistant"
          placeholderTextColor={colors.text + '80'}
          multiline
          numberOfLines={3}
          textAlignVertical="top"
        />
      </View>
    </View>
  );

  return (
    <View style={[styles.container, { backgroundColor: colors.background }]}>
      {/* Section Tabs */}
      <View style={styles.tabContainer}>
        <TouchableOpacity
          style={[styles.tab, activeSection === 'basic' && { backgroundColor: colors.tint }]}
          onPress={() => setActiveSection('basic')}
        >
          <ThemedText style={[styles.tabText, { color: activeSection === 'basic' ? colors.background : colors.text }]}>
            Basic
          </ThemedText>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.tab, activeSection === 'social' && { backgroundColor: colors.tint }]}
          onPress={() => setActiveSection('social')}
        >
          <ThemedText style={[styles.tabText, { color: activeSection === 'social' ? colors.background : colors.text }]}>
            Social
          </ThemedText>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.tab, activeSection === 'stats' && { backgroundColor: colors.tint }]}
          onPress={() => setActiveSection('stats')}
        >
          <ThemedText style={[styles.tabText, { color: activeSection === 'stats' ? colors.background : colors.text }]}>
            Stats
          </ThemedText>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.tab, activeSection === 'content' && { backgroundColor: colors.tint }]}
          onPress={() => setActiveSection('content')}
        >
          <ThemedText style={[styles.tabText, { color: activeSection === 'content' ? colors.background : colors.text }]}>
            Content
          </ThemedText>
        </TouchableOpacity>
      </View>

      {/* Content */}
      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        {activeSection === 'basic' && renderBasicInfo()}
        {activeSection === 'social' && renderSocialLinks()}
        {activeSection === 'stats' && renderStats()}
        {activeSection === 'content' && renderContent()}
      </ScrollView>

      {/* Action Buttons */}
      <View style={styles.actionButtons}>
        <TouchableOpacity
          style={[styles.actionButton, { borderColor: colors.tint, borderWidth: 1 }]}
          onPress={onCancel}
        >
          <ThemedText style={[styles.actionButtonText, { color: colors.tint }]}>
            Cancel
          </ThemedText>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.actionButton, { backgroundColor: colors.tint }]}
          onPress={handleSave}
        >
          <ThemedText style={[styles.actionButtonText, { color: colors.background }]}>
            Save Changes
          </ThemedText>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  tabContainer: {
    flexDirection: 'row',
    paddingHorizontal: 20,
    paddingVertical: 15,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(0,0,0,0.1)',
  },
  tab: {
    flex: 1,
    paddingVertical: 10,
    paddingHorizontal: 15,
    borderRadius: 8,
    marginHorizontal: 5,
    alignItems: 'center',
  },
  tabText: {
    fontSize: 14,
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
    marginBottom: 20,
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
    height: 100,
    borderWidth: 1,
    borderRadius: 8,
    paddingHorizontal: 15,
    paddingTop: 15,
    fontSize: 16,
  },
  actionButtons: {
    flexDirection: 'row',
    padding: 20,
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
}); 