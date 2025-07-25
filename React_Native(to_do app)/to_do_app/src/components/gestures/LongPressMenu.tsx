"use client"

import type React from "react"
import { useRef, useState } from "react"
import { View, Text, StyleSheet, Animated, TouchableWithoutFeedback, Dimensions } from "react-native"
import Icon from "react-native-vector-icons/MaterialIcons"

interface MenuAction {
  id: string
  title: string
  icon: string
  color?: string
  onPress: () => void
}

interface LongPressMenuProps {
  children: React.ReactNode
  actions: MenuAction[]
  onLongPress?: () => void
  longPressDuration?: number
  disabled?: boolean
}

const { width: screenWidth, height: screenHeight } = Dimensions.get("window")

export const LongPressMenu: React.FC<LongPressMenuProps> = ({
  children,
  actions,
  onLongPress,
  longPressDuration = 500,
  disabled = false,
}) => {
  const [isMenuVisible, setIsMenuVisible] = useState(false)
  const [menuPosition, setMenuPosition] = useState({ x: 0, y: 0 })

  // Animation values
  const scaleAnim = useRef(new Animated.Value(1)).current
  const menuOpacity = useRef(new Animated.Value(0)).current
  const menuScale = useRef(new Animated.Value(0.8)).current
  const progressAnim = useRef(new Animated.Value(0)).current

  // Long press timer
  const longPressTimer = useRef<NodeJS.Timeout | null>(null)
  const progressTimer = useRef<NodeJS.Timeout | null>(null)

  const startLongPress = (event: any) => {
    if (disabled) return

    const { pageX, pageY } = event.nativeEvent

    // Calculate menu position
    const menuX = Math.min(pageX, screenWidth - 200)
    const menuY = Math.max(60, Math.min(pageY - 100, screenHeight - actions.length * 50 - 100))

    setMenuPosition({ x: menuX, y: menuY })

    // Start press animation
    Animated.spring(scaleAnim, {
      toValue: 0.95,
      tension: 300,
      friction: 10,
      useNativeDriver: true,
    }).start()

    // Start progress animation
    Animated.timing(progressAnim, {
      toValue: 1,
      duration: longPressDuration,
      useNativeDriver: false,
    }).start()

    // Set long press timer
    longPressTimer.current = setTimeout(() => {
      triggerLongPress()
    }, longPressDuration)
  }

  const cancelLongPress = () => {
    if (longPressTimer.current) {
      clearTimeout(longPressTimer.current)
      longPressTimer.current = null
    }

    // Reset animations
    Animated.parallel([
      Animated.spring(scaleAnim, {
        toValue: 1,
        tension: 300,
        friction: 10,
        useNativeDriver: true,
      }),
      Animated.timing(progressAnim, {
        toValue: 0,
        duration: 200,
        useNativeDriver: false,
      }),
    ]).start()
  }

  const triggerLongPress = () => {
    onLongPress?.()
    setIsMenuVisible(true)

    // Show menu with animation
    Animated.parallel([
      Animated.timing(menuOpacity, {
        toValue: 1,
        duration: 200,
        useNativeDriver: true,
      }),
      Animated.spring(menuScale, {
        toValue: 1,
        tension: 300,
        friction: 10,
        useNativeDriver: true,
      }),
    ]).start()

    // Reset scale
    Animated.spring(scaleAnim, {
      toValue: 1,
      tension: 300,
      friction: 10,
      useNativeDriver: true,
    }).start()
  }

  const hideMenu = () => {
    Animated.parallel([
      Animated.timing(menuOpacity, {
        toValue: 0,
        duration: 150,
        useNativeDriver: true,
      }),
      Animated.spring(menuScale, {
        toValue: 0.8,
        tension: 300,
        friction: 10,
        useNativeDriver: true,
      }),
    ]).start(() => {
      setIsMenuVisible(false)
    })
  }

  const handleActionPress = (action: MenuAction) => {
    hideMenu()
    setTimeout(() => {
      action.onPress()
    }, 100)
  }

  // Progress circle
  const progressCircle = progressAnim.interpolate({
    inputRange: [0, 1],
    outputRange: ["0deg", "360deg"],
  })

  return (
    <>
      <TouchableWithoutFeedback
        onPressIn={startLongPress}
        onPressOut={cancelLongPress}
        onLongPress={() => {}} // Prevent default long press
      >
        <Animated.View
          style={[
            styles.container,
            {
              transform: [{ scale: scaleAnim }],
            },
          ]}
        >
          {children}

          {/* Progress Indicator */}
          <Animated.View
            style={[
              styles.progressIndicator,
              {
                opacity: progressAnim.interpolate({
                  inputRange: [0, 0.1, 1],
                  outputRange: [0, 1, 0],
                }),
              },
            ]}
          >
            <Animated.View
              style={[
                styles.progressCircle,
                {
                  transform: [{ rotate: progressCircle }],
                },
              ]}
            />
          </Animated.View>
        </Animated.View>
      </TouchableWithoutFeedback>

      {/* Menu Overlay */}
      {isMenuVisible && (
        <View style={styles.overlay}>
          <TouchableWithoutFeedback onPress={hideMenu}>
            <View style={styles.overlayBackground} />
          </TouchableWithoutFeedback>

          <Animated.View
            style={[
              styles.menu,
              {
                left: menuPosition.x,
                top: menuPosition.y,
                opacity: menuOpacity,
                transform: [{ scale: menuScale }],
              },
            ]}
          >
            {actions.map((action, index) => (
              <TouchableWithoutFeedback key={action.id} onPress={() => handleActionPress(action)}>
                <Animated.View
                  style={[
                    styles.menuItem,
                    {
                      opacity: menuOpacity,
                      transform: [
                        {
                          translateY: menuOpacity.interpolate({
                            inputRange: [0, 1],
                            outputRange: [20, 0],
                          }),
                        },
                      ],
                    },
                  ]}
                >
                  <Icon name={action.icon} size={20} color={action.color || "#1F2937"} />
                  <Text style={[styles.menuItemText, { color: action.color || "#1F2937" }]}>{action.title}</Text>
                </Animated.View>
              </TouchableWithoutFeedback>
            ))}
          </Animated.View>
        </View>
      )}
    </>
  )
}

const styles = StyleSheet.create({
  container: {
    position: "relative",
  },
  progressIndicator: {
    position: "absolute",
    top: -5,
    left: -5,
    right: -5,
    bottom: -5,
    borderRadius: 50,
    borderWidth: 2,
    borderColor: "transparent",
  },
  progressCircle: {
    flex: 1,
    borderRadius: 50,
    borderWidth: 2,
    borderColor: "#8B5CF6",
    borderTopColor: "transparent",
    borderRightColor: "transparent",
  },
  overlay: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    zIndex: 1000,
  },
  overlayBackground: {
    flex: 1,
    backgroundColor: "rgba(0, 0, 0, 0.3)",
  },
  menu: {
    position: "absolute",
    backgroundColor: "#FFFFFF",
    borderRadius: 12,
    paddingVertical: 8,
    minWidth: 180,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  menuItem: {
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 16,
    paddingVertical: 12,
  },
  menuItemText: {
    fontSize: 16,
    fontWeight: "500",
    marginLeft: 12,
  },
})
