import { View, StyleSheet, Image, TouchableOpacity, TouchableWithoutFeedback, Dimensions } from 'react-native';
import { DrawerContentScrollView } from '@react-navigation/drawer';
import { Ionicons } from '@expo/vector-icons';
import { ThemedText } from '@/components/ThemedText';
import { LinearGradient } from 'expo-linear-gradient';

const { width } = Dimensions.get('window');

interface MenuItem {
  icon: string;
  label: string;
  onPress: () => void;
  isActive?: boolean;
}

export function DrawerContent(props: any) {
  const menuItems: MenuItem[] = [
    {
      icon: 'home-outline',
      label: 'Home',
      onPress: () => props.navigation.navigate('(tabs)'),
      isActive: props.state.index === 0,
    },
    {
      icon: 'settings-outline',
      label: 'Settings',
      onPress: () => props.navigation.navigate('settings'),
      isActive: props.state.index === 1,
    },
    {
      icon: 'information-circle-outline',
      label: 'About',
      onPress: () => props.navigation.navigate('about'),
      isActive: props.state.index === 2,
    },
    {
      icon: 'shield-checkmark-outline',
      label: 'Privacy Policy',
      onPress: () => props.navigation.navigate('privacy'),
      isActive: props.state.index === 3,
    },
  ];

  const renderMenuItem = (item: MenuItem, index: number) => (
    <TouchableWithoutFeedback key={index} onPress={item.onPress}>
      <View style={[styles.menuItem, item.isActive && styles.activeMenuItem]}>
        <View style={styles.menuIconContainer}>
          <Ionicons 
            name={item.icon as any} 
            size={24} 
            color={item.isActive ? '#4F46E5' : '#666'} 
          />
        </View>
        <ThemedText style={[
          styles.menuLabel, 
          item.isActive && styles.activeMenuLabel
        ]}>
          {item.label}
        </ThemedText>
        {item.isActive && <View style={styles.activeIndicator} />}
      </View>
    </TouchableWithoutFeedback>
  );

  return (
    <View style={styles.container}>
      <DrawerContentScrollView 
        {...props} 
        contentContainerStyle={styles.scrollView}
      >
        <LinearGradient
          colors={['#4F46E5', '#7C3AED']}
          style={styles.drawerHeader}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
        >
          <View style={styles.avatarContainer}>
            <Ionicons name="checkmark-done" size={40} color="white" />
          </View>
          <ThemedText style={styles.appName}>TaskMaster Pro</ThemedText>
          <ThemedText style={styles.appVersion}>v1.0.0</ThemedText>
        </LinearGradient>

        <View style={styles.menuContainer}>
          {menuItems.map(renderMenuItem)}
        </View>
      </DrawerContentScrollView>

      <View style={styles.footer}>
        <ThemedText style={styles.footerText}>© 2025 TaskMaster Pro</ThemedText>
        <View style={styles.socialIcons}>
          <TouchableOpacity style={styles.socialIcon}>
            <Ionicons name="logo-twitter" size={20} color="#4F46E5" />
          </TouchableOpacity>
          <TouchableOpacity style={styles.socialIcon}>
            <Ionicons name="logo-github" size={20} color="#4F46E5" />
          </TouchableOpacity>
          <TouchableOpacity style={styles.socialIcon}>
            <Ionicons name="mail-outline" size={20} color="#4F46E5" />
          </TouchableOpacity>
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  scrollView: {
    flexGrow: 1,
  },
  drawerHeader: {
    padding: 20,
    paddingTop: 50,
    paddingBottom: 30,
    alignItems: 'center',
    borderBottomRightRadius: 20,
  },
  avatarContainer: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 15,
  },
  appName: {
    fontSize: 22,
    fontWeight: 'bold',
    color: '#fff',
    marginTop: 10,
  },
  appVersion: {
    fontSize: 12,
    color: 'rgba(255, 255, 255, 0.8)',
    marginTop: 4,
  },
  menuContainer: {
    paddingVertical: 15,
  },
  menuItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 15,
    paddingHorizontal: 25,
    position: 'relative',
  },
  activeMenuItem: {
    backgroundColor: '#F5F3FF',
  },
  menuIconContainer: {
    width: 40,
    alignItems: 'center',
  },
  menuLabel: {
    fontSize: 16,
    color: '#666',
    marginLeft: 10,
  },
  activeMenuLabel: {
    color: '#4F46E5',
    fontWeight: '600',
  },
  activeIndicator: {
    position: 'absolute',
    left: 0,
    top: 0,
    bottom: 0,
    width: 4,
    backgroundColor: '#4F46E5',
    borderTopRightRadius: 2,
    borderBottomRightRadius: 2,
  },
  footer: {
    padding: 20,
    borderTopWidth: 1,
    borderTopColor: '#f0f0f0',
    alignItems: 'center',
  },
  footerText: {
    fontSize: 12,
    color: '#888',
    marginBottom: 10,
  },
  socialIcons: {
    flexDirection: 'row',
    justifyContent: 'center',
  },
  socialIcon: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: '#f0f0f0',
    justifyContent: 'center',
    alignItems: 'center',
    marginHorizontal: 6,
  },
});
