import React from "react";
import { View, Text, StyleSheet } from "react-native";
import { TaskPriority } from "../types/task";

interface PriorityStatsCardProps {
  priority: TaskPriority;
  count: number;
  total: number;
  color: string;
}

export const PriorityStatsCard: React.FC<PriorityStatsCardProps> = ({
  priority,
  count,
  total,
  color,
}) => {
  const percentage = total > 0 ? Math.round((count / total) * 100) : 0;

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <View style={[styles.priorityDot, { backgroundColor: color }]} />
        <Text style={styles.priorityText}>
          {priority.charAt(0).toUpperCase() + priority.slice(1)} Priority
        </Text>
        <Text style={styles.countText}>
          {count} {count === 1 ? 'task' : 'tasks'}
        </Text>
      </View>
      <View style={styles.progressBar}>
        <View
          style={[
            styles.progressFill,
            { width: `${percentage}%`, backgroundColor: color },
          ]}
        />
      </View>
      <Text style={styles.percentageText}>{percentage}%</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
  },
  priorityDot: {
    width: 12,
    height: 12,
    borderRadius: 6,
    marginRight: 8,
  },
  priorityText: {
    flex: 1,
    fontSize: 14,
    color: '#4B5563',
    fontWeight: '500',
  },
  countText: {
    fontSize: 14,
    color: '#6B7280',
  },
  progressBar: {
    height: 8,
    backgroundColor: '#E5E7EB',
    borderRadius: 4,
    marginVertical: 8,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    borderRadius: 4,
  },
  percentageText: {
    fontSize: 14,
    color: '#6B7280',
    textAlign: 'right',
  },
});
