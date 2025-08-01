import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity, Dimensions } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { ThemedText } from '@/components/ThemedText';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/useColorScheme';
import { IconSymbol } from '@/components/ui/IconSymbol';

const { width } = Dimensions.get('window');

interface Project {
  id: string;
  title: string;
  description: string;
  image: string;
  technologies: string[];
  category: string;
  liveDemo?: string;
  github?: string;
}

const projects: Project[] = [
  {
    id: '1',
    title: 'Portfolio App',
    description: 'A professional React Native portfolio application with modern UI/UX and comprehensive navigation features.',
    image: '📱',
    technologies: ['React Native', 'TypeScript', 'Expo', 'Navigation'],
    category: 'Mobile',
    liveDemo: 'https://example.com',
    github: 'https://github.com/example/portfolio-app',
  },
  {
    id: '2',
    title: 'E-commerce Platform',
    description: 'Full-stack e-commerce solution with payment integration and admin dashboard.',
    image: '🛒',
    technologies: ['React', 'Node.js', 'MongoDB', 'Stripe'],
    category: 'Web',
    liveDemo: 'https://example.com',
    github: 'https://github.com/example/ecommerce',
  },
  {
    id: '3',
    title: 'AI Chat Assistant',
    description: 'Intelligent chatbot powered by machine learning with natural language processing.',
    image: '🤖',
    technologies: ['Python', 'TensorFlow', 'React', 'FastAPI'],
    category: 'AI/ML',
    liveDemo: 'https://example.com',
    github: 'https://github.com/example/ai-chat',
  },
  {
    id: '4',
    title: 'Task Management App',
    description: 'Collaborative task management tool with real-time updates and team features.',
    image: '📋',
    technologies: ['Vue.js', 'Firebase', 'Vuex', 'Vuetify'],
    category: 'Web',
    liveDemo: 'https://example.com',
    github: 'https://github.com/example/task-manager',
  },
  {
    id: '5',
    title: 'Weather Dashboard',
    description: 'Real-time weather application with location-based forecasts and beautiful UI.',
    image: '🌤️',
    technologies: ['React', 'OpenWeather API', 'Chart.js', 'CSS3'],
    category: 'Web',
    liveDemo: 'https://example.com',
    github: 'https://github.com/example/weather-app',
  },
  {
    id: '6',
    title: 'Fitness Tracker',
    description: 'Mobile fitness tracking app with workout plans and progress analytics.',
    image: '💪',
    technologies: ['Flutter', 'Dart', 'Firebase', 'Google Fit API'],
    category: 'Mobile',
    liveDemo: 'https://example.com',
    github: 'https://github.com/example/fitness-tracker',
  },
];

const categories = ['All', 'Web', 'Mobile', 'AI/ML'];

export default function PortfolioScreen() {
  const colorScheme = useColorScheme();
  const [selectedCategory, setSelectedCategory] = useState('All');
  const colors = Colors[colorScheme ?? 'light'];

  const filteredProjects = selectedCategory === 'All' 
    ? projects 
    : projects.filter(project => project.category === selectedCategory);

  const renderTechnologyTag = (tech: string) => (
    <View key={tech} style={[styles.techTag, { backgroundColor: colors.tint }]}>
      <ThemedText style={[styles.techText, { color: colors.background }]}>
        {tech}
      </ThemedText>
    </View>
  );

  const renderProjectCard = (project: Project) => (
    <View key={project.id} style={[styles.projectCard, { backgroundColor: colors.background }]}>
      <View style={styles.projectHeader}>
        <ThemedText style={styles.projectIcon}>{project.image}</ThemedText>
        <View style={styles.projectInfo}>
          <ThemedText style={[styles.projectTitle, { color: colors.text }]}>
            {project.title}
          </ThemedText>
          <View style={[styles.categoryBadge, { backgroundColor: colors.tint }]}>
            <ThemedText style={[styles.categoryText, { color: colors.background }]}>
              {project.category}
            </ThemedText>
          </View>
        </View>
      </View>
      
      <ThemedText style={[styles.projectDescription, { color: colors.text }]}>
        {project.description}
      </ThemedText>
      
      <View style={styles.technologiesContainer}>
        {project.technologies.map(renderTechnologyTag)}
      </View>
      
      <View style={styles.projectActions}>
        {project.liveDemo && (
          <TouchableOpacity style={[styles.actionButton, { backgroundColor: colors.tint }]}>
            <ThemedText style={[styles.actionButtonText, { color: colors.background }]}>
              Live Demo
            </ThemedText>
          </TouchableOpacity>
        )}
        {project.github && (
          <TouchableOpacity style={[styles.actionButton, { borderColor: colors.tint, borderWidth: 1 }]}>
            <ThemedText style={[styles.actionButtonText, { color: colors.tint }]}>
              GitHub
            </ThemedText>
          </TouchableOpacity>
        )}
      </View>
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
            My Portfolio
          </ThemedText>
          <ThemedText style={[styles.headerSubtitle, { color: colors.text }]}>
            Showcasing my best work
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

      {/* Projects Grid */}
      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        <View style={styles.projectsGrid}>
          {filteredProjects.map(renderProjectCard)}
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
  projectsGrid: {
    gap: 20,
  },
  projectCard: {
    borderRadius: 16,
    padding: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 4,
  },
  projectHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 15,
  },
  projectIcon: {
    fontSize: 40,
    marginRight: 15,
  },
  projectInfo: {
    flex: 1,
  },
  projectTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 5,
  },
  categoryBadge: {
    alignSelf: 'flex-start',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
  },
  categoryText: {
    fontSize: 12,
    fontWeight: '500',
  },
  projectDescription: {
    fontSize: 14,
    lineHeight: 20,
    marginBottom: 15,
    opacity: 0.8,
  },
  technologiesContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginBottom: 20,
  },
  techTag: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 16,
  },
  techText: {
    fontSize: 12,
    fontWeight: '500',
  },
  projectActions: {
    flexDirection: 'row',
    gap: 10,
  },
  actionButton: {
    flex: 1,
    paddingVertical: 10,
    borderRadius: 8,
    alignItems: 'center',
  },
  actionButtonText: {
    fontSize: 14,
    fontWeight: '600',
  },
}); 