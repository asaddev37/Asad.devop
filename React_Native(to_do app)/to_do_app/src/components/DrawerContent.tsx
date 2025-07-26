import React from 'react';
import { View, StyleSheet, Text, TouchableOpacity } from 'react-native';
import { DrawerContentScrollView, DrawerItemList, DrawerContentComponentProps } from '@react-navigation/drawer';
import { useNavigation, DrawerActions } from '@react-navigation/native';
import type { DrawerNavigationProp } from '@react-navigation/drawer';
import { Category } from '../types';
import { useTaskStore } from '../store/taskStore';

type RootDrawerParamList = {
  Home: undefined;
  // Add other screen params as needed
};

type NavigationProp = DrawerNavigationProp<RootDrawerParamList>;

interface TaskStoreState {
  categories: Category[];
  selectedCategory: string | null;
  setSelectedCategory: (id: string | null) => void;
}

const useTaskStoreSelector = (state: any): TaskStoreState => ({
  categories: state.categories,
  selectedCategory: state.selectedCategory,
  setSelectedCategory: state.setSelectedCategory,
});

const DrawerContent = (props: DrawerContentComponentProps) => {
  const navigation = useNavigation<NavigationProp>();
  const { categories, selectedCategory, setSelectedCategory } = useTaskStore(useTaskStoreSelector);

  return (
    <View style={styles.container}>
      <DrawerContentScrollView {...props}>
        <View style={styles.header}>
          <Text style={styles.headerTitle}>TaskFlow</Text>
          <Text style={styles.headerSubtitle}>Your Productivity Companion</Text>
        </View>
        
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Categories</Text>
          {categories?.map((category: Category) => (
            <TouchableOpacity
              key={category.id}
              style={[
                styles.categoryItem,
                selectedCategory === category.id && styles.selectedCategoryItem
              ]}
              onPress={() => {
                setSelectedCategory(category.id);
                navigation.dispatch(DrawerActions.closeDrawer());
              }}
            >
              <View style={[styles.categoryColor, { backgroundColor: category.color }]} />
              <Text style={styles.categoryText}>{category.name}</Text>
              <Text style={styles.taskCount}>({category.taskCount})</Text>
            </TouchableOpacity>
          ))}
        </View>

        <View style={styles.divider} />
        
        <DrawerItemList {...props} />
      </DrawerContentScrollView>
      
      <View style={styles.footer}>
        <Text style={styles.version}>v1.0.0</Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  header: {
    padding: 20,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
  },
  headerSubtitle: {
    fontSize: 14,
    color: '#666',
    marginTop: 4,
  },
  section: {
    marginTop: 10,
    paddingHorizontal: 15,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#666',
    marginVertical: 15,
    marginLeft: 10,
  },
  categoryItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    paddingHorizontal: 10,
    borderRadius: 8,
    marginBottom: 5,
  },
  selectedCategoryItem: {
    backgroundColor: '#f0f0f0',
  },
  categoryColor: {
    width: 12,
    height: 12,
    borderRadius: 6,
    marginRight: 10,
  },
  categoryText: {
    flex: 1,
    fontSize: 16,
    color: '#333',
  },
  taskCount: {
    color: '#888',
    fontSize: 14,
    marginLeft: 5,
  },
  divider: {
    height: 1,
    backgroundColor: '#f0f0f0',
    marginVertical: 15,
  },
  footer: {
    padding: 20,
    borderTopWidth: 1,
    borderTopColor: '#f0f0f0',
  },
  version: {
    fontSize: 12,
    color: '#999',
    textAlign: 'center',
  },
});

export default DrawerContent;
