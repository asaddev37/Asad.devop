import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity, Animated } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { ThemedText } from '@/components/ThemedText';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/useColorScheme';

interface Experience {
  id: string;
  company: string;
  position: string;
  duration: string;
  location: string;
  description: string;
  achievements: string[];
  technologies: string[];
  logo: string;
  startDate: string;
  endDate?: string;
  isCurrent: boolean;
}

const experiences: Experience[] = [
  {
    id: '1',
    company: 'TechCorp Solutions',
    position: 'Senior Full Stack Developer',
    duration: '2022 - Present',
    location: 'San Francisco, CA',
    description: 'Leading development of enterprise web applications and mobile solutions. Collaborating with cross-functional teams to deliver high-quality software products.',
    achievements: [
      'Led a team of 5 developers in building a customer portal that increased user engagement by 40%',
      'Implemented CI/CD pipeline reducing deployment time by 60%',
      'Mentored junior developers and conducted code reviews',
      'Optimized application performance resulting in 30% faster load times'
    ],
    technologies: ['React', 'Node.js', 'TypeScript', 'MongoDB', 'AWS'],
    logo: '🏢',
    startDate: '2022-01',
    isCurrent: true,
  },
  {
    id: '2',
    company: 'InnovateTech',
    position: 'Frontend Developer',
    duration: '2020 - 2022',
    location: 'New York, NY',
    description: 'Developed responsive web applications and user interfaces. Worked closely with designers to implement pixel-perfect designs.',
    achievements: [
      'Built 10+ responsive web applications using React and Vue.js',
      'Improved website accessibility score from 70% to 95%',
      'Reduced bundle size by 25% through code optimization',
      'Implemented automated testing increasing code coverage to 85%'
    ],
    technologies: ['React', 'Vue.js', 'JavaScript', 'CSS3', 'Webpack'],
    logo: '💡',
    startDate: '2020-03',
    endDate: '2022-01',
    isCurrent: false,
  },
  {
    id: '3',
    company: 'StartupHub',
    position: 'Mobile App Developer',
    duration: '2019 - 2020',
    location: 'Austin, TX',
    description: 'Developed cross-platform mobile applications using React Native. Collaborated with product managers to define app features.',
    achievements: [
      'Developed 3 mobile applications with over 10,000 downloads',
      'Implemented push notifications increasing user retention by 35%',
      'Integrated third-party APIs for payment and analytics',
      'Optimized app performance for low-end devices'
    ],
    technologies: ['React Native', 'JavaScript', 'Firebase', 'Redux'],
    logo: '🚀',
    startDate: '2019-06',
    endDate: '2020-03',
    isCurrent: false,
  },
  {
    id: '4',
    company: 'Digital Solutions Inc.',
    position: 'Junior Developer',
    duration: '2018 - 2019',
    location: 'Chicago, IL',
    description: 'Started career as a junior developer working on various web projects. Learned modern development practices and tools.',
    achievements: [
      'Developed 5+ client websites using HTML, CSS, and JavaScript',
      'Learned modern frameworks like React and Node.js',
      'Participated in code reviews and team meetings',
      'Contributed to open-source projects'
    ],
    technologies: ['HTML5', 'CSS3', 'JavaScript', 'jQuery', 'PHP'],
    logo: '💻',
    startDate: '2018-01',
    endDate: '2019-06',
    isCurrent: false,
  },
];

