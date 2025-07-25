import type { Task, RecurringPattern } from "./types"

export function getNextDueDate(pattern: RecurringPattern, fromDate: Date = new Date()): Date | null {
  const nextDate = new Date(fromDate)

  switch (pattern.type) {
    case "daily":
      nextDate.setDate(nextDate.getDate() + pattern.interval)
      break

    case "weekly":
      if (pattern.daysOfWeek && pattern.daysOfWeek.length > 0) {
        // Find next occurrence of specified days
        const currentDay = nextDate.getDay()
        const sortedDays = [...pattern.daysOfWeek].sort((a, b) => a - b)

        let nextDay = sortedDays.find((day) => day > currentDay)
        if (!nextDay) {
          // Move to next week and use first day
          nextDay = sortedDays[0]
          nextDate.setDate(nextDate.getDate() + (7 - currentDay + nextDay))
        } else {
          nextDate.setDate(nextDate.getDate() + (nextDay - currentDay))
        }

        // Apply interval (every N weeks)
        if (pattern.interval > 1) {
          nextDate.setDate(nextDate.getDate() + (pattern.interval - 1) * 7)
        }
      } else {
        nextDate.setDate(nextDate.getDate() + pattern.interval * 7)
      }
      break

    case "monthly":
      if (pattern.dayOfMonth) {
        nextDate.setMonth(nextDate.getMonth() + pattern.interval)
        nextDate.setDate(pattern.dayOfMonth)

        // Handle months with fewer days
        if (nextDate.getDate() !== pattern.dayOfMonth) {
          nextDate.setDate(0) // Last day of previous month
        }
      } else {
        nextDate.setMonth(nextDate.getMonth() + pattern.interval)
      }
      break

    case "yearly":
      nextDate.setFullYear(nextDate.getFullYear() + pattern.interval)
      break

    case "custom":
      nextDate.setDate(nextDate.getDate() + pattern.interval)
      break

    default:
      return null
  }

  // Check end conditions
  if (pattern.endDate && nextDate > new Date(pattern.endDate)) {
    return null
  }

  return nextDate
}

export function shouldGenerateNextTask(task: Task): boolean {
  if (!task.isRecurring || !task.recurringPattern) return false

  const pattern = task.recurringPattern
  const now = new Date()

  // Check if we've reached max occurrences
  if (pattern.maxOccurrences) {
    // This would need to be tracked in the store
    // For now, we'll assume it's handled elsewhere
  }

  // Check if we've passed the end date
  if (pattern.endDate && now > new Date(pattern.endDate)) {
    return false
  }

  return true
}

export function generateNextRecurringTask(completedTask: Task): Task | null {
  if (!completedTask.isRecurring || !completedTask.recurringPattern) {
    return null
  }

  if (!shouldGenerateNextTask(completedTask)) {
    return null
  }

  const nextDueDate = getNextDueDate(completedTask.recurringPattern, new Date())
  if (!nextDueDate) {
    return null
  }

  const nextTask: Task = {
    ...completedTask,
    id: Date.now().toString() + Math.random().toString(36).substr(2, 9),
    completed: false,
    dueDate: nextDueDate.toISOString(),
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    parentTaskId: completedTask.parentTaskId || completedTask.id,
    recurringPattern: {
      ...completedTask.recurringPattern,
      lastGenerated: new Date().toISOString(),
    },
  }

  return nextTask
}

export function getRecurringPatternDescription(pattern: RecurringPattern): string {
  const { type, interval, daysOfWeek, dayOfMonth } = pattern

  switch (type) {
    case "daily":
      return interval === 1 ? "Daily" : `Every ${interval} days`

    case "weekly":
      if (daysOfWeek && daysOfWeek.length > 0) {
        const dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        const selectedDays = daysOfWeek.map((day) => dayNames[day]).join(", ")
        const weekText = interval === 1 ? "Weekly" : `Every ${interval} weeks`
        return `${weekText} on ${selectedDays}`
      }
      return interval === 1 ? "Weekly" : `Every ${interval} weeks`

    case "monthly":
      const monthText = interval === 1 ? "Monthly" : `Every ${interval} months`
      if (dayOfMonth) {
        const suffix = getDayOfMonthSuffix(dayOfMonth)
        return `${monthText} on the ${dayOfMonth}${suffix}`
      }
      return monthText

    case "yearly":
      return interval === 1 ? "Yearly" : `Every ${interval} years`

    case "custom":
      return `Every ${interval} days`

    default:
      return "Custom"
  }
}

function getDayOfMonthSuffix(day: number): string {
  if (day >= 11 && day <= 13) return "th"
  switch (day % 10) {
    case 1:
      return "st"
    case 2:
      return "nd"
    case 3:
      return "rd"
    default:
      return "th"
  }
}
