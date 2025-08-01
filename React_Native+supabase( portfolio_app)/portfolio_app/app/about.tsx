import React from 'react';
import { View, StyleSheet, ScrollView } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { ThemedText } from '@/components/ThemedText';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/useColorScheme';

interface Education {
  id: string;
  degree: string;
  institution: string;
  year: string;
  description: string;
}

interface Certification {
  id: string;
  name: string;
  issuer: string;
  year: string;
  icon: string;
}

const education: Education[] = [
  {
    id: '1',
    degree: 'Bachelor of Science in Computer Science',
    institution: 'Stanford University',
    year: '2018',
    description: 'Specialized in software engineering and web development. Graduated with honors.',
  },
  {
    id: '2',
    degree: 'Master of Science in Software Engineering',
    institution: 'MIT',
    year: '2020',
    description: 'Focused on advanced software architecture and cloud computing technologies.',
  },
];

const certifications: Certification[] = [
  {
    id: '1',
    name: 'AWS Certified Solutions Architect',
    issuer: 'Amazon Web Services',
    year: '2023',
    icon: '☁️',
  },
  {
    id: '2',
    name: 'Google Cloud Professional Developer',
    issuer: 'Google',
    year: '2022',
    icon: '🌐',
  },
  {
    id: '3',
    name: 'Microsoft Certified: Azure Developer',
    issuer: 'Microsoft',
    year: '2021',
    icon: '🔷',
  },
  {
    id: '4',
    name: 'React Native Certified Developer',
    issuer: 'Meta',
    year: '2022',
    icon: '⚛️',
  },
];

