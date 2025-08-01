import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity, Animated } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { ThemedText } from '@/components/ThemedText';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/useColorScheme';

interface Skill {
  id: string;
  name: string;
  level: number;
  icon: string;
  category: string;
  description: string;
}

const skills: Skill[] = [
  // Frontend Skills
  { id: '1', name: 'React', level: 90, icon: '⚛️', category: 'Frontend', description: 'Advanced React development with hooks and context' },
  { id: '2', name: 'React Native', level: 85, icon: '📱', category: 'Frontend', description: 'Cross-platform mobile development' },
  { id: '3', name: 'TypeScript', level: 80, icon: '📘', category: 'Frontend', description: 'Type-safe JavaScript development' },
  { id: '4', name: 'Vue.js', level: 75, icon: '💚', category: 'Frontend', description: 'Progressive JavaScript framework' },
  { id: '5', name: 'CSS/SCSS', level: 85, icon: '🎨', category: 'Frontend', description: 'Advanced styling and animations' },
  { id: '6', name: 'HTML5', level: 95, icon: '🌐', category: 'Frontend', description: 'Semantic markup and accessibility' },

  // Backend Skills
  { id: '7', name: 'Node.js', level: 85, icon: '🟢', category: 'Backend', description: 'Server-side JavaScript development' },
  { id: '8', name: 'Python', level: 80, icon: '🐍', category: 'Backend', description: 'Backend development and automation' },
  { id: '9', name: 'Express.js', level: 80, icon: '🚂', category: 'Backend', description: 'Web application framework' },
  { id: '10', name: 'MongoDB', level: 75, icon: '🍃', category: 'Backend', description: 'NoSQL database management' },
  { id: '11', name: 'PostgreSQL', level: 70, icon: '🐘', category: 'Backend', description: 'Relational database management' },
  { id: '12', name: 'Firebase', level: 75, icon: '🔥', category: 'Backend', description: 'Backend-as-a-Service platform' },

  // Mobile Skills
  { id: '13', name: 'Flutter', level: 70, icon: '🦋', category: 'Mobile', description: 'Cross-platform mobile development' },
  { id: '14', name: 'Expo', level: 85, icon: '📦', category: 'Mobile', description: 'React Native development platform' },
  { id: '15', name: 'iOS Development', level: 65, icon: '🍎', category: 'Mobile', description: 'Native iOS app development' },
  { id: '16', name: 'Android Development', level: 60, icon: '🤖', category: 'Mobile', description: 'Native Android app development' },

  // Tools & Others
  { id: '17', name: 'Git', level: 90, icon: '📚', category: 'Tools', description: 'Version control and collaboration' },
  { id: '18', name: 'Docker', level: 70, icon: '🐳', category: 'Tools', description: 'Containerization and deployment' },
  { id: '19', name: 'AWS', level: 65, icon: '☁️', category: 'Tools', description: 'Cloud infrastructure and services' },
  { id: '20', name: 'CI/CD', level: 75, icon: '🔄', category: 'Tools', description: 'Continuous integration and deployment' },
];

const categories = ['All', 'Frontend', 'Backend', 'Mobile', 'Tools'];

