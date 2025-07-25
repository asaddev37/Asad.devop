"use client"

import { useState } from "react"

import type React from "react"
import { useMemo } from "react"
import { View, Text, ScrollView, StyleSheet } from "react-native"
import { SafeAreaView } from "react-native-safe-area-context"
import Icon from "react-native-vector-icons/MaterialIcons"
import { useNavigation } from "@react-navigation/native"

import { AnimatedTaskItem } from "../components/AnimatedTaskItem"
import { AnimatedStatsCard } from "../components/AnimatedStatsCard"
import { AnimatedProgressBar } from "../components/AnimatedProgressBar"
import { AnimatedFloatingActionButton } from "../components/AnimatedFloatingActionButton"
import { AnimatedView } from "../components/AnimatedView"
import { PullToRefresh } from "../components/gestures/PullToRefresh"
import { SwipeableRow } from "../components/gestures/SwipeableRow"
import { useTaskStore } from "../store/taskStore"
import type { Task } from "../types"

export const DashboardScreen: React.FC = () => {
  const navigation = useNavigation()
  const { tasks, toggleTask, deleteTask } = useTaskStore()
  const [refreshing, setRefreshing] = useState(false)

  const stats = useMemo(() => {
    const total = tasks.length
    const completed = tasks.filter((task) => task.completed).length
    const pending = total - completed
    const overdue = tasks.filter((task) => {
      if (!task.dueDate || task.completed) return false
      return new Date(task.dueDate) < new Date()
    }).length

    return {
      total,
      completed,
      pending,
      overdue,
      completionRate: total > 0 ? Math.round((completed / total) * 100) : 0,
    }
  }, [tasks])

  const recentTasks = useMemo(() => {
    return tasks
      .filter((task) => !task.completed)
      .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
      .slice(0, 3)
  }, [tasks])

  const upcomingTasks = useMemo(() => {
    return tasks
      .filter((task) => !task.completed && task.dueDate)
      .sort((a, b) => new Date(a.dueDate!).getTime() - new Date(b.dueDate!).getTime())
      .slice(0, 3)
  }, [tasks])

  const tasksWithNotifications = useMemo(() => {
    return tasks.filter((task) => task.notifications?.enabled).length
  }, [tasks])

  const handleEditTask = (task: Task) => {
    navigation.navigate("TaskForm", { task })
  }

  const handleAddTask = () => {
    navigation.navigate("TaskForm")
  }

  const handleRefresh = async () => {
    setRefreshing(true)
    // Simulate refresh delay
    await new Promise((resolve) => setTimeout(resolve, 1200))
    setRefreshing(false)
  }

  const getTaskSwipeActions = (task: Task) => {
    const leftActions = [
      {
        id: "complete",
        title: task.completed ? "Undo" : "Complete",
        icon: task.completed ? "undo" : "check",
        color: "#FFFFFF",
        backgroundColor: "#10B981",
        onPress: () => toggleTask(task.id),
      },
    ]

    const rightActions = [
      {
        id: "edit",
        title: "Edit",
        icon: "edit",
        color: "#FFFFFF",
        backgroundColor: "#3B82F6",
        onPress: () => handleEditTask(task),
      },
      {
        id: "delete",
        title: "Delete",
        icon: "delete",
        color: "#FFFFFF",
        backgroundColor: "#EF4444",
        onPress: () => deleteTask(task.id),
      },
    ]

    return { leftActions, rightActions }
  }

  return (
    <SafeAreaView style={styles.container}>
      <PullToRefresh onRefresh={handleRefresh} refreshing={refreshing}>
        <ScrollView style={styles.scrollView} showsVerticalScrollIndicator={false}>
          {/* Welcome Section */}
          <AnimatedView animation="slideInDown" style={styles.welcomeSection}>
            <Text style={styles.welcomeTitle}>Good morning! 👋</Text>
            <Text style={styles.welcomeSubtitle}>You have {stats.pending} tasks pending today</Text>
            {tasksWithNotifications > 0 && (
              <AnimatedView animation="fadeIn" delay={300} style={styles.notificationInfo}>
                <Icon name="notifications" size={16} color="#3B82F6" />
                <Text style={styles.notificationText}>{tasksWithNotifications} tasks with notifications</Text>
              </AnimatedView>
            )}
          </AnimatedView>

          {/* Stats Cards */}
          <View style={styles.statsGrid}>
            <AnimatedStatsCard
              title="Completed"
              value={stats.completed}
              icon="check-circle"
              color="#10B981"
              backgroundColor="#ECFDF5"
              index={0}
            />
            <AnimatedStatsCard
              title="Pending"
              value={stats.pending}
              icon="schedule"
              color="#3B82F6"
              backgroundColor="#EFF6FF"
              index={1}
            />
            <AnimatedStatsCard
              title="Overdue"
              value={stats.overdue}
              icon="warning"
              color="#EF4444"
              backgroundColor="#FEF2F2"
              index={2}
            />
            <AnimatedStatsCard
              title="Success Rate"
              value={`${stats.completionRate}%`}
              icon="trending-up"
              color="#8B5CF6"
              backgroundColor="#F3E8FF"
              index={3}
            />
          </View>

          {/* Progress */}
          <AnimatedView animation="slideInUp" delay={600} style={styles.progressSection}>
            <Text style={styles.sectionTitle}>Today's Progress</Text>
            <View style={styles.progressContainer}>
              <View style={styles.progressHeader}>
                <Text style={styles.progressLabel}>Completed Tasks</Text>
                <Text style={styles.progressValue}>
                  {stats.completed}/{stats.total}
                </Text>
              </View>
              <AnimatedProgressBar progress={stats.completionRate} />
            </View>
          </AnimatedView>

          {/* Recent Tasks */}
          {recentTasks.length > 0 && (
            <AnimatedView animation="slideInUp" delay={800} style={styles.section}>
              <Text style={styles.sectionTitle}>Recent Tasks</Text>
              {recentTasks.map((task, index) => {
                const { leftActions, rightActions } = getTaskSwipeActions(task)
                return (
                  <SwipeableRow key={task.id} leftActions={leftActions} rightActions={rightActions}>
                    <AnimatedTaskItem task={task} onEdit={handleEditTask} index={index} />
                  </SwipeableRow>
                )
              })}
            </AnimatedView>
          )}

          {/* Upcoming Tasks */}
          {upcomingTasks.length > 0 && (
            <AnimatedView animation="slideInUp" delay={1000} style={styles.section}>
              <Text style={styles.sectionTitle}>Upcoming Deadlines</Text>
              {upcomingTasks.map((task, index) => {
                const { leftActions, rightActions } = getTaskSwipeActions(task)
                return (
                  <SwipeableRow key={task.id} leftActions={leftActions} rightActions={rightActions}>
                    <AnimatedTaskItem task={task} onEdit={handleEditTask} index={index} />
                  </SwipeableRow>
                )
              })}
            </AnimatedView>
          )}

          {/* Empty State */}
          {tasks.length === 0 && (
            <AnimatedView animation="scaleIn" delay={500} style={styles.emptyState}>
              <Text style={styles.emptyStateIcon}>📝</Text>
              <Text style={styles.emptyStateTitle}>No tasks yet</Text>
              <Text style={styles.emptyStateSubtitle}>Create your first task to get started</Text>
              <Text style={styles.gestureHint}>💡 Pull down to refresh • Swipe tasks for quick actions</Text>
            </AnimatedView>
          )}
        </ScrollView>
      </PullToRefresh>

      <AnimatedFloatingActionButton onPress={handleAddTask} />
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
  welcomeSection: {
    paddingVertical: 24,
    alignItems: "center",
  },
  welcomeTitle: {
    fontSize: 24,
    fontWeight: "bold",
    color: "#1F2937",
    marginBottom: 8,
  },
  welcomeSubtitle: {
    fontSize: 16,
    color: "#6B7280",
    textAlign: "center",
  },
  notificationInfo: {
    flexDirection: "row",
    alignItems: "center",
    marginTop: 8,
  },
  notificationText: {
    fontSize: 14,
    color: "#3B82F6",
    marginLeft: 4,
  },
  statsGrid: {
    flexDirection: "row",
    flexWrap: "wrap",
    justifyContent: "space-between",
    marginBottom: 24,
  },
  progressSection: {
    marginBottom: 24,
  },
  progressContainer: {
    backgroundColor: "#FFFFFF",
    borderRadius: 12,
    padding: 16,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  progressHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 12,
  },
  progressLabel: {
    fontSize: 14,
    color: "#6B7280",
  },
  progressValue: {
    fontSize: 14,
    fontWeight: "600",
    color: "#1F2937",
  },
  section: {
    marginBottom: 24,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: "600",
    color: "#1F2937",
    marginBottom: 12,
  },
  emptyState: {
    alignItems: "center",
    paddingVertical: 48,
  },
  emptyStateIcon: {
    fontSize: 64,
    marginBottom: 16,
  },
  emptyStateTitle: {
    fontSize: 20,
    fontWeight: "600",
    color: "#1F2937",
    marginBottom: 8,
  },
  emptyStateSubtitle: {
    fontSize: 16,
    color: "#6B7280",
    textAlign: "center",
    marginBottom: 16,
  },
  gestureHint: {
    fontSize: 12,
    color: "#9CA3AF",
    fontStyle: "italic",
    textAlign: "center",
  },
})
