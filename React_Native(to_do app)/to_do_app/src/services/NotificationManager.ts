import * as Notifications from 'expo-notifications';
import * as Haptics from 'expo-haptics';
import { Platform } from 'react-native';
import Constants from 'expo-constants';
import type { Task, NotificationReminder } from '../types';

// Check if running in Expo Go
const isExpoGo = Constants.appOwnership === 'expo';

// Mock notification functions for Expo Go
const mockNotification = {
  requestPermissionsAsync: async () => ({ status: 'denied' }),
  getPermissionsAsync: async () => ({ status: 'denied' }),
  scheduleNotificationAsync: async () => '',
  cancelScheduledNotificationAsync: async () => {},
  cancelAllScheduledNotificationsAsync: async () => {},
  setNotificationHandler: () => {},
  setNotificationChannelAsync: async () => {},
};

// Use mock in Expo Go
const Notification = isExpoGo ? mockNotification : Notifications;

export class NotificationManager {
  private static scheduledNotifications: Map<string, string> = new Map();

  static async initialize() {
    // Skip initialization in Expo Go
    if (isExpoGo) {
      console.log('Running in Expo Go - notifications are disabled');
      return;
    }

    try {

      // Request permissions
      const { status } = await Notification.requestPermissionsAsync();
    if (status !== 'granted') {
      console.log('Notification permissions not granted');
      return;
    }

      // Configure notification channel for Android
      if (Platform.OS === 'android') {
        await Notification.setNotificationChannelAsync('default', {
          name: 'Default',
          importance: Notifications.AndroidImportance.MAX,
          vibrationPattern: [0, 250, 250, 250],
          lightColor: '#8B5CF6',
        });
      }
    } catch (error) {
      console.warn('Failed to initialize notifications:', error);
    }
  }

  static async requestPermission(): Promise<boolean> {
    if (isExpoGo) {
      console.log('Running in Expo Go - notifications are disabled');
      return false;
    }
    const { status } = await Notifications.requestPermissionsAsync();
    return status === 'granted';
  }

  static async scheduleTaskNotifications(task: Task): Promise<void> {
    if (isExpoGo || !task.notifications?.enabled || !task.dueDate) return;

    // Clear existing notifications for this task
    this.clearTaskNotifications(task.id);

    const dueDate = new Date(task.dueDate);
    const now = new Date();

    for (const reminder of task.notifications.reminders) {
      if (!reminder.enabled) continue;

      const notificationTime = this.calculateNotificationTime(dueDate, reminder);

      // Only schedule if the notification time is in the future
      if (notificationTime > now) {
        try {
          const notificationId = await Notifications.scheduleNotificationAsync({
            content: {
              title: `${this.getPriorityEmoji(task.priority)} Task Reminder`,
              body: `${task.title} is due ${this.getReminderTimeText(reminder)}`,
              data: {
                taskId: task.id,
                reminderType: `${reminder.value} ${reminder.type}`,
              },
              sound: true,
              priority: task.priority === 'high' ? Notifications.AndroidNotificationPriority.HIGH : Notifications.AndroidNotificationPriority.DEFAULT,
            },
            trigger: {
              type: 'date',  // FIXED: Added missing type property
              date: notificationTime,
            } as Notifications.DateTriggerInput,
          });

          this.scheduledNotifications.set(`${task.id}-${reminder.id}`, notificationId);
        } catch (error) {
          console.error('Error scheduling notification:', error);
        }
      }
    }
  }

  private static calculateNotificationTime(dueDate: Date, reminder: NotificationReminder): Date {
    const notificationTime = new Date(dueDate);

    switch (reminder.type) {
      case 'minutes':
        notificationTime.setMinutes(notificationTime.getMinutes() - reminder.value);
        break;
      case 'hours':
        notificationTime.setHours(notificationTime.getHours() - reminder.value);
        break;
      case 'days':
        notificationTime.setDate(notificationTime.getDate() - reminder.value);
        break;
    }

    return notificationTime;
  }

  private static getReminderTimeText(reminder: NotificationReminder): string {
    if (reminder.value === 0) return 'now';

    const unit = reminder.type === 'minutes' ? 'min' : reminder.type === 'hours' ? 'hr' : 'day';
    const plural = reminder.value > 1 ? (unit === 'min' ? 'mins' : unit === 'hr' ? 'hrs' : 'days') : unit;

    return `in ${reminder.value} ${plural}`;
  }

  private static getPriorityEmoji(priority: string): string {
    switch (priority) {
      case 'high':
        return '🔴';
      case 'medium':
        return '🟡';
      case 'low':
        return '🟢';
      default:
        return '📋';
    }
  }

  static async clearTaskNotifications(taskId: string): Promise<void> {
    // Clear all scheduled notifications for this task
    for (const [key, notificationId] of this.scheduledNotifications.entries()) {
      if (key.startsWith(`${taskId}-`)) {
        try {
          await Notifications.cancelScheduledNotificationAsync(notificationId);
          this.scheduledNotifications.delete(key);
        } catch (error) {
          console.error('Error canceling notification:', error);
        }
      }
    }
  }

  static async clearAllNotifications(): Promise<void> {
    try {
      await Notifications.cancelAllScheduledNotificationsAsync();
      this.scheduledNotifications.clear();
    } catch (error) {
      console.error('Error clearing all notifications:', error);
    }
  }

  static async cancelAllScheduledNotifications(): Promise<void> {
    await this.clearAllNotifications();
  }

  static async triggerHapticFeedback(type: 'light' | 'medium' | 'heavy' = 'medium') {
    try {
      switch (type) {
        case 'light':
          await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
          break;
        case 'medium':
          await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
          break;
        case 'heavy':
          await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy);
          break;
      }
    } catch (error) {
      console.error('Error triggering haptic feedback:', error);
    }
  }

  // Additional utility methods for better notification management
  static async getScheduledNotifications() {
    try {
      return await Notifications.getAllScheduledNotificationsAsync();
    } catch (error) {
      console.error('Error getting scheduled notifications:', error);
      return [];
    }
  }

  static async snoozeTask(taskId: string, minutes = 15): Promise<void> {
    const snoozeTime = new Date();
    snoozeTime.setMinutes(snoozeTime.getMinutes() + minutes);

    try {
      const notificationId = await Notifications.scheduleNotificationAsync({
        content: {
          title: '⏰ Snoozed Task Reminder',
          body: 'Your snoozed task is ready for attention',
          data: { taskId, snoozed: true },
          sound: true,
        },
        trigger: {
          type: 'date',
          date: snoozeTime,
        } as Notifications.DateTriggerInput,
      });

      this.scheduledNotifications.set(`snoozed-${taskId}`, notificationId);
    } catch (error) {
      console.error('Error snoozing task:', error);
    }
  }
}