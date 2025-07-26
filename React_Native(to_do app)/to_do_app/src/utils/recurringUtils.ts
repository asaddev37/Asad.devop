import { Task, RecurringPattern } from "../types";
import { addDays, addWeeks, addMonths, addYears, isAfter, parseISO } from "date-fns";

/**
 * Generates the next occurrence of a recurring task
 * @param task The completed recurring task
 * @returns The next occurrence of the task or null if no more occurrences
 */
export const generateNextRecurringTask = (task: Task): Task | null => {
  if (!task.isRecurring || !task.recurringPattern) {
    return null;
  }

  const now = new Date();
  const lastOccurrence = parseISO(task.dueDate || task.createdAt);
  let nextDate: Date;

  switch (task.recurringPattern.type) {
    case "daily":
      nextDate = addDays(lastOccurrence, task.recurringPattern.interval || 1);
      break;
    case "weekly":
      nextDate = addWeeks(lastOccurrence, task.recurringPattern.interval || 1);
      // If specific days of week are specified, find the next occurrence
      if (task.recurringPattern.daysOfWeek?.length) {
        const dayOfWeek = lastOccurrence.getDay();
        const nextDayIndex = task.recurringPattern.daysOfWeek.findIndex(d => d > dayOfWeek);
        const daysToAdd = nextDayIndex !== -1 
          ? task.recurringPattern.daysOfWeek[nextDayIndex] - dayOfWeek
          : 7 - dayOfWeek + (task.recurringPattern.daysOfWeek[0] || 0);
        nextDate = addDays(lastOccurrence, daysToAdd);
      }
      break;
    case "monthly":
      nextDate = addMonths(lastOccurrence, task.recurringPattern.interval || 1);
      // If a specific day of month is specified, set that day
      if (task.recurringPattern.dayOfMonth) {
        nextDate.setDate(task.recurringPattern.dayOfMonth);
      }
      break;
    case "yearly":
      nextDate = addYears(lastOccurrence, task.recurringPattern.interval || 1);
      break;
    default:
      return null;
  }

  // Check if we've exceeded the end date or max occurrences
  if (
    (task.recurringPattern.endDate && isAfter(parseISO(task.recurringPattern.endDate), nextDate)) ||
    (task.recurringPattern.maxOccurrences && 
     task.recurringPattern.maxOccurrences > 0 && 
     task.recurringPattern.maxOccurrences <= (task.occurrenceCount || 0) + 1)
  ) {
    return null;
  }

  // Create the next task
  const nextTask: Task = {
    ...task,
    id: `${task.id}-${(task.occurrenceCount || 0) + 1}`,
    parentTaskId: task.parentTaskId || task.id,
    completed: false,
    dueDate: nextDate.toISOString(),
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    occurrenceCount: (task.occurrenceCount || 0) + 1,
  };

  return nextTask;
};

/**
 * Gets the next occurrence date for a recurring task
 * @param pattern The recurring pattern
 * @param lastDate The last occurrence date
 * @returns The next occurrence date or null if no more occurrences
 */
export const getNextOccurrence = (pattern: RecurringPattern, lastDate: Date): Date | null => {
  let nextDate: Date;

  switch (pattern.type) {
    case "daily":
      nextDate = addDays(lastDate, pattern.interval || 1);
      break;
    case "weekly":
      nextDate = addWeeks(lastDate, pattern.interval || 1);
      if (pattern.daysOfWeek?.length) {
        const dayOfWeek = lastDate.getDay();
        const nextDayIndex = pattern.daysOfWeek.findIndex(d => d > dayOfWeek);
        const daysToAdd = nextDayIndex !== -1 
          ? pattern.daysOfWeek[nextDayIndex] - dayOfWeek
          : 7 - dayOfWeek + (pattern.daysOfWeek[0] || 0);
        nextDate = addDays(lastDate, daysToAdd);
      }
      break;
    case "monthly":
      nextDate = addMonths(lastDate, pattern.interval || 1);
      if (pattern.dayOfMonth) {
        nextDate.setDate(pattern.dayOfMonth);
      }
      break;
    case "yearly":
      nextDate = addYears(lastDate, pattern.interval || 1);
      break;
    default:
      return null;
  }

  // Check if we've exceeded the end date
  if (pattern.endDate && isAfter(parseISO(pattern.endDate), nextDate)) {
    return null;
  }

  return nextDate;
};
