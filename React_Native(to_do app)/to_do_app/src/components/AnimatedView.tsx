"use client"

import type React from "react"
import { useEffect, useRef } from "react"
import { Animated, type ViewStyle } from "react-native"
import { AnimationConfig, AnimationPresets } from "../animations/AnimationConfig"

interface AnimatedViewProps {
  children: React.ReactNode
  animation?: keyof typeof AnimationPresets
  duration?: number
  delay?: number
  style?: ViewStyle
  onAnimationComplete?: () => void
}

export const AnimatedView: React.FC<AnimatedViewProps> = ({
  children,
  animation = "fadeIn",
  duration = AnimationConfig.card.duration,
  delay = 0,
  style,
  onAnimationComplete,
}) => {
  const animatedValue = useRef(new Animated.Value(0)).current
  const scaleValue = useRef(new Animated.Value(1)).current
  const translateXValue = useRef(new Animated.Value(0)).current
  const translateYValue = useRef(new Animated.Value(0)).current

  useEffect(() => {
    const preset = AnimationPresets[animation]

    // Set initial values
    if (preset.from.opacity !== undefined) {
      animatedValue.setValue(preset.from.opacity)
    }
    if (preset.from.scale !== undefined) {
      scaleValue.setValue(preset.from.scale)
    }
    if (preset.from.translateX !== undefined) {
      translateXValue.setValue(preset.from.translateX)
    }
    if (preset.from.translateY !== undefined) {
      translateYValue.setValue(preset.from.translateY)
    }

    // Create animations
    const animations: Animated.CompositeAnimation[] = []

    if (preset.to.opacity !== undefined) {
      animations.push(
        Animated.timing(animatedValue, {
          toValue: preset.to.opacity,
          duration,
          delay,
          easing: AnimationConfig.card.easing,
          useNativeDriver: true,
        }),
      )
    }

    if (preset.to.scale !== undefined) {
      animations.push(
        Animated.timing(scaleValue, {
          toValue: preset.to.scale,
          duration,
          delay,
          easing: AnimationConfig.card.easing,
          useNativeDriver: true,
        }),
      )
    }

    if (preset.to.translateX !== undefined) {
      animations.push(
        Animated.timing(translateXValue, {
          toValue: preset.to.translateX,
          duration,
          delay,
          easing: AnimationConfig.card.easing,
          useNativeDriver: true,
        }),
      )
    }

    if (preset.to.translateY !== undefined) {
      animations.push(
        Animated.timing(translateYValue, {
          toValue: preset.to.translateY,
          duration,
          delay,
          easing: AnimationConfig.card.easing,
          useNativeDriver: true,
        }),
      )
    }

    // Run animations
    Animated.parallel(animations).start(onAnimationComplete)
  }, [animation, duration, delay, onAnimationComplete])

  const animatedStyle = {
    opacity: animatedValue,
    transform: [{ scale: scaleValue }, { translateX: translateXValue }, { translateY: translateYValue }],
  }

  return <Animated.View style={[style, animatedStyle]}>{children}</Animated.View>
}
