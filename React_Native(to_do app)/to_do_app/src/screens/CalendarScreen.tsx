"use client"

import type React from "react"
import { useState, useMemo } from "react"
import { View, Text, StyleSheet, ScrollView } from "react-native"
import { SafeAreaView } from "react-native-safe-area-context"
import { Calendar, type DateData } from "react-native-calendars"
import { useNavigation } from "@react-navigation/native"
import { format, isSameDay } from "date-fns"

import { AnimatedTaskItem } from "../components/AnimatedTaskItem"
import { AnimatedFloatingActionButton } from "../components/AnimatedFloatingActionButton"
import { PinchZoomView } from "../components/gestures/PinchZoomView"
import { PullToRefresh } from "../components/gestures/PullToRefresh"
import { useTaskStore } from "../store/taskStore"
import type { Task } from "../types"

export const CalendarScreen: React.FC = () => {
  const navigation = useNavigation()
  const { tasks } = useTaskStore()
  const [selectedDate, setSelectedDate] = useState(format(new Date(), "yyyy-MM-dd"))
  const [refreshing, setRefreshing] = useState(false)

  const tasksWithDates = useMemo(() => {
    return tasks.filter((task) => task.dueDate)
  }, [tasks])

  const selectedDateTasks = useMemo(() => {
    return tasksWithDates.filter((task) => isSameDay(new Date(task.dueDate!), new Date(selectedDate)))
  }, [tasksWithDates, selectedDate])

  const markedDates = useMemo(() => {
    const marked: { [key: string]: any } = {}

    // Mark dates with tasks
    tasksWithDates.forEach((task) => {
      const dateKey = format(new Date(task.dueDate!), "yyyy-MM-dd")
      if (!marked[dateKey]) {
        marked[dateKey] = {
          marked: true,
          dotColor: "#8B5CF6",
        }
      }
    })

    // Mark selected date
    marked[selectedDate] = {
      ...marked[selectedDate],
      selected: true,
      selectedColor: "#8B5CF6",
      selectedTextColor: "#FFFFFF",
    }

    return marked
  }, [tasksWithDates, selectedDate])

  const handleEditTask = (task: Task) => {
    navigation.navigate("TaskForm", { task })
  }

  const handleAddTask = () => {
    navigation.navigate("TaskForm", {
      defaultDate: selectedDate,
    })
  }

  const handleRefresh = async () => {
    setRefreshing(true)
    // Simulate refresh delay
    await new Promise((resolve) => setTimeout(resolve, 1000))
    setRefreshing(false)
  }

  const onDayPress = (day: DateData) => {
    setSelectedDate(day.dateString)
  }

  return (
    <SafeAreaView style={styles.container}>
      <PullToRefresh onRefresh={handleRefresh} refreshing={refreshing}>
        <ScrollView style={styles.scrollView} showsVerticalScrollIndicator={false}>
          {/* Calendar with Pinch Zoom */}
          <View style={styles.calendarContainer}>
            <PinchZoomView minScale={0.8} maxScale={1.5} onZoomStart={() => console.log("Zoom started")}>
              <Calendar
                current={selectedDate}
                onDayPress={onDayPress}
                markedDates={markedDates}
                theme={{
                  backgroundColor: "#FFFFFF",
                  calendarBackground: "#FFFFFF",
                  textSectionTitleColor: "#6B7280",
                  selectedDayBackgroundColor: "#8B5CF6",
                  selectedDayTextColor: "#FFFFFF",
                  todayTextColor: "#8B5CF6",
                  dayTextColor: "#1F2937",
                  textDisabledColor: "#D1D5DB",
                  dotColor: "#8B5CF6",
                  selectedDotColor: "#FFFFFF",
                  arrowColor: "#8B5CF6",
                  disabledArrowColor: "#D1D5DB",
                  monthTextColor: "#1F2937",
                  indicatorColor: "#8B5CF6",
                  textDayFontFamily: "System",
                  textMonthFontFamily: "System",
                  textDayHeaderFontFamily: "System",
                  textDayFontWeight: "400",
                  textMonthFontWeight: "600",
                  textDayHeaderFontWeight: "600",
                  textDayFontSize: 16,
                  textMonthFontSize: 18,
                  textDayHeaderFontSize: 14,
                }}
                style={styles.calendar}
              />
            </PinchZoomView>
          </View>

          {/* Selected Date Tasks */}
          <View style={styles.tasksSection}>
            <Text style={styles.sectionTitle}>Tasks for {format(new Date(selectedDate), "MMMM d, yyyy")}</Text>

            {selectedDateTasks.length > 0 ? (
              <View style={styles.tasksList}>
                {selectedDateTasks.map((task, index) => (
                  <AnimatedTaskItem key={task.id} task={task} onEdit={handleEditTask} index={index} />
                ))}
              </View>
            ) : (
              <View style={styles.emptyState}>
                <Text style={styles.emptyStateIcon}>📅</Text>
                <Text style={styles.emptyStateTitle}>No tasks scheduled</Text>
                <Text style={styles.emptyStateSubtitle}>No tasks are scheduled for this date</Text>
              </View>
            )}
          </View>

          {/* Calendar Legend */}
          <View style={styles.legendContainer}>
            <Text style={styles.legendTitle}>Legend</Text>
            <View style={styles.legendItem}>
              <View style={[styles.legendDot, { backgroundColor: "#8B5CF6" }]} />
              <Text style={styles.legendText}>Has tasks</Text>
            </View>
            <View style={styles.legendItem}>
              <View
                style={[styles.legendDot, { backgroundColor: "#8B5CF6", borderWidth: 2, borderColor: "#FFFFFF" }]}
              />
              <Text style={styles.legendText}>Selected date</Text>
            </View>
            <Text style={styles.legendHint}>💡 Pinch to zoom calendar • Pull down to refresh</Text>
          </View>
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
  },
  calendarContainer: {
    backgroundColor: "#FFFFFF",
    margin: 16,
    borderRadius: 12,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
    overflow: "hidden",
  },
  calendar: {
    borderRadius: 12,
    paddingBottom: 16,
  },
  tasksSection: {
    paddingHorizontal: 16,
    paddingBottom: 24,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: "600",
    color: "#1F2937",
    marginBottom: 16,
  },
  tasksList: {
    gap: 8,
  },
  emptyState: {
    alignItems: "center",
    paddingVertical: 48,
  },
  emptyStateIcon: {
    fontSize: 48,
    marginBottom: 16,
  },
  emptyStateTitle: {
    fontSize: 18,
    fontWeight: "600",
    color: "#1F2937",
    marginBottom: 8,
  },
  emptyStateSubtitle: {
    fontSize: 16,
    color: "#6B7280",
    textAlign: "center",
  },
  legendContainer: {
    backgroundColor: "#FFFFFF",
    margin: 16,
    marginTop: 0,
    padding: 16,
    borderRadius: 12,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  legendTitle: {
    fontSize: 16,
    fontWeight: "600",
    color: "#1F2937",
    marginBottom: 12,
  },
  legendItem: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: 8,
  },
  legendDot: {
    width: 12,
    height: 12,
    borderRadius: 6,
    marginRight: 12,
  },
  legendText: {
    fontSize: 14,
    color: "#6B7280",
  },
  legendHint: {
    fontSize: 12,
    color: "#9CA3AF",
    fontStyle: "italic",
    marginTop: 8,
  },
})
