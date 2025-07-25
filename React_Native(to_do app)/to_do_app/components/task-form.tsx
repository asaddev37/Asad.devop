"use client"

import type React from "react"
import { useState, useEffect } from "react"
import { X, Calendar, Flag, Tag } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { RecurringForm } from "@/components/recurring-form"
import { NotificationSettings } from "@/components/notification-settings"
import { useTaskStore } from "@/lib/store"
import type { Task, RecurringPattern, NotificationSettings as NotificationSettingsType } from "@/lib/types"
import { notificationManager } from "@/lib/notification-utils"

interface TaskFormProps {
  isOpen: boolean
  onClose: () => void
  task?: Task | null
}

export function TaskForm({ isOpen, onClose, task }: TaskFormProps) {
  const { addTask, updateTask, categories } = useTaskStore()
  const [formData, setFormData] = useState({
    title: "",
    description: "",
    priority: "medium" as "low" | "medium" | "high",
    category: "",
    dueDate: "",
    isRecurring: false,
    recurringPattern: undefined as RecurringPattern | undefined,
    notifications: undefined as NotificationSettingsType | undefined,
  })

  useEffect(() => {
    if (task) {
      setFormData({
        title: task.title,
        description: task.description || "",
        priority: task.priority,
        category: task.category,
        dueDate: task.dueDate ? task.dueDate.split("T")[0] : "",
        isRecurring: task.isRecurring,
        recurringPattern: task.recurringPattern,
        notifications: task.notifications,
      })
    } else {
      setFormData({
        title: "",
        description: "",
        priority: "medium",
        category: categories[0]?.id || "",
        dueDate: "",
        isRecurring: false,
        recurringPattern: undefined,
        notifications: {
          enabled: false,
          reminders: notificationManager.getDefaultReminders(),
        },
      })
    }
  }, [task, categories, isOpen])

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()

    if (!formData.title.trim()) return

    const taskData = {
      title: formData.title.trim(),
      description: formData.description.trim(),
      priority: formData.priority,
      category: formData.category,
      dueDate: formData.dueDate || undefined,
      completed: task?.completed || false,
      isRecurring: formData.isRecurring,
      recurringPattern: formData.isRecurring ? formData.recurringPattern : undefined,
      notifications: formData.notifications,
    }

    if (task) {
      updateTask(task.id, taskData)
    } else {
      addTask(taskData)
    }

    onClose()
  }

  const handleRecurringChange = (pattern: RecurringPattern | undefined) => {
    setFormData({
      ...formData,
      isRecurring: !!pattern,
      recurringPattern: pattern,
    })
  }

  const handleNotificationChange = (notifications: NotificationSettingsType | undefined) => {
    setFormData({
      ...formData,
      notifications,
    })
  }

  if (!isOpen) return null

  return (
    <>
      {/* Backdrop */}
      <div className="fixed inset-0 bg-black/50 z-50" onClick={onClose} />

      {/* Modal */}
      <div className="fixed inset-x-4 top-4 bottom-4 bg-background rounded-lg border shadow-lg z-50 max-w-md mx-auto overflow-y-auto">
        <div className="flex items-center justify-between p-4 border-b sticky top-0 bg-background">
          <h2 className="text-lg font-semibold">{task ? "Edit Task" : "Add New Task"}</h2>
          <Button variant="ghost" size="icon" onClick={onClose}>
            <X className="h-5 w-5" />
          </Button>
        </div>

        <form onSubmit={handleSubmit} className="p-4 space-y-4">
          <div>
            <Input
              placeholder="Task title"
              value={formData.title}
              onChange={(e) => setFormData({ ...formData, title: e.target.value })}
              className="text-base"
              autoFocus
            />
          </div>

          <div>
            <Textarea
              placeholder="Description (optional)"
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              rows={3}
            />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <Select
                value={formData.priority}
                onValueChange={(value: "low" | "medium" | "high") => setFormData({ ...formData, priority: value })}
              >
                <SelectTrigger>
                  <div className="flex items-center gap-2">
                    <Flag className="h-4 w-4" />
                    <SelectValue />
                  </div>
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="low">Low Priority</SelectItem>
                  <SelectItem value="medium">Medium Priority</SelectItem>
                  <SelectItem value="high">High Priority</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div>
              <Select
                value={formData.category}
                onValueChange={(value) => setFormData({ ...formData, category: value })}
              >
                <SelectTrigger>
                  <div className="flex items-center gap-2">
                    <Tag className="h-4 w-4" />
                    <SelectValue />
                  </div>
                </SelectTrigger>
                <SelectContent>
                  {categories.map((category) => (
                    <SelectItem key={category.id} value={category.id}>
                      <div className="flex items-center gap-2">
                        <span>{category.icon}</span>
                        {category.name}
                      </div>
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>

          <div>
            <div className="relative">
              <Calendar className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                type="date"
                value={formData.dueDate}
                onChange={(e) => setFormData({ ...formData, dueDate: e.target.value })}
                className="pl-10"
                min={new Date().toISOString().split("T")[0]}
              />
            </div>
          </div>

          {/* Notification Settings */}
          {formData.dueDate && (
            <NotificationSettings settings={formData.notifications} onChange={handleNotificationChange} />
          )}

          {/* Recurring Form */}
          <RecurringForm pattern={formData.recurringPattern} onChange={handleRecurringChange} />

          <div className="flex gap-3 pt-2">
            <Button type="button" variant="outline" onClick={onClose} className="flex-1 bg-transparent">
              Cancel
            </Button>
            <Button type="submit" className="flex-1">
              {task ? "Update" : "Add"} Task
            </Button>
          </div>
        </form>
      </div>
    </>
  )
}
