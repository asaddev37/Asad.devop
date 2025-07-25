"use client"

import { Calendar } from "@/components/ui/calendar"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { TaskItem } from "@/components/task-item"
import { useTaskStore } from "@/lib/store"
import type { Task } from "@/lib/types"
import { useState } from "react"
import { format, isSameDay } from "date-fns"

interface CalendarViewProps {
  onEditTask: (task: Task) => void
}

export function CalendarView({ onEditTask }: CalendarViewProps) {
  const { tasks } = useTaskStore()
  const [selectedDate, setSelectedDate] = useState<Date>(new Date())

  const tasksWithDates = tasks.filter((task) => task.dueDate)
  const selectedDateTasks = tasksWithDates.filter((task) => isSameDay(new Date(task.dueDate!), selectedDate))

  const taskDates = tasksWithDates.map((task) => new Date(task.dueDate!))

  return (
    <div className="p-4 space-y-6">
      <Card>
        <CardHeader>
          <CardTitle className="text-center">{format(selectedDate, "MMMM yyyy")}</CardTitle>
        </CardHeader>
        <CardContent>
          <Calendar
            mode="single"
            selected={selectedDate}
            onSelect={(date) => date && setSelectedDate(date)}
            modifiers={{
              hasTask: taskDates,
            }}
            modifiersStyles={{
              hasTask: {
                backgroundColor: "hsl(var(--primary))",
                color: "hsl(var(--primary-foreground))",
                borderRadius: "50%",
              },
            }}
            className="w-full"
          />
        </CardContent>
      </Card>

      <div>
        <h3 className="font-semibold mb-3">Tasks for {format(selectedDate, "MMMM d, yyyy")}</h3>

        {selectedDateTasks.length > 0 ? (
          <div className="space-y-3">
            {selectedDateTasks.map((task) => (
              <TaskItem key={task.id} task={task} onEdit={onEditTask} />
            ))}
          </div>
        ) : (
          <div className="text-center py-8">
            <div className="text-4xl mb-2">📅</div>
            <p className="text-muted-foreground">No tasks scheduled for this date</p>
          </div>
        )}
      </div>
    </div>
  )
}
