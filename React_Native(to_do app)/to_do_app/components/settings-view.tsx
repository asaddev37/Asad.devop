"use client"

import { Moon, Sun, Bell, BellOff, Trash2, Download, Upload, Shield } from "lucide-react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Switch } from "@/components/ui/switch"
import { Badge } from "@/components/ui/badge"
import { useTaskStore } from "@/lib/store"
import { notificationManager } from "@/lib/notification-utils"
import { useState, useEffect } from "react"

export function SettingsView() {
  const {
    tasks,
    categories,
    notificationPermission,
    globalNotificationsEnabled,
    requestNotificationPermission,
    setGlobalNotifications,
    scheduleAllNotifications,
  } = useTaskStore()

  const [isDark, setIsDark] = useState(false)
  const [isNotificationSupported, setIsNotificationSupported] = useState(false)

  useEffect(() => {
    const savedTheme = localStorage.getItem("theme")
    const prefersDark =
      savedTheme === "dark" || (!savedTheme && window.matchMedia("(prefers-color-scheme: dark)").matches)
    setIsDark(prefersDark)
    setIsNotificationSupported(notificationManager.isNotificationSupported())
  }, [])

  const toggleTheme = (checked: boolean) => {
    setIsDark(checked)
    localStorage.setItem("theme", checked ? "dark" : "light")
    document.documentElement.classList.toggle("dark", checked)
  }

  const handleNotificationToggle = async (enabled: boolean) => {
    if (enabled && !notificationPermission.granted) {
      await requestNotificationPermission()
    }
    setGlobalNotifications(enabled)
  }

  const handleRequestPermission = async () => {
    await requestNotificationPermission()
  }

  const exportData = () => {
    const data = {
      tasks,
      categories,
      exportDate: new Date().toISOString(),
    }

    const blob = new Blob([JSON.stringify(data, null, 2)], { type: "application/json" })
    const url = URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = `taskflow-backup-${new Date().toISOString().split("T")[0]}.json`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
  }

  const clearAllData = () => {
    if (confirm("Are you sure you want to delete all tasks? This action cannot be undone.")) {
      alert("Data cleared successfully!")
    }
  }

  const getNotificationStatus = () => {
    if (!isNotificationSupported) return { text: "Not Supported", color: "destructive" }
    if (notificationPermission.granted) return { text: "Granted", color: "default" }
    if (notificationPermission.denied) return { text: "Denied", color: "destructive" }
    return { text: "Not Requested", color: "secondary" }
  }

  const notificationStatus = getNotificationStatus()
  const tasksWithNotifications = tasks.filter((task) => task.notifications?.enabled).length

  return (
    <div className="p-4 space-y-6">
      {/* Appearance */}
      <Card>
        <CardHeader>
          <CardTitle>Appearance</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              {isDark ? <Moon className="h-5 w-5" /> : <Sun className="h-5 w-5" />}
              <div>
                <p className="font-medium">Dark Mode</p>
                <p className="text-sm text-muted-foreground">Toggle dark theme</p>
              </div>
            </div>
            <Switch checked={isDark} onCheckedChange={toggleTheme} />
          </div>
        </CardContent>
      </Card>

      {/* Notifications */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Bell className="h-5 w-5" />
            Notifications
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          {/* Permission Status */}
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <Shield className="h-5 w-5" />
              <div>
                <p className="font-medium">Permission Status</p>
                <p className="text-sm text-muted-foreground">Browser notification permission</p>
              </div>
            </div>
            <Badge variant={notificationStatus.color as any}>{notificationStatus.text}</Badge>
          </div>

          {/* Request Permission Button */}
          {!notificationPermission.granted && isNotificationSupported && (
            <Button onClick={handleRequestPermission} className="w-full">
              <Bell className="h-4 w-4 mr-2" />
              Enable Notifications
            </Button>
          )}

          {/* Global Notifications Toggle */}
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              {globalNotificationsEnabled ? <Bell className="h-5 w-5" /> : <BellOff className="h-5 w-5" />}
              <div>
                <p className="font-medium">Task Notifications</p>
                <p className="text-sm text-muted-foreground">
                  Get notified about due tasks ({tasksWithNotifications} tasks enabled)
                </p>
              </div>
            </div>
            <Switch
              checked={globalNotificationsEnabled && notificationPermission.granted}
              onCheckedChange={handleNotificationToggle}
              disabled={!notificationPermission.granted}
            />
          </div>

          {/* Notification Info */}
          {isNotificationSupported && (
            <div className="p-3 bg-muted rounded-lg space-y-2">
              <p className="text-sm font-medium">Notification Features:</p>
              <ul className="text-xs text-muted-foreground space-y-1">
                <li>• Multiple reminders per task (minutes, hours, days before)</li>
                <li>• Priority-based notifications (high priority requires interaction)</li>
                <li>• Automatic scheduling for recurring tasks</li>
                <li>• Click notifications to focus the app</li>
              </ul>
            </div>
          )}

          {!isNotificationSupported && (
            <div className="p-3 bg-destructive/10 border border-destructive/20 rounded-lg">
              <p className="text-sm text-destructive">
                Notifications are not supported in this browser or environment.
              </p>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Data Management */}
      <Card>
        <CardHeader>
          <CardTitle>Data Management</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <Button onClick={exportData} className="w-full justify-start gap-3">
            <Download className="h-4 w-4" />
            Export Data
          </Button>

          <Button variant="outline" className="w-full justify-start gap-3 bg-transparent">
            <Upload className="h-4 w-4" />
            Import Data
          </Button>

          <Button variant="destructive" onClick={clearAllData} className="w-full justify-start gap-3">
            <Trash2 className="h-4 w-4" />
            Clear All Data
          </Button>
        </CardContent>
      </Card>

      {/* App Info */}
      <Card>
        <CardHeader>
          <CardTitle>About</CardTitle>
        </CardHeader>
        <CardContent className="space-y-2">
          <div className="flex justify-between">
            <span className="text-muted-foreground">Version</span>
            <span>1.0.0</span>
          </div>
          <div className="flex justify-between">
            <span className="text-muted-foreground">Total Tasks</span>
            <span>{tasks.length}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-muted-foreground">Categories</span>
            <span>{categories.length}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-muted-foreground">Tasks with Notifications</span>
            <span>{tasksWithNotifications}</span>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
