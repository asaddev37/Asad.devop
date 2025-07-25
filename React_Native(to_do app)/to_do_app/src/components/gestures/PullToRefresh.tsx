"use client"

import type React from "react"
import { useRef, useState } from "react"
import { View, Text, StyleSheet, Animated, PanResponder, Dimensions } from "react-native"
import Icon from "react-native-vector-icons/MaterialIcons"

interface PullToRefreshProps {
  children: React.ReactNode
  onRefresh: () => Promise<void>
  refreshing?: boolean
  pullDistance?: number
  refreshThreshold?: number
  colors?: string[]
}

const { height: screenHeight } = Dimensions.get("window")

export const PullToRefresh: React.FC<PullToRefreshProps> = ({
  children,
  onRefresh,
  refreshing = false,
  pullDistance = 120,
  refreshThreshold = 80,
  colors = ["#8B5CF6", "#3B82F6", "#10B981"],
}) => {
  const [isRefreshing, setIsRefreshing] = useState(false)
  const [pullState, setPullState] = useState<"idle" | "pulling" | "ready" | "refreshing">("idle")

  // Animation values
  const translateY = useRef(new Animated.Value(0)).current
  const pullProgress = useRef(new Animated.Value(0)).current
  const rotateValue = useRef(new Animated.Value(0)).current
  const scaleValue = useRef(new Animated.Value(0)).current

  // Rotation animation
  const startRotation = () => {
    Animated.loop(
      Animated.timing(rotateValue, {
        toValue: 1,
        duration: 1000,
        useNativeDriver: true,
      }),
    ).start()
  }

  const stopRotation = () => {
    rotateValue.stopAnimation()
    rotateValue.setValue(0)
  }

  const panResponder = useRef(
    PanResponder.create({
      onMoveShouldSetPanResponder: (evt, gestureState) => {
        // Only respond to downward gestures at the top of the screen
        return gestureState.dy > 0 && evt.nativeEvent.pageY < 100
      },

      onPanResponderGrant: () => {
        translateY.setOffset(translateY._value)
        translateY.setValue(0)
      },

      onPanResponderMove: (evt, gestureState) => {
        if (isRefreshing) return

        const { dy } = gestureState
        const progress = Math.min(dy / pullDistance, 1)

        // Apply resistance curve for natural feel
        const resistance = dy > pullDistance ? 0.5 : 1
        const adjustedDy = dy * resistance

        translateY.setValue(Math.max(0, adjustedDy))
        pullProgress.setValue(progress)

        // Update pull state
        if (dy > refreshThreshold && pullState !== "ready") {
          setPullState("ready")
          // Haptic feedback would go here
        } else if (dy <= refreshThreshold && pullState !== "pulling" && dy > 0) {
          setPullState("pulling")
        }

        // Scale animation for refresh indicator
        const scale = Math.min(progress * 1.5, 1)
        scaleValue.setValue(scale)
      },

      onPanResponderRelease: async (evt, gestureState) => {
        translateY.flattenOffset()

        if (gestureState.dy > refreshThreshold && !isRefreshing) {
          // Trigger refresh
          setIsRefreshing(true)
          setPullState("refreshing")
          startRotation()

          // Animate to refresh position
          Animated.spring(translateY, {
            toValue: refreshThreshold,
            tension: 100,
            friction: 8,
            useNativeDriver: true,
          }).start()

          try {
            await onRefresh()
          } finally {
            // Reset after refresh
            setIsRefreshing(false)
            setPullState("idle")
            stopRotation()

            Animated.parallel([
              Animated.spring(translateY, {
                toValue: 0,
                tension: 100,
                friction: 8,
                useNativeDriver: true,
              }),
              Animated.timing(pullProgress, {
                toValue: 0,
                duration: 300,
                useNativeDriver: false,
              }),
              Animated.timing(scaleValue, {
                toValue: 0,
                duration: 300,
                useNativeDriver: true,
              }),
            ]).start()
          }
        } else {
          // Snap back
          Animated.parallel([
            Animated.spring(translateY, {
              toValue: 0,
              tension: 100,
              friction: 8,
              useNativeDriver: true,
            }),
            Animated.timing(pullProgress, {
              toValue: 0,
              duration: 300,
              useNativeDriver: false,
            }),
            Animated.timing(scaleValue, {
              toValue: 0,
              duration: 300,
              useNativeDriver: true,
            }),
          ]).start(() => {
            setPullState("idle")
          })
        }
      },
    }),
  ).current

  // Interpolated values
  const rotate = rotateValue.interpolate({
    inputRange: [0, 1],
    outputRange: ["0deg", "360deg"],
  })

  const indicatorOpacity = pullProgress.interpolate({
    inputRange: [0, 0.3, 1],
    outputRange: [0, 0.5, 1],
    extrapolate: "clamp",
  })

  const arrowRotate = pullProgress.interpolate({
    inputRange: [0, 0.5, 1],
    outputRange: ["0deg", "90deg", "180deg"],
    extrapolate: "clamp",
  })

  const backgroundColor = pullProgress.interpolate({
    inputRange: [0, 0.5, 1],
    outputRange: colors,
    extrapolate: "clamp",
  })

  const getRefreshText = () => {
    switch (pullState) {
      case "pulling":
        return "Pull to refresh"
      case "ready":
        return "Release to refresh"
      case "refreshing":
        return "Refreshing..."
      default:
        return ""
    }
  }

  return (
    <View style={styles.container} {...panResponder.panHandlers}>
      {/* Refresh Indicator */}
      <Animated.View
        style={[
          styles.refreshIndicator,
          {
            opacity: indicatorOpacity,
            backgroundColor,
            transform: [{ scale: scaleValue }],
          },
        ]}
      >
        {pullState === "refreshing" ? (
          <Animated.View style={{ transform: [{ rotate }] }}>
            <Icon name="refresh" size={24} color="#FFFFFF" />
          </Animated.View>
        ) : (
          <Animated.View style={{ transform: [{ rotate: arrowRotate }] }}>
            <Icon name="keyboard-arrow-down" size={24} color="#FFFFFF" />
          </Animated.View>
        )}
        <Text style={styles.refreshText}>{getRefreshText()}</Text>
      </Animated.View>

      {/* Content */}
      <Animated.View
        style={[
          styles.content,
          {
            transform: [{ translateY }],
          },
        ]}
      >
        {children}
      </Animated.View>
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  refreshIndicator: {
    position: "absolute",
    top: -60,
    left: 0,
    right: 0,
    height: 60,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    borderRadius: 30,
    marginHorizontal: 20,
    zIndex: 1000,
  },
  refreshText: {
    color: "#FFFFFF",
    fontSize: 14,
    fontWeight: "600",
    marginLeft: 8,
  },
  content: {
    flex: 1,
  },
})
