"use client"

import type React from "react"
import { useMemo } from "react"
import { View, Text, ScrollView, StyleSheet } from "react-native"
import { SafeAreaView } from "react-native-safe-area-context"
import { ProgressBar } from "../components/ProgressBar"
import { CategoryStatsCard } from "../components/CategoryStatsCard"
import { PriorityStatsCard } from "../components/PriorityStatsCard"
import { useTaskStore } from "../store/taskStore"

export const StatsScreen: React.FC = () => {
  const tasks = useTaskStore((state) => state.tasks)
  const categories = useTaskStore((state) => state.categories)

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

  const categoryStats = useMemo(() => {
    return categories
      .map((category) => {
        const categoryTasks = tasks.filter((task) => task.category === category.id)
        const completed = categoryTasks.filter((task) => task.completed).length
        const total = categoryTasks.length
        const completionRate = total > 0 ? Math.round((completed / total) * 100) : 0

        return {
          ...category,
          total,
          completed,
          completionRate,
        }
      })
      .filter((cat) => cat.total > 0)
  }, [tasks, categories])

  const priorityStats = useMemo(() => {
    return ["high", "medium", "low"]
      .map((priority) => {
        const priorityTasks = tasks.filter((task) => task.priority === priority)
        const completed = priorityTasks.filter((task) => task.completed).length
        const total = priorityTasks.length

        return {
          priority,
          total,
          completed,
          completionRate: total > 0 ? Math.round((completed / total) * 100) : 0,
        }
      })
      .filter((stat) => stat.total > 0)
  }, [tasks])

  if (tasks.length === 0) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.emptyState}>
          <Text style={styles.emptyStateIcon}>📊</Text>
          <Text style={styles.emptyStateTitle}>No data yet</Text>
          <Text style={styles.emptyStateSubtitle}>Create some tasks to see your statistics</Text>
        </View>
      </SafeAreaView>
    )
  }

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.scrollView} showsVerticalScrollIndicator={false}>
        {/* Overall Stats */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Overall Statistics</Text>

          <View style={styles.overallStatsContainer}>
            <View style={styles.statsGrid}>
              <View style={styles.statItem}>
                <Text style={styles.statValue}>{stats.completed}</Text>
                <Text style={styles.statLabel}>Completed</Text>
              </View>
              <View style={styles.statItem}>
                <Text style={styles.statValue}>{stats.pending}</Text>
                <Text style={styles.statLabel}>Pending</Text>
              </View>
            </View>

            <View style={styles.progressContainer}>
              <View style={styles.progressHeader}>
                <Text style={styles.progressLabel}>Completion Rate</Text>
                <Text style={styles.progressValue}>{stats.completionRate}%</Text>
              </View>
              <ProgressBar progress={stats.completionRate} />
            </View>
          </View>
        </View>

        {/* Category Stats */}
        {categoryStats.length > 0 && (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Categories</Text>
            <View style={styles.categoryStatsContainer}>
              {categoryStats.map((category) => (
                <CategoryStatsCard key={category.id} category={category} />
              ))}
            </View>
          </View>
        )}

        {/* Priority Stats */}
        {priorityStats.length > 0 && (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Priority Breakdown</Text>
            <View style={styles.priorityStatsContainer}>
              {priorityStats.map((stat) => (
                <PriorityStatsCard key={stat.priority} stat={stat} />
              ))}
            </View>
          </View>
        )}

        {/* Additional Insights */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Insights</Text>
          <View style={styles.insightsContainer}>
            <View style={styles.insightCard}>
              <Text style={styles.insightTitle}>Most Productive Category</Text>
              <Text style={styles.insightValue}>
                {categoryStats.length > 0
                  ? categoryStats.reduce((prev, current) =>
                      prev.completionRate > current.completionRate ? prev : current,
                    ).name
                  : "N/A"}
              </Text>
            </View>

            <View style={styles.insightCard}>
              <Text style={styles.insightTitle}>Tasks This Week</Text>
              <Text style={styles.insightValue}>
                {
                  tasks.filter((task) => {
                    const taskDate = new Date(task.createdAt)
                    const weekAgo = new Date()
                    weekAgo.setDate(weekAgo.getDate() - 7)
                    return taskDate >= weekAgo
                  }).length
                }
              </Text>
            </View>

            <View style={styles.insightCard}>
              <Text style={styles.insightTitle}>Average Daily Tasks</Text>
              <Text style={styles.insightValue}>
                {Math.round(
                  tasks.length /
                    Math.max(
                      1,
                      Math.ceil(
                        (Date.now() - new Date(tasks[0]?.createdAt || Date.now()).getTime()) / (1000 * 60 * 60 * 24),
                      ),
                    ),
                )}
              </Text>
            </View>
          </View>
        </View>
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
  section: {
    marginBottom: 24,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: "600",
    color: "#1F2937",
    marginBottom: 16,
  },
  overallStatsContainer: {
    backgroundColor: "#FFFFFF",
    borderRadius: 12,
    padding: 20,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  statsGrid: {
    flexDirection: "row",
    justifyContent: "space-around",
    marginBottom: 20,
  },
  statItem: {
    alignItems: "center",
  },
  statValue: {
    fontSize: 32,
    fontWeight: "bold",
    color: "#1F2937",
    marginBottom: 4,
  },
  statLabel: {
    fontSize: 14,
    color: "#6B7280",
  },
  progressContainer: {
    marginTop: 8,
  },
  progressHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 12,
  },
  progressLabel: {
    fontSize: 16,
    color: "#6B7280",
  },
  progressValue: {
    fontSize: 16,
    fontWeight: "600",
    color: "#1F2937",
  },
  categoryStatsContainer: {
    gap: 12,
  },
  priorityStatsContainer: {
    gap: 12,
  },
  insightsContainer: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 12,
  },
  insightCard: {
    backgroundColor: "#FFFFFF",
    borderRadius: 12,
    padding: 16,
    flex: 1,
    minWidth: "45%",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  insightTitle: {
    fontSize: 14,
    color: "#6B7280",
    marginBottom: 8,
  },
  insightValue: {
    fontSize: 20,
    fontWeight: "600",
    color: "#1F2937",
  },
  emptyState: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    paddingHorizontal: 32,
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
  },
})
