import React, { useState } from 'react';
import { StyleSheet, TouchableOpacity, View, ViewStyle } from 'react-native';
import Animated, { useAnimatedStyle, withTiming, withSpring } from 'react-native-reanimated';
import { ThemedText } from './ThemedText';
import { ThemedView } from './ThemedView';

type CollapsibleProps = {
  title: string;
  children: React.ReactNode;
  style?: ViewStyle;
};

export function Collapsible({ title, children, style }: CollapsibleProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [height, setHeight] = useState(0);

  const toggleOpen = () => {
    setIsOpen(!isOpen);
  };

  const animatedStyle = useAnimatedStyle(() => ({
    height: withSpring(isOpen ? 'auto' : 0, {
      damping: 15,
      stiffness: 100,
    }),
    opacity: withTiming(isOpen ? 1 : 0, { duration: 200 }),
  }));

  const arrowStyle = useAnimatedStyle(() => ({
    transform: [{ rotate: withTiming(isOpen ? '180deg' : '0deg', { duration: 200 }) }],
  }));

  return (
    <ThemedView style={[styles.container, style]}>
      <TouchableOpacity
        style={styles.header}
        onPress={toggleOpen}
        activeOpacity={0.8}
      >
        <ThemedText type="subtitle">{title}</ThemedText>
        <Animated.View style={[styles.arrow, arrowStyle]}>
          <ThemedText>▼</ThemedText>
        </Animated.View>
      </TouchableOpacity>
      <Animated.View 
        style={[styles.content, animatedStyle]}
        onLayout={e => setHeight(e.nativeEvent.layout.height)}
      >
        <View style={styles.contentContainer}>
          {children}
        </View>
      </Animated.View>
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    borderRadius: 8,
    overflow: 'hidden',
    marginBottom: 12,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 16,
    backgroundColor: 'rgba(0,0,0,0.05)',
  },
  arrow: {
    marginLeft: 8,
  },
  content: {
    overflow: 'hidden',
  },
  contentContainer: {
    padding: 16,
  },
});
