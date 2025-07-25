import { create } from "zustand"
import { persist, createJSONStorage } from "zustand/middleware"
import AsyncStorage from "@react-native-async-storage/async-storage"
import type { Task, Category } from "../types"
import { generateNextRecurringTask } from "../utils/recurringUtils"
import { NotificationManager } from "../services/NotificationManager"

interface TaskStore {
  tasks: Task[]
  categories: Category[]
  selectedCategory: string | null
  globalNotificationsEnabled: boolean

  // Task actions
  addTask: (task: Omit<Task, "id" | "createdAt" | "updatedAt">) => void
  updateTask: (id: string, updates: Partial<Task>) => void
  deleteTask: (id: string) => void
  toggleTask: (id: string) => void
  deleteRecurringSeries: (parentTaskId: string) => void

  // Notification actions
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
            reminders: [],
          },
        }

        set((state) => ({
          tasks: [...state.tasks, newTask],
        }))

        // Schedule notifications for the new task
        if (get().globalNotificationsEnabled) {
          NotificationManager.scheduleTaskNotifications(newTask)
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
            NotificationManager.clearTaskNotifications(id)
            NotificationManager.scheduleTaskNotifications(updatedTask)
          }

          return { tasks: updatedTasks }
        })
      },

      deleteTask: (id) => {
        NotificationManager.clearTaskNotifications(id)
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
            NotificationManager.clearTaskNotifications(id)
          } else {
            const uncompletedTask = updatedTasks.find((t) => t.id === id)
            if (uncompletedTask && state.globalNotificationsEnabled) {
              NotificationManager.scheduleTaskNotifications(uncompletedTask)
            }
          }

          // If completing a recurring task, generate the next occurrence
          if (!task.completed && task.isRecurring) {
            const nextTask = generateNextRecurringTask({ ...task, completed: true })
            if (nextTask) {
              updatedTasks.push(nextTask)
              if (state.globalNotificationsEnabled) {
                NotificationManager.scheduleTaskNotifications(nextTask)
              }
            }
          }

          return { tasks: updatedTasks }
        })
      },

      deleteRecurringSeries: (parentTaskId) => {
        const state = get()
        state.tasks.forEach((task) => {
          if (task.id === parentTaskId || task.parentTaskId === parentTaskId) {
            NotificationManager.clearTaskNotifications(task.id)
          }
        })

        set((state) => ({
          tasks: state.tasks.filter((task) => task.id !== parentTaskId && task.parentTaskId !== parentTaskId),
        }))
      },

      setGlobalNotifications: (enabled) => {
        set({ globalNotificationsEnabled: enabled })

        if (enabled) {
          get().scheduleAllNotifications()
        } else {
          NotificationManager.clearAllNotifications()
        }
      },

      scheduleAllNotifications: () => {
        const state = get()
        if (!state.globalNotificationsEnabled) return

        NotificationManager.clearAllNotifications()

        state.tasks.forEach((task) => {
          if (!task.completed) {
            NotificationManager.scheduleTaskNotifications(task)
          }
        })
      },

      setSelectedCategory: (categoryId) => {
        set({ selectedCategory: categoryId })
      },
    }),
    {
      name: "task-store",
      storage: createJSONStorage(() => AsyncStorage),
      partialize: (state) => ({
        tasks: state.tasks,
        categories: state.categories,
        selectedCategory: state.selectedCategory,
        globalNotificationsEnabled: state.globalNotificationsEnabled,
      }),
    },
  ),
)
