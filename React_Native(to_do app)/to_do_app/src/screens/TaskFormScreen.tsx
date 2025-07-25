"use client"

import type React from "react"
import { useState, useEffect } from "react"
import {
  View,
  Text,
  ScrollView,
  StyleSheet,
  TextInput,
  TouchableOpacity,
  Alert,
  KeyboardAvoidingView,
  Platform,
} from "react-native"
import { SafeAreaView } from "react-native-safe-area-context"
import Icon from "react-native-vector-icons/MaterialIcons"
import DateTimePicker from "@react-native-community/datetimepicker"
import { useNavigation, useRoute } from "@react-navigation/native"

import { PrioritySelector } from "../components/PrioritySelector"
import { CategorySelector } from "../components/CategorySelector"
import { RecurringFormNative } from "../components/RecurringFormNative"
import { NotificationSettingsNative } from "../components/NotificationSettingsNative"
import { useTaskStore } from "../store/taskStore"
import type { Task, RecurringPattern, NotificationSettings } from "../types"

export const TaskFormScreen: React.FC = () => {
  const navigation = useNavigation()
  const route = useRoute()
  const { addTask, updateTask, categories } = useTaskStore()

  // Get task from route params if editing
  const task = route.params?.task as Task | undefined
  const defaultDate = route.params?.defaultDate as string | undefined

  const [formData, setFormData] = useState({
    title: "",
    description: "",
    priority: "medium" as "low" | "medium" | "high",
    category: "",
    dueDate: "",
    isRecurring: false,
    recurringPattern: undefined as RecurringPattern | undefined,
    notifications: undefined as NotificationSettings | undefined,
  })

  const [showDatePicker, setShowDatePicker] = useState(false)
  const [isSubmitting, setIsSubmitting] = useState(false)

  useEffect(() => {
    if (task) {
      // Editing existing task
      setFormData({
        title: task.title,
        description: task.description || "",
        priority: task.priority,
        category: task.category,
        dueDate: task.dueDate ? task.dueDate.split("T")[0] : "",
        isRecurring: task.isRecurring,
        recurringPattern: task.recurringPattern,
        notifications: task.notifications,
      })
    } else {
      // Creating new task
      setFormData({
        title: "",
        description: "",
        priority: "medium",
        category: categories[0]?.id || "",
        dueDate: defaultDate || "",
        isRecurring: false,
        recurringPattern: undefined,
        notifications: {
          enabled: false,
          reminders: [],
        },
      })
    }
  }, [task, categories, defaultDate])

  const handleSubmit = async () => {
    if (!formData.title.trim()) {
      Alert.alert("Error", "Please enter a task title.")
      return
    }

    if (!formData.category) {
      Alert.alert("Error", "Please select a category.")
      return
    }

    setIsSubmitting(true)

    try {
      const taskData = {
        title: formData.title.trim(),
        description: formData.description.trim(),
        priority: formData.priority,
        category: formData.category,
        dueDate: formData.dueDate || undefined,
        completed: task?.completed || false,
        isRecurring: formData.isRecurring,
        recurringPattern: formData.isRecurring ? formData.recurringPattern : undefined,
        notifications: formData.notifications,
      }

      if (task) {
        updateTask(task.id, taskData)
      } else {
        addTask(taskData)
      }

      navigation.goBack()
    } catch (error) {
      Alert.alert("Error", "Failed to save task. Please try again.")
    } finally {
      setIsSubmitting(false)
    }
  }

  const handleDateChange = (event: any, selectedDate?: Date) => {
    setShowDatePicker(false)
    if (selectedDate) {
      setFormData({
        ...formData,
        dueDate: selectedDate.toISOString().split("T")[0],
      })
    }
  }

  const handleRecurringChange = (pattern: RecurringPattern | undefined) => {
    setFormData({
      ...formData,
      isRecurring: !!pattern,
      recurringPattern: pattern,
    })
  }

  const handleNotificationChange = (notifications: NotificationSettings | undefined) => {
    setFormData({
      ...formData,
      notifications,
    })
  }

  const clearDueDate = () => {
    setFormData({
      ...formData,
      dueDate: "",
    })
  }

  return (
    <SafeAreaView style={styles.container}>
      <KeyboardAvoidingView style={styles.keyboardAvoid} behavior={Platform.OS === "ios" ? "padding" : "height"}>
        {/* Header */}
        <View style={styles.header}>
          <TouchableOpacity onPress={() => navigation.goBack()} style={styles.headerButton}>
            <Icon name="close" size={24} color="#1F2937" />
          </TouchableOpacity>
          <Text style={styles.headerTitle}>{task ? "Edit Task" : "Add New Task"}</Text>
          <TouchableOpacity
            onPress={handleSubmit}
            style={[styles.headerButton, styles.saveButton]}
            disabled={isSubmitting}
          >
            <Text style={styles.saveButtonText}>{isSubmitting ? "Saving..." : "Save"}</Text>
          </TouchableOpacity>
        </View>

        <ScrollView style={styles.scrollView} showsVerticalScrollIndicator={false}>
          {/* Title Input */}
          <View style={styles.inputContainer}>
            <Text style={styles.inputLabel}>Title *</Text>
            <TextInput
              style={styles.textInput}
              placeholder="Enter task title"
              value={formData.title}
              onChangeText={(text) => setFormData({ ...formData, title: text })}
              placeholderTextColor="#9CA3AF"
              autoFocus={!task}
            />
          </View>

          {/* Description Input */}
          <View style={styles.inputContainer}>
            <Text style={styles.inputLabel}>Description</Text>
            <TextInput
              style={[styles.textInput, styles.textArea]}
              placeholder="Enter task description (optional)"
              value={formData.description}
              onChangeText={(text) => setFormData({ ...formData, description: text })}
              placeholderTextColor="#9CA3AF"
              multiline
              numberOfLines={3}
              textAlignVertical="top"
            />
          </View>

          {/* Priority and Category */}
          <View style={styles.row}>
            <View style={styles.halfWidth}>
              <Text style={styles.inputLabel}>Priority</Text>
              <PrioritySelector
                value={formData.priority}
                onChange={(priority) => setFormData({ ...formData, priority })}
              />
            </View>

            <View style={styles.halfWidth}>
              <Text style={styles.inputLabel}>Category</Text>
              <CategorySelector
                value={formData.category}
                onChange={(category) => setFormData({ ...formData, category })}
                categories={categories}
              />
            </View>
          </View>

          {/* Due Date */}
          <View style={styles.inputContainer}>
            <Text style={styles.inputLabel}>Due Date</Text>
            <TouchableOpacity style={styles.dateButton} onPress={() => setShowDatePicker(true)}>
              <Icon name="event" size={20} color="#6B7280" />
              <Text style={[styles.dateButtonText, !formData.dueDate && styles.placeholder]}>
                {formData.dueDate ? new Date(formData.dueDate).toLocaleDateString() : "Select due date"}
              </Text>
              {formData.dueDate && (
                <TouchableOpacity onPress={clearDueDate} style={styles.clearDateButton}>
                  <Icon name="clear" size={20} color="#6B7280" />
                </TouchableOpacity>
              )}
            </TouchableOpacity>
          </View>

          {/* Date Picker */}
          {showDatePicker && (
            <DateTimePicker
              value={formData.dueDate ? new Date(formData.dueDate) : new Date()}
              mode="date"
              display="default"
              onChange={handleDateChange}
              minimumDate={new Date()}
            />
          )}

          {/* Notification Settings */}
          {formData.dueDate && (
            <NotificationSettingsNative settings={formData.notifications} onChange={handleNotificationChange} />
          )}

          {/* Recurring Form */}
          <RecurringFormNative pattern={formData.recurringPattern} onChange={handleRecurringChange} />
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#F9FAFB",
  },
  keyboardAvoid: {
    flex: 1,
  },
  header: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: "#FFFFFF",
    borderBottomWidth: 1,
    borderBottomColor: "#E5E7EB",
  },
  headerButton: {
    padding: 8,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: "600",
    color: "#1F2937",
  },
  saveButton: {
    backgroundColor: "#8B5CF6",
    borderRadius: 8,
    paddingHorizontal: 16,
    paddingVertical: 8,
  },
  saveButtonText: {
    color: "#FFFFFF",
    fontWeight: "600",
  },
  scrollView: {
    flex: 1,
    paddingHorizontal: 16,
  },
  inputContainer: {
    marginBottom: 20,
  },
  inputLabel: {
    fontSize: 16,
    fontWeight: "600",
    color: "#1F2937",
    marginBottom: 8,
  },
  textInput: {
    backgroundColor: "#FFFFFF",
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 12,
    fontSize: 16,
    color: "#1F2937",
    borderWidth: 1,
    borderColor: "#E5E7EB",
  },
  textArea: {
    height: 80,
    paddingTop: 12,
  },
  row: {
    flexDirection: "row",
    gap: 12,
    marginBottom: 20,
  },
  halfWidth: {
    flex: 1,
  },
  dateButton: {
    backgroundColor: "#FFFFFF",
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 12,
    flexDirection: "row",
    alignItems: "center",
    borderWidth: 1,
    borderColor: "#E5E7EB",
  },
  dateButtonText: {
    fontSize: 16,
    color: "#1F2937",
    marginLeft: 8,
    flex: 1,
  },
  placeholder: {
    color: "#9CA3AF",
  },
  clearDateButton: {
    padding: 4,
  },
})
