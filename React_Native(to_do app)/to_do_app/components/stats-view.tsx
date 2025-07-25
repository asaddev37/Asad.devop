"use client"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Progress } from "@/components/ui/progress"
import { useTaskStore } from "@/lib/store"
import { useMemo } from "react"

export function StatsView() {
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

  return (
    <div className="p-4 space-y-6">
      {/* Overall Stats */}
      <Card>
        <CardHeader>
          <CardTitle>Overall Statistics</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-2 gap-4 text-center">
            <div>
              <p className="text-2xl font-bold text-green-600">{stats.completed}</p>
              <p className="text-sm text-muted-foreground">Completed</p>
            </div>
            <div>
              <p className="text-2xl font-bold text-blue-600">{stats.pending}</p>
              <p className="text-sm text-muted-foreground">Pending</p>
            </div>
          </div>

          <div>
            <div className="flex justify-between text-sm mb-2">
              <span>Completion Rate</span>
              <span>{stats.completionRate}%</span>
            </div>
            <Progress value={stats.completionRate} className="h-2" />
          </div>
        </CardContent>
      </Card>

      {/* Category Stats */}
      {categoryStats.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Categories</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {categoryStats.map((category) => (
              <div key={category.id}>
                <div className="flex items-center justify-between mb-2">
                  <div className="flex items-center gap-2">
                    <span>{category.icon}</span>
                    <span className="font-medium">{category.name}</span>
                  </div>
                  <span className="text-sm text-muted-foreground">
                    {category.completed}/{category.total}
                  </span>
                </div>
                <Progress value={category.completionRate} className="h-2" />
              </div>
            ))}
          </CardContent>
        </Card>
      )}

      {/* Priority Stats */}
      {priorityStats.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Priority Breakdown</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {priorityStats.map((stat) => (
              <div key={stat.priority}>
                <div className="flex items-center justify-between mb-2">
                  <div className="flex items-center gap-2">
                    <div
                      className={`w-3 h-3 rounded-full ${
                        stat.priority === "high"
                          ? "bg-red-500"
                          : stat.priority === "medium"
                            ? "bg-yellow-500"
                            : "bg-green-500"
                      }`}
                    />
                    <span className="font-medium capitalize">{stat.priority} Priority</span>
                  </div>
                  <span className="text-sm text-muted-foreground">
                    {stat.completed}/{stat.total}
                  </span>
                </div>
                <Progress value={stat.completionRate} className="h-2" />
              </div>
            ))}
          </CardContent>
        </Card>
      )}

      {/* Empty State */}
      {tasks.length === 0 && (
        <div className="text-center py-12">
          <div className="text-6xl mb-4">📊</div>
          <h3 className="text-lg font-semibold mb-2">No data yet</h3>
          <p className="text-muted-foreground">Create some tasks to see your statistics</p>
        </div>
      )}
    </div>
  )
}
