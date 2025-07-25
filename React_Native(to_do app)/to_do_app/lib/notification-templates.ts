import type { NotificationReminder } from "./types"

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

export const notificationTemplates: NotificationTemplate[] = [
  // Work Templates
  {
    id: "meeting-reminder",
    name: "Meeting Reminder",
    description: "Perfect for important meetings and calls",
    icon: "👥",
    category: "work",
    useCase: "Get notified well in advance for meetings",
    priority: "high",
    reminders: [
      { id: "1", type: "days", value: 1, enabled: true },
      { id: "2", type: "hours", value: 2, enabled: true },
      { id: "3", type: "minutes", value: 15, enabled: true },
    ],
  },
  {
    id: "deadline-alert",
    name: "Project Deadline",
    description: "For important project deadlines",
    icon: "📋",
    category: "work",
    useCase: "Stay on top of critical deadlines",
    priority: "high",
    reminders: [
      { id: "1", type: "days", value: 7, enabled: true },
      { id: "2", type: "days", value: 3, enabled: true },
      { id: "3", type: "days", value: 1, enabled: true },
      { id: "4", type: "hours", value: 4, enabled: true },
    ],
  },
  {
    id: "daily-standup",
    name: "Daily Standup",
    description: "Quick reminder for daily team meetings",
    icon: "🗣️",
    category: "work",
    useCase: "Never miss your daily standup",
    priority: "medium",
    reminders: [
      { id: "1", type: "minutes", value: 10, enabled: true },
      { id: "2", type: "minutes", value: 2, enabled: true },
    ],
  },

  // Personal Templates
  {
    id: "appointment-reminder",
    name: "Appointment",
    description: "Doctor, dentist, or other appointments",
    icon: "🏥",
    category: "personal",
    useCase: "Never miss important appointments",
    priority: "high",
    reminders: [
      { id: "1", type: "days", value: 1, enabled: true },
      { id: "2", type: "hours", value: 2, enabled: true },
      { id: "3", type: "minutes", value: 30, enabled: true },
    ],
  },
  {
    id: "social-event",
    name: "Social Event",
    description: "Parties, dinners, and social gatherings",
    icon: "🎉",
    category: "personal",
    useCase: "Be ready for social events",
    priority: "medium",
    reminders: [
      { id: "1", type: "hours", value: 4, enabled: true },
      { id: "2", type: "hours", value: 1, enabled: true },
    ],
  },
  {
    id: "travel-preparation",
    name: "Travel Prep",
    description: "Flight, train, or trip preparation",
    icon: "✈️",
    category: "personal",
    useCase: "Prepare for travel in advance",
    priority: "high",
    reminders: [
      { id: "1", type: "days", value: 3, enabled: true },
      { id: "2", type: "days", value: 1, enabled: true },
      { id: "3", type: "hours", value: 4, enabled: true },
      { id: "4", type: "hours", value: 1, enabled: true },
    ],
  },

  // Health Templates
  {
    id: "medication-reminder",
    name: "Medication",
    description: "Daily medication or supplements",
    icon: "💊",
    category: "health",
    useCase: "Never miss your medication",
    priority: "high",
    reminders: [
      { id: "1", type: "minutes", value: 15, enabled: true },
      { id: "2", type: "minutes", value: 5, enabled: true },
    ],
  },
  {
    id: "workout-session",
    name: "Workout",
    description: "Gym sessions or exercise routines",
    icon: "💪",
    category: "health",
    useCase: "Stay consistent with workouts",
    priority: "medium",
    reminders: [
      { id: "1", type: "hours", value: 1, enabled: true },
      { id: "2", type: "minutes", value: 15, enabled: true },
    ],
  },
  {
    id: "health-checkup",
    name: "Health Checkup",
    description: "Annual checkups and health screenings",
    icon: "🩺",
    category: "health",
    useCase: "Stay on top of preventive care",
    priority: "high",
    reminders: [
      { id: "1", type: "days", value: 7, enabled: true },
      { id: "2", type: "days", value: 3, enabled: true },
      { id: "3", type: "days", value: 1, enabled: true },
    ],
  },

  // Finance Templates
  {
    id: "bill-payment",
    name: "Bill Payment",
    description: "Utility bills, rent, and recurring payments",
    icon: "💳",
    category: "finance",
    useCase: "Never miss bill payments",
    priority: "high",
    reminders: [
      { id: "1", type: "days", value: 5, enabled: true },
      { id: "2", type: "days", value: 2, enabled: true },
      { id: "3", type: "days", value: 1, enabled: true },
    ],
  },
  {
    id: "tax-deadline",
    name: "Tax Deadline",
    description: "Tax filing and financial deadlines",
    icon: "📊",
    category: "finance",
    useCase: "Stay compliant with tax deadlines",
    priority: "high",
    reminders: [
      { id: "1", type: "days", value: 30, enabled: true },
      { id: "2", type: "days", value: 14, enabled: true },
      { id: "3", type: "days", value: 7, enabled: true },
      { id: "4", type: "days", value: 3, enabled: true },
    ],
  },
  {
    id: "investment-review",
    name: "Investment Review",
    description: "Portfolio reviews and financial planning",
    icon: "📈",
    category: "finance",
    useCase: "Regular financial health checks",
    priority: "medium",
    reminders: [
      { id: "1", type: "days", value: 3, enabled: true },
      { id: "2", type: "days", value: 1, enabled: true },
    ],
  },

  // Education Templates
  {
    id: "exam-preparation",
    name: "Exam Prep",
    description: "Study sessions and exam preparation",
    icon: "📚",
    category: "education",
    useCase: "Prepare thoroughly for exams",
    priority: "high",
    reminders: [
      { id: "1", type: "days", value: 14, enabled: true },
      { id: "2", type: "days", value: 7, enabled: true },
      { id: "3", type: "days", value: 3, enabled: true },
      { id: "4", type: "days", value: 1, enabled: true },
    ],
  },
  {
    id: "assignment-deadline",
    name: "Assignment Due",
    description: "School or course assignments",
    icon: "📝",
    category: "education",
    useCase: "Submit assignments on time",
    priority: "high",
    reminders: [
      { id: "1", type: "days", value: 3, enabled: true },
      { id: "2", type: "days", value: 1, enabled: true },
      { id: "3", type: "hours", value: 6, enabled: true },
    ],
  },
  {
    id: "online-class",
    name: "Online Class",
    description: "Virtual classes and webinars",
    icon: "💻",
    category: "education",
    useCase: "Join online sessions on time",
    priority: "medium",
    reminders: [
      { id: "1", type: "hours", value: 1, enabled: true },
      { id: "2", type: "minutes", value: 10, enabled: true },
    ],
  },

  // General Templates
  {
    id: "quick-reminder",
    name: "Quick Reminder",
    description: "Simple 15-minute heads up",
    icon: "⏰",
    category: "general",
    useCase: "Basic reminder for any task",
    priority: "medium",
    reminders: [{ id: "1", type: "minutes", value: 15, enabled: true }],
  },
  {
    id: "important-task",
    name: "Important Task",
    description: "Critical tasks that need attention",
    icon: "⚡",
    category: "general",
    useCase: "High-priority tasks requiring focus",
    priority: "high",
    reminders: [
      { id: "1", type: "hours", value: 4, enabled: true },
      { id: "2", type: "hours", value: 1, enabled: true },
      { id: "3", type: "minutes", value: 15, enabled: true },
    ],
  },
  {
    id: "routine-task",
    name: "Routine Task",
    description: "Regular daily or weekly tasks",
    icon: "🔄",
    category: "general",
    useCase: "Consistent reminders for habits",
    priority: "low",
    reminders: [{ id: "1", type: "minutes", value: 30, enabled: true }],
  },
]

