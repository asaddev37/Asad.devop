import React, { useState, useLayoutEffect } from 'react';
import { 
  StyleSheet, 
  View, 
  TextInput, 
  TouchableOpacity, 
  FlatList, 
  StatusBar,
  Platform,
  KeyboardAvoidingView
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useNavigation, DrawerActions } from '@react-navigation/native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import { useTasks } from '@/contexts/TaskContext';
import { useUser } from '@/contexts/UserContext';
import { ThemedText } from '@/components/ThemedText';
import { ThemedView } from '@/components/ThemedView';

const TaskItem = ({ task, onToggle, onDelete }: { 
  task: { id: string; title: string; completed: boolean }; 
  onToggle: (id: string) => void;
  onDelete: (id: string) => void;
}) => {
  return (
    <View style={[styles.taskItem, task.completed && styles.taskItemCompleted]}>
      <TouchableOpacity 
        style={[styles.checkbox, task.completed && styles.checkboxCompleted]}
        onPress={() => onToggle(task.id)}
      >
        {task.completed && (
          <Ionicons name="checkmark" size={20} color="#fff" />
        )}
      </TouchableOpacity>
      <ThemedText 
        style={[
          styles.taskText, 
          task.completed && styles.taskCompleted
        ]}
        numberOfLines={2}
      >
        {task.title}
      </ThemedText>
      <TouchableOpacity 
        style={styles.deleteButton}
        onPress={() => onDelete(task.id)}
      >
        <Ionicons name="trash-outline" size={20} color="#ef4444" />
      </TouchableOpacity>
    </View>
  );
};

const FilterButton = ({ 
  label, 
  isActive, 
  onPress 
}: { 
  label: string; 
  isActive: boolean; 
  onPress: () => void;
}) => (
  <TouchableOpacity 
    style={[styles.filterButton, isActive && styles.filterButtonActive]}
    onPress={onPress}
  >
    <ThemedText style={[
      styles.filterButtonText,
      isActive && styles.filterButtonTextActive
    ]}>
      {label}
    </ThemedText>
  </TouchableOpacity>
);

