"use client"

import type React from "react"
import { useRef, useState } from "react"
import { View, StyleSheet, Animated, PanResponder, Dimensions } from "react-native"

interface PinchZoomViewProps {
  children: React.ReactNode
  minScale?: number
  maxScale?: number
  initialScale?: number
  onZoomStart?: () => void
  onZoomEnd?: (scale: number) => void
  onZoomChange?: (scale: number) => void
  disabled?: boolean
}

const { width: screenWidth, height: screenHeight } = Dimensions.get("window")

export const PinchZoomView: React.FC<PinchZoomViewProps> = ({
  children,
  minScale = 0.5,
  maxScale = 3,
  initialScale = 1,
  onZoomStart,
  onZoomEnd,
  onZoomChange,
  disabled = false,
}) => {
  const [isZooming, setIsZooming] = useState(false)
  const [isPanning, setIsPanning] = useState(false)

  // Animation values
  const scale = useRef(new Animated.Value(initialScale)).current
  const translateX = useRef(new Animated.Value(0)).current
  const translateY = useRef(new Animated.Value(0)).current

  // Gesture state
  const lastScale = useRef(initialScale)
  const lastTranslateX = useRef(0)
  const lastTranslateY = useRef(0)

  const panResponder = useRef(
    PanResponder.create({
      onStartShouldSetPanResponder: () => !disabled,
      onMoveShouldSetPanResponder: () => !disabled,
      onPanResponderGrant: (evt) => {
        if (evt.nativeEvent.touches.length === 2) {
          // Pinch gesture
          setIsZooming(true)
          onZoomStart?.()
        } else if (evt.nativeEvent.touches.length === 1 && lastScale.current > 1) {
          // Pan gesture (only when zoomed in)
          setIsPanning(true)
          translateX.setOffset(lastTranslateX.current)
          translateY.setOffset(lastTranslateY.current)
          translateX.setValue(0)
          translateY.setValue(0)
        }
      },

      onPanResponderMove: (evt, gestureState) => {
        if (evt.nativeEvent.touches.length === 2) {
          // Handle pinch zoom
          const touch1 = evt.nativeEvent.touches[0]
          const touch2 = evt.nativeEvent.touches[1]

          const distance = Math.sqrt(
            Math.pow(touch2.pageX - touch1.pageX, 2) + Math.pow(touch2.pageY - touch1.pageY, 2),
          )

          // Calculate scale based on initial distance
          if (!gestureState.pinchDistance) {
            gestureState.pinchDistance = distance
            gestureState.initialScale = lastScale.current
          }

          const scaleChange = distance / gestureState.pinchDistance
          let newScale = gestureState.initialScale * scaleChange

          // Clamp scale
          newScale = Math.max(minScale, Math.min(maxScale, newScale))

          scale.setValue(newScale)
          onZoomChange?.(newScale)
        } else if (evt.nativeEvent.touches.length === 1 && isPanning) {
          // Handle pan
          const { dx, dy } = gestureState

          // Apply boundaries based on current scale
          const currentScale = lastScale.current
          const maxTranslateX = (screenWidth * (currentScale - 1)) / 2
          const maxTranslateY = (screenHeight * (currentScale - 1)) / 2

          const boundedDx = Math.max(-maxTranslateX, Math.min(maxTranslateX, dx))
          const boundedDy = Math.max(-maxTranslateY, Math.min(maxTranslateY, dy))

          translateX.setValue(boundedDx)
          translateY.setValue(boundedDy)
        }
      },

      onPanResponderRelease: (evt, gestureState) => {
        if (isZooming) {
          // End zoom
          setIsZooming(false)
          const currentScale = scale._value
          lastScale.current = currentScale

          // Snap to boundaries if needed
          if (currentScale < minScale) {
            Animated.spring(scale, {
              toValue: minScale,
              tension: 100,
              friction: 8,
              useNativeDriver: true,
            }).start()
            lastScale.current = minScale
          } else if (currentScale > maxScale) {
            Animated.spring(scale, {
              toValue: maxScale,
              tension: 100,
              friction: 8,
              useNativeDriver: true,
            }).start()
            lastScale.current = maxScale
          }

          // Reset position if zoomed out completely
          if (currentScale <= 1) {
            Animated.parallel([
              Animated.spring(translateX, {
                toValue: 0,
                tension: 100,
                friction: 8,
                useNativeDriver: true,
              }),
              Animated.spring(translateY, {
                toValue: 0,
                tension: 100,
                friction: 8,
                useNativeDriver: true,
              }),
            ]).start()
            lastTranslateX.current = 0
            lastTranslateY.current = 0
          }

          onZoomEnd?.(lastScale.current)
        }

        if (isPanning) {
          // End pan
          setIsPanning(false)
          translateX.flattenOffset()
          translateY.flattenOffset()
          lastTranslateX.current = translateX._value
          lastTranslateY.current = translateY._value
        }
      },
    }),
  ).current

  // Double tap to zoom
  const doubleTapRef = useRef<NodeJS.Timeout | null>(null)
  const handleDoubleTap = () => {
    if (doubleTapRef.current) {
      clearTimeout(doubleTapRef.current)
      doubleTapRef.current = null

      // Double tap detected - toggle zoom
      const targetScale = lastScale.current > 1 ? 1 : 2
      const targetTranslateX = targetScale === 1 ? 0 : lastTranslateX.current
      const targetTranslateY = targetScale === 1 ? 0 : lastTranslateY.current

      Animated.parallel([
        Animated.spring(scale, {
          toValue: targetScale,
          tension: 100,
          friction: 8,
          useNativeDriver: true,
        }),
        Animated.spring(translateX, {
          toValue: targetTranslateX,
          tension: 100,
          friction: 8,
          useNativeDriver: true,
        }),
        Animated.spring(translateY, {
          toValue: targetTranslateY,
          tension: 100,
          friction: 8,
          useNativeDriver: true,
        }),
      ]).start()

      lastScale.current = targetScale
      lastTranslateX.current = targetTranslateX
      lastTranslateY.current = targetTranslateY

      onZoomEnd?.(targetScale)
    } else {
      doubleTapRef.current = setTimeout(() => {
        doubleTapRef.current = null
      }, 300)
    }
  }

  return (
    <View style={styles.container} {...panResponder.panHandlers}>
      <Animated.View
        style={[
          styles.content,
          {
            transform: [{ scale }, { translateX }, { translateY }],
          },
        ]}
        onTouchEnd={handleDoubleTap}
      >
        {children}
      </Animated.View>

      {/* Zoom Indicator */}
      {(isZooming || isPanning) && (
        <View style={styles.zoomIndicator}>
          <View style={styles.indicatorContainer}>
            <View style={[styles.indicatorBar, { width: `${(lastScale.current / maxScale) * 100}%` }]} />
          </View>
        </View>
      )}
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    overflow: "hidden",
  },
  content: {
    flex: 1,
  },
  zoomIndicator: {
    position: "absolute",
    top: 20,
    right: 20,
    backgroundColor: "rgba(0, 0, 0, 0.7)",
    borderRadius: 20,
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  indicatorContainer: {
    width: 60,
    height: 4,
    backgroundColor: "rgba(255, 255, 255, 0.3)",
    borderRadius: 2,
  },
  indicatorBar: {
    height: "100%",
    backgroundColor: "#FFFFFF",
    borderRadius: 2,
  },
})
