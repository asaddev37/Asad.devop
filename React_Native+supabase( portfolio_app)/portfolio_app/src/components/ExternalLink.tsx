import React from 'react';
import { Linking, TouchableOpacity, StyleSheet, GestureResponderEvent } from 'react-native';
import { ThemedText } from './ThemedText';

type ExternalLinkProps = {
  href: string;
  children: React.ReactNode;
  style?: any;
  textStyle?: any;
  onPress?: (event: GestureResponderEvent) => void;
};

export function ExternalLink({ 
  href, 
  children, 
  style, 
  textStyle, 
  onPress,
  ...rest 
}: ExternalLinkProps) {
  const handlePress = async (event: GestureResponderEvent) => {
    if (onPress) {
      onPress(event);
    } else if (href) {
      await Linking.openURL(href);
    }
  };

  return (
    <TouchableOpacity 
      style={[styles.link, style]} 
      onPress={handlePress}
      accessibilityRole="link"
      {...rest}
    >
      {typeof children === 'string' ? (
        <ThemedText style={[styles.text, textStyle]}>{children}</ThemedText>
      ) : (
        children
      )}
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  link: {
    marginTop: 8,
    marginBottom: 4,
  },
  text: {
    textAlign: 'center',
  },
});
