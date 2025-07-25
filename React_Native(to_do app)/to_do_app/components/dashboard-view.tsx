"use client"

import { CheckCircle, Clock, AlertTriangle, TrendingUp, Bell, Sparkles } from "lucide-react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Progress } from "@/components/ui/progress"
import { Button } from "@/components/ui/button"
import { TaskItem } from "@/components/task-item"
import { TemplateShowcase } from "@/components/template-showcase"
import { useTaskStore } from "@/lib/store"
import type { Task, NotificationSettings } from "@/lib/types"
import { useMemo, useState } from "react"

interface DashboardViewProps {
  onEditTask: (task: Task) => void
}

export function DashboardView({ onEditTask }: DashboardViewProps) {
  const tasks = useTaskStore((state) => state.tasks)
  const [showTemplateShowcase, setShowTemplateShowcase] = useState(false)

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

  const handleTemplateSelect = (settings: NotificationSettings) => {
    // This could be used to create a new task with the template
    // For now, we'll just show a success message
    console.log("Template selected:", settings)
    setShowTemplateShowcase(false)
  }

  return (
    <div className="p-4 space-y-6">
      {/* Welcome Section */}
      <div className="text-center py-6">
        <h2 className="text-2xl font-bold mb-2">Good morning! 👋</h2>
        <p className="text-muted-foreground">You have {stats.pending} tasks pending today</p>
        {tasksWithNotifications > 0 && (
          <div className="flex items-center justify-center gap-1 mt-2 text-sm text-blue-600 dark:text-blue-400">
            <Bell className="h-4 w-4" />
            <span>{tasksWithNotifications} tasks with notifications</span>
          </div>
        )}
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-2 gap-4">
        <Card>
          <CardContent className="p-4">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-green-100 dark:bg-green-900 rounded-lg">
                <CheckCircle className="h-5 w-5 text-green-600 dark:text-green-400" />
              </div>
              <div>
                <p className="text-2xl font-bold">{stats.completed}</p>
                <p className="text-xs text-muted-foreground">Completed</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-blue-100 dark:bg-blue-900 rounded-lg">
                <Clock className="h-5 w-5 text-blue-600 dark:text-blue-400" />
              </div>
              <div>
                <p className="text-2xl font-bold">{stats.pending}</p>
                <p className="text-xs text-muted-foreground">Pending</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-red-100 dark:bg-red-900 rounded-lg">
                <AlertTriangle className="h-5 w-5 text-red-600 dark:text-red-400" />
              </div>
              <div>
                <p className="text-2xl font-bold">{stats.overdue}</p>
                <p className="text-xs text-muted-foreground">Overdue</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-purple-100 dark:bg-purple-900 rounded-lg">
                <TrendingUp className="h-5 w-5 text-purple-600 dark:text-purple-400" />
              </div>
              <div>
                <p className="text-2xl font-bold">{stats.completionRate}%</p>
                <p className="text-xs text-muted-foreground">Success Rate</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Progress */}
      <Card>
        <CardHeader className="pb-3">
          <CardTitle className="text-base">Today's Progress</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-2">
            <div className="flex justify-between text-sm">
              <span>Completed Tasks</span>
              <span>
                {stats.completed}/{stats.total}
              </span>
            </div>
            <Progress value={stats.completionRate} className="h-2" />
          </div>
        </CardContent>
      </Card>

      {/* Template Showcase */}
      {!showTemplateShowcase && tasks.length > 0 && (
        <div className="flex justify-center">
          <Button
            variant="outline"
            onClick={() => setShowTemplateShowcase(true)}
            className="bg-gradient-to-r from-purple-50 to-blue-50 dark:from-purple-950 dark:to-blue-950 border-purple-200 dark:border-purple-800"
          >
            <Sparkles className="h-4 w-4 mr-2 text-purple-600" />
            Explore Notification Templates
          </Button>
        </div>
      )}

      {showTemplateShowcase && <TemplateShowcase onTemplateSelect={handleTemplateSelect} />}

      {/* Recent Tasks */}
      {recentTasks.length > 0 && (
        <div>
          <h3 className="font-semibold mb-3">Recent Tasks</h3>
          <div className="space-y-3">
            {recentTasks.map((task) => (
              <TaskItem key={task.id} task={task} onEdit={onEditTask} />
            ))}
          </div>
        </div>
      )}

      {/* Upcoming Tasks */}
      {upcomingTasks.length > 0 && (
        <div>
          <h3 className="font-semibold mb-3">Upcoming Deadlines</h3>
          <div className="space-y-3">
            {upcomingTasks.map((task) => (
              <TaskItem key={task.id} task={task} onEdit={onEditTask} />
            ))}
          </div>
        </div>
      )}

      {/* Empty State */}
      {tasks.length === 0 && (
        <div className="text-center py-12 space-y-4">
          <div className="text-6xl mb-4">📝</div>
          <h3 className="text-lg font-semibold mb-2">No tasks yet</h3>
          <p className="text-muted-foreground mb-4">Create your first task to get started</p>
          <TemplateShowcase onTemplateSelect={handleTemplateSelect} />
        </div>
      )}
    </div>
  )
}
