"use client"

import type React from "react"
import { useState, useRef, useEffect } from "react"
import { View, Text, TouchableOpacity, StyleSheet, Alert, Animated, PanGestureHandler, State } from "react-native"
import type { PanGestureHandlerGestureEvent, PanGestureHandlerStateChangeEvent } from "react-native-gesture-handler"
import Icon from "react-native-vector-icons/MaterialIcons"
import type { Task } from "../types"
import { useTaskStore } from "../store/taskStore"
import { format } from "date-fns"
import { getRecurringPatternDescription } from "../utils/recurringUtils"
import { AnimationConfig } from "../animations/AnimationConfig"

interface AnimatedTaskItemProps {
  task: Task
  onEdit: (task: Task) => void
  index: number
}

export const AnimatedTaskItem: React.FC<AnimatedTaskItemProps> = ({ task, onEdit, index }) => {
  const { toggleTask, deleteTask, deleteRecurringSeries, categories } = useTaskStore()
  const [isDeleting, setIsDeleting] = useState(false)

  // Animation values
  const translateX = useRef(new Animated.Value(0)).current
  const scale = useRef(new Animated.Value(1)).current
  const opacity = useRef(new Animated.Value(0)).current
  const checkboxScale = useRef(new Animated.Value(1)).current

  const category = categories.find((c) => c.id === task.category)
  const isOverdue = task.dueDate && new Date(task.dueDate) < new Date() && !task.completed

  // Entrance animation
  useEffect(() => {
    Animated.parallel([
      Animated.timing(opacity, {
        toValue: 1,
        duration: AnimationConfig.listItem.duration,
        delay: index * AnimationConfig.listItem.stagger,
        easing: AnimationConfig.listItem.easing,
        useNativeDriver: true,
      }),
      Animated.spring(scale, {
        toValue: 1,
        delay: index * AnimationConfig.listItem.stagger,
        tension: AnimationConfig.spring.tension,
        friction: AnimationConfig.spring.friction,
        useNativeDriver: true,
      }),
    ]).start()
  }, [index])

  const handleDelete = () => {
    Alert.alert("Delete Task", "Are you sure you want to delete this task?", [
      { text: "Cancel", style: "cancel" },
      {
        text: "Delete",
        style: "destructive",
        onPress: () => {
          setIsDeleting(true)

          // Exit animation
          Animated.parallel([
            Animated.timing(scale, {
              toValue: 0.8,
              duration: AnimationConfig.buttonPress.duration,
              useNativeDriver: true,
            }),
            Animated.timing(opacity, {
              toValue: 0,
              duration: AnimationConfig.buttonPress.duration,
              useNativeDriver: true,
            }),
          ]).start(() => {
            deleteTask(task.id)
          })
        },
      },
    ])
  }

  const handleDeleteSeries = () => {
    Alert.alert("Delete Recurring Series", "Delete this recurring task and all future occurrences?", [
      { text: "Cancel", style: "cancel" },
      {
        text: "Delete Series",
        style: "destructive",
        onPress: () => {
          setIsDeleting(true)

          Animated.parallel([
            Animated.timing(scale, {
              toValue: 0.8,
              duration: AnimationConfig.buttonPress.duration,
              useNativeDriver: true,
            }),
            Animated.timing(opacity, {
              toValue: 0,
              duration: AnimationConfig.buttonPress.duration,
              useNativeDriver: true,
            }),
          ]).start(() => {
            deleteRecurringSeries(task.parentTaskId || task.id)
          })
        },
      },
    ])
  }

  const handleToggleTask = () => {
    // Checkbox animation
    Animated.sequence([
      Animated.timing(checkboxScale, {
        toValue: 1.3,
        duration: 100,
        useNativeDriver: true,
      }),
      Animated.timing(checkboxScale, {
        toValue: 1,
        duration: 100,
        useNativeDriver: true,
      }),
    ]).start()

    toggleTask(task.id)
  }

  const showActionSheet = () => {
    // Scale animation for press feedback
    Animated.sequence([
      Animated.timing(scale, {
        toValue: 0.98,
        duration: 50,
        useNativeDriver: true,
      }),
      Animated.timing(scale, {
        toValue: 1,
        duration: 50,
        useNativeDriver: true,
      }),
    ]).start()

    const options = ["Edit", "Delete"]
    if (task.isRecurring) {
      options.splice(1, 0, "Delete Series")
    }
    options.push("Cancel")

    Alert.alert("Task Actions", "Choose an action", [
      { text: "Edit", onPress: () => onEdit(task) },
      ...(task.isRecurring
        ? [{ text: "Delete Series", onPress: handleDeleteSeries, style: "destructive" as const }]
        : []),
      { text: "Delete", onPress: handleDelete, style: "destructive" as const },
      { text: "Cancel", style: "cancel" },
    ])
  }

  // Swipe gesture handling
  const onGestureEvent = (event: PanGestureHandlerGestureEvent) => {
    translateX.setValue(event.nativeEvent.translationX)
  }

  const onHandlerStateChange = (event: PanGestureHandlerStateChangeEvent) => {
    if (event.nativeEvent.state === State.END) {
      const { translationX, velocityX } = event.nativeEvent

      // Swipe right to complete
      if (translationX > 100 || velocityX > 500) {
        Animated.timing(translateX, {
          toValue: 300,
          duration: 200,
          useNativeDriver: true,
        }).start(() => {
          handleToggleTask()
          translateX.setValue(0)
        })
      }
      // Swipe left to delete
      else if (translationX < -100 || velocityX < -500) {
        Animated.timing(translateX, {
          toValue: -300,
          duration: 200,
          useNativeDriver: true,
        }).start(() => {
          handleDelete()
        })
      }
      // Snap back
      else {
        Animated.spring(translateX, {
          toValue: 0,
          tension: AnimationConfig.spring.tension,
          friction: AnimationConfig.spring.friction,
          useNativeDriver: true,
        }).start()
      }
    }
  }

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case "high":
        return "#EF4444"
      case "medium":
        return "#F59E0B"
      case "low":
        return "#10B981"
      default:
        return "#6B7280"
    }
  }

  return (
    <PanGestureHandler
      onGestureEvent={onGestureEvent}
      onHandlerStateChange={onHandlerStateChange}
      activeOffsetX={[-10, 10]}
    >
      <Animated.View
        style={[
          styles.container,
          {
            opacity,
            transform: [{ scale }, { translateX }],
          },
          task.completed && styles.completed,
        ]}
      >
        {/* Swipe Actions Background */}
        <View style={styles.swipeActionsContainer}>
          <View style={styles.completeAction}>
            <Icon name="check" size={24} color="#FFFFFF" />
            <Text style={styles.actionText}>Complete</Text>
          </View>
          <View style={styles.deleteAction}>
            <Icon name="delete" size={24} color="#FFFFFF" />
            <Text style={styles.actionText}>Delete</Text>
          </View>
        </View>

        <View style={styles.content}>
          <Animated.View style={{ transform: [{ scale: checkboxScale }] }}>
            <TouchableOpacity style={styles.checkbox} onPress={handleToggleTask}>
              <Icon
                name={task.completed ? "check-box" : "check-box-outline-blank"}
                size={24}
                color={task.completed ? "#10B981" : "#6B7280"}
              />
            </TouchableOpacity>
          </Animated.View>

          <View style={styles.taskContent}>
            <View style={styles.header}>
              <View style={styles.titleRow}>
                <Text style={[styles.title, task.completed && styles.completedText]}>{task.title}</Text>
                {task.isRecurring && <Icon name="repeat" size={16} color="#3B82F6" />}
              </View>

              <TouchableOpacity onPress={showActionSheet}>
                <Icon name="more-vert" size={20} color="#6B7280" />
              </TouchableOpacity>
            </View>

            {task.description && (
              <Text style={styles.description} numberOfLines={2}>
                {task.description}
              </Text>
            )}

            {task.isRecurring && task.recurringPattern && (
              <Text style={styles.recurringText}>{getRecurringPatternDescription(task.recurringPattern)}</Text>
            )}

            <View style={styles.metadata}>
              <View style={styles.priority}>
                <View style={[styles.priorityDot, { backgroundColor: getPriorityColor(task.priority) }]} />
                <Text style={styles.priorityText}>{task.priority}</Text>
              </View>

              {category && (
                <View style={styles.category}>
                  <Text style={styles.categoryIcon}>{category.icon}</Text>
                  <Text style={styles.categoryText}>{category.name}</Text>
                </View>
              )}

              {task.dueDate && (
                <View style={styles.dueDate}>
                  <Icon name="event" size={12} color={isOverdue ? "#EF4444" : "#6B7280"} />
                  <Text style={[styles.dueDateText, isOverdue && styles.overdueText]}>
                    {format(new Date(task.dueDate), "MMM d")}
                  </Text>
                </View>
              )}
            </View>
          </View>
        </View>
      </Animated.View>
    </PanGestureHandler>
  )
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: "#FFFFFF",
    borderRadius: 12,
    marginVertical: 4,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
    overflow: "hidden",
  },
  completed: {
    opacity: 0.75,
  },
  swipeActionsContainer: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    flexDirection: "row",
    justifyContent: "space-between",
  },
  completeAction: {
    backgroundColor: "#10B981",
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
  },
  deleteAction: {
    backgroundColor: "#EF4444",
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
  },
  actionText: {
    color: "#FFFFFF",
    fontSize: 12,
    fontWeight: "600",
    marginTop: 4,
  },
  content: {
    flexDirection: "row",
    alignItems: "flex-start",
    padding: 16,
    backgroundColor: "#FFFFFF",
  },
  checkbox: {
    marginRight: 12,
    marginTop: 2,
  },
  taskContent: {
    flex: 1,
  },
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "flex-start",
    marginBottom: 4,
  },
  titleRow: {
    flexDirection: "row",
    alignItems: "center",
    flex: 1,
    marginRight: 8,
  },
  title: {
    fontSize: 16,
    fontWeight: "600",
    color: "#1F2937",
    marginRight: 8,
    flex: 1,
  },
  completedText: {
    textDecorationLine: "line-through",
    color: "#6B7280",
  },
  description: {
    fontSize: 14,
    color: "#6B7280",
    marginBottom: 8,
    lineHeight: 20,
  },
  recurringText: {
    fontSize: 12,
    color: "#3B82F6",
    marginBottom: 8,
  },
  metadata: {
    flexDirection: "row",
    alignItems: "center",
    flexWrap: "wrap",
    gap: 12,
  },
  priority: {
    flexDirection: "row",
    alignItems: "center",
  },
  priorityDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    marginRight: 4,
  },
  priorityText: {
    fontSize: 12,
    color: "#6B7280",
    textTransform: "capitalize",
  },
  category: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "#F3F4F6",
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
  },
  categoryIcon: {
    fontSize: 12,
    marginRight: 4,
  },
  categoryText: {
    fontSize: 12,
    color: "#374151",
  },
  dueDate: {
    flexDirection: "row",
    alignItems: "center",
  },
  dueDateText: {
    fontSize: 12,
    color: "#6B7280",
    marginLeft: 4,
  },
  overdueText: {
    color: "#EF4444",
  },
})
