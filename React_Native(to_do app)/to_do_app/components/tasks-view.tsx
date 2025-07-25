"use client"

import { useState } from "react"
import { Search, Filter, SortAsc, Repeat } from "lucide-react"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { TaskItem } from "@/components/task-item"
import { useTaskStore } from "@/lib/store"
import type { Task } from "@/lib/types"

interface TasksViewProps {
  onEditTask: (task: Task) => void
}

export function TasksView({ onEditTask }: TasksViewProps) {
  const { tasks } = useTaskStore()
  const [searchQuery, setSearchQuery] = useState("")
  const [showCompleted, setShowCompleted] = useState(false)
  const [showRecurringOnly, setShowRecurringOnly] = useState(false)
  const [sortBy, setSortBy] = useState<"created" | "due" | "priority">("created")

  const filteredTasks = tasks
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

  const recurringTasksCount = tasks.filter((task) => task.isRecurring).length

  return (
    <div className="p-4 space-y-4">
      {/* Search */}
      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
        <Input
          placeholder="Search tasks..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="pl-10"
        />
      </div>

      {/* Filters */}
      <div className="flex gap-2 overflow-x-auto pb-2">
        <Button
          variant={showCompleted ? "default" : "outline"}
          size="sm"
          onClick={() => setShowCompleted(!showCompleted)}
        >
          <Filter className="h-4 w-4 mr-2" />
          {showCompleted ? "All" : "Active"}
        </Button>

        <Button
          variant={showRecurringOnly ? "default" : "outline"}
          size="sm"
          onClick={() => setShowRecurringOnly(!showRecurringOnly)}
        >
          <Repeat className="h-4 w-4 mr-2" />
          Recurring ({recurringTasksCount})
        </Button>

        <Button
          variant="outline"
          size="sm"
          onClick={() => {
            const nextSort = sortBy === "created" ? "due" : sortBy === "due" ? "priority" : "created"
            setSortBy(nextSort)
          }}
        >
          <SortAsc className="h-4 w-4 mr-2" />
          {sortBy === "created" ? "Recent" : sortBy === "due" ? "Due Date" : "Priority"}
        </Button>
      </div>

      {/* Task List */}
      <div className="space-y-3">
        {filteredTasks.map((task) => (
          <TaskItem key={task.id} task={task} onEdit={onEditTask} />
        ))}
      </div>

      {/* Empty State */}
      {filteredTasks.length === 0 && (
        <div className="text-center py-12">
          <div className="text-6xl mb-4">
            {searchQuery ? "🔍" : showRecurringOnly ? "🔄" : tasks.length === 0 ? "📝" : "✅"}
          </div>
          <h3 className="text-lg font-semibold mb-2">
            {searchQuery
              ? "No tasks found"
              : showRecurringOnly
                ? "No recurring tasks"
                : tasks.length === 0
                  ? "No tasks yet"
                  : "All done!"}
          </h3>
          <p className="text-muted-foreground">
            {searchQuery
              ? "Try adjusting your search terms"
              : showRecurringOnly
                ? "Create a recurring task to see it here"
                : tasks.length === 0
                  ? "Create your first task to get started"
                  : "Great job completing all your tasks!"}
          </p>
        </div>
      )}
    </div>
  )
}
