"use client"

import { X, Home, BarChart3, Calendar, Settings, Info, MessageSquare } from "lucide-react"
import { Button } from "@/components/ui/button"
import { useTaskStore } from "@/lib/store"
import { useMemo } from "react"

interface DrawerMenuProps {
  isOpen: boolean
  onClose: () => void
  currentPage: string
  onNavigate: (page: string) => void
}

export function DrawerMenu({ isOpen, onClose, currentPage, onNavigate }: DrawerMenuProps) {
  const tasks = useTaskStore((state) => state.tasks)
  const categories = useTaskStore((state) => state.categories)

  const categoryStats = useMemo(() => {
    return categories.map((category) => ({
      ...category,
      taskCount: tasks.filter((task) => task.category === category.id).length,
    }))
  }, [tasks, categories])

  const menuItems = [
    { id: "dashboard", label: "Dashboard", icon: Home },
    { id: "tasks", label: "All Tasks", icon: BarChart3 },
    { id: "calendar", label: "Calendar", icon: Calendar },
    { id: "settings", label: "Settings", icon: Settings },
    { id: "about", label: "About", icon: Info },
    { id: "feedback", label: "Feedback", icon: MessageSquare },
  ]

  if (!isOpen) return null

  return (
    <>
      {/* Backdrop */}
      <div className="fixed inset-0 bg-black/50 z-50" onClick={onClose} />

      {/* Drawer */}
      <div className="fixed left-0 top-0 h-full w-80 max-w-[85vw] bg-background border-r z-50 transform transition-transform duration-300">
        <div className="flex flex-col h-full">
          {/* Header */}
          <div className="flex items-center justify-between p-4 border-b">
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 rounded-full bg-gradient-to-r from-purple-500 to-blue-500 flex items-center justify-center">
                <span className="text-white font-bold text-sm">T</span>
              </div>
              <div>
                <h2 className="font-semibold">TaskFlow</h2>
                <p className="text-xs text-muted-foreground">Smart To-Do App</p>
              </div>
            </div>
            <Button variant="ghost" size="icon" onClick={onClose}>
              <X className="h-5 w-5" />
            </Button>
          </div>

          {/* Navigation */}
          <div className="flex-1 overflow-y-auto">
            <div className="p-4 space-y-2">
              {menuItems.map((item) => {
                const Icon = item.icon
                return (
                  <Button
                    key={item.id}
                    variant={currentPage === item.id ? "secondary" : "ghost"}
                    className="w-full justify-start gap-3 h-12"
                    onClick={() => {
                      onNavigate(item.id)
                      onClose()
                    }}
                  >
                    <Icon className="h-5 w-5" />
                    {item.label}
                  </Button>
                )
              })}
            </div>

            {/* Categories */}
            <div className="p-4 border-t">
              <h3 className="font-medium mb-3 text-sm text-muted-foreground uppercase tracking-wide">Categories</h3>
              <div className="space-y-2">
                {categoryStats.map((category) => (
                  <Button
                    key={category.id}
                    variant="ghost"
                    className="w-full justify-start gap-3 h-10"
                    onClick={() => {
                      onNavigate("tasks")
                      onClose()
                    }}
                  >
                    <span className="text-lg">{category.icon}</span>
                    <span className="flex-1 text-left">{category.name}</span>
                    <span className="text-xs bg-muted px-2 py-1 rounded-full">{category.taskCount}</span>
                  </Button>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  )
}