export default function SkillsScreen() {
  const colorScheme = useColorScheme();
  const [selectedCategory, setSelectedCategory] = useState('All');
  const [selectedSkill, setSelectedSkill] = useState<Skill | null>(null);
  const colors = Colors[colorScheme ?? 'light'];

  const filteredSkills = selectedCategory === 'All' 
    ? skills 
    : skills.filter(skill => skill.category === selectedCategory);

  const getLevelColor = (level: number) => {
    if (level >= 90) return '#4CAF50';
    if (level >= 80) return '#8BC34A';
    if (level >= 70) return '#FFC107';
    if (level >= 60) return '#FF9800';
    return '#F44336';
  };

  const renderSkillCard = (skill: Skill) => (
    <TouchableOpacity
      key={skill.id}
      style={[styles.skillCard, { backgroundColor: colors.background }]}
      onPress={() => setSelectedSkill(skill)}
    >
      <View style={styles.skillHeader}>
        <ThemedText style={styles.skillIcon}>{skill.icon}</ThemedText>
        <View style={styles.skillInfo}>
          <ThemedText style={[styles.skillName, { color: colors.text }]}>
            {skill.name}
          </ThemedText>
          <ThemedText style={[styles.skillLevel, { color: getLevelColor(skill.level) }]}>
            {skill.level}%
          </ThemedText>
        </View>
      </View>
      
      <View style={styles.progressContainer}>
        <View style={[styles.progressBar, { backgroundColor: colors.background }]}>
          <View
            style={[
              styles.progressFill,
              {
                width: `${skill.level}%`,
                backgroundColor: getLevelColor(skill.level),
              },
            ]}
          />
        </View>
      </View>
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
            My Skills
          </ThemedText>
          <ThemedText style={[styles.headerSubtitle, { color: colors.text }]}>
            Technical expertise and proficiency
          </ThemedText>
        </View>
      </LinearGradient>

      {/* Category Filter */}
      <View style={styles.filterContainer}>
        <ScrollView horizontal showsHorizontalScrollIndicator={false}>
          {categories.map((category) => (
            <TouchableOpacity
              key={category}
              style={[
                styles.filterButton,
                selectedCategory === category && { backgroundColor: colors.tint }
              ]}
              onPress={() => setSelectedCategory(category)}
            >
              <ThemedText 
                style={[
                  styles.filterText, 
                  { 
                    color: selectedCategory === category ? colors.background : colors.text 
                  }
                ]}
              >
                {category}
              </ThemedText>
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>

      {/* Skills Grid */}
      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        <View style={styles.skillsGrid}>
          {filteredSkills.map(renderSkillCard)}
        </View>
      </ScrollView>

      {/* Skill Detail Modal */}
      {selectedSkill && (
        <View style={styles.modalOverlay}>
          <View style={[styles.modalContent, { backgroundColor: colors.background }]}>
            <View style={styles.modalHeader}>
              <ThemedText style={styles.modalIcon}>{selectedSkill.icon}</ThemedText>
              <ThemedText style={[styles.modalTitle, { color: colors.text }]}>
                {selectedSkill.name}
              </ThemedText>
              <TouchableOpacity
                style={styles.closeButton}
                onPress={() => setSelectedSkill(null)}
              >
                <ThemedText style={styles.closeButtonText}>✕</ThemedText>
              </TouchableOpacity>
            </View>
            
            <View style={styles.modalBody}>
              <ThemedText style={[styles.modalDescription, { color: colors.text }]}>
                {selectedSkill.description}
              </ThemedText>
              
              <View style={styles.modalProgress}>
                <View style={styles.modalProgressHeader}>
                  <ThemedText style={[styles.modalProgressLabel, { color: colors.text }]}>
                    Proficiency Level
                  </ThemedText>
                  <ThemedText style={[styles.modalProgressValue, { color: getLevelColor(selectedSkill.level) }]}>
                    {selectedSkill.level}%
                  </ThemedText>
                </View>
                <View style={[styles.modalProgressBar, { backgroundColor: colors.background }]}>
                  <View
                    style={[
                      styles.modalProgressFill,
                      {
                        width: `${selectedSkill.level}%`,
                        backgroundColor: getLevelColor(selectedSkill.level),
                      },
                    ]}
                  />
                </View>
              </View>
              
              <View style={[styles.modalCategory, { backgroundColor: colors.tint }]}>
                <ThemedText style={[styles.modalCategoryText, { color: colors.background }]}>
                  {selectedSkill.category}
                </ThemedText>
              </View>
            </View>
          </View>
        </View>
      )}
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
  filterContainer: {
    paddingHorizontal: 20,
    paddingVertical: 15,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(0,0,0,0.1)',
  },
  filterButton: {
    paddingHorizontal: 20,
    paddingVertical: 8,
    borderRadius: 20,
    marginRight: 10,
    borderWidth: 1,
    borderColor: 'rgba(0,0,0,0.1)',
  },
  filterText: {
    fontSize: 14,
    fontWeight: '500',
  },
  content: {
    flex: 1,
    padding: 20,
  },
  skillsGrid: {
    gap: 15,
  },
  skillCard: {
    borderRadius: 12,
    padding: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  skillHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 10,
  },
  skillIcon: {
    fontSize: 30,
    marginRight: 15,
  },
  skillInfo: {
    flex: 1,
  },
  skillName: {
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 2,
  },
  skillLevel: {
    fontSize: 14,
    fontWeight: '600',
  },
  progressContainer: {
    marginTop: 5,
  },
  progressBar: {
    height: 6,
    borderRadius: 3,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    borderRadius: 3,
  },
  modalOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'center',
    alignItems: 'center',
    zIndex: 1000,
  },
  modalContent: {
    width: '85%',
    borderRadius: 16,
    padding: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  modalHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 20,
  },
  modalIcon: {
    fontSize: 40,
    marginRight: 15,
  },
  modalTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    flex: 1,
  },
  closeButton: {
    padding: 8,
  },
  closeButtonText: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#666',
  },
  modalBody: {
    gap: 20,
  },
  modalDescription: {
    fontSize: 16,
    lineHeight: 24,
    opacity: 0.8,
  },
  modalProgress: {
    gap: 10,
  },
  modalProgressHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  modalProgressLabel: {
    fontSize: 14,
    fontWeight: '600',
  },
  modalProgressValue: {
    fontSize: 16,
    fontWeight: 'bold',
  },
  modalProgressBar: {
    height: 8,
    borderRadius: 4,
    overflow: 'hidden',
  },
  modalProgressFill: {
    height: '100%',
    borderRadius: 4,
  },
  modalCategory: {
    alignSelf: 'flex-start',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 16,
  },
  modalCategoryText: {
    fontSize: 12,
    fontWeight: '600',
  },
}); 