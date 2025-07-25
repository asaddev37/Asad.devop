"use client"

import type React from "react"
import { useRef, useState } from "react"
import { View, Text, StyleSheet, Animated, PanResponder, Dimensions } from "react-native"
import Icon from "react-native-vector-icons/MaterialIcons"

interface SwipeToDeleteProps {
  children: React.ReactNode
  onDelete: () => void
  deleteThreshold?: number
  deleteText?: string
  deleteColor?: string
  disabled?: boolean
}

const { width: screenWidth } = Dimensions.get("window")

export const SwipeToDelete: React.FC<SwipeToDeleteProps> = ({
  children,
  onDelete,
  deleteThreshold = 120,
  deleteText = "Delete",
  deleteColor = "#EF4444",
  disabled = false,
}) => {
  const [isDeleting, setIsDeleting] = useState(false)
  const [deleteProgress, setDeleteProgress] = useState(0)

  const translateX = useRef(new Animated.Value(0)).current
  const deleteOpacity = useRef(new Animated.Value(0)).current
  const deleteScale = useRef(new Animated.Value(1)).current
  const contentOpacity = useRef(new Animated.Value(1)).current

  const panResponder = useRef(
    PanResponder.create({
      onMoveShouldSetPanResponder: (evt, gestureState) => {
        return !disabled && Math.abs(gestureState.dx) > Math.abs(gestureState.dy) && Math.abs(gestureState.dx) > 10
      },

      onPanResponderGrant: () => {
        translateX.setOffset(translateX._value)
        translateX.setValue(0)
      },

      onPanResponderMove: (evt, gestureState) => {
        const { dx } = gestureState

        // Only allow left swipe (negative dx)
        if (dx >= 0) {
          translateX.setValue(0)
          deleteOpacity.setValue(0)
          setDeleteProgress(0)
          return
        }

        const progress = Math.min(Math.abs(dx) / deleteThreshold, 1)
        const adjustedDx = dx * (progress > 0.8 ? 0.5 : 1) // Add resistance near threshold

        translateX.setValue(adjustedDx)
        deleteOpacity.setValue(progress)
        setDeleteProgress(progress)

        // Scale animation for delete icon
        if (progress > 0.8) {
          deleteScale.setValue(1.2)
        } else {
          deleteScale.setValue(1)
        }
      },

      onPanResponderRelease: (evt, gestureState) => {
        translateX.flattenOffset()

        const { dx, vx } = gestureState
        const shouldDelete = Math.abs(dx) > deleteThreshold || (Math.abs(vx) > 0.5 && dx < 0)

        if (shouldDelete && !isDeleting) {
          // Trigger delete animation
          setIsDeleting(true)

          Animated.parallel([
            Animated.timing(translateX, {
              toValue: -screenWidth,
              duration: 300,
              useNativeDriver: true,
            }),
            Animated.timing(contentOpacity, {
              toValue: 0,
              duration: 300,
              useNativeDriver: true,
            }),
            Animated.timing(deleteScale, {
              toValue: 1.5,
              duration: 300,
              useNativeDriver: true,
            }),
          ]).start(() => {
            onDelete()
          })
        } else {
          // Snap back
          Animated.parallel([
            Animated.spring(translateX, {
              toValue: 0,
              tension: 100,
              friction: 8,
              useNativeDriver: true,
            }),
            Animated.timing(deleteOpacity, {
              toValue: 0,
              duration: 200,
              useNativeDriver: true,
            }),
            Animated.timing(deleteScale, {
              toValue: 1,
              duration: 200,
              useNativeDriver: true,
            }),
          ]).start(() => {
            setDeleteProgress(0)
          })
        }
      },
    }),
  ).current

  return (
    <View style={styles.container}>
      {/* Delete Background */}
      <Animated.View
        style={[
          styles.deleteBackground,
          {
            backgroundColor: deleteColor,
            opacity: deleteOpacity,
          },
        ]}
      >
        <View style={styles.deleteContent}>
          <Animated.View
            style={{
              transform: [{ scale: deleteScale }],
            }}
          >
            <Icon name="delete" size={24} color="#FFFFFF" />
          </Animated.View>
          <Text style={styles.deleteText}>{deleteText}</Text>
        </View>

        {/* Progress Indicator */}
        <View style={styles.progressContainer}>
          <Animated.View
            style={[
              styles.progressBar,
              {
                width: `${deleteProgress * 100}%`,
                backgroundColor: deleteProgress > 0.8 ? "#FFFFFF" : "rgba(255, 255, 255, 0.5)",
              },
            ]}
          />
        </View>
      </Animated.View>

      {/* Content */}
      <Animated.View
        style={[
          styles.content,
          {
            opacity: contentOpacity,
            transform: [{ translateX }],
          },
        ]}
        {...panResponder.panHandlers}
      >
        {children}
      </Animated.View>

      {/* Swipe Hint */}
      {!isDeleting && deleteProgress === 0 && (
        <View style={styles.swipeHint}>
          <Icon name="keyboard-arrow-left" size={16} color="#9CA3AF" />
          <Text style={styles.hintText}>Swipe left to delete</Text>
        </View>
      )}
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    position: "relative",
    overflow: "hidden",
  },
  deleteBackground: {
    position: "absolute",
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    justifyContent: "center",
    alignItems: "flex-end",
    paddingRight: 20,
  },
  deleteContent: {
    alignItems: "center",
  },
  deleteText: {
    color: "#FFFFFF",
    fontSize: 12,
    fontWeight: "600",
    marginTop: 4,
  },
  progressContainer: {
    position: "absolute",
    bottom: 0,
    left: 0,
    right: 0,
    height: 2,
  },
  progressBar: {
    height: "100%",
  },
  content: {
    backgroundColor: "#FFFFFF",
    zIndex: 1,
  },
  swipeHint: {
    position: "absolute",
    top: "50%",
    right: 10,
    flexDirection: "row",
    alignItems: "center",
    opacity: 0.5,
    transform: [{ translateY: -10 }],
  },
  hintText: {
    fontSize: 10,
    color: "#9CA3AF",
    marginLeft: 2,
  },
})
