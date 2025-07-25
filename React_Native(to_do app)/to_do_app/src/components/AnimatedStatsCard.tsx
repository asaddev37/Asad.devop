"use client"

import type React from "react"
import { useEffect, useRef } from "react"
import { View, Text, StyleSheet, Animated } from "react-native"
import Icon from "react-native-vector-icons/MaterialIcons"
import { AnimationConfig } from "../animations/AnimationConfig"

interface AnimatedStatsCardProps {
  title: string
  value: string | number
  icon: string
  color: string
  backgroundColor: string
  index: number
}

export const AnimatedStatsCard: React.FC<AnimatedStatsCardProps> = ({
  title,
  value,
  icon,
  color,
  backgroundColor,
  index,
}) => {
  const scaleAnim = useRef(new Animated.Value(0)).current
  const opacityAnim = useRef(new Animated.Value(0)).current
  const translateYAnim = useRef(new Animated.Value(30)).current
  const countAnim = useRef(new Animated.Value(0)).current

  useEffect(() => {
    // Entrance animation with stagger
    Animated.parallel([
      Animated.timing(opacityAnim, {
        toValue: 1,
        duration: AnimationConfig.card.duration,
        delay: index * 100,
        easing: AnimationConfig.card.easing,
        useNativeDriver: true,
      }),
      Animated.spring(scaleAnim, {
        toValue: 1,
        delay: index * 100,
        tension: AnimationConfig.spring.tension,
        friction: AnimationConfig.spring.friction,
        useNativeDriver: true,
      }),
      Animated.timing(translateYAnim, {
        toValue: 0,
        duration: AnimationConfig.card.duration,
        delay: index * 100,
        easing: AnimationConfig.card.easing,
        useNativeDriver: true,
      }),
    ]).start()

    // Count up animation for numeric values
    if (typeof value === "number") {
      Animated.timing(countAnim, {
        toValue: value,
        duration: AnimationConfig.progress.duration,
        delay: index * 100 + 200,
        easing: AnimationConfig.progress.easing,
        useNativeDriver: false,
      }).start()
    }
  }, [index, value])

  const animatedValue =
    typeof value === "number"
      ? countAnim.interpolate({
          inputRange: [0, value],
          outputRange: [0, value],
          extrapolate: "clamp",
        })
      : value

  return (
    <Animated.View
      style={[
        styles.card,
        {
          opacity: opacityAnim,
          transform: [{ scale: scaleAnim }, { translateY: translateYAnim }],
        },
      ]}
    >
      <View style={styles.content}>
        <View style={[styles.iconContainer, { backgroundColor }]}>
          <Icon name={icon} size={20} color={color} />
        </View>
        <View style={styles.textContainer}>
          {typeof value === "number" ? (
            <Animated.Text style={styles.value}>{animatedValue}</Animated.Text>
          ) : (
            <Text style={styles.value}>{value}</Text>
          )}
          <Text style={styles.title}>{title}</Text>
        </View>
      </View>
    </Animated.View>
  )
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: "#FFFFFF",
    borderRadius: 12,
    padding: 16,
    marginBottom: 8,
    width: "48%",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  content: {
    flexDirection: "row",
    alignItems: "center",
  },
  iconContainer: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: "center",
    alignItems: "center",
    marginRight: 12,
  },
  textContainer: {
    flex: 1,
  },
  value: {
    fontSize: 24,
    fontWeight: "bold",
    color: "#1F2937",
    marginBottom: 2,
  },
  title: {
    fontSize: 12,
    color: "#6B7280",
  },
})
