"use client"

import type React from "react"
import { useRef, useEffect } from "react"
import { TouchableOpacity, StyleSheet, Animated } from "react-native"
import Icon from "react-native-vector-icons/MaterialIcons"
import { AnimationConfig } from "../animations/AnimationConfig"

interface AnimatedFloatingActionButtonProps {
  onPress: () => void
  visible?: boolean
}

export const AnimatedFloatingActionButton: React.FC<AnimatedFloatingActionButtonProps> = ({
  onPress,
  visible = true,
}) => {
  const scaleAnim = useRef(new Animated.Value(0)).current
  const rotateAnim = useRef(new Animated.Value(0)).current
  const translateYAnim = useRef(new Animated.Value(100)).current

  useEffect(() => {
    if (visible) {
      // Entrance animation
      Animated.parallel([
        Animated.spring(scaleAnim, {
          toValue: 1,
          tension: AnimationConfig.spring.tension,
          friction: AnimationConfig.spring.friction,
          useNativeDriver: true,
        }),
        Animated.timing(translateYAnim, {
          toValue: 0,
          duration: AnimationConfig.fab.duration,
          easing: AnimationConfig.fab.easing,
          useNativeDriver: true,
        }),
      ]).start()
    } else {
      // Exit animation
      Animated.parallel([
        Animated.timing(scaleAnim, {
          toValue: 0,
          duration: AnimationConfig.fab.duration,
          useNativeDriver: true,
        }),
        Animated.timing(translateYAnim, {
          toValue: 100,
          duration: AnimationConfig.fab.duration,
          useNativeDriver: true,
        }),
      ]).start()
    }
  }, [visible])

  const handlePress = () => {
    // Press animation
    Animated.sequence([
      Animated.timing(scaleAnim, {
        toValue: 0.9,
        duration: 100,
        useNativeDriver: true,
      }),
      Animated.spring(scaleAnim, {
        toValue: 1,
        tension: 300,
        friction: 10,
        useNativeDriver: true,
      }),
    ]).start()

    // Rotation animation
    Animated.timing(rotateAnim, {
      toValue: 1,
      duration: 200,
      useNativeDriver: true,
    }).start(() => {
      rotateAnim.setValue(0)
    })

    onPress()
  }

  const rotate = rotateAnim.interpolate({
    inputRange: [0, 1],
    outputRange: ["0deg", "45deg"],
  })

  return (
    <Animated.View
      style={[
        styles.container,
        {
          transform: [{ scale: scaleAnim }, { translateY: translateYAnim }],
        },
      ]}
    >
      <TouchableOpacity style={styles.fab} onPress={handlePress} activeOpacity={0.8}>
        <Animated.View style={{ transform: [{ rotate }] }}>
          <Icon name="add" size={28} color="#FFFFFF" />
        </Animated.View>
      </TouchableOpacity>
    </Animated.View>
  )
}

const styles = StyleSheet.create({
  container: {
    position: "absolute",
    bottom: 20,
    right: 20,
  },
  fab: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: "#8B5CF6",
    justifyContent: "center",
    alignItems: "center",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
})
