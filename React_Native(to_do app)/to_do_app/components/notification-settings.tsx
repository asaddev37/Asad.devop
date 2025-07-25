"use client"

import { useState } from "react"
import { Bell, BellOff, Plus, Trash2, Sparkles } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Switch } from "@/components/ui/switch"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Input } from "@/components/ui/input"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { NotificationTemplatePicker } from "@/components/notification-template-picker"
import type { NotificationSettings as NotificationSettingsType } from "@/lib/types"

interface NotificationSettingsProps {
  settings?: NotificationSettingsType
  onChange: (settings: NotificationSettingsType | undefined) => void
}

export function NotificationSettings({ settings, onChange }: NotificationSettingsProps) {
  const [isEnabled, setIsEnabled] = useState(settings?.enabled || false)
  const [reminders, setReminders] = useState<any[]>(
    settings?.reminders || [
      { id: "1", type: "minutes", value: 15, enabled: true },
      { id: "2", type: "hours", value: 1, enabled: false },
      { id: "3", type: "days", value: 1, enabled: false },
    ],
  )
  const [showTemplatePicker, setShowTemplatePicker] = useState(false)

  const handleEnabledChange = (enabled: boolean) => {
    setIsEnabled(enabled)
    if (enabled) {
      onChange({ enabled: true, reminders })
    } else {
      onChange(undefined)
    }
  }

  const handleReminderChange = (id: string, updates: any) => {
    const updatedReminders = reminders.map((reminder) => (reminder.id === id ? { ...reminder, ...updates } : reminder))
    setReminders(updatedReminders)
    if (isEnabled) {
      onChange({ enabled: true, reminders: updatedReminders })
    }
  }

  const addReminder = () => {
    const newReminder = {
      id: Date.now().toString(),
      type: "minutes",
      value: 30,
      enabled: true,
    }
    const updatedReminders = [...reminders, newReminder]
    setReminders(updatedReminders)
    if (isEnabled) {
      onChange({ enabled: true, reminders: updatedReminders })
    }
  }

  const removeReminder = (id: string) => {
    const updatedReminders = reminders.filter((reminder) => reminder.id !== id)
    setReminders(updatedReminders)
    if (isEnabled) {
      onChange({ enabled: true, reminders: updatedReminders })
    }
  }

  const handleTemplateSelect = (templateSettings: NotificationSettingsType) => {
    setIsEnabled(true)
    setReminders(templateSettings.reminders)
    onChange(templateSettings)
  }

  const getReminderText = (reminder: any) => {
    const unit = reminder.type === "minutes" ? "min" : reminder.type === "hours" ? "hr" : "day"
    const plural = reminder.value > 1 ? (unit === "min" ? "mins" : unit === "hr" ? "hrs" : "days") : unit
    return `${reminder.value} ${plural} before`
  }

  return (
    <>
      <Card>
        <CardHeader className="pb-3">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              {isEnabled ? <Bell className="h-4 w-4" /> : <BellOff className="h-4 w-4" />}
              <CardTitle className="text-base">Notifications</CardTitle>
            </div>
            <Switch checked={isEnabled} onCheckedChange={handleEnabledChange} />
          </div>
        </CardHeader>

        {isEnabled && (
          <CardContent className="space-y-4">
            {/* Template Button */}
            <Button
              variant="outline"
              onClick={() => setShowTemplatePicker(true)}
              className="w-full bg-gradient-to-r from-purple-50 to-blue-50 dark:from-purple-950 dark:to-blue-950 border-purple-200 dark:border-purple-800"
            >
              <Sparkles className="h-4 w-4 mr-2 text-purple-600" />
              Use Template
            </Button>

            <div className="space-y-3">
              {reminders.map((reminder) => (
                <div key={reminder.id} className="flex items-center gap-3 p-3 border rounded-lg">
                  <Switch
                    checked={reminder.enabled}
                    onCheckedChange={(enabled) => handleReminderChange(reminder.id, { enabled })}
                  />

                  <div className="flex-1 grid grid-cols-2 gap-2">
                    <Input
                      type="number"
                      min="1"
                      max="999"
                      value={reminder.value}
                      onChange={(e) =>
                        handleReminderChange(reminder.id, { value: Number.parseInt(e.target.value) || 1 })
                      }
                      className="text-sm"
                    />

                    <Select
                      value={reminder.type}
                      onValueChange={(value: any) => handleReminderChange(reminder.id, { type: value })}
                    >
                      <SelectTrigger className="text-sm">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="minutes">Minutes</SelectItem>
                        <SelectItem value="hours">Hours</SelectItem>
                        <SelectItem value="days">Days</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  <div className="text-xs text-muted-foreground min-w-0 flex-shrink-0">{getReminderText(reminder)}</div>

                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={() => removeReminder(reminder.id)}
                    className="h-8 w-8 text-destructive hover:text-destructive"
                  >
                    <Trash2 className="h-4 w-4" />
                  </Button>
                </div>
              ))}
            </div>

            <Button variant="outline" onClick={addReminder} className="w-full bg-transparent">
              <Plus className="h-4 w-4 mr-2" />
              Add Custom Reminder
            </Button>

            <div className="text-xs text-muted-foreground space-y-1">
              <p>
                💡 <strong>Tip:</strong> High priority tasks require interaction to dismiss
              </p>
              <p>
                ⚡ <strong>Templates:</strong> Quick setup for common scenarios
              </p>
            </div>
          </CardContent>
        )}
      </Card>

      <NotificationTemplatePicker
        isOpen={showTemplatePicker}
        onClose={() => setShowTemplatePicker(false)}
        onSelect={handleTemplateSelect}
      />
    </>
  )
}
