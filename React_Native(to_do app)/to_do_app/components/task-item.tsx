"use client"

import { useState } from "react"
import { MoreVertical, Edit, Trash2, Calendar, Repeat, RotateCcw } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Checkbox } from "@/components/ui/checkbox"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
  DropdownMenuSeparator,
} from "@/components/ui/dropdown-menu"
import { Badge } from "@/components/ui/badge"
import { useTaskStore } from "@/lib/store"
import type { Task } from "@/lib/types"
import { format } from "date-fns"
import { getRecurringPatternDescription } from "@/lib/recurring-utils"

interface TaskItemProps {
  task: Task
  onEdit: (task: Task) => void
}

export function TaskItem({ task, onEdit }: TaskItemProps) {
  const { toggleTask, deleteTask, deleteRecurringSeries, categories } = useTaskStore()
  const [isDeleting, setIsDeleting] = useState(false)

  const category = categories.find((c) => c.id === task.category)
  const isOverdue = task.dueDate && new Date(task.dueDate) < new Date() && !task.completed

  const handleDelete = async () => {
    setIsDeleting(true)
    setTimeout(() => {
      deleteTask(task.id)
    }, 150)
  }

  const handleDeleteSeries = async () => {
    if (confirm("Delete this recurring task and all future occurrences?")) {
      setIsDeleting(true)
      setTimeout(() => {
        deleteRecurringSeries(task.parentTaskId || task.id)
      }, 150)
    }
  }

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case "high":
        return "bg-red-500"
      case "medium":
        return "bg-yellow-500"
      case "low":
        return "bg-green-500"
      default:
        return "bg-gray-500"
    }
  }

  return (
    <div
      className={`task-item bg-card border rounded-lg p-4 ${isDeleting ? "opacity-50 scale-95" : ""} ${task.completed ? "opacity-75" : ""}`}
    >
      <div className="flex items-start gap-3">
        <Checkbox checked={task.completed} onCheckedChange={() => toggleTask(task.id)} className="mt-1" />

        <div className="flex-1 min-w-0">
          <div className="flex items-start justify-between gap-2">
            <div className="flex-1">
              <div className="flex items-center gap-2">
                <h3 className={`font-medium ${task.completed ? "line-through text-muted-foreground" : ""}`}>
                  {task.title}
                </h3>
                {task.isRecurring && <Repeat className="h-4 w-4 text-blue-500 flex-shrink-0" />}
              </div>
              {task.description && (
                <p className="text-sm text-muted-foreground mt-1 line-clamp-2">{task.description}</p>
              )}
              {task.isRecurring && task.recurringPattern && (
                <p className="text-xs text-blue-600 dark:text-blue-400 mt-1">
                  {getRecurringPatternDescription(task.recurringPattern)}
                </p>
              )}
            </div>

            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="ghost" size="icon" className="h-8 w-8">
                  <MoreVertical className="h-4 w-4" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end">
                <DropdownMenuItem onClick={() => onEdit(task)}>
                  <Edit className="h-4 w-4 mr-2" />
                  Edit
                </DropdownMenuItem>
                {task.isRecurring && (
                  <>
                    <DropdownMenuSeparator />
                    <DropdownMenuItem onClick={handleDeleteSeries} className="text-destructive">
                      <RotateCcw className="h-4 w-4 mr-2" />
                      Delete Series
                    </DropdownMenuItem>
                  </>
                )}
                <DropdownMenuItem onClick={handleDelete} className="text-destructive">
                  <Trash2 className="h-4 w-4 mr-2" />
                  Delete {task.isRecurring ? "This Instance" : ""}
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>

          <div className="flex items-center gap-2 mt-3 flex-wrap">
            {/* Priority */}
            <div className="flex items-center gap-1">
              <div className={`w-2 h-2 rounded-full ${getPriorityColor(task.priority)}`} />
              <span className="text-xs text-muted-foreground capitalize">{task.priority}</span>
            </div>

            {/* Category */}
            {category && (
              <Badge variant="secondary" className="text-xs">
                <span className="mr-1">{category.icon}</span>
                {category.name}
              </Badge>
            )}

            {/* Due Date */}
            {task.dueDate && (
              <div
                className={`flex items-center gap-1 text-xs ${isOverdue ? "text-red-500" : "text-muted-foreground"}`}
              >
                <Calendar className="h-3 w-3" />
                {format(new Date(task.dueDate), "MMM d")}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
