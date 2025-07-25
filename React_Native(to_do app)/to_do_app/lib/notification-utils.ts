import type { Task, NotificationReminder } from "./types"

export class NotificationManager {
  private static instance: NotificationManager
  private scheduledNotifications: Map<string, number> = new Map()
  private isSupported = false

  constructor() {
    this.isSupported = "Notification" in window && "serviceWorker" in navigator
  }

  static getInstance(): NotificationManager {
    if (!NotificationManager.instance) {
      NotificationManager.instance = new NotificationManager()
    }
    return NotificationManager.instance
  }

  async requestPermission(): Promise<NotificationPermission> {
    if (!this.isSupported) {
      return { granted: false, denied: true, default: false }
    }

    try {
      const permission = await Notification.requestPermission()
      return {
        granted: permission === "granted",
        denied: permission === "denied",
        default: permission === "default",
      }
    } catch (error) {
      console.error("Error requesting notification permission:", error)
      return { granted: false, denied: true, default: false }
    }
  }

  getPermissionStatus(): NotificationPermission {
    if (!this.isSupported) {
      return { granted: false, denied: true, default: false }
    }

    const permission = Notification.permission
    return {
      granted: permission === "granted",
      denied: permission === "denied",
      default: permission === "default",
    }
  }

  scheduleTaskNotifications(task: Task): void {
    if (!task.notifications?.enabled || !task.dueDate) return

    // Clear existing notifications for this task
    this.clearTaskNotifications(task.id)

    const dueDate = new Date(task.dueDate)
    const now = new Date()

    task.notifications.reminders.forEach((reminder) => {
      if (!reminder.enabled) return

      const notificationTime = this.calculateNotificationTime(dueDate, reminder)

      // Only schedule if the notification time is in the future
      if (notificationTime > now) {
        const timeoutId = window.setTimeout(() => {
          this.showNotification(task, reminder)
        }, notificationTime.getTime() - now.getTime())

        this.scheduledNotifications.set(`${task.id}-${reminder.id}`, timeoutId)
      }
    })
  }

  private calculateNotificationTime(dueDate: Date, reminder: NotificationReminder): Date {
    const notificationTime = new Date(dueDate)

    switch (reminder.type) {
      case "minutes":
        notificationTime.setMinutes(notificationTime.getMinutes() - reminder.value)
        break
      case "hours":
        notificationTime.setHours(notificationTime.getHours() - reminder.value)
        break
      case "days":
        notificationTime.setDate(notificationTime.getDate() - reminder.value)
        break
    }

    return notificationTime
  }

  private async showNotification(task: Task, reminder: NotificationReminder): Promise<void> {
    const permission = this.getPermissionStatus()
    if (!permission.granted) return

    const timeText = this.getReminderTimeText(reminder)
    const priorityEmoji = this.getPriorityEmoji(task.priority)

    try {
      const notification = new Notification(`${priorityEmoji} Task Reminder`, {
        body: `${task.title} is due ${timeText}`,
        icon: "/favicon.ico",
        badge: "/favicon.ico",
        tag: `task-${task.id}`,
        requireInteraction: task.priority === "high",
        actions: [
          { action: "complete", title: "Mark Complete" },
          { action: "snooze", title: "Snooze 15min" },
        ],
        data: {
          taskId: task.id,
          reminderType: `${reminder.value} ${reminder.type}`,
        },
      })

      notification.onclick = () => {
        window.focus()
        notification.close()
        // Navigate to task (this would need to be implemented based on your routing)
        window.location.hash = `#task-${task.id}`
      }

      // Auto-close notification after 10 seconds for non-high priority tasks
      if (task.priority !== "high") {
        setTimeout(() => notification.close(), 10000)
      }
    } catch (error) {
      console.error("Error showing notification:", error)
    }
  }

  private getReminderTimeText(reminder: NotificationReminder): string {
    if (reminder.value === 0) return "now"

    const unit = reminder.type === "minutes" ? "min" : reminder.type === "hours" ? "hr" : "day"
    const plural = reminder.value > 1 ? (unit === "min" ? "mins" : unit === "hr" ? "hrs" : "days") : unit

    return `in ${reminder.value} ${plural}`
  }

  private getPriorityEmoji(priority: string): string {
    switch (priority) {
      case "high":
        return "🔴"
      case "medium":
        return "🟡"
      case "low":
        return "🟢"
      default:
        return "📋"
    }
  }

  clearTaskNotifications(taskId: string): void {
    // Clear all scheduled notifications for this task
    for (const [key, timeoutId] of this.scheduledNotifications.entries()) {
      if (key.startsWith(`${taskId}-`)) {
        clearTimeout(timeoutId)
        this.scheduledNotifications.delete(key)
      }
    }
  }

  clearAllNotifications(): void {
    // Clear all scheduled notifications
    for (const timeoutId of this.scheduledNotifications.values()) {
      clearTimeout(timeoutId)
    }
    this.scheduledNotifications.clear()
  }

  snoozeTask(taskId: string, minutes = 15): void {
    // This would reschedule the notification
    const snoozeTime = new Date()
    snoozeTime.setMinutes(snoozeTime.getMinutes() + minutes)

    const timeoutId = window.setTimeout(
      () => {
        // Show a snoozed notification
        if (this.getPermissionStatus().granted) {
          new Notification("⏰ Snoozed Task Reminder", {
            body: "Your snoozed task is ready for attention",
            icon: "/favicon.ico",
            tag: `snoozed-${taskId}`,
          })
        }
      },
      minutes * 60 * 1000,
    )

    this.scheduledNotifications.set(`snoozed-${taskId}`, timeoutId)
  }

  // Utility method to check if notifications are supported
  isNotificationSupported(): boolean {
    return this.isSupported
  }

  // Method to get default notification reminders
  getDefaultReminders(): NotificationReminder[] {
    return [
      {
        id: "1",
        type: "minutes",
        value: 15,
        enabled: true,
      },
      {
        id: "2",
        type: "hours",
        value: 1,
        enabled: false,
      },
      {
        id: "3",
        type: "days",
        value: 1,
        enabled: false,
      },
    ]
  }
}

// Export singleton instance
export const notificationManager = NotificationManager.getInstance()
