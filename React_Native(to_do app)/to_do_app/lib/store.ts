"use client"

import { create } from "zustand"
import { persist } from "zustand/middleware"
import type { Task, Category, NotificationPermission } from "./types"
import { generateNextRecurringTask } from "./recurring-utils"
import { notificationManager } from "./notification-utils"

interface TaskStore {
  tasks: Task[]
  categories: Category[]
  selectedCategory: string | null
  notificationPermission: NotificationPermission
  globalNotificationsEnabled: boolean

  // Task actions
  addTask: (task: Omit<Task, "id" | "createdAt" | "updatedAt">) => void
  updateTask: (id: string, updates: Partial<Task>) => void
  deleteTask: (id: string) => void
  toggleTask: (id: string) => void
  deleteRecurringSeries: (parentTaskId: string) => void

  // Notification actions
  requestNotificationPermission: () => Promise<void>
  setGlobalNotifications: (enabled: boolean) => void
  scheduleAllNotifications: () => void

  // Category actions
  setSelectedCategory: (categoryId: string | null) => void
}

const defaultCategories: Category[] = [
  { id: "1", name: "Work", color: "#3B82F6", icon: "💼", taskCount: 0 },
  { id: "2", name: "Personal", color: "#10B981", icon: "🏠", taskCount: 0 },
  { id: "3", name: "Shopping", color: "#F59E0B", icon: "🛒", taskCount: 0 },
  { id: "4", name: "Health", color: "#EF4444", icon: "❤️", taskCount: 0 },
]

export const useTaskStore = create<TaskStore>()(
  persist(
    (set, get) => ({
      tasks: [],
      categories: defaultCategories,
      selectedCategory: null,
      notificationPermission: { granted: false, denied: false, default: true },
      globalNotificationsEnabled: true,

      addTask: (taskData) => {
        const newTask: Task = {
          ...taskData,
          id: Date.now().toString() + Math.random().toString(36).substr(2, 9),
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
          isRecurring: taskData.isRecurring || false,
          notifications: taskData.notifications || {
            enabled: false,
            reminders: notificationManager.getDefaultReminders(),
          },
        }

        set((state) => ({
          tasks: [...state.tasks, newTask],
        }))

        // Schedule notifications for the new task
        if (get().globalNotificationsEnabled) {
          notificationManager.scheduleTaskNotifications(newTask)
        }
      },

      updateTask: (id, updates) => {
        set((state) => {
          const updatedTasks = state.tasks.map((task) =>
            task.id === id ? { ...task, ...updates, updatedAt: new Date().toISOString() } : task,
          )

          // Reschedule notifications for updated task
          const updatedTask = updatedTasks.find((t) => t.id === id)
          if (updatedTask && state.globalNotificationsEnabled) {
            notificationManager.clearTaskNotifications(id)
            notificationManager.scheduleTaskNotifications(updatedTask)
          }

          return { tasks: updatedTasks }
        })
      },

      deleteTask: (id) => {
        // Clear notifications for deleted task
        notificationManager.clearTaskNotifications(id)

        set((state) => ({
          tasks: state.tasks.filter((task) => task.id !== id),
        }))
      },

      toggleTask: (id) => {
        set((state) => {
          const task = state.tasks.find((t) => t.id === id)
          if (!task) return state

          const updatedTasks = state.tasks.map((t) =>
            t.id === id
              ? {
                  ...t,
                  completed: !t.completed,
                  updatedAt: new Date().toISOString(),
                }
              : t,
          )

          // Handle notifications when task is completed/uncompleted
          if (!task.completed) {
            // Task is being completed - clear its notifications
            notificationManager.clearTaskNotifications(id)
          } else {
            // Task is being uncompleted - reschedule notifications
            const uncompletedTask = updatedTasks.find((t) => t.id === id)
            if (uncompletedTask && state.globalNotificationsEnabled) {
              notificationManager.scheduleTaskNotifications(uncompletedTask)
            }
          }

          // If completing a recurring task, generate the next occurrence
          if (!task.completed && task.isRecurring) {
            const nextTask = generateNextRecurringTask({ ...task, completed: true })
            if (nextTask) {
              updatedTasks.push(nextTask)
              // Schedule notifications for the new recurring task
              if (state.globalNotificationsEnabled) {
                notificationManager.scheduleTaskNotifications(nextTask)
              }
            }
          }

          return { tasks: updatedTasks }
        })
      },

      deleteRecurringSeries: (parentTaskId) => {
        // Clear notifications for all tasks in the series
        const state = get()
        state.tasks.forEach((task) => {
          if (task.id === parentTaskId || task.parentTaskId === parentTaskId) {
            notificationManager.clearTaskNotifications(task.id)
          }
        })

        set((state) => ({
          tasks: state.tasks.filter((task) => task.id !== parentTaskId && task.parentTaskId !== parentTaskId),
        }))
      },

      requestNotificationPermission: async () => {
        const permission = await notificationManager.requestPermission()
        set({ notificationPermission: permission })

        // If permission granted, schedule all notifications
        if (permission.granted) {
          get().scheduleAllNotifications()
        }
      },

      setGlobalNotifications: (enabled) => {
        set({ globalNotificationsEnabled: enabled })

        if (enabled) {
          get().scheduleAllNotifications()
        } else {
          notificationManager.clearAllNotifications()
        }
      },

      scheduleAllNotifications: () => {
        const state = get()
        if (!state.globalNotificationsEnabled) return

        // Clear all existing notifications
        notificationManager.clearAllNotifications()

        // Schedule notifications for all incomplete tasks
        state.tasks.forEach((task) => {
          if (!task.completed) {
            notificationManager.scheduleTaskNotifications(task)
          }
        })
      },

      setSelectedCategory: (categoryId) => {
        set({ selectedCategory: categoryId })
      },
    }),
    {
      name: "task-store",
      partialize: (state) => ({
        tasks: state.tasks,
        categories: state.categories,
        selectedCategory: state.selectedCategory,
        globalNotificationsEnabled: state.globalNotificationsEnabled,
        // Don't persist notification permission as it can change
      }),
    },
  ),
)

// Initialize notification permission on store creation
if (typeof window !== "undefined") {
  useTaskStore.setState({
    notificationPermission: notificationManager.getPermissionStatus(),
  })
}
