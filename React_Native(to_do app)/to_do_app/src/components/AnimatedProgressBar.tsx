"use client"

import type React from "react"
import { useEffect, useRef } from "react"
import { StyleSheet, Animated } from "react-native"
import { AnimationConfig } from "../animations/AnimationConfig"

interface AnimatedProgressBarProps {
  progress: number // 0-100
  height?: number
  backgroundColor?: string
  progressColor?: string
  animated?: boolean
  duration?: number
}

export const AnimatedProgressBar: React.FC<AnimatedProgressBarProps> = ({
  progress,
  height = 8,
  backgroundColor = "#E5E7EB",
  progressColor = "#8B5CF6",
  animated = true,
  duration = AnimationConfig.progress.duration,
}) => {
  const progressAnim = useRef(new Animated.Value(0)).current
  const scaleAnim = useRef(new Animated.Value(0)).current

  useEffect(() => {
    if (animated) {
      // Scale in animation
      Animated.spring(scaleAnim, {
        toValue: 1,
        tension: AnimationConfig.spring.tension,
        friction: AnimationConfig.spring.friction,
        useNativeDriver: true,
      }).start()

      // Progress animation
      Animated.timing(progressAnim, {
        toValue: Math.min(100, Math.max(0, progress)),
        duration,
        easing: AnimationConfig.progress.easing,
        useNativeDriver: false,
      }).start()
    } else {
      scaleAnim.setValue(1)
      progressAnim.setValue(progress)
    }
  }, [progress, animated, duration])

  const progressWidth = progressAnim.interpolate({
    inputRange: [0, 100],
    outputRange: ["0%", "100%"],
    extrapolate: "clamp",
  })

  return (
    <Animated.View
      style={[
        styles.container,
        {
          height,
          backgroundColor,
          transform: [{ scaleX: scaleAnim }],
        },
      ]}
    >
      <Animated.View
        style={[
          styles.progress,
          {
            width: progressWidth,
            backgroundColor: progressColor,
          },
        ]}
      />
    </Animated.View>
  )
}

const styles = StyleSheet.create({
  container: {
    borderRadius: 4,
    overflow: "hidden",
  },
  progress: {
    height: "100%",
    borderRadius: 4,
  },
})