export function getTemplatesByCategory(category: string): NotificationTemplate[] {
  return notificationTemplates.filter((template) => template.category === category)
}

export function getTemplateById(id: string): NotificationTemplate | undefined {
  return notificationTemplates.find((template) => template.id === id)
}

export function getPopularTemplates(): NotificationTemplate[] {
  return notificationTemplates.filter((template) =>
    ["meeting-reminder", "medication-reminder", "bill-payment", "quick-reminder", "important-task"].includes(
      template.id,
    ),
  )
}

export function searchTemplates(query: string): NotificationTemplate[] {
  const lowercaseQuery = query.toLowerCase()
  return notificationTemplates.filter(
    (template) =>
      template.name.toLowerCase().includes(lowercaseQuery) ||
      template.description.toLowerCase().includes(lowercaseQuery) ||
      template.useCase.toLowerCase().includes(lowercaseQuery),
  )
}

export const templateCategories = [
  { id: "work", name: "Work", icon: "💼", color: "#3B82F6" },
  { id: "personal", name: "Personal", icon: "🏠", color: "#10B981" },
  { id: "health", name: "Health", icon: "❤️", color: "#EF4444" },
  { id: "finance", name: "Finance", icon: "💰", color: "#F59E0B" },
  { id: "education", name: "Education", icon: "🎓", color: "#8B5CF6" },
  { id: "general", name: "General", icon: "📋", color: "#6B7280" },
]
