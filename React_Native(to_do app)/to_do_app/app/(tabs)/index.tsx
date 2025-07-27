import { useState, useCallback, useEffect } from 'react';
import { StyleSheet, View, TouchableOpacity, TextInput, FlatList } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { useTasks } from '@/contexts/TaskContext';
import { useUser } from '@/contexts/UserContext';
import { ThemedView } from '@/components/ThemedView';
import { ThemedText } from '@/components/ThemedText';
import { useFocusEffect } from '@react-navigation/native';
import AsyncStorage from '@react-native-async-storage/async-storage';

const TaskItem = ({ task, onToggle, onDelete }: { 
  task: { id: string; title: string; completed: boolean }; 
  onToggle: (id: string) => void;
  onDelete: (id: string) => void;
}) => {
  return (
    <View style={styles.taskItem}>
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

export default function HomeScreen() {
  const { tasks, addTask, toggleTask, deleteTask, filter, setFilter } = useTasks();
  const { userName, updateUserName } = useUser();
  const [newTaskTitle, setNewTaskTitle] = useState('');
  const [displayName, setDisplayName] = useState('User');
  const insets = useSafeAreaInsets();
  
  // Update display name whenever userName changes
  useEffect(() => {
    console.log('HomeScreen: userName changed to:', userName);
    if (userName) {
      setDisplayName(userName);
    } else {
      setDisplayName('User');
    }
  }, [userName]);
  
  // Force refresh when screen comes into focus
  useFocusEffect(
    useCallback(() => {
      console.log('HomeScreen focused, current userName:', userName);
      // Force a refresh of the user name when the screen comes into focus
      const refreshUserName = async () => {
        try {
          const savedName = await AsyncStorage.getItem('@userName');
          console.log('Refreshed userName from storage:', savedName);
          if (savedName) {
            setDisplayName(savedName);
          }
        } catch (error) {
          console.error('Failed to refresh user name:', error);
        }
      };
      refreshUserName();
    }, [userName])
  );

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

  const getGreeting = useCallback(() => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }, []);

  return (
    <ThemedView style={[styles.container, { paddingTop: insets.top }]}>
      <View style={styles.header}>
        <View style={styles.userGreetingContainer}>
          <ThemedText style={styles.greeting}>{getGreeting()}</ThemedText>
          <ThemedText style={styles.userName}>
            {displayName}
          </ThemedText>
        </View>
        <ThemedText style={styles.title}>My Tasks</ThemedText>
        <View style={styles.filterContainer}>
          <TouchableOpacity 
            style={[styles.filterButton, filter === 'all' && styles.filterActive]}
            onPress={() => setFilter('all')}
          >
            <ThemedText style={filter === 'all' && styles.filterTextActive}>
              All
            </ThemedText>
          </TouchableOpacity>
          <TouchableOpacity 
            style={[styles.filterButton, filter === 'active' && styles.filterActive]}
            onPress={() => setFilter('active')}
          >
            <ThemedText style={filter === 'active' && styles.filterTextActive}>
              Active
            </ThemedText>
          </TouchableOpacity>
          <TouchableOpacity 
            style={[styles.filterButton, filter === 'completed' && styles.filterActive]}
            onPress={() => setFilter('completed')}
          >
            <ThemedText style={filter === 'completed' && styles.filterTextActive}>
              Completed
            </ThemedText>
          </TouchableOpacity>
        </View>
      </View>

      <FlatList<{id: string; title: string; completed: boolean}>
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
            <Ionicons name="checkmark-done" size={48} color="#e2e8f0" />
            <ThemedText style={styles.emptyStateText}>
              {filter === 'completed' 
                ? 'No completed tasks yet' 
                : filter === 'active'
                ? 'No active tasks' 
                : 'No tasks yet'}
            </ThemedText>
          </View>
        }
      />

      <View style={styles.inputContainer}>
        <TextInput
          style={styles.input}
          placeholder="Add a new task..."
          value={newTaskTitle}
          onChangeText={setNewTaskTitle}
          onSubmitEditing={handleAddTask}
          returnKeyType="done"
        />
        <TouchableOpacity 
          style={styles.addButton}
          onPress={handleAddTask}
          disabled={!newTaskTitle.trim()}
        >
          <Ionicons 
            name="add" 
            size={24} 
            color={newTaskTitle.trim() ? "#0ea5e9" : "#94a3b8"} 
          />
        </TouchableOpacity>
      </View>
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 20,
    paddingHorizontal: 20,
    paddingTop: 20,
  },
  userGreetingContainer: {
    flex: 1,
  },
  greeting: {
    fontSize: 16,
    color: '#6B7280',
  },
  userName: {
    fontSize: 24,
    fontWeight: 'bold',
    marginTop: 4,
    color: '#111827',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    textAlign: 'right',
  },
  filterContainer: {
    flexDirection: 'row',
    marginTop: 16,
    backgroundColor: '#f1f5f9',
    borderRadius: 8,
    padding: 4,
  },
  filterButton: {
    flex: 1,
    paddingVertical: 8,
    alignItems: 'center',
    borderRadius: 6,
  },
  filterActive: {
    backgroundColor: '#fff',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  filterTextActive: {
    color: '#0ea5e9',
    fontWeight: '600',
  },
  taskList: {
    flexGrow: 1,
    padding: 16,
  },
  taskItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    paddingHorizontal: 16,
    backgroundColor: '#fff',
    borderRadius: 8,
    marginBottom: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 1,
  },
  checkbox: {
    width: 24,
    height: 24,
    borderRadius: 12,
    borderWidth: 2,
    borderColor: '#e2e8f0',
    marginRight: 12,
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
  },
  taskCompleted: {
    textDecorationLine: 'line-through',
    color: '#94a3b8',
  },
  deleteButton: {
    padding: 4,
    marginLeft: 8,
  },
  inputContainer: {
    flexDirection: 'row',
    padding: 16,
    borderTopWidth: 1,
    borderTopColor: '#e2e8f0',
    backgroundColor: '#fff',
  },
  input: {
    flex: 1,
    backgroundColor: '#f8fafc',
    borderRadius: 8,
    padding: 12,
    marginRight: 8,
    fontSize: 16,
  },
  addButton: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: '#f8fafc',
    alignItems: 'center',
    justifyContent: 'center',
  },
  emptyState: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 40,
  },
  emptyStateText: {
    marginTop: 16,
    color: '#94a3b8',
    textAlign: 'center',
    fontSize: 16,
  },
});
