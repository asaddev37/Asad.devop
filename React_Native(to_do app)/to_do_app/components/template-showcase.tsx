"use client"

import { useState } from "react"
import { Sparkles, Clock, Star } from "lucide-react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { NotificationTemplatePicker } from "@/components/notification-template-picker"
import { getPopularTemplates, templateCategories } from "@/lib/notification-templates"
import type { NotificationSettings } from "@/lib/types"

interface TemplateShowcaseProps {
  onTemplateSelect: (settings: NotificationSettings) => void
}

export function TemplateShowcase({ onTemplateSelect }: TemplateShowcaseProps) {
  const [showPicker, setShowPicker] = useState(false)
  const popularTemplates = getPopularTemplates()

  const handleTemplateSelect = (settings: NotificationSettings) => {
    onTemplateSelect(settings)
    setShowPicker(false)
  }

  const getQuickTemplate = (templateId: string) => {
    const template = popularTemplates.find((t) => t.id === templateId)
    if (!template) return null

    const settings: NotificationSettings = {
      enabled: true,
      reminders: template.reminders.map((reminder) => ({
        ...reminder,
        id: Date.now().toString() + Math.random().toString(36).substr(2, 9),
      })),
    }

    return {
      template,
      settings,
    }
  }

  return (
    <>
      <Card className="bg-gradient-to-br from-purple-50 to-blue-50 dark:from-purple-950 dark:to-blue-950 border-purple-200 dark:border-purple-800">
        <CardHeader className="pb-3">
          <div className="flex items-center gap-2">
            <Sparkles className="h-5 w-5 text-purple-600" />
            <CardTitle className="text-base">Quick Templates</CardTitle>
          </div>
          <p className="text-sm text-muted-foreground">Pre-configured notification patterns for common tasks</p>
        </CardHeader>
        <CardContent className="space-y-3">
          {/* Quick Actions */}
          <div className="grid grid-cols-2 gap-2">
            {popularTemplates.slice(0, 4).map((template) => {
              const quickTemplate = getQuickTemplate(template.id)
              if (!quickTemplate) return null

              return (
                <Button
                  key={template.id}
                  variant="outline"
                  size="sm"
                  onClick={() => onTemplateSelect(quickTemplate.settings)}
                  className="h-auto p-3 flex flex-col items-start gap-1 bg-white/50 dark:bg-black/20"
                >
                  <div className="flex items-center gap-1 w-full">
                    <span className="text-sm">{template.icon}</span>
                    <span className="text-xs font-medium truncate">{template.name}</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <Clock className="h-3 w-3 text-muted-foreground" />
                    <span className="text-xs text-muted-foreground">
                      {template.reminders.filter((r) => r.enabled).length} reminders
                    </span>
                  </div>
                </Button>
              )
            })}
          </div>

          {/* Browse All Templates */}
          <Button variant="outline" onClick={() => setShowPicker(true)} className="w-full bg-white/70 dark:bg-black/30">
            <Star className="h-4 w-4 mr-2" />
            Browse All Templates ({popularTemplates.length + 10}+)
          </Button>

          {/* Categories Preview */}
          <div className="flex flex-wrap gap-1 pt-2">
            {templateCategories.slice(0, 4).map((category) => (
              <Badge key={category.id} variant="secondary" className="text-xs">
                <span className="mr-1">{category.icon}</span>
                {category.name}
              </Badge>
            ))}
            <Badge variant="secondary" className="text-xs">
              +2 more
            </Badge>
          </div>
        </CardContent>
      </Card>

      <NotificationTemplatePicker
        isOpen={showPicker}
        onClose={() => setShowPicker(false)}
        onSelect={handleTemplateSelect}
      />
    </>
  )
}
