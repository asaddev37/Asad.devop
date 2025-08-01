import React, { createContext, useContext, useState, ReactNode } from 'react';

export interface ProfileData {
  name: string;
  title: string;
  email: string;
  phone: string;
  location: string;
  bio: string;
  avatar: string;
  profileImage?: string; // Base64 encoded image
  socialLinks: {
    linkedin: string;
    github: string;
    twitter: string;
    portfolio: string;
  };
  stats: {
    projects: number;
    experience: number;
    skills: number;
    satisfaction: number;
  };
}

const defaultProfileData: ProfileData = {
  name: 'John Doe',
  title: 'Senior Full Stack Developer',
  email: 'john.doe@example.com',
  phone: '+1 (555) 123-4567',
  location: 'San Francisco, CA',
  bio: 'Passionate full-stack developer with 5+ years of experience building scalable web and mobile applications.',
  avatar: '👨‍💻',
  profileImage: undefined,
  socialLinks: {
    linkedin: 'linkedin.com/in/johndoe',
    github: 'github.com/johndoe',
    twitter: '@johndoe',
    portfolio: 'johndoe.dev',
  },
  stats: {
    projects: 15,
    experience: 5,
    skills: 20,
    satisfaction: 100,
  },
};

interface ProfileContextType {
  profileData: ProfileData;
  updateProfile: (data: Partial<ProfileData>) => void;
  updateProfileImage: (imageUri: string) => void;
  resetProfile: () => void;
}

const ProfileContext = createContext<ProfileContextType | undefined>(undefined);

export const useProfile = () => {
  const context = useContext(ProfileContext);
  if (!context) {
    throw new Error('useProfile must be used within a ProfileProvider');
  }
  return context;
};

interface ProfileProviderProps {
  children: ReactNode;
}

export const ProfileProvider: React.FC<ProfileProviderProps> = ({ children }) => {
  const [profileData, setProfileData] = useState<ProfileData>(defaultProfileData);

  const updateProfile = (data: Partial<ProfileData>) => {
    setProfileData(prev => ({ ...prev, ...data }));
  };

  const updateProfileImage = (imageUri: string) => {
    setProfileData(prev => ({ ...prev, profileImage: imageUri }));
  };

  const resetProfile = () => {
    setProfileData(defaultProfileData);
  };

  return (
    <ProfileContext.Provider value={{ profileData, updateProfile, updateProfileImage, resetProfile }}>
      {children}
    </ProfileContext.Provider>
  );
}; 