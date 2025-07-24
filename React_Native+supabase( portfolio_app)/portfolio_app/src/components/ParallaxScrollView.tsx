import React, { ReactNode } from 'react';
import { ScrollView, StyleSheet, View, ViewStyle, StyleProp } from 'react-native';
import { useColorScheme } from 'react-native';
import { ThemedView } from './ThemedView';

type ParallaxScrollViewProps = {
  children: ReactNode;
  headerBackgroundColor: { light: string; dark: string };
  headerImage: ReactNode;
  style?: StyleProp<ViewStyle>;
};

export default function ParallaxScrollView({
  children,
  headerBackgroundColor,
  headerImage,
  style,
}: ParallaxScrollViewProps) {
  const colorScheme = useColorScheme() ?? 'light';
  const backgroundColor = colorScheme === 'dark' 
    ? headerBackgroundColor.dark 
    : headerBackgroundColor.light;

  return (
    <ScrollView
      style={[styles.container, style]}
      contentContainerStyle={styles.contentContainer}
      showsVerticalScrollIndicator={false}
    >
      <View style={[styles.header, { backgroundColor }]}>
        {headerImage}
      </View>
      <ThemedView style={styles.content}>
        {children}
      </ThemedView>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  contentContainer: {
    paddingBottom: 20,
  },
  header: {
    height: 200,
    width: '100%',
    justifyContent: 'center',
    alignItems: 'center',
  },
  content: {
    flex: 1,
    padding: 16,
  },
});
