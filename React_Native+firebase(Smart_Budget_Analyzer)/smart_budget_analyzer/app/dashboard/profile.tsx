import React, { useState, useRef, useEffect } from 'react';
import { ExportService } from '../../src/services/exportService';
import { FirestoreService } from '../../src/services/firestoreService';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Animated,
  StatusBar,
  Alert,
  TextInput,
  Modal,
  Switch,
  Image,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { useAuth } from '../../src/contexts/AuthContext';
import { router } from 'expo-router';
import * as SecureStore from 'expo-secure-store';
import * as LocalAuthentication from 'expo-local-authentication';
import * as ImagePicker from 'expo-image-picker';
import { LoadingOverlay } from '../../components/LoadingOverlay';
import { LoadingAnimation } from '../../components/LoadingAnimation';

const BIOMETRIC_CREDENTIALS_KEY = 'biometric_credentials';
const BIOMETRIC_ENABLED_KEY = 'biometric_enabled';

interface ProfileFormData {
  fullName: string;
  email: string;
  currency: string;
  profilePicture?: string;
}

const ProfileScreen = () => {
  const { user, userProfile, updateProfile, signOut } = useAuth();
  const [loading, setLoading] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);
  const [isBiometricEnabled, setIsBiometricEnabled] = useState(false);
  const [isBiometricAvailable, setIsBiometricAvailable] = useState(false);
  const [uploadingImage, setUploadingImage] = useState(false);
  
  const [formData, setFormData] = useState<ProfileFormData>({
    fullName: '',
    email: '',
    currency: 'USD',
    profilePicture: '',
  });

  const fadeAnim = useRef(new Animated.Value(0)).current;
  const slideAnim = useRef(new Animated.Value(50)).current;

  // Check biometric availability
  useEffect(() => {
    const checkBiometricStatus = async () => {
      try {
        const compatible = await LocalAuthentication.hasHardwareAsync();
        const enrolled = await LocalAuthentication.isEnrolledAsync();
        setIsBiometricAvailable(compatible && enrolled);

        const enabled = await SecureStore.getItemAsync(BIOMETRIC_ENABLED_KEY);
        setIsBiometricEnabled(enabled === 'true');
      } catch (error) {
        console.error('Error checking biometric status:', error);
      }
    };

    checkBiometricStatus();
  }, []);

  // Initialize form data
  useEffect(() => {
    if (userProfile) {
      setFormData({
        fullName: userProfile.fullName || '',
        email: userProfile.email || '',
        currency: userProfile.currency || 'USD',
        profilePicture: userProfile.profilePicture || '',
      });
    }
  }, [userProfile]);

  const handleEditProfile = async () => {
    if (!formData.fullName.trim()) {
      Alert.alert('Error', 'Please enter your full name');
      return;
    }

    try {
      setLoading(true);
      await updateProfile({
        fullName: formData.fullName.trim(),
        currency: formData.currency,
        profilePicture: formData.profilePicture,
      });
      setShowEditModal(false);
      Alert.alert('Success', 'Profile updated successfully');
    } catch (error) {
      console.error('Error updating profile:', error);
      Alert.alert('Error', 'Failed to update profile');
    } finally {
      setLoading(false);
    }
  };

  const pickImage = async () => {
    try {
      // Request permissions
      const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
      if (status !== 'granted') {
        Alert.alert('Permission needed', 'Please grant camera roll permissions to select a profile picture.');
        return;
      }

      // Launch image picker
      const result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ImagePicker.MediaTypeOptions.Images,
        allowsEditing: true,
        aspect: [1, 1],
        quality: 0.8,
      });

      if (!result.canceled && result.assets[0]) {
        setFormData({ ...formData, profilePicture: result.assets[0].uri });
      }
    } catch (error) {
      console.error('Error picking image:', error);
      Alert.alert('Error', 'Failed to pick image');
    }
  };

  const takePhoto = async () => {
    try {
      // Request permissions
      const { status } = await ImagePicker.requestCameraPermissionsAsync();
      if (status !== 'granted') {
        Alert.alert('Permission needed', 'Please grant camera permissions to take a photo.');
        return;
      }

      // Launch camera
      const result = await ImagePicker.launchCameraAsync({
        allowsEditing: true,
        aspect: [1, 1],
        quality: 0.8,
      });

      if (!result.canceled && result.assets[0]) {
        setFormData({ ...formData, profilePicture: result.assets[0].uri });
      }
    } catch (error) {
      console.error('Error taking photo:', error);
      Alert.alert('Error', 'Failed to take photo');
    }
  };

  const showImagePickerOptions = () => {
    Alert.alert(
      'Profile Picture',
      'Choose an option',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Take Photo', onPress: takePhoto },
        { text: 'Choose from Library', onPress: pickImage },
      ]
    );
  };

  const handleLogout = async () => {
    Alert.alert(
      'Logout',
      'Are you sure you want to logout?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Logout',
          style: 'destructive',
          onPress: async () => {
            try {
              await signOut();
              await SecureStore.deleteItemAsync(BIOMETRIC_CREDENTIALS_KEY);
              await SecureStore.deleteItemAsync(BIOMETRIC_ENABLED_KEY);
              router.replace('/home');
            } catch (error) {
              console.error('Error during logout:', error);
            }
          },
        },
      ]
    );
  };

  const toggleBiometric = async () => {
    if (!isBiometricAvailable) {
      Alert.alert('Not Available', 'Biometric authentication is not available on this device');
      return;
    }

    if (isBiometricEnabled) {
      // Disable biometric
      await SecureStore.deleteItemAsync(BIOMETRIC_CREDENTIALS_KEY);
      await SecureStore.setItemAsync(BIOMETRIC_ENABLED_KEY, 'false');
      setIsBiometricEnabled(false);
      Alert.alert('Disabled', 'Biometric authentication has been disabled');
    } else {
      // Enable biometric
      try {
        const result = await LocalAuthentication.authenticateAsync({
          promptMessage: 'Authenticate to enable biometric login',
        });

        if (result.success) {
          await SecureStore.setItemAsync(BIOMETRIC_ENABLED_KEY, 'true');
          setIsBiometricEnabled(true);
          Alert.alert('Enabled', 'Biometric authentication has been enabled');
        }
      } catch (error) {
        console.error('Error enabling biometric:', error);
        Alert.alert('Error', 'Failed to enable biometric authentication');
      }
    }
  };

  const formatCurrency = (amount: number) => {
    const currency = userProfile?.currency || 'USD';
    const symbol = currency === 'USD' ? '$' : currency === 'PKR' ? '₨' : currency === 'EUR' ? '€' : currency === 'GBP' ? '£' : '$';
    return `${symbol}${Math.abs(amount).toFixed(2)}`;
  };

  const getCurrencySymbol = (currency: string) => {
    switch (currency) {
      case 'USD': return '$';
      case 'PKR': return '₨';
      case 'EUR': return '€';
      case 'GBP': return '£';
      default: return '$';
    }
  };

  const currencyOptions = [
    { code: 'USD', name: 'US Dollar', symbol: '$' },
    { code: 'PKR', name: 'Pakistani Rupee', symbol: '₨' },
    { code: 'EUR', name: 'Euro', symbol: '€' },
    { code: 'GBP', name: 'British Pound', symbol: '£' },
  ];

  useEffect(() => {
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 800,
        useNativeDriver: true,
      }),
      Animated.timing(slideAnim, {
        toValue: 0,
        duration: 800,
        useNativeDriver: true,
      }),
    ]).start();
  }, []);

  return (
    <View style={styles.container}>
      <StatusBar barStyle="dark-content" backgroundColor="transparent" translucent />
      
      {/* Loading Overlay */}
      <LoadingOverlay 
        visible={loading || uploadingImage} 
        message={uploadingImage ? "Uploading profile picture..." : loading ? "Processing..." : "Updating profile..."} 
        transparent={true}
        animationType="circular"
      />
      <LoadingAnimation
        visible={loading}
        type="circular"
        size="large"
        message={uploadingImage ? "Uploading profile picture..." : "Processing..."}
        style={styles.loadingAnimation}
      />
      
      {/* Header */}
      <LinearGradient colors={['#4A90E2', '#357ABD']} style={styles.header}>
        <View style={styles.headerContent}>
          <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
            <Ionicons name="arrow-back" size={24} color="white" />
          </TouchableOpacity>
          <Text style={styles.headerTitle}>Profile</Text>
          <TouchableOpacity onPress={() => setShowEditModal(true)} style={styles.editButton}>
            <Ionicons name="pencil" size={24} color="white" />
          </TouchableOpacity>
        </View>
      </LinearGradient>

      <ScrollView style={styles.content}>
        <Animated.View
          style={[
            styles.contentContainer,
            {
              opacity: fadeAnim,
              transform: [{ translateY: slideAnim }],
            },
          ]}
        >
          {/* Profile Card */}
          <View style={styles.profileCard}>
            <View style={styles.avatarContainer}>
              <TouchableOpacity onPress={showImagePickerOptions} style={styles.avatarWrapper}>
                {userProfile?.profilePicture ? (
                  <Image source={{ uri: userProfile.profilePicture }} style={styles.avatarImage} />
                ) : (
                  <View style={styles.avatar}>
                    <Text style={styles.avatarText}>
                      {userProfile?.fullName?.charAt(0)?.toUpperCase() || 'U'}
                    </Text>
                  </View>
                )}
                <View style={styles.editAvatarButton}>
                  <Ionicons name="camera" size={16} color="white" />
                </View>
              </TouchableOpacity>
            </View>
            <Text style={styles.profileName}>{userProfile?.fullName || 'User'}</Text>
            <Text style={styles.profileEmail}>{userProfile?.email || 'user@example.com'}</Text>
          </View>

          {/* Settings Sections */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Account Settings</Text>
            
            {/* Personal Information */}
            <View style={styles.settingCard}>
              <View style={styles.settingHeader}>
                <Ionicons name="person" size={20} color="#1e90ff" />
                <Text style={styles.settingTitle}>Personal Information</Text>
              </View>
              <View style={styles.settingContent}>
                <View style={styles.settingRow}>
                  <Text style={styles.settingLabel}>Full Name</Text>
                  <Text style={styles.settingValue}>{userProfile?.fullName || 'Not set'}</Text>
                </View>
                <View style={styles.settingRow}>
                  <Text style={styles.settingLabel}>Email</Text>
                  <Text style={styles.settingValue}>{userProfile?.email || 'Not set'}</Text>
                </View>
                <View style={styles.settingRow}>
                  <Text style={styles.settingLabel}>Currency</Text>
                  <Text style={styles.settingValue}>
                    {userProfile?.currency || 'USD'} ({getCurrencySymbol(userProfile?.currency || 'USD')})
                  </Text>
                </View>
              </View>
            </View>

            {/* Security Settings */}
            <View style={styles.settingCard}>
              <View style={styles.settingHeader}>
                <Ionicons name="shield" size={20} color="#32cd32" />
                <Text style={styles.settingTitle}>Security</Text>
              </View>
              <View style={styles.settingContent}>
                <View style={styles.settingRow}>
                  <Text style={styles.settingLabel}>Biometric Login</Text>
                  <Switch
                    value={isBiometricEnabled}
                    onValueChange={toggleBiometric}
                    trackColor={{ false: '#e0e0e0', true: '#32cd32' }}
                    thumbColor={isBiometricEnabled ? '#fff' : '#f4f3f4'}
                    disabled={!isBiometricAvailable}
                  />
                </View>
                {!isBiometricAvailable && (
                  <Text style={styles.settingHint}>
                    Biometric authentication is not available on this device
                  </Text>
                )}
              </View>
            </View>

            {/* App Settings */}
            <View style={styles.settingCard}>
              <View style={styles.settingHeader}>
                <Ionicons name="settings" size={20} color="#ff6b35" />
                <Text style={styles.settingTitle}>App Settings</Text>
              </View>
              <View style={styles.settingContent}>
                <TouchableOpacity style={styles.settingRow}>
                  <Text style={styles.settingLabel}>Notifications</Text>
                  <Ionicons name="chevron-forward" size={20} color="#666" />
                </TouchableOpacity>
                <TouchableOpacity 
                  style={styles.settingRow}
                  onPress={async () => {
                    try {
                      setLoading(true);
                      const transactions = await FirestoreService.getTransactions(user?.uid || '');
                      await ExportService.exportTransactionsToCSV(transactions);
                      Alert.alert('Success', 'Transactions exported successfully');
                    } catch (error) {
                      console.error('Error exporting transactions:', error);
                      Alert.alert('Error', 'Failed to export transactions');
                    } finally {
                      setLoading(false);
                    }
                  }}
                >
                  <Text style={styles.settingLabel}>Data Export</Text>
                  <Ionicons name="download-outline" size={20} color="#666" />
                </TouchableOpacity>
                <TouchableOpacity 
                  style={styles.settingRow}
                  onPress={() => router.push('/drawer/privacy-policy')}
                >
                  <Text style={styles.settingLabel}>Privacy Policy</Text>
                  <Ionicons name="chevron-forward" size={20} color="#666" />
                </TouchableOpacity>
              </View>
            </View>

            {/* AI Features */}
            <View style={styles.settingCard}>
              <View style={styles.settingHeader}>
                <Ionicons name="sparkles" size={20} color="#9c27b0" />
                <Text style={styles.settingTitle}>AI Features</Text>
              </View>
              <View style={styles.settingContent}>
                <View style={styles.settingRow}>
                  <Text style={styles.settingLabel}>Smart Analytics</Text>
                  <Text style={styles.settingValue}>Coming Soon</Text>
                </View>
                <View style={styles.settingRow}>
                  <Text style={styles.settingLabel}>Predictive Alerts</Text>
                  <Text style={styles.settingValue}>Coming Soon</Text>
                </View>
                <View style={styles.settingRow}>
                  <Text style={styles.settingLabel}>AI Categorization</Text>
                  <Text style={styles.settingValue}>Coming Soon</Text>
                </View>
              </View>
            </View>
          </View>

          {/* Logout Button */}
          <TouchableOpacity style={styles.logoutButton} onPress={handleLogout}>
            <Ionicons name="log-out-outline" size={20} color="white" />
            <Text style={styles.logoutText}>Logout</Text>
          </TouchableOpacity>

          {/* App Info */}
          <View style={styles.appInfo}>
            <Text style={styles.appVersion}>SmartBudgetAnalyzer v1.1</Text>
            <Text style={styles.appDeveloper}>Made with ❤ by AK~~37</Text>
          </View>
        </Animated.View>
      </ScrollView>

      {/* Edit Profile Modal */}
      <Modal
        visible={showEditModal}
        animationType="slide"
        presentationStyle="pageSheet"
      >
        <View style={styles.modalContainer}>
          <View style={styles.modalHeader}>
            <TouchableOpacity onPress={() => setShowEditModal(false)}>
              <Text style={styles.cancelButton}>Cancel</Text>
            </TouchableOpacity>
            <Text style={styles.modalTitle}>Edit Profile</Text>
            <TouchableOpacity onPress={handleEditProfile} disabled={loading}>
              <Text style={[styles.saveButton, loading && styles.saveButtonDisabled]}>
                {loading ? 'Saving...' : 'Save'}
              </Text>
            </TouchableOpacity>
          </View>

          <ScrollView style={styles.modalContent}>
            {/* Profile Picture */}
            <View style={styles.inputGroup}>
              <Text style={styles.inputLabel}>Profile Picture</Text>
              <TouchableOpacity onPress={showImagePickerOptions} style={styles.profilePictureContainer}>
                {formData.profilePicture ? (
                  <Image source={{ uri: formData.profilePicture }} style={styles.profilePicturePreview} />
                ) : (
                  <View style={styles.profilePicturePlaceholder}>
                    <Ionicons name="camera" size={32} color="#666" />
                    <Text style={styles.profilePictureText}>Tap to add photo</Text>
                  </View>
                )}
              </TouchableOpacity>
            </View>

            {/* Full Name */}
            <View style={styles.inputGroup}>
              <Text style={styles.inputLabel}>Full Name *</Text>
              <TextInput
                style={styles.textInput}
                value={formData.fullName}
                onChangeText={(text) => setFormData({ ...formData, fullName: text })}
                placeholder="Enter your full name"
              />
            </View>

            {/* Email (Read-only) */}
            <View style={styles.inputGroup}>
              <Text style={styles.inputLabel}>Email</Text>
              <TextInput
                style={[styles.textInput, styles.disabledInput]}
                value={formData.email}
                editable={false}
                placeholder="Email address"
              />
              <Text style={styles.inputHint}>
                Email cannot be changed. Contact support if needed.
              </Text>
            </View>

            {/* Currency */}
            <View style={styles.inputGroup}>
              <Text style={styles.inputLabel}>Currency</Text>
              <View style={styles.currencyContainer}>
                {currencyOptions.map((currency) => (
                  <TouchableOpacity
                    key={currency.code}
                    style={[
                      styles.currencyButton,
                      formData.currency === currency.code && styles.activeCurrencyButton,
                    ]}
                    onPress={() => setFormData({ ...formData, currency: currency.code })}
                  >
                    <Text
                      style={[
                        styles.currencyText,
                        formData.currency === currency.code && styles.activeCurrencyText,
                      ]}
                    >
                      {currency.symbol} {currency.code}
                    </Text>
                  </TouchableOpacity>
                ))}
              </View>
            </View>
          </ScrollView>
        </View>
      </Modal>
    </View>
  );
};

const styles = StyleSheet.create({
  loadingAnimation: {
    position: 'absolute',
    top: '50%',
    left: '50%',
    transform: [{ translateX: -50 }, { translateY: -50 }],
    zIndex: 1000,
    backgroundColor: 'rgba(255, 255, 255, 0.9)',
    borderRadius: 15,
    padding: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
  },
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  header: {
    paddingTop: 60,
    paddingBottom: 20,
    paddingHorizontal: 20,
  },
  headerContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  backButton: {
    padding: 8,
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: 'white',
  },
  editButton: {
    padding: 8,
  },
  content: {
    flex: 1,
  },
  contentContainer: {
    padding: 20,
  },
  profileCard: {
    backgroundColor: 'white',
    borderRadius: 20,
    padding: 30,
    alignItems: 'center',
    marginBottom: 25,
    elevation: 5,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
  },
  avatarContainer: {
    marginBottom: 15,
  },
  avatarWrapper: {
    position: 'relative',
  },
  avatar: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: '#1e90ff',
    justifyContent: 'center',
    alignItems: 'center',
  },
  avatarImage: {
    width: 80,
    height: 80,
    borderRadius: 40,
  },
  editAvatarButton: {
    position: 'absolute',
    bottom: 0,
    right: 0,
    backgroundColor: '#1e90ff',
    borderRadius: 15,
    width: 30,
    height: 30,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: 'white',
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
  },
  avatarText: {
    fontSize: 32,
    fontWeight: 'bold',
    color: 'white',
  },
  profileName: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 5,
  },
  profileEmail: {
    fontSize: 16,
    color: '#666',
  },
  section: {
    marginBottom: 25,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 15,
  },
  settingCard: {
    backgroundColor: 'white',
    borderRadius: 15,
    padding: 20,
    marginBottom: 15,
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
  },
  settingHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 15,
  },
  settingTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#333',
    marginLeft: 10,
  },
  settingContent: {
    gap: 15,
  },
  settingRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  settingLabel: {
    fontSize: 16,
    color: '#333',
  },
  settingValue: {
    fontSize: 16,
    color: '#666',
    fontWeight: '500',
  },
  settingHint: {
    fontSize: 12,
    color: '#999',
    fontStyle: 'italic',
  },
  logoutButton: {
    backgroundColor: '#ff6b35',
    borderRadius: 15,
    padding: 15,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 25,
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
  },
  logoutText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
    marginLeft: 10,
  },
  appInfo: {
    alignItems: 'center',
    padding: 20,
  },
  appVersion: {
    fontSize: 14,
    color: '#666',
    marginBottom: 5,
  },
  appDeveloper: {
    fontSize: 12,
    color: '#999',
  },
  modalContainer: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 20,
    paddingTop: 60,
    backgroundColor: 'white',
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  cancelButton: {
    fontSize: 16,
    color: '#666',
  },
  modalTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  saveButton: {
    fontSize: 16,
    color: '#1e90ff',
    fontWeight: '600',
  },
  saveButtonDisabled: {
    color: '#ccc',
  },
  modalContent: {
    flex: 1,
    padding: 20,
  },
  inputGroup: {
    marginBottom: 20,
  },
  inputLabel: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginBottom: 8,
  },
  textInput: {
    backgroundColor: 'white',
    borderRadius: 10,
    padding: 15,
    fontSize: 16,
    borderWidth: 1,
    borderColor: '#e0e0e0',
  },
  disabledInput: {
    backgroundColor: '#f5f5f5',
    color: '#666',
  },
  inputHint: {
    fontSize: 12,
    color: '#666',
    marginTop: 5,
  },
  profilePictureContainer: {
    width: 100,
    height: 100,
    borderRadius: 50,
    backgroundColor: '#f0f0f0',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 10,
    overflow: 'hidden',
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
  },
  profilePicturePreview: {
    width: '100%',
    height: '100%',
  },
  profilePicturePlaceholder: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  profilePictureText: {
    fontSize: 14,
    color: '#666',
    marginTop: 5,
  },
  currencyContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 10,
  },
  currencyButton: {
    paddingVertical: 10,
    paddingHorizontal: 15,
    borderRadius: 20,
    backgroundColor: '#f0f0f0',
    borderWidth: 1,
    borderColor: '#e0e0e0',
  },
  activeCurrencyButton: {
    backgroundColor: '#1e90ff',
    borderColor: '#1e90ff',
  },
  currencyText: {
    fontSize: 14,
    color: '#666',
    fontWeight: '500',
  },
  activeCurrencyText: {
    color: 'white',
  },
});

export default ProfileScreen;