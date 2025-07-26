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
  occurrenceCount?: number
}

export interface RecurringPattern {
  type: "daily" | "weekly" | "monthly" | "yearly" | "custom"
  interval: number
  daysOfWeek?: number[]
  dayOfMonth?: number
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
  value: number
  enabled: boolean
}

export interface Category {
  id: string
  name: string
  color: string
  icon: string
  taskCount: number
}

export interface NotificationTemplate {
  id: string
  name: string
  description: string
  icon: string
  category: "work" | "personal" | "health" | "finance" | "education" | "general"
  reminders: NotificationReminder[]
  useCase: string
  priority: "high" | "medium" | "low"
}