export default function TasksScreen() {
  const navigation = useNavigation();
  const insets = useSafeAreaInsets();
  const { tasks, addTask, toggleTask, deleteTask, filter, setFilter } = useTasks();
  const { userName } = useUser();
  const [newTaskTitle, setNewTaskTitle] = useState('');

  useLayoutEffect(() => {
    navigation.setOptions({
      headerShown: false,
    });
  }, [navigation]);

  const handleAddTask = () => {
    if (newTaskTitle.trim()) {
      addTask({
        title: newTaskTitle.trim(),
        priority: 'medium',
      });
      setNewTaskTitle('');
    }
  };

  const filteredTasks = tasks.filter(task => {
    if (filter === 'active') return !task.completed;
    if (filter === 'completed') return task.completed;
    return true;
  });

  return (
    <ThemedView style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor="#4F46E5" />
      
      {/* Header */}
      <LinearGradient
        colors={['#4F46E5', '#7C3AED']}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
        style={[styles.header, { paddingTop: insets.top + 16 }]}
      >
        <View style={styles.headerContent}>
          <View>
            <ThemedText style={styles.greeting}>
              {userName ? `Hello, ${userName}` : 'Hello, User'}
            </ThemedText>
            <ThemedText style={styles.taskCount}>
              {tasks.filter(t => !t.completed).length} tasks for today
            </ThemedText>
          </View>
          <TouchableOpacity 
            style={styles.menuButton}
            onPress={() => navigation.dispatch(DrawerActions.openDrawer())}
          >
            <Ionicons name="menu" size={28} color="#fff" />
          </TouchableOpacity>
        </View>
      </LinearGradient>

      {/* Main Content */}
      <View style={styles.content}>
        {/* Filter Tabs */}
        <View style={styles.filterContainer}>
          <FilterButton 
            label="All" 
            isActive={filter === 'all'}
            onPress={() => setFilter('all')}
          />
          <FilterButton 
            label="Active" 
            isActive={filter === 'active'}
            onPress={() => setFilter('active')}
          />
          <FilterButton 
            label="Completed" 
            isActive={filter === 'completed'}
            onPress={() => setFilter('completed')}
          />
        </View>

        {/* Task List */}
        <FlatList
          data={filteredTasks}
          keyExtractor={(item) => item.id}
          renderItem={({ item }) => (
            <TaskItem 
              task={item} 
              onToggle={toggleTask}
              onDelete={deleteTask}
            />
          )}
          contentContainerStyle={styles.taskList}
          ListEmptyComponent={
            <View style={styles.emptyState}>
              <Ionicons 
                name={filter === 'completed' ? 'checkmark-done-circle-outline' : 'checkmark-circle-outline'} 
                size={64} 
                color="#e2e8f0" 
              />
              <ThemedText style={styles.emptyStateText}>
                {filter === 'completed' 
                  ? 'No completed tasks yet' 
                  : filter === 'active'
                  ? 'No active tasks' 
                  : 'No tasks yet. Add your first task!'}
              </ThemedText>
            </View>
          }
          showsVerticalScrollIndicator={false}
        />
      </View>

      {/* Add Task Input */}
      <KeyboardAvoidingView 
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={[styles.inputContainer, { paddingBottom: insets.bottom + 16 }]}
      >
        <View style={styles.inputWrapper}>
          <TextInput
            style={styles.input}
            placeholder="Add a new task..."
            placeholderTextColor="#94a3b8"
            value={newTaskTitle}
            onChangeText={setNewTaskTitle}
            onSubmitEditing={handleAddTask}
            returnKeyType="done"
          />
          <TouchableOpacity 
            style={[styles.addButton, !newTaskTitle.trim() && styles.addButtonDisabled]}
            onPress={handleAddTask}
            disabled={!newTaskTitle.trim()}
          >
            <Ionicons 
              name="add" 
              size={24} 
              color="#fff" 
            />
          </TouchableOpacity>
        </View>
      </KeyboardAvoidingView>
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8fafc',
  },
  header: {
    padding: 24,
    paddingBottom: 32,
    borderBottomLeftRadius: 24,
    borderBottomRightRadius: 24,
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.1,
    shadowRadius: 12,
  },
  headerContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  greeting: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 4,
  },
  taskCount: {
    fontSize: 16,
    color: 'rgba(255, 255, 255, 0.9)',
  },
  menuButton: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  content: {
    flex: 1,
    padding: 16,
    marginTop: -24,
  },
  filterContainer: {
    flexDirection: 'row',
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 6,
    marginBottom: 24,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  filterButton: {
    flex: 1,
    paddingVertical: 10,
    borderRadius: 8,
    alignItems: 'center',
  },
  filterButtonActive: {
    backgroundColor: '#4F46E5',
  },
  filterButtonText: {
    fontSize: 14,
    fontWeight: '500',
    color: '#64748b',
  },
  filterButtonTextActive: {
    color: '#fff',
    fontWeight: '600',
  },
  taskList: {
    flexGrow: 1,
    paddingBottom: 16,
  },
  taskItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    backgroundColor: '#fff',
    borderRadius: 12,
    marginBottom: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 1,
  },
  taskItemCompleted: {
    opacity: 0.7,
  },
  checkbox: {
    width: 24,
    height: 24,
    borderRadius: 12,
    borderWidth: 2,
    borderColor: '#e2e8f0',
    marginRight: 16,
    alignItems: 'center',
    justifyContent: 'center',
  },
  checkboxCompleted: {
    backgroundColor: '#10b981',
    borderColor: '#10b981',
  },
  taskText: {
    flex: 1,
    fontSize: 16,
    color: '#1e293b',
    lineHeight: 24,
  },
  taskCompleted: {
    textDecorationLine: 'line-through',
    color: '#94a3b8',
  },
  deleteButton: {
    padding: 8,
    marginLeft: 8,
  },
  emptyState: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 40,
  },
  emptyStateText: {
    marginTop: 16,
    fontSize: 16,
    color: '#94a3b8',
    textAlign: 'center',
    lineHeight: 24,
  },
  inputContainer: {
    padding: 16,
    backgroundColor: '#fff',
    borderTopWidth: 1,
    borderTopColor: '#e2e8f0',
  },
  inputWrapper: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  input: {
    flex: 1,
    height: 56,
    backgroundColor: '#f8fafc',
    borderRadius: 12,
    paddingHorizontal: 20,
    fontSize: 16,
    color: '#1e293b',
    marginRight: 12,
    borderWidth: 1,
    borderColor: '#e2e8f0',
  },
  addButton: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: '#4F46E5',
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#4F46E5',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 4,
  },
  addButtonDisabled: {
    backgroundColor: '#c7d2fe',
    shadowOpacity: 0,
  },
});
