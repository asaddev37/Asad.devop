"use client"

import { useState, useEffect } from "react"
import { MobileHeader } from "@/components/mobile-header"
import { DrawerMenu } from "@/components/drawer-menu"
import { BottomNavigation } from "@/components/bottom-navigation"
import { AddTaskFab } from "@/components/add-task-fab"
import { TaskForm } from "@/components/task-form"
import { DashboardView } from "@/components/dashboard-view"
import { TasksView } from "@/components/tasks-view"
import { CalendarView } from "@/components/calendar-view"
import { StatsView } from "@/components/stats-view"
import { SettingsView } from "@/components/settings-view"
import { useTaskStore } from "@/lib/store"
import { notificationManager } from "@/lib/notification-utils"
import type { Task } from "@/lib/types"

export default function Home() {
  const [isDrawerOpen, setIsDrawerOpen] = useState(false)
  const [currentPage, setCurrentPage] = useState("dashboard")
  const [isTaskFormOpen, setIsTaskFormOpen] = useState(false)
  const [editingTask, setEditingTask] = useState<Task | null>(null)

  const { scheduleAllNotifications, globalNotificationsEnabled } = useTaskStore()

  // Initialize notifications on app load
  useEffect(() => {
    if (globalNotificationsEnabled) {
      // Update permission status
      useTaskStore.setState({
        notificationPermission: notificationManager.getPermissionStatus(),
      })

      // Schedule all notifications
      scheduleAllNotifications()
    }
  }, [globalNotificationsEnabled, scheduleAllNotifications])

  const getPageTitle = () => {
    switch (currentPage) {
      case "dashboard":
        return "Dashboard"
      case "tasks":
        return "Tasks"
      case "calendar":
        return "Calendar"
      case "stats":
        return "Statistics"
      case "settings":
        return "Settings"
      default:
        return "TaskFlow"
    }
  }

  const handleEditTask = (task: Task) => {
    setEditingTask(task)
    setIsTaskFormOpen(true)
  }

  const handleCloseTaskForm = () => {
    setIsTaskFormOpen(false)
    setEditingTask(null)
  }

  const renderCurrentView = () => {
    switch (currentPage) {
      case "dashboard":
        return <DashboardView onEditTask={handleEditTask} />
      case "tasks":
        return <TasksView onEditTask={handleEditTask} />
      case "calendar":
        return <CalendarView onEditTask={handleEditTask} />
      case "stats":
        return <StatsView />
      case "settings":
        return <SettingsView />
      default:
        return <DashboardView onEditTask={handleEditTask} />
    }
  }

  return (
    <div className="mobile-container">
      <MobileHeader
        title={getPageTitle()}
        onMenuClick={() => setIsDrawerOpen(true)}
        showSearch={currentPage === "tasks"}
      />

      <main className="pb-20 min-h-[calc(100vh-3.5rem)]">{renderCurrentView()}</main>

      <BottomNavigation currentPage={currentPage} onNavigate={setCurrentPage} />

      <AddTaskFab onClick={() => setIsTaskFormOpen(true)} />

      <DrawerMenu
        isOpen={isDrawerOpen}
        onClose={() => setIsDrawerOpen(false)}
        currentPage={currentPage}
        onNavigate={setCurrentPage}
      />

      <TaskForm isOpen={isTaskFormOpen} onClose={handleCloseTaskForm} task={editingTask} />
    </div>
  )
}
