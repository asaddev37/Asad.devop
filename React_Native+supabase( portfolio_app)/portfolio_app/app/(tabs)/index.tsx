import React, { useState, useRef } from 'react';
import { View, StyleSheet, Animated, TouchableOpacity, ScrollView, Dimensions } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { router } from 'expo-router';
import { ThemedText } from '@/components/ThemedText';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/useColorScheme';
import { IconSymbol } from '@/components/ui/IconSymbol';
import { useProfile } from '@/contexts/ProfileContext';
import ProfilePicture from '@/components/ProfilePicture';

const { width } = Dimensions.get('window');

export default function HomeScreen() {
  const colorScheme = useColorScheme();
  const colors = Colors[colorScheme ?? 'light'];
  const { profileData } = useProfile();
  
  const [drawerOpen, setDrawerOpen] = useState(false);
  const drawerAnim = useRef(new Animated.Value(-width * 0.8)).current;
  const backdropAnim = useRef(new Animated.Value(0)).current;

  const toggleDrawer = () => {
    const toValue = drawerOpen ? -width * 0.8 : 0;
    const backdropValue = drawerOpen ? 0 : 1;

    Animated.parallel([
      Animated.timing(drawerAnim, {
        toValue,
        duration: 300,
        useNativeDriver: true,
      }),
      Animated.timing(backdropAnim, {
        toValue: backdropValue,
        duration: 300,
        useNativeDriver: true,
      }),
    ]).start();

    setDrawerOpen(!drawerOpen);
  };

  const closeDrawer = () => {
    if (drawerOpen) {
      toggleDrawer();
    }
  };

  const navigateTo = (screen: string) => {
    closeDrawer();
    router.push(screen);
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
          <TouchableOpacity onPress={toggleDrawer} style={styles.menuButton}>
            <IconSymbol size={24} name="line.3.horizontal" color={colors.text} />
          </TouchableOpacity>
          
          <View style={styles.profileSection}>
            <ProfilePicture size={50} />
            <View style={styles.welcomeText}>
              <ThemedText style={[styles.welcomeTitle, { color: colors.text }]}>
                Welcome, {profileData.name}!
              </ThemedText>
              <ThemedText style={[styles.welcomeSubtitle, { color: colors.text }]}>
                Ready to showcase your portfolio? 🚀
              </ThemedText>
            </View>
          </View>
        </View>
      </LinearGradient>

      {/* Main Content */}
      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        {/* Quick Stats */}
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

        {/* Quick Actions */}
        <View style={styles.section}>
          <ThemedText style={[styles.sectionTitle, { color: colors.text }]}>
            Quick Actions
          </ThemedText>
          <View style={styles.actionsGrid}>
            <TouchableOpacity 
              style={[styles.actionCard, { backgroundColor: colors.cardBackground }]}
              onPress={() => router.push('/portfolio')}
            >
              <ThemedText style={styles.actionIcon}>📁</ThemedText>
              <ThemedText style={[styles.actionTitle, { color: colors.text }]}>
                View Portfolio
              </ThemedText>
            </TouchableOpacity>
            
            <TouchableOpacity 
              style={[styles.actionCard, { backgroundColor: colors.cardBackground }]}
              onPress={() => router.push('/skills')}
            >
              <ThemedText style={styles.actionIcon}>⭐</ThemedText>
              <ThemedText style={[styles.actionTitle, { color: colors.text }]}>
                My Skills
              </ThemedText>
            </TouchableOpacity>
            
            <TouchableOpacity 
              style={[styles.actionCard, { backgroundColor: colors.cardBackground }]}
              onPress={() => router.push('/contact')}
            >
              <ThemedText style={styles.actionIcon}>📞</ThemedText>
              <ThemedText style={[styles.actionTitle, { color: colors.text }]}>
                Contact Me
              </ThemedText>
            </TouchableOpacity>
            
            <TouchableOpacity 
              style={[styles.actionCard, { backgroundColor: colors.cardBackground }]}
              onPress={() => router.push('/about')}
            >
              <ThemedText style={styles.actionIcon}>ℹ️</ThemedText>
              <ThemedText style={[styles.actionTitle, { color: colors.text }]}>
                About Me
              </ThemedText>
            </TouchableOpacity>
          </View>
        </View>
      </ScrollView>

      {/* Drawer */}
      <Animated.View
        style={[
          styles.drawer,
          {
            transform: [{ translateX: drawerAnim }],
          },
        ]}
      >
        <LinearGradient
          colors={
            colorScheme === 'dark'
              ? ['#1e40af', '#7c3aed', '#1e2937']
              : ['#667eea', '#764ba2', '#f0f9ff']
          }
          style={styles.drawerContent}
        >
          {/* User Profile in Drawer */}
          <View style={styles.drawerProfile}>
            <ProfilePicture size={80} />
            <ThemedText style={[styles.drawerUserName, { color: colors.text }]}>
              {profileData.name}
            </ThemedText>
            <ThemedText style={[styles.drawerUserTitle, { color: colors.text }]}>
              {profileData.title}
            </ThemedText>
          </View>

          {/* Menu Items */}
          <View style={styles.menuItems}>
            <TouchableOpacity 
              style={styles.menuItem}
              onPress={() => navigateTo('/(tabs)')}
            >
              <ThemedText style={styles.menuIcon}>🏠</ThemedText>
              <ThemedText style={[styles.menuText, { color: colors.text }]}>Home</ThemedText>
            </TouchableOpacity>
            
            <TouchableOpacity 
              style={styles.menuItem}
              onPress={() => navigateTo('/about')}
            >
              <ThemedText style={styles.menuIcon}>ℹ️</ThemedText>
              <ThemedText style={[styles.menuText, { color: colors.text }]}>About</ThemedText>
            </TouchableOpacity>
            
            <TouchableOpacity 
              style={styles.menuItem}
              onPress={() => navigateTo('/privacy-policy')}
            >
              <ThemedText style={styles.menuIcon}>📋</ThemedText>
              <ThemedText style={[styles.menuText, { color: colors.text }]}>Privacy Policy</ThemedText>
            </TouchableOpacity>
            
            <TouchableOpacity 
              style={styles.menuItem}
              onPress={() => navigateTo('/settings')}
            >
              <ThemedText style={styles.menuIcon}>⚙️</ThemedText>
              <ThemedText style={[styles.menuText, { color: colors.text }]}>Settings</ThemedText>
            </TouchableOpacity>
            
            <TouchableOpacity 
              style={styles.menuItem}
              onPress={() => navigateTo('/contact')}
            >
              <ThemedText style={styles.menuIcon}>📞</ThemedText>
              <ThemedText style={[styles.menuText, { color: colors.text }]}>Contact</ThemedText>
            </TouchableOpacity>
          </View>

          {/* Logout */}
          <TouchableOpacity style={styles.logoutButton}>
            <ThemedText style={styles.menuIcon}>🚪</ThemedText>
            <ThemedText style={[styles.menuText, { color: colors.text }]}>Logout</ThemedText>
          </TouchableOpacity>
        </LinearGradient>
      </Animated.View>

      {/* Backdrop */}
      <Animated.View
        style={[
          styles.backdrop,
          {
            opacity: backdropAnim,
          },
        ]}
      >
        <TouchableOpacity style={styles.backdropTouchable} onPress={closeDrawer} />
      </Animated.View>
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
    flexDirection: 'row',
    alignItems: 'center',
  },
  menuButton: {
    marginRight: 15,
    padding: 8,
  },
  profileSection: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
  },
  welcomeText: {
    flex: 1,
    marginLeft: 15,
  },
  welcomeTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 4,
  },
  welcomeSubtitle: {
    fontSize: 14,
    opacity: 0.8,
  },
  content: {
    flex: 1,
    padding: 20,
  },
  statsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 30,
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
  section: {
    marginBottom: 30,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 15,
  },
  actionsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  actionCard: {
    width: (width - 60) / 2,
    padding: 20,
    borderRadius: 12,
    alignItems: 'center',
    marginBottom: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  actionIcon: {
    fontSize: 30,
    marginBottom: 10,
  },
  actionTitle: {
    fontSize: 14,
    fontWeight: '600',
    textAlign: 'center',
  },
  drawer: {
    position: 'absolute',
    top: 0,
    left: 0,
    width: width * 0.8,
    height: '100%',
    zIndex: 1000,
  },
  drawerContent: {
    flex: 1,
    paddingTop: 60,
  },
  drawerProfile: {
    alignItems: 'center',
    paddingVertical: 30,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255,255,255,0.1)',
    marginBottom: 20,
  },
  drawerUserName: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 5,
    marginTop: 15,
  },
  drawerUserTitle: {
    fontSize: 14,
    opacity: 0.8,
  },
  menuItems: {
    flex: 1,
    paddingHorizontal: 20,
  },
  menuItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 15,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255,255,255,0.1)',
  },
  menuIcon: {
    fontSize: 20,
    marginRight: 15,
  },
  menuText: {
    fontSize: 16,
    fontWeight: '500',
  },
  logoutButton: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingVertical: 15,
    borderTopWidth: 1,
    borderTopColor: 'rgba(255,255,255,0.1)',
  },
  backdrop: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0,0,0,0.5)',
    zIndex: 999,
  },
  backdropTouchable: {
    flex: 1,
  },
});
