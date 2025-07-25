"use client"

import type React from "react"
import { useRef, useState } from "react"
import { View, Text, StyleSheet, Animated, PanResponder, Dimensions, TouchableOpacity } from "react-native"
import Icon from "react-native-vector-icons/MaterialIcons"

interface SwipeAction {
  id: string
  title: string
  icon: string
  color: string
  backgroundColor: string
  onPress: () => void
}

interface SwipeableRowProps {
  children: React.ReactNode
  leftActions?: SwipeAction[]
  rightActions?: SwipeAction[]
  swipeThreshold?: number
  maxSwipeDistance?: number
  onSwipeStart?: () => void
  onSwipeEnd?: () => void
}

const { width: screenWidth } = Dimensions.get("window")

export const SwipeableRow: React.FC<SwipeableRowProps> = ({
  children,
  leftActions = [],
  rightActions = [],
  swipeThreshold = 80,
  maxSwipeDistance = 200,
  onSwipeStart,
  onSwipeEnd,
}) => {
  const [isSwipeActive, setIsSwipeActive] = useState(false)
  const [activeAction, setActiveAction] = useState<SwipeAction | null>(null)

  const translateX = useRef(new Animated.Value(0)).current
  const leftActionOpacity = useRef(new Animated.Value(0)).current
  const rightActionOpacity = useRef(new Animated.Value(0)).current
  const actionScale = useRef(new Animated.Value(1)).current

  const panResponder = useRef(
    PanResponder.create({
      onMoveShouldSetPanResponder: (evt, gestureState) => {
        return Math.abs(gestureState.dx) > Math.abs(gestureState.dy) && Math.abs(gestureState.dx) > 10
      },

      onPanResponderGrant: () => {
        setIsSwipeActive(true)
        onSwipeStart?.()
        translateX.setOffset(translateX._value)
        translateX.setValue(0)
      },

      onPanResponderMove: (evt, gestureState) => {
        const { dx } = gestureState
        const progress = Math.abs(dx) / maxSwipeDistance

        // Apply resistance for over-swipe
        let adjustedDx = dx
        if (Math.abs(dx) > maxSwipeDistance) {
          const resistance = 0.3
          const overSwipe = Math.abs(dx) - maxSwipeDistance
          adjustedDx = dx > 0 ? maxSwipeDistance + overSwipe * resistance : -maxSwipeDistance - overSwipe * resistance
        }

        translateX.setValue(adjustedDx)

        // Animate action visibility
        if (dx > 0 && leftActions.length > 0) {
          leftActionOpacity.setValue(Math.min(progress, 1))
          rightActionOpacity.setValue(0)

          // Determine active action
          const actionIndex = Math.min(
            Math.floor(Math.abs(dx) / (maxSwipeDistance / leftActions.length)),
            leftActions.length - 1,
          )
          setActiveAction(leftActions[actionIndex])
        } else if (dx < 0 && rightActions.length > 0) {
          rightActionOpacity.setValue(Math.min(progress, 1))
          leftActionOpacity.setValue(0)

          // Determine active action
          const actionIndex = Math.min(
            Math.floor(Math.abs(dx) / (maxSwipeDistance / rightActions.length)),
            rightActions.length - 1,
          )
          setActiveAction(rightActions[actionIndex])
        } else {
          leftActionOpacity.setValue(0)
          rightActionOpacity.setValue(0)
          setActiveAction(null)
        }

        // Scale animation for active action
        if (Math.abs(dx) > swipeThreshold) {
          actionScale.setValue(1.1)
        } else {
          actionScale.setValue(1)
        }
      },

      onPanResponderRelease: (evt, gestureState) => {
        translateX.flattenOffset()
        setIsSwipeActive(false)
        onSwipeEnd?.()

        const { dx, vx } = gestureState
        const shouldTriggerAction = Math.abs(dx) > swipeThreshold || Math.abs(vx) > 0.5

        if (shouldTriggerAction && activeAction) {
          // Animate to action position and trigger
          const targetX = dx > 0 ? maxSwipeDistance : -maxSwipeDistance

          Animated.parallel([
            Animated.spring(translateX, {
              toValue: targetX,
              tension: 100,
              friction: 8,
              useNativeDriver: true,
            }),
            Animated.timing(actionScale, {
              toValue: 1.2,
              duration: 150,
              useNativeDriver: true,
            }),
          ]).start(() => {
            // Trigger action
            activeAction.onPress()

            // Reset
            setTimeout(() => {
              resetPosition()
            }, 100)
          })
        } else {
          // Snap back
          resetPosition()
        }
      },
    }),
  ).current

  const resetPosition = () => {
    Animated.parallel([
      Animated.spring(translateX, {
        toValue: 0,
        tension: 100,
        friction: 8,
        useNativeDriver: true,
      }),
      Animated.timing(leftActionOpacity, {
        toValue: 0,
        duration: 200,
        useNativeDriver: true,
      }),
      Animated.timing(rightActionOpacity, {
        toValue: 0,
        duration: 200,
        useNativeDriver: true,
      }),
      Animated.timing(actionScale, {
        toValue: 1,
        duration: 200,
        useNativeDriver: true,
      }),
    ]).start(() => {
      setActiveAction(null)
    })
  }

  const renderActions = (actions: SwipeAction[], side: "left" | "right", opacity: Animated.AnimatedValue) => {
    if (actions.length === 0) return null

    return (
      <Animated.View
        style={[styles.actionsContainer, side === "left" ? styles.leftActions : styles.rightActions, { opacity }]}
      >
        {actions.map((action, index) => (
          <Animated.View
            key={action.id}
            style={[
              styles.actionButton,
              {
                backgroundColor: action.backgroundColor,
                transform: [{ scale: activeAction?.id === action.id ? actionScale : 1 }],
              },
            ]}
          >
            <TouchableOpacity
              style={styles.actionTouchable}
              onPress={() => {
                action.onPress()
                resetPosition()
              }}
              activeOpacity={0.8}
            >
              <Icon name={action.icon} size={24} color={action.color} />
              <Text style={[styles.actionText, { color: action.color }]}>{action.title}</Text>
            </TouchableOpacity>
          </Animated.View>
        ))}
      </Animated.View>
    )
  }

  return (
    <View style={styles.container}>
      {/* Left Actions */}
      {renderActions(leftActions, "left", leftActionOpacity)}

      {/* Right Actions */}
      {renderActions(rightActions, "right", rightActionOpacity)}

      {/* Main Content */}
      <Animated.View
        style={[
          styles.content,
          {
            transform: [{ translateX }],
          },
        ]}
        {...panResponder.panHandlers}
      >
        {children}
      </Animated.View>

      {/* Swipe Indicator */}
      {isSwipeActive && (
        <View style={styles.swipeIndicator}>
          <View style={[styles.indicatorDot, { backgroundColor: activeAction?.backgroundColor || "#8B5CF6" }]} />
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
  content: {
    backgroundColor: "#FFFFFF",
    zIndex: 1,
  },
  actionsContainer: {
    position: "absolute",
    top: 0,
    bottom: 0,
    flexDirection: "row",
    alignItems: "center",
    zIndex: 0,
  },
  leftActions: {
    left: 0,
    justifyContent: "flex-start",
  },
  rightActions: {
    right: 0,
    justifyContent: "flex-end",
  },
  actionButton: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    minWidth: 80,
    height: "100%",
  },
  actionTouchable: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    width: "100%",
  },
  actionText: {
    fontSize: 12,
    fontWeight: "600",
    marginTop: 4,
  },
  swipeIndicator: {
    position: "absolute",
    top: "50%",
    left: "50%",
    transform: [{ translateX: -4 }, { translateY: -4 }],
    zIndex: 2,
  },
  indicatorDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
  },
})
