export interface Task {
  id: string;
  title: string;
  completed: boolean;
  createdAt: Date;
  completedAt?: Date;
  priority?: 'low' | 'medium' | 'high';
  description?: string;
}

export type TaskFilter = 'all' | 'active' | 'completed';
