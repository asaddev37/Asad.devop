"use client"

import { useState } from "react"
import { Search, Star, Clock, Users, Heart, DollarSign, GraduationCap, FileText } from "lucide-react"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { ScrollArea } from "@/components/ui/scroll-area"
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs"
import {
  getTemplatesByCategory,
  getPopularTemplates,
  searchTemplates,
  templateCategories,
  type NotificationTemplate,
} from "@/lib/notification-templates"
import type { NotificationSettings } from "@/lib/types"

interface NotificationTemplatePickerProps {
  isOpen: boolean
  onClose: () => void
  onSelect: (settings: NotificationSettings) => void
}

export function NotificationTemplatePicker({ isOpen, onClose, onSelect }: NotificationTemplatePickerProps) {
  const [searchQuery, setSearchQuery] = useState("")
  const [selectedCategory, setSelectedCategory] = useState("popular")

  const handleTemplateSelect = (template: NotificationTemplate) => {
    const settings: NotificationSettings = {
      enabled: true,
      reminders: template.reminders.map((reminder) => ({
        ...reminder,
        id: Date.now().toString() + Math.random().toString(36).substr(2, 9),
      })),
    }
    onSelect(settings)
    onClose()
  }

  const getTemplatesForTab = (tabId: string): NotificationTemplate[] => {
    if (tabId === "popular") return getPopularTemplates()
    if (tabId === "search") return searchTemplates(searchQuery)
    return getTemplatesByCategory(tabId)
  }

  const getCategoryIcon = (categoryId: string) => {
    const iconMap: Record<string, any> = {
      work: Users,
      personal: Heart,
      health: Heart,
      finance: DollarSign,
      education: GraduationCap,
      general: FileText,
      popular: Star,
    }
    return iconMap[categoryId] || FileText
  }

  const getReminderSummary = (template: NotificationTemplate): string => {
    const enabledReminders = template.reminders.filter((r) => r.enabled)
    if (enabledReminders.length === 0) return "No reminders"
    if (enabledReminders.length === 1) {
      const r = enabledReminders[0]
      return `${r.value} ${r.type} before`
    }
    return `${enabledReminders.length} reminders`
  }

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case "high":
        return "destructive"
      case "medium":
        return "default"
      case "low":
        return "secondary"
      default:
        return "default"
    }
  }

  if (!isOpen) return null

  return (
    <>
      {/* Backdrop */}
      <div className="fixed inset-0 bg-black/50 z-50" onClick={onClose} />

      {/* Modal */}
      <div className="fixed inset-x-4 top-4 bottom-4 bg-background rounded-lg border shadow-lg z-50 max-w-md mx-auto">
        <div className="flex flex-col h-full">
          {/* Header */}
          <div className="flex items-center justify-between p-4 border-b">
            <h2 className="text-lg font-semibold">Notification Templates</h2>
            <Button variant="ghost" size="icon" onClick={onClose}>
              ✕
            </Button>
          </div>

          {/* Search */}
          <div className="p-4 border-b">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Search templates..."
                value={searchQuery}
                onChange={(e) => {
                  setSearchQuery(e.target.value)
                  if (e.target.value) setSelectedCategory("search")
                }}
                className="pl-10"
              />
            </div>
          </div>

          {/* Content */}
          <div className="flex-1 overflow-hidden">
            <Tabs value={selectedCategory} onValueChange={setSelectedCategory} className="h-full flex flex-col">
              <TabsList className="grid w-full grid-cols-3 mx-4 mt-2">
                <TabsTrigger value="popular" className="text-xs">
                  Popular
                </TabsTrigger>
                <TabsTrigger value="work" className="text-xs">
                  Work
                </TabsTrigger>
                <TabsTrigger value="personal" className="text-xs">
                  Personal
                </TabsTrigger>
              </TabsList>

              <div className="px-4 py-2">
                <div className="flex gap-2 overflow-x-auto pb-2">
                  {templateCategories.slice(2).map((category) => (
                    <Button
                      key={category.id}
                      variant={selectedCategory === category.id ? "default" : "outline"}
                      size="sm"
                      onClick={() => setSelectedCategory(category.id)}
                      className="whitespace-nowrap"
                    >
                      <span className="mr-1">{category.icon}</span>
                      {category.name}
                    </Button>
                  ))}
                </div>
              </div>

              <ScrollArea className="flex-1 px-4">
                <div className="space-y-3 pb-4">
                  {getTemplatesForTab(selectedCategory).map((template) => (
                    <Card
                      key={template.id}
                      className="cursor-pointer hover:shadow-md transition-shadow"
                      onClick={() => handleTemplateSelect(template)}
                    >
                      <CardHeader className="pb-2">
                        <div className="flex items-start justify-between">
                          <div className="flex items-center gap-2">
                            <span className="text-lg">{template.icon}</span>
                            <div>
                              <CardTitle className="text-sm">{template.name}</CardTitle>
                              <p className="text-xs text-muted-foreground mt-1">{template.description}</p>
                            </div>
                          </div>
                          <Badge variant={getPriorityColor(template.priority) as any} className="text-xs">
                            {template.priority}
                          </Badge>
                        </div>
                      </CardHeader>
                      <CardContent className="pt-0">
                        <div className="flex items-center justify-between">
                          <div className="flex items-center gap-1 text-xs text-muted-foreground">
                            <Clock className="h-3 w-3" />
                            {getReminderSummary(template)}
                          </div>
                          <Badge variant="outline" className="text-xs">
                            {templateCategories.find((c) => c.id === template.category)?.name}
                          </Badge>
                        </div>
                        <p className="text-xs text-muted-foreground mt-2">{template.useCase}</p>
                      </CardContent>
                    </Card>
                  ))}

                  {getTemplatesForTab(selectedCategory).length === 0 && (
                    <div className="text-center py-8">
                      <div className="text-4xl mb-2">🔍</div>
                      <p className="text-muted-foreground">
                        {searchQuery ? "No templates found" : "No templates in this category"}
                      </p>
                    </div>
                  )}
                </div>
              </ScrollArea>
            </Tabs>
          </div>

          {/* Footer */}
          <div className="p-4 border-t">
            <Button variant="outline" onClick={onClose} className="w-full bg-transparent">
              Create Custom
            </Button>
          </div>
        </div>
      </div>
    </>
  )
}
