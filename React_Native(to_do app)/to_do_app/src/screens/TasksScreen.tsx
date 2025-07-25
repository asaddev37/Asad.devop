"use client"

import type React from "react"
import { useState, useMemo } from "react"
import { View, Text, StyleSheet, TextInput, TouchableOpacity, FlatList, ScrollView } from "react-native"
import { SafeAreaView } from "react-native-safe-area-context"
import Icon from "react-native-vector-icons/MaterialIcons"
import { useNavigation } from "@react-navigation/native"

import { AnimatedTaskItem } from "../components/AnimatedTaskItem"
import { AnimatedFloatingActionButton } from "../components/AnimatedFloatingActionButton"
import { FilterChip } from "../components/FilterChip"
import { AnimatedView } from "../components/AnimatedView"
import { PullToRefresh } from "../components/gestures/PullToRefresh"
import { SwipeableRow } from "../components/gestures/SwipeableRow"
import { LongPressMenu } from "../components/gestures/LongPressMenu"
import { useTaskStore } from "../store/taskStore"
import type { Task } from "../types"

export const TasksScreen: React.FC = () => {
  const navigation = useNavigation()
  const { tasks, toggleTask, deleteTask, deleteRecurringSeries } = useTaskStore()
  const [searchQuery, setSearchQuery] = useState("")
  const [showCompleted, setShowCompleted] = useState(false)
  const [showRecurringOnly, setShowRecurringOnly] = useState(false)
  const [sortBy, setSortBy] = useState<"created" | "due" | "priority">("created")
  const [refreshing, setRefreshing] = useState(false)

  const filteredTasks = useMemo(() => {
    return tasks
      .filter((task) => {
        const matchesSearch =
          task.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
          task.description?.toLowerCase().includes(searchQuery.toLowerCase())
        const matchesCompleted = showCompleted || !task.completed
        const matchesRecurring = !showRecurringOnly || task.isRecurring
        return matchesSearch && matchesCompleted && matchesRecurring
      })
      .sort((a, b) => {
        switch (sortBy) {
          case "due":
            if (!a.dueDate && !b.dueDate) return 0
            if (!a.dueDate) return 1
            if (!b.dueDate) return -1
            return new Date(a.dueDate).getTime() - new Date(b.dueDate).getTime()
          case "priority":
            const priorityOrder = { high: 3, medium: 2, low: 1 }
            return priorityOrder[b.priority] - priorityOrder[a.priority]
          default:
            return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
        }
      })
  }, [tasks, searchQuery, showCompleted, showRecurringOnly, sortBy])

  const recurringTasksCount = useMemo(() => {
    return tasks.filter((task) => task.isRecurring).length
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
    await new Promise((resolve) => setTimeout(resolve, 1500))
    setRefreshing(false)
  }

  const cycleSortBy = () => {
    const nextSort = sortBy === "created" ? "due" : sortBy === "due" ? "priority" : "created"
    setSortBy(nextSort)
  }

  const getSortLabel = () => {
    switch (sortBy) {
      case "created":
        return "Recent"
      case "due":
        return "Due Date"
      case "priority":
        return "Priority"
      default:
        return "Recent"
    }
  }

  const getSwipeActions = (task: Task) => {
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

    if (task.isRecurring) {
      rightActions.splice(1, 0, {
        id: "delete-series",
        title: "Delete Series",
        icon: "delete-sweep",
        color: "#FFFFFF",
        backgroundColor: "#F59E0B",
        onPress: () => deleteRecurringSeries(task.parentTaskId || task.id),
      })
    }

    return { leftActions, rightActions }
  }

  const getLongPressActions = (task: Task) => [
    {
      id: "edit",
      title: "Edit Task",
      icon: "edit",
      onPress: () => handleEditTask(task),
    },
    {
      id: "duplicate",
      title: "Duplicate",
      icon: "content-copy",
      onPress: () => {
        // Implement duplicate functionality
        console.log("Duplicate task:", task.id)
      },
    },
    {
      id: "share",
      title: "Share",
      icon: "share",
      onPress: () => {
        // Implement share functionality
        console.log("Share task:", task.id)
      },
    },
    {
      id: "delete",
      title: "Delete",
      icon: "delete",
      color: "#EF4444",
      onPress: () => deleteTask(task.id),
    },
  ]

  const renderEmptyState = () => {
    const icon = searchQuery ? "🔍" : showRecurringOnly ? "🔄" : tasks.length === 0 ? "📝" : "✅"
    const title = searchQuery
      ? "No tasks found"
      : showRecurringOnly
        ? "No recurring tasks"
        : tasks.length === 0
          ? "No tasks yet"
          : "All done!"
    const subtitle = searchQuery
      ? "Try adjusting your search terms"
      : showRecurringOnly
        ? "Create a recurring task to see it here"
        : tasks.length === 0
          ? "Create your first task to get started"
          : "Great job completing all your tasks!"

    return (
      <AnimatedView animation="scaleIn" style={styles.emptyState}>
        <Text style={styles.emptyStateIcon}>{icon}</Text>
        <Text style={styles.emptyStateTitle}>{title}</Text>
        <Text style={styles.emptyStateSubtitle}>{subtitle}</Text>
      </AnimatedView>
    )
  }

  const renderTaskItem = ({ item, index }: { item: Task; index: number }) => {
    const { leftActions, rightActions } = getSwipeActions(item)
    const longPressActions = getLongPressActions(item)

    return (
      <SwipeableRow leftActions={leftActions} rightActions={rightActions}>
        <LongPressMenu actions={longPressActions}>
          <AnimatedTaskItem key={item.id} task={item} onEdit={handleEditTask} index={index} />
        </LongPressMenu>
      </SwipeableRow>
    )
  }

  return (
    <SafeAreaView style={styles.container}>
      <PullToRefresh onRefresh={handleRefresh} refreshing={refreshing}>
        {/* Search Bar */}
        <AnimatedView animation="slideInDown" style={styles.searchContainer}>
          <View style={styles.searchInputContainer}>
            <Icon name="search" size={20} color="#6B7280" style={styles.searchIcon} />
            <TextInput
              style={styles.searchInput}
              placeholder="Search tasks..."
              value={searchQuery}
              onChangeText={setSearchQuery}
              placeholderTextColor="#9CA3AF"
            />
            {searchQuery.length > 0 && (
              <TouchableOpacity onPress={() => setSearchQuery("")} style={styles.clearButton}>
                <Icon name="clear" size={20} color="#6B7280" />
              </TouchableOpacity>
            )}
          </View>
        </AnimatedView>

        {/* Filters */}
        <AnimatedView animation="slideInLeft" delay={200} style={styles.filtersContainer}>
          <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.filtersContent}>
            <FilterChip
              label={showCompleted ? "All" : "Active"}
              icon="filter-list"
              active={showCompleted}
              onPress={() => setShowCompleted(!showCompleted)}
            />
            <FilterChip
              label={`Recurring (${recurringTasksCount})`}
              icon="repeat"
              active={showRecurringOnly}
              onPress={() => setShowRecurringOnly(!showRecurringOnly)}
            />
            <FilterChip label={getSortLabel()} icon="sort" active={false} onPress={cycleSortBy} />
          </ScrollView>
        </AnimatedView>

        {/* Task List */}
        <View style={styles.listContainer}>
          {filteredTasks.length > 0 ? (
            <FlatList
              data={filteredTasks}
              renderItem={renderTaskItem}
              keyExtractor={(item) => item.id}
              showsVerticalScrollIndicator={false}
              contentContainerStyle={styles.listContent}
              ItemSeparatorComponent={() => <View style={styles.separator} />}
            />
          ) : (
            renderEmptyState()
          )}
        </View>
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
  searchContainer: {
    paddingHorizontal: 16,
    paddingVertical: 12,
  },
  searchInputContainer: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "#FFFFFF",
    borderRadius: 12,
    paddingHorizontal: 12,
    paddingVertical: 8,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  searchIcon: {
    marginRight: 8,
  },
  searchInput: {
    flex: 1,
    fontSize: 16,
    color: "#1F2937",
    paddingVertical: 4,
  },
  clearButton: {
    padding: 4,
  },
  filtersContainer: {
    paddingHorizontal: 16,
    marginBottom: 8,
  },
  filtersContent: {
    paddingRight: 16,
  },
  listContainer: {
    flex: 1,
    paddingHorizontal: 16,
  },
  listContent: {
    paddingBottom: 100,
  },
  separator: {
    height: 8,
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
    textAlign: "center",
  },
  emptyStateSubtitle: {
    fontSize: 16,
    color: "#6B7280",
    textAlign: "center",
    lineHeight: 24,
  },
})