export default function ExperienceScreen() {
  const colorScheme = useColorScheme();
  const [selectedExperience, setSelectedExperience] = useState<Experience | null>(null);
  const colors = Colors[colorScheme ?? 'light'];

  const renderTimelineItem = (experience: Experience, index: number) => (
    <View key={experience.id} style={styles.timelineItem}>
      {/* Timeline Line */}
      <View style={styles.timelineLine}>
        <View style={[styles.timelineDot, { backgroundColor: colors.tint }]} />
        {index < experiences.length - 1 && (
          <View style={[styles.timelineConnector, { backgroundColor: colors.tint }]} />
        )}
      </View>

      {/* Experience Card */}
      <TouchableOpacity
        style={[styles.experienceCard, { backgroundColor: colors.background }]}
        onPress={() => setSelectedExperience(experience)}
      >
        <View style={styles.cardHeader}>
          <View style={styles.companyLogo}>
            <ThemedText style={styles.logoText}>{experience.logo}</ThemedText>
          </View>
          <View style={styles.companyInfo}>
            <ThemedText style={[styles.companyName, { color: colors.text }]}>
              {experience.company}
            </ThemedText>
            <ThemedText style={[styles.position, { color: colors.tint }]}>
              {experience.position}
            </ThemedText>
            <ThemedText style={[styles.duration, { color: colors.text }]}>
              {experience.duration}
            </ThemedText>
          </View>
          {experience.isCurrent && (
            <View style={[styles.currentBadge, { backgroundColor: colors.tint }]}>
              <ThemedText style={[styles.currentText, { color: colors.background }]}>
                Current
              </ThemedText>
            </View>
          )}
        </View>

        <ThemedText style={[styles.location, { color: colors.text }]}>
          📍 {experience.location}
        </ThemedText>

        <ThemedText style={[styles.description, { color: colors.text }]}>
          {experience.description}
        </ThemedText>

        <View style={styles.technologiesContainer}>
          {experience.technologies.slice(0, 3).map((tech, techIndex) => (
            <View key={techIndex} style={[styles.techTag, { backgroundColor: colors.tint }]}>
              <ThemedText style={[styles.techText, { color: colors.background }]}>
                {tech}
              </ThemedText>
            </View>
          ))}
          {experience.technologies.length > 3 && (
            <View style={[styles.techTag, { backgroundColor: colors.tint }]}>
              <ThemedText style={[styles.techText, { color: colors.background }]}>
                +{experience.technologies.length - 3}
              </ThemedText>
            </View>
          )}
        </View>
      </TouchableOpacity>
    </View>
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
            Work Experience
          </ThemedText>
          <ThemedText style={[styles.headerSubtitle, { color: colors.text }]}>
            Professional journey and achievements
          </ThemedText>
        </View>
      </LinearGradient>

      {/* Timeline */}
      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        <View style={styles.timelineContainer}>
          {experiences.map((experience, index) => renderTimelineItem(experience, index))}
        </View>
      </ScrollView>

      {/* Experience Detail Modal */}
      {selectedExperience && (
        <View style={styles.modalOverlay}>
          <View style={[styles.modalContent, { backgroundColor: colors.background }]}>
            <View style={styles.modalHeader}>
              <View style={styles.modalLogo}>
                <ThemedText style={styles.modalLogoText}>{selectedExperience.logo}</ThemedText>
              </View>
              <View style={styles.modalHeaderInfo}>
                <ThemedText style={[styles.modalCompanyName, { color: colors.text }]}>
                  {selectedExperience.company}
                </ThemedText>
                <ThemedText style={[styles.modalPosition, { color: colors.tint }]}>
                  {selectedExperience.position}
                </ThemedText>
                <ThemedText style={[styles.modalDuration, { color: colors.text }]}>
                  {selectedExperience.duration}
                </ThemedText>
              </View>
              <TouchableOpacity
                style={styles.closeButton}
                onPress={() => setSelectedExperience(null)}
              >
                <ThemedText style={styles.closeButtonText}>✕</ThemedText>
              </TouchableOpacity>
            </View>

            <View style={styles.modalBody}>
              <View style={styles.modalLocation}>
                <ThemedText style={[styles.modalLocationText, { color: colors.text }]}>
                  📍 {selectedExperience.location}
                </ThemedText>
              </View>

              <View style={styles.modalSection}>
                <ThemedText style={[styles.modalSectionTitle, { color: colors.text }]}>
                  Description
                </ThemedText>
                <ThemedText style={[styles.modalDescription, { color: colors.text }]}>
                  {selectedExperience.description}
                </ThemedText>
              </View>

              <View style={styles.modalSection}>
                <ThemedText style={[styles.modalSectionTitle, { color: colors.text }]}>
                  Key Achievements
                </ThemedText>
                {selectedExperience.achievements.map((achievement, index) => (
                  <View key={index} style={styles.achievementItem}>
                    <ThemedText style={styles.achievementBullet}>•</ThemedText>
                    <ThemedText style={[styles.achievementText, { color: colors.text }]}>
                      {achievement}
                    </ThemedText>
                  </View>
                ))}
              </View>

              <View style={styles.modalSection}>
                <ThemedText style={[styles.modalSectionTitle, { color: colors.text }]}>
                  Technologies Used
                </ThemedText>
                <View style={styles.modalTechnologies}>
                  {selectedExperience.technologies.map((tech, index) => (
                    <View key={index} style={[styles.modalTechTag, { backgroundColor: colors.tint }]}>
                      <ThemedText style={[styles.modalTechText, { color: colors.background }]}>
                        {tech}
                      </ThemedText>
                    </View>
                  ))}
                </View>
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
  content: {
    flex: 1,
    padding: 20,
  },
  timelineContainer: {
    paddingLeft: 20,
  },
  timelineItem: {
    flexDirection: 'row',
    marginBottom: 30,
  },
  timelineLine: {
    width: 20,
    alignItems: 'center',
    marginRight: 20,
  },
  timelineDot: {
    width: 12,
    height: 12,
    borderRadius: 6,
    marginTop: 10,
  },
  timelineConnector: {
    width: 2,
    height: 80,
    marginTop: 5,
  },
  experienceCard: {
    flex: 1,
    borderRadius: 16,
    padding: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 4,
  },
  cardHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 15,
  },
  companyLogo: {
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: 'rgba(0,0,0,0.1)',
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 15,
  },
  logoText: {
    fontSize: 24,
  },
  companyInfo: {
    flex: 1,
  },
  companyName: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 2,
  },
  position: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 2,
  },
  duration: {
    fontSize: 14,
    opacity: 0.7,
  },
  currentBadge: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
  },
  currentText: {
    fontSize: 12,
    fontWeight: '600',
  },
  location: {
    fontSize: 14,
    marginBottom: 10,
    opacity: 0.8,
  },
  description: {
    fontSize: 14,
    lineHeight: 20,
    marginBottom: 15,
    opacity: 0.8,
  },
  technologiesContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  techTag: {
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 12,
  },
  techText: {
    fontSize: 12,
    fontWeight: '500',
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
    width: '90%',
    maxHeight: '80%',
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
  modalLogo: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: 'rgba(0,0,0,0.1)',
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 15,
  },
  modalLogoText: {
    fontSize: 28,
  },
  modalHeaderInfo: {
    flex: 1,
  },
  modalCompanyName: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 2,
  },
  modalPosition: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 2,
  },
  modalDuration: {
    fontSize: 14,
    opacity: 0.7,
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
  modalLocation: {
    marginBottom: 10,
  },
  modalLocationText: {
    fontSize: 16,
    fontWeight: '500',
  },
  modalSection: {
    gap: 10,
  },
  modalSectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 5,
  },
  modalDescription: {
    fontSize: 16,
    lineHeight: 24,
    opacity: 0.8,
  },
  achievementItem: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    marginBottom: 8,
  },
  achievementBullet: {
    fontSize: 16,
    marginRight: 10,
    marginTop: 2,
    color: '#667eea',
  },
  achievementText: {
    fontSize: 14,
    lineHeight: 20,
    flex: 1,
    opacity: 0.8,
  },
  modalTechnologies: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  modalTechTag: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 16,
  },
  modalTechText: {
    fontSize: 14,
    fontWeight: '500',
  },
}); 