import type React from "react"
import { View, StyleSheet } from "react-native"

interface ProgressBarProps {
  progress: number // 0-100
  height?: number
  backgroundColor?: string
  progressColor?: string
}

export const ProgressBar: React.FC<ProgressBarProps> = ({
  progress,
  height = 8,
  backgroundColor = "#E5E7EB",
  progressColor = "#8B5CF6",
}) => {
  return (
    <View style={[styles.container, { height, backgroundColor }]}>
      <View
        style={[
          styles.progress,
          {
            width: `${Math.min(100, Math.max(0, progress))}%`,
            backgroundColor: progressColor,
          },
        ]}
      />
    </View>
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
