"use client"

import { useState } from "react"
import { Repeat } from "lucide-react"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Checkbox } from "@/components/ui/checkbox"
import type { RecurringPattern } from "@/lib/types"
import { getRecurringPatternDescription } from "@/lib/recurring-utils"

interface RecurringFormProps {
  pattern?: RecurringPattern
  onChange: (pattern: RecurringPattern | undefined) => void
}

export function RecurringForm({ pattern, onChange }: RecurringFormProps) {
  const [isEnabled, setIsEnabled] = useState(!!pattern)
  const [formData, setFormData] = useState<RecurringPattern>(
    pattern || {
      type: "daily",
      interval: 1,
    },
  )

  const handleEnabledChange = (enabled: boolean) => {
    setIsEnabled(enabled)
    if (enabled) {
      onChange(formData)
    } else {
      onChange(undefined)
    }
  }

  const handlePatternChange = (updates: Partial<RecurringPattern>) => {
    const newPattern = { ...formData, ...updates }
    setFormData(newPattern)
    if (isEnabled) {
      onChange(newPattern)
    }
  }

  const dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

  return (
    <div className="space-y-4 p-4 border rounded-lg">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <Repeat className="h-4 w-4" />
          <Label className="font-medium">Recurring Task</Label>
        </div>
        <Checkbox checked={isEnabled} onCheckedChange={handleEnabledChange} />
      </div>

      {isEnabled && (
        <div className="space-y-4">
          {/* Pattern Type */}
          <div>
            <Label className="text-sm">Repeat</Label>
            <Select
              value={formData.type}
              onValueChange={(value: RecurringPattern["type"]) =>
                handlePatternChange({ type: value, daysOfWeek: undefined, dayOfMonth: undefined })
              }
            >
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="daily">Daily</SelectItem>
                <SelectItem value="weekly">Weekly</SelectItem>
                <SelectItem value="monthly">Monthly</SelectItem>
                <SelectItem value="yearly">Yearly</SelectItem>
                <SelectItem value="custom">Custom</SelectItem>
              </SelectContent>
            </Select>
          </div>

          {/* Interval */}
          <div>
            <Label className="text-sm">
              Every{" "}
              {formData.type === "daily"
                ? "days"
                : formData.type === "weekly"
                  ? "weeks"
                  : formData.type === "monthly"
                    ? "months"
                    : formData.type === "yearly"
                      ? "years"
                      : "days"}
            </Label>
            <Input
              type="number"
              min="1"
              max="365"
              value={formData.interval}
              onChange={(e) => handlePatternChange({ interval: Number.parseInt(e.target.value) || 1 })}
            />
          </div>

          {/* Weekly - Days of Week */}
          {formData.type === "weekly" && (
            <div>
              <Label className="text-sm">Days of the week</Label>
              <div className="grid grid-cols-7 gap-2 mt-2">
                {dayNames.map((day, index) => (
                  <div key={day} className="flex flex-col items-center">
                    <Label className="text-xs mb-1">{day}</Label>
                    <Checkbox
                      checked={formData.daysOfWeek?.includes(index) || false}
                      onCheckedChange={(checked) => {
                        const currentDays = formData.daysOfWeek || []
                        const newDays = checked ? [...currentDays, index] : currentDays.filter((d) => d !== index)
                        handlePatternChange({ daysOfWeek: newDays.length > 0 ? newDays : undefined })
                      }}
                    />
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Monthly - Day of Month */}
          {formData.type === "monthly" && (
            <div>
              <Label className="text-sm">Day of month</Label>
              <Input
                type="number"
                min="1"
                max="31"
                placeholder="e.g., 15"
                value={formData.dayOfMonth || ""}
                onChange={(e) => handlePatternChange({ dayOfMonth: Number.parseInt(e.target.value) || undefined })}
              />
            </div>
          )}

          {/* End Conditions */}
          <div className="space-y-3">
            <Label className="text-sm font-medium">End Condition (Optional)</Label>

            <div>
              <Label className="text-xs">End Date</Label>
              <Input
                type="date"
                value={formData.endDate?.split("T")[0] || ""}
                onChange={(e) => handlePatternChange({ endDate: e.target.value || undefined })}
                min={new Date().toISOString().split("T")[0]}
              />
            </div>

            <div>
              <Label className="text-xs">Max Occurrences</Label>
              <Input
                type="number"
                min="1"
                placeholder="e.g., 10"
                value={formData.maxOccurrences || ""}
                onChange={(e) => handlePatternChange({ maxOccurrences: Number.parseInt(e.target.value) || undefined })}
              />
            </div>
          </div>

          {/* Preview */}
          <div className="p-3 bg-muted rounded-lg">
            <Label className="text-xs text-muted-foreground">Preview</Label>
            <p className="text-sm font-medium">{getRecurringPatternDescription(formData)}</p>
          </div>
        </div>
      )}
    </div>
  )
}
