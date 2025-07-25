"use client"

import { Home, CheckSquare, Calendar, BarChart3 } from "lucide-react"
import { Button } from "@/components/ui/button"

interface BottomNavigationProps {
  currentPage: string
  onNavigate: (page: string) => void
}

export function BottomNavigation({ currentPage, onNavigate }: BottomNavigationProps) {
  const navItems = [
    { id: "dashboard", label: "Home", icon: Home },
    { id: "tasks", label: "Tasks", icon: CheckSquare },
    { id: "calendar", label: "Calendar", icon: Calendar },
    { id: "stats", label: "Stats", icon: BarChart3 },
  ]

  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-background border-t z-40">
      <div className="max-w-md mx-auto">
        <div className="flex items-center justify-around py-2">
          {navItems.map((item) => {
            const Icon = item.icon
            const isActive = currentPage === item.id

            return (
              <Button
                key={item.id}
                variant="ghost"
                size="sm"
                className={`flex flex-col items-center gap-1 h-auto py-2 px-3 ${
                  isActive ? "text-primary" : "text-muted-foreground"
                }`}
                onClick={() => onNavigate(item.id)}
              >
                <Icon className={`h-5 w-5 ${isActive ? "fill-current" : ""}`} />
                <span className="text-xs">{item.label}</span>
              </Button>
            )
          })}
        </div>
      </div>
    </nav>
  )
}