export default function AboutScreen() {
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
          <ThemedText style={[styles.headerTitle, { color: colors.text }]}>
            About Me
          </ThemedText>
          <ThemedText style={[styles.headerSubtitle, { color: colors.text }]}>
            Get to know me better
          </ThemedText>
        </View>
      </LinearGradient>

      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        {/* Professional Bio */}
        <View style={styles.section}>
          <ThemedText style={[styles.sectionTitle, { color: colors.text }]}>
            Professional Bio
          </ThemedText>
          <View style={[styles.sectionCard, { backgroundColor: colors.background }]}>
            <ThemedText style={[styles.bioText, { color: colors.text }]}>
              I'm a passionate full-stack developer with over 5 years of experience in building scalable web and mobile applications. My journey in technology began when I wrote my first "Hello World" program, and since then, I've been constantly learning and evolving with the ever-changing tech landscape.
            </ThemedText>
            <ThemedText style={[styles.bioText, { color: colors.text }]}>
              I specialize in modern web technologies including React, React Native, Node.js, and cloud platforms. I believe in writing clean, maintainable code and creating user experiences that are both beautiful and functional.
            </ThemedText>
            <ThemedText style={[styles.bioText, { color: colors.text }]}>
              When I'm not coding, you can find me contributing to open-source projects, mentoring junior developers, or exploring new technologies. I'm always excited to take on new challenges and work on innovative projects that make a difference.
            </ThemedText>
          </View>
        </View>

        {/* Personal Story */}
        <View style={styles.section}>
          <ThemedText style={[styles.sectionTitle, { color: colors.text }]}>
            My Story
          </ThemedText>
          <View style={[styles.sectionCard, { backgroundColor: colors.background }]}>
            <ThemedText style={[styles.storyText, { color: colors.text }]}>
              My passion for technology started at a young age when I disassembled my first computer (much to my parents' dismay). This curiosity led me to pursue a degree in Computer Science, where I discovered my love for software development.
            </ThemedText>
            <ThemedText style={[styles.storyText, { color: colors.text }]}>
              After graduating, I joined a startup where I wore many hats - from frontend developer to DevOps engineer. This experience taught me the importance of understanding the full stack and how different technologies work together.
            </ThemedText>
            <ThemedText style={[styles.storyText, { color: colors.text }]}>
              Today, I work as a Senior Full Stack Developer, leading teams and mentoring others. I believe in continuous learning and staying up-to-date with the latest technologies and best practices in the industry.
            </ThemedText>
          </View>
        </View>

        {/* Education */}
        <View style={styles.section}>
          <ThemedText style={[styles.sectionTitle, { color: colors.text }]}>
            Education
          </ThemedText>
          <View style={styles.educationContainer}>
            {education.map((edu) => (
              <View key={edu.id} style={[styles.educationCard, { backgroundColor: colors.background }]}>
                <View style={styles.educationHeader}>
                  <ThemedText style={[styles.degree, { color: colors.text }]}>
                    {edu.degree}
                  </ThemedText>
                  <View style={[styles.yearBadge, { backgroundColor: colors.tint }]}>
                    <ThemedText style={[styles.yearText, { color: colors.background }]}>
                      {edu.year}
                    </ThemedText>
                  </View>
                </View>
                <ThemedText style={[styles.institution, { color: colors.tint }]}>
                  {edu.institution}
                </ThemedText>
                <ThemedText style={[styles.educationDescription, { color: colors.text }]}>
                  {edu.description}
                </ThemedText>
              </View>
            ))}
          </View>
        </View>

        {/* Certifications */}
        <View style={styles.section}>
          <ThemedText style={[styles.sectionTitle, { color: colors.text }]}>
            Certifications
          </ThemedText>
          <View style={styles.certificationsContainer}>
            {certifications.map((cert) => (
              <View key={cert.id} style={[styles.certificationCard, { backgroundColor: colors.background }]}>
                <View style={styles.certificationHeader}>
                  <ThemedText style={styles.certificationIcon}>{cert.icon}</ThemedText>
                  <View style={styles.certificationInfo}>
                    <ThemedText style={[styles.certificationName, { color: colors.text }]}>
                      {cert.name}
                    </ThemedText>
                    <ThemedText style={[styles.certificationIssuer, { color: colors.tint }]}>
                      {cert.issuer}
                    </ThemedText>
                  </View>
                  <View style={[styles.certificationYear, { backgroundColor: colors.tint }]}>
                    <ThemedText style={[styles.certificationYearText, { color: colors.background }]}>
                      {cert.year}
                    </ThemedText>
                  </View>
                </View>
              </View>
            ))}
          </View>
        </View>

        {/* Personal Interests */}
        <View style={styles.section}>
          <ThemedText style={[styles.sectionTitle, { color: colors.text }]}>
            Personal Interests
          </ThemedText>
          <View style={[styles.sectionCard, { backgroundColor: colors.background }]}>
            <View style={styles.interestsContainer}>
              <View style={styles.interestItem}>
                <ThemedText style={styles.interestIcon}>📚</ThemedText>
                <ThemedText style={[styles.interestText, { color: colors.text }]}>
                  Reading tech blogs and books
                </ThemedText>
              </View>
              <View style={styles.interestItem}>
                <ThemedText style={styles.interestIcon}>🏃‍♂️</ThemedText>
                <ThemedText style={[styles.interestText, { color: colors.text }]}>
                  Running and fitness
                </ThemedText>
              </View>
              <View style={styles.interestItem}>
                <ThemedText style={styles.interestIcon}>🎵</ThemedText>
                <ThemedText style={[styles.interestText, { color: colors.text }]}>
                  Playing guitar
                </ThemedText>
              </View>
              <View style={styles.interestItem}>
                <ThemedText style={styles.interestIcon}>✈️</ThemedText>
                <ThemedText style={[styles.interestText, { color: colors.text }]}>
                  Traveling and photography
                </ThemedText>
              </View>
              <View style={styles.interestItem}>
                <ThemedText style={styles.interestIcon}>🎮</ThemedText>
                <ThemedText style={[styles.interestText, { color: colors.text }]}>
                  Gaming and VR
                </ThemedText>
              </View>
              <View style={styles.interestItem}>
                <ThemedText style={styles.interestIcon}>☕</ThemedText>
                <ThemedText style={[styles.interestText, { color: colors.text }]}>
                  Coffee and good conversations
                </ThemedText>
              </View>
            </View>
          </View>
        </View>

        {/* Values */}
        <View style={styles.section}>
          <ThemedText style={[styles.sectionTitle, { color: colors.text }]}>
            My Values
          </ThemedText>
          <View style={styles.valuesContainer}>
            <View style={[styles.valueCard, { backgroundColor: colors.background }]}>
              <ThemedText style={styles.valueIcon}>💡</ThemedText>
              <ThemedText style={[styles.valueTitle, { color: colors.text }]}>
                Innovation
              </ThemedText>
              <ThemedText style={[styles.valueDescription, { color: colors.text }]}>
                Always exploring new technologies and creative solutions
              </ThemedText>
            </View>
            <View style={[styles.valueCard, { backgroundColor: colors.background }]}>
              <ThemedText style={styles.valueIcon}>🤝</ThemedText>
              <ThemedText style={[styles.valueTitle, { color: colors.text }]}>
                Collaboration
              </ThemedText>
              <ThemedText style={[styles.valueDescription, { color: colors.text }]}>
                Working together to achieve better results
              </ThemedText>
            </View>
            <View style={[styles.valueCard, { backgroundColor: colors.background }]}>
              <ThemedText style={styles.valueIcon}>📈</ThemedText>
              <ThemedText style={[styles.valueTitle, { color: colors.text }]}>
                Growth
              </ThemedText>
              <ThemedText style={[styles.valueDescription, { color: colors.text }]}>
                Continuous learning and personal development
              </ThemedText>
            </View>
            <View style={[styles.valueCard, { backgroundColor: colors.background }]}>
              <ThemedText style={styles.valueIcon}>🎯</ThemedText>
              <ThemedText style={[styles.valueTitle, { color: colors.text }]}>
                Quality
              </ThemedText>
              <ThemedText style={[styles.valueDescription, { color: colors.text }]}>
                Delivering excellence in everything I do
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
  sectionCard: {
    borderRadius: 16,
    padding: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 4,
  },
  bioText: {
    fontSize: 16,
    lineHeight: 24,
    marginBottom: 15,
    opacity: 0.8,
  },
  storyText: {
    fontSize: 16,
    lineHeight: 24,
    marginBottom: 15,
    opacity: 0.8,
  },
  educationContainer: {
    gap: 15,
  },
  educationCard: {
    borderRadius: 12,
    padding: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  educationHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
  },
  degree: {
    fontSize: 18,
    fontWeight: 'bold',
    flex: 1,
  },
  yearBadge: {
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 12,
  },
  yearText: {
    fontSize: 12,
    fontWeight: '600',
  },
  institution: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 10,
  },
  educationDescription: {
    fontSize: 14,
    lineHeight: 20,
    opacity: 0.8,
  },
  certificationsContainer: {
    gap: 15,
  },
  certificationCard: {
    borderRadius: 12,
    padding: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  certificationHeader: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  certificationIcon: {
    fontSize: 24,
    marginRight: 15,
  },
  certificationInfo: {
    flex: 1,
  },
  certificationName: {
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 2,
  },
  certificationIssuer: {
    fontSize: 14,
    fontWeight: '500',
  },
  certificationYear: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 8,
  },
  certificationYearText: {
    fontSize: 12,
    fontWeight: '600',
  },
  interestsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 15,
  },
  interestItem: {
    flexDirection: 'row',
    alignItems: 'center',
    width: '47%',
  },
  interestIcon: {
    fontSize: 20,
    marginRight: 10,
  },
  interestText: {
    fontSize: 14,
    flex: 1,
  },
  valuesContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 15,
  },
  valueCard: {
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
  valueIcon: {
    fontSize: 30,
    marginBottom: 10,
  },
  valueTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 8,
    textAlign: 'center',
  },
  valueDescription: {
    fontSize: 12,
    textAlign: 'center',
    opacity: 0.8,
    lineHeight: 16,
  },
}); 