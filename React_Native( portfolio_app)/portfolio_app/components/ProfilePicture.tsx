import React, { useState } from 'react';
import { View, StyleSheet, TouchableOpacity, Image, Alert } from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import { ThemedText } from '@/components/ThemedText';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/useColorScheme';
import { useProfile } from '@/contexts/ProfileContext';

interface ProfilePictureProps {
  size?: number;
  editable?: boolean;
  onImageChange?: (imageUri: string) => void;
}

export default function ProfilePicture({ 
  size = 80, 
  editable = false, 
  onImageChange 
}: ProfilePictureProps) {
  const colorScheme = useColorScheme();
  const colors = Colors[colorScheme ?? 'light'];
  const { profileData, updateProfileImage } = useProfile();

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
        base64: true,
      });

      if (!result.canceled && result.assets[0]) {
        const imageUri = result.assets[0].uri;
        const base64Image = result.assets[0].base64;
        
        if (base64Image) {
          const fullBase64 = `data:image/jpeg;base64,${base64Image}`;
          updateProfileImage(fullBase64);
          onImageChange?.(fullBase64);
        }
      }
    } catch (error) {
      Alert.alert('Error', 'Failed to pick image. Please try again.');
    }
  };

  const takePhoto = async () => {
    try {
      // Request permissions
      const { status } = await ImagePicker.requestCameraPermissionsAsync();
      if (status !== 'granted') {
        Alert.alert('Permission needed', 'Please grant camera permissions to take a profile picture.');
        return;
      }

      // Launch camera
      const result = await ImagePicker.launchCameraAsync({
        allowsEditing: true,
        aspect: [1, 1],
        quality: 0.8,
        base64: true,
      });

      if (!result.canceled && result.assets[0]) {
        const imageUri = result.assets[0].uri;
        const base64Image = result.assets[0].base64;
        
        if (base64Image) {
          const fullBase64 = `data:image/jpeg;base64,${base64Image}`;
          updateProfileImage(fullBase64);
          onImageChange?.(fullBase64);
        }
      }
    } catch (error) {
      Alert.alert('Error', 'Failed to take photo. Please try again.');
    }
  };

  const showImageOptions = () => {
    Alert.alert(
      'Profile Picture',
      'Choose an option',
      [
        { text: 'Take Photo', onPress: takePhoto },
        { text: 'Choose from Gallery', onPress: pickImage },
        { text: 'Cancel', style: 'cancel' },
      ]
    );
  };

  const containerStyle = {
    width: size,
    height: size,
    borderRadius: size / 2,
  };

  const imageStyle = {
    width: size,
    height: size,
    borderRadius: size / 2,
  };

  const editButtonStyle = {
    position: 'absolute' as const,
    bottom: 0,
    right: 0,
    width: size * 0.3,
    height: size * 0.3,
    borderRadius: (size * 0.3) / 2,
    backgroundColor: colors.tint,
    alignItems: 'center' as const,
    justifyContent: 'center' as const,
  };

  if (profileData.profileImage) {
    return (
      <View style={[styles.container, containerStyle]}>
        <TouchableOpacity
          onPress={editable ? showImageOptions : undefined}
          activeOpacity={editable ? 0.8 : 1}
        >
          <Image
            source={{ uri: profileData.profileImage }}
            style={[styles.image, imageStyle]}
          />
          {editable && (
            <View style={editButtonStyle}>
              <ThemedText style={[styles.editIcon, { color: colors.background }]}>
                📷
              </ThemedText>
            </View>
          )}
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <View style={[styles.container, containerStyle]}>
      <TouchableOpacity
        onPress={editable ? showImageOptions : undefined}
        activeOpacity={editable ? 0.8 : 1}
                 style={[styles.avatarContainer, containerStyle, { backgroundColor: colors.primary }]}
      >
        <ThemedText style={[styles.avatar, { fontSize: size * 0.5 }]}>
          {profileData.avatar}
        </ThemedText>
        {editable && (
          <View style={editButtonStyle}>
            <ThemedText style={[styles.editIcon, { color: colors.background }]}>
              📷
            </ThemedText>
          </View>
        )}
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    position: 'relative',
  },
  avatarContainer: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  avatar: {
    textAlign: 'center',
  },
  image: {
    resizeMode: 'cover',
  },
  editIcon: {
    fontSize: 12,
  },
}); 