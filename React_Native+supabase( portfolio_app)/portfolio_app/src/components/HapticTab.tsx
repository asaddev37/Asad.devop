import * as Haptics from 'expo-haptics';
import { ComponentProps } from 'react';
import { TouchableOpacity } from 'react-native';

type HapticTabProps = ComponentProps<typeof TouchableOpacity> & {
  children: React.ReactNode;
};

export function HapticTab({ children, onPress, ...props }: HapticTabProps) {
  const handlePress = (event: any) => {
    // Trigger haptic feedback
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    
    // Call the original onPress handler if it exists
    if (onPress) {
      onPress(event);
    }
  };

  return (
    <TouchableOpacity onPress={handlePress} activeOpacity={0.8} {...props}>
      {children}
    </TouchableOpacity>
  );
}
