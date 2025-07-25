export interface Task {
  id: string
  title: string
  description?: string
  completed: boolean
  priority: "low" | "medium" | "high"
  category: string
  dueDate?: string
  createdAt: string
  updatedAt: string
  isRecurring: boolean
  parentTaskId?: string
  recurringPattern?: RecurringPattern
  notifications?: NotificationSettings
}

export interface RecurringPattern {
  type: "daily" | "weekly" | "monthly" | "yearly" | "custom"
  interval: number // e.g., every 2 days, every 3 weeks
  daysOfWeek?: number[] // 0-6, Sunday = 0, for weekly patterns
  dayOfMonth?: number // 1-31, for monthly patterns
  endDate?: string
  maxOccurrences?: number
  lastGenerated?: string
}

export interface NotificationSettings {
  enabled: boolean
  reminders: NotificationReminder[]
}

export interface NotificationReminder {
  id: string
  type: "minutes" | "hours" | "days"
  value: number // e.g., 15 minutes, 2 hours, 1 day
  enabled: boolean
}

export interface ScheduledNotification {
  id: string
  taskId: string
  scheduledTime: string
  reminderType: string
  sent: boolean
  createdAt: string
}

export interface Category {
  id: string
  name: string
  color: string
  icon: string
  taskCount: number
}

export interface TaskStats {
  total: number
  completed: number
  pending: number
  overdue: number
  completionRate: number
}

export interface NotificationPermission {
  granted: boolean
  denied: boolean
  default: boolean
}
