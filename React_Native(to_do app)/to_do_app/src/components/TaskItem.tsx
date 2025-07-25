"use client"

import type React from "react"
import { useState } from "react"
import { View, Text, TouchableOpacity, StyleSheet, Alert } from "react-native"
import Icon from "react-native-vector-icons/MaterialIcons"
import type { Task } from "../types"
import { useTaskStore } from "../store/taskStore"
import { format } from "date-fns"
import { getRecurringPatternDescription } from "../utils/recurringUtils"

interface TaskItemProps {
  task: Task
  onEdit: (task: Task) => void
}

export const TaskItem: React.FC<TaskItemProps> = ({ task, onEdit }) => {
  const { toggleTask, deleteTask, deleteRecurringSeries, categories } = useTaskStore()
  const [isDeleting, setIsDeleting] = useState(false)

  const category = categories.find((c) => c.id === task.category)
  const isOverdue = task.dueDate && new Date(task.dueDate) < new Date() && !task.completed

  const handleDelete = () => {
    Alert.alert("Delete Task", "Are you sure you want to delete this task?", [
      { text: "Cancel", style: "cancel" },
      {
        text: "Delete",
        style: "destructive",
        onPress: () => {
          setIsDeleting(true)
          setTimeout(() => {
            deleteTask(task.id)
          }, 150)
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
          setTimeout(() => {
            deleteRecurringSeries(task.parentTaskId || task.id)
          }, 150)
        },
      },
    ])
  }

  const showActionSheet = () => {
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
    <View style={[styles.container, isDeleting && styles.deleting, task.completed && styles.completed]}>
      <View style={styles.content}>
        <TouchableOpacity style={styles.checkbox} onPress={() => toggleTask(task.id)}>
          <Icon
            name={task.completed ? "check-box" : "check-box-outline-blank"}
            size={24}
            color={task.completed ? "#10B981" : "#6B7280"}
          />
        </TouchableOpacity>

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
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: "#FFFFFF",
    borderRadius: 12,
    padding: 16,
    marginVertical: 4,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  deleting: {
    opacity: 0.5,
    transform: [{ scale: 0.95 }],
  },
  completed: {
    opacity: 0.75,
  },
  content: {
    flexDirection: "row",
    alignItems: "flex-start",
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
