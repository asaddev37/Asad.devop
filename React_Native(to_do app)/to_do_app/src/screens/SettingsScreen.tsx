"use client"

import type React from "react"
import { useState, useEffect } from "react"
import { View, Text, ScrollView, StyleSheet, Switch, Alert, Share } from "react-native"
import { SafeAreaView } from "react-native-safe-area-context"
import AsyncStorage from "@react-native-async-storage/async-storage"

import { SettingsCard } from "../components/SettingsCard"
import { SettingsRow } from "../components/SettingsRow"
import { useTaskStore } from "../store/taskStore"
import { NotificationManager } from "../services/NotificationManager"

export const SettingsScreen: React.FC = () => {
  const { tasks, categories, globalNotificationsEnabled, setGlobalNotifications } = useTaskStore()

  const [isDarkMode, setIsDarkMode] = useState(false)
  const [notificationPermission, setNotificationPermission] = useState(false)

  useEffect(() => {
    // Check notification permission status
    checkNotificationPermission()
  }, [])

  const checkNotificationPermission = async () => {
    // This would check the actual permission status
    // For now, we'll assume it's granted if global notifications are enabled
    setNotificationPermission(globalNotificationsEnabled)
  }

  const handleNotificationToggle = async (enabled: boolean) => {
    if (enabled && !notificationPermission) {
      const granted = await NotificationManager.requestPermission()
      if (granted) {
        setNotificationPermission(true)
        setGlobalNotifications(true)
      } else {
        Alert.alert(
          "Permission Required",
          "Please enable notifications in your device settings to receive task reminders.",
          [{ text: "OK" }],
        )
      }
    } else {
      setGlobalNotifications(enabled)
    }
  }

  const exportData = async () => {
    try {
      const data = {
        tasks,
        categories,
        exportDate: new Date().toISOString(),
      }

      const jsonString = JSON.stringify(data, null, 2)

      await Share.share({
        message: jsonString,
        title: "TaskFlow Data Export",
      })
    } catch (error) {
      Alert.alert("Export Failed", "Unable to export data. Please try again.")
    }
  }

  const clearAllData = () => {
    Alert.alert("Clear All Data", "Are you sure you want to delete all tasks? This action cannot be undone.", [
      { text: "Cancel", style: "cancel" },
      {
        text: "Delete All",
        style: "destructive",
        onPress: async () => {
          try {
            await AsyncStorage.clear()
            Alert.alert("Success", "All data has been cleared.")
            // You might want to reset the store here
          } catch (error) {
            Alert.alert("Error", "Failed to clear data.")
          }
        },
      },
    ])
  }

  const tasksWithNotifications = tasks.filter((task) => task.notifications?.enabled).length

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.scrollView} showsVerticalScrollIndicator={false}>
        {/* Appearance */}
        <SettingsCard title="Appearance" icon="palette">
          <SettingsRow
            title="Dark Mode"
            subtitle="Toggle dark theme"
            icon="dark-mode"
            rightComponent={
              <Switch
                value={isDarkMode}
                onValueChange={setIsDarkMode}
                trackColor={{ false: "#E5E7EB", true: "#8B5CF6" }}
                thumbColor={isDarkMode ? "#FFFFFF" : "#F3F4F6"}
              />
            }
          />
        </SettingsCard>

        {/* Notifications */}
        <SettingsCard title="Notifications" icon="notifications">
          <SettingsRow
            title="Task Notifications"
            subtitle={`Get notified about due tasks (${tasksWithNotifications} tasks enabled)`}
            icon="notifications-active"
            rightComponent={
              <Switch
                value={globalNotificationsEnabled}
                onValueChange={handleNotificationToggle}
                trackColor={{ false: "#E5E7EB", true: "#8B5CF6" }}
                thumbColor={globalNotificationsEnabled ? "#FFFFFF" : "#F3F4F6"}
              />
            }
          />

          <View style={styles.notificationInfo}>
            <Text style={styles.infoTitle}>Notification Features:</Text>
            <Text style={styles.infoText}>• Multiple reminders per task</Text>
            <Text style={styles.infoText}>• Priority-based notifications</Text>
            <Text style={styles.infoText}>• Automatic recurring task scheduling</Text>
            <Text style={styles.infoText}>• Smart notification templates</Text>
          </View>
        </SettingsCard>

        {/* Data Management */}
        <SettingsCard title="Data Management" icon="storage">
          <SettingsRow
            title="Export Data"
            subtitle="Share your tasks and settings"
            icon="file-download"
            onPress={exportData}
            showArrow
          />

          <SettingsRow
            title="Clear All Data"
            subtitle="Delete all tasks and settings"
            icon="delete-forever"
            onPress={clearAllData}
            showArrow
            destructive
          />
        </SettingsCard>

        {/* App Information */}
        <SettingsCard title="About" icon="info">
          <SettingsRow title="Version" subtitle="1.0.0" icon="info-outline" />

          <SettingsRow title="Total Tasks" subtitle={tasks.length.toString()} icon="assignment" />

          <SettingsRow title="Categories" subtitle={categories.length.toString()} icon="category" />

          <SettingsRow
            title="Tasks with Notifications"
            subtitle={tasksWithNotifications.toString()}
            icon="notifications"
          />
        </SettingsCard>

        {/* Support */}
        <SettingsCard title="Support" icon="help">
          <SettingsRow
            title="Help & FAQ"
            subtitle="Get help using TaskFlow"
            icon="help-outline"
            onPress={() => {
              Alert.alert("Help", "Help documentation coming soon!")
            }}
            showArrow
          />

          <SettingsRow
            title="Send Feedback"
            subtitle="Share your thoughts and suggestions"
            icon="feedback"
            onPress={() => {
              Alert.alert("Feedback", "Feedback form coming soon!")
            }}
            showArrow
          />

          <SettingsRow
            title="Rate App"
            subtitle="Rate TaskFlow in the App Store"
            icon="star-rate"
            onPress={() => {
              Alert.alert("Rate App", "App Store rating coming soon!")
            }}
            showArrow
          />
        </SettingsCard>

        {/* Legal */}
        <SettingsCard title="Legal" icon="gavel">
          <SettingsRow
            title="Privacy Policy"
            subtitle="How we handle your data"
            icon="privacy-tip"
            onPress={() => {
              Alert.alert("Privacy Policy", "Privacy policy coming soon!")
            }}
            showArrow
          />

          <SettingsRow
            title="Terms of Service"
            subtitle="Terms and conditions"
            icon="description"
            onPress={() => {
              Alert.alert("Terms of Service", "Terms of service coming soon!")
            }}
            showArrow
          />
        </SettingsCard>
      </ScrollView>
    </SafeAreaView>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#F9FAFB",
  },
  scrollView: {
    flex: 1,
    paddingHorizontal: 16,
  },
  notificationInfo: {
    backgroundColor: "#F3F4F6",
    borderRadius: 8,
    padding: 12,
    marginTop: 12,
  },
  infoTitle: {
    fontSize: 14,
    fontWeight: "600",
    color: "#1F2937",
    marginBottom: 8,
  },
  infoText: {
    fontSize: 12,
    color: "#6B7280",
    marginBottom: 4,
  },
})
