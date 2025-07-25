"use client"

import { Plus } from "lucide-react"
import { Button } from "@/components/ui/button"

interface AddTaskFabProps {
  onClick: () => void
}

export function AddTaskFab({ onClick }: AddTaskFabProps) {
  return (
    <Button
      onClick={onClick}
      size="icon"
      className="floating-action h-14 w-14 rounded-full shadow-lg bg-gradient-to-r from-purple-500 to-blue-500 hover:from-purple-600 hover:to-blue-600"
    >
      <Plus className="h-6 w-6" />
    </Button>
  )
}
