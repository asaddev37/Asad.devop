import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  TextInput,
  Modal,
  FlatList,
  Alert
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { FirestoreService, Category } from '../src/services/firestoreService';
import { useAuth } from '../src/contexts/AuthContext';

interface CategorySelectorProps {
  selectedCategory: string;
  onSelectCategory: (categoryName: string) => void;
}

// Available icons for categories
const AVAILABLE_ICONS = [
  'restaurant', 'car', 'home', 'cart', 'medical', 'school', 'airplane',
  'gift', 'game-controller', 'bag', 'flash', 'cut', 'briefcase', 'trending-up',
  'shield-checkmark', 'wallet', 'card', 'cash', 'fitness', 'paw', 'beer',
  'wine', 'basketball', 'football', 'bicycle', 'book', 'film', 'musical-notes',
  'headset', 'desktop', 'phone-portrait', 'tablet-portrait', 'tv', 'camera',
  'shirt', 'glasses', 'watch', 'bed', 'hammer', 'construct', 'leaf', 'flower',
  'heart', 'happy', 'sad', 'cloud', 'sunny', 'rainy', 'snow', 'umbrella'
];

// Available colors for categories
const AVAILABLE_COLORS = [
  '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7', '#A78BFA',
  '#FF9F43', '#6C5CE7', '#00B894', '#FDCB6E', '#E84393', '#74B9FF',
  '#FD79A8', '#636E72', '#4CAF50', '#FF5722', '#9C27B0', '#3F51B5',
  '#2196F3', '#009688', '#FFEB3B', '#FF9800', '#795548', '#607D8B'
];

const CategorySelector: React.FC<CategorySelectorProps> = ({
  selectedCategory,
  onSelectCategory
}) => {
  const { user } = useAuth();
  const [categories, setCategories] = useState<Category[]>([]);
  const [showAddModal, setShowAddModal] = useState(false);
  const [newCategoryName, setNewCategoryName] = useState('');
  const [selectedIcon, setSelectedIcon] = useState('restaurant');
  const [selectedColor, setSelectedColor] = useState(AVAILABLE_COLORS[0]);
  const [loading, setLoading] = useState(true);

  // Load categories
  useEffect(() => {
    const loadCategories = async () => {
      if (!user?.uid) return;
      
      try {
        setLoading(true);
        const userCategories = await FirestoreService.getCategories(user.uid);
        setCategories(userCategories);
      } catch (error) {
        console.error('Error loading categories:', error);
        // Fallback to default categories
        setCategories(FirestoreService.getDefaultCategories());
      } finally {
        setLoading(false);
      }
    };

    loadCategories();
  }, [user?.uid]);

  // Create a new category
  const handleCreateCategory = async () => {
    if (!user?.uid || !newCategoryName.trim()) {
      Alert.alert('Error', 'Please enter a category name');
      return;
    }

    try {
      // Check if category with same name already exists
      if (categories.some(cat => cat.name.toLowerCase() === newCategoryName.trim().toLowerCase())) {
        Alert.alert('Error', 'A category with this name already exists');
        return;
      }

      const categoryData = {
        userId: user.uid,
        name: newCategoryName.trim(),
        isDefault: false,
        parentCategory: 'Expenses', // Default to Expenses, can be made customizable
        keywords: [newCategoryName.toLowerCase()],
        color: selectedColor,
        icon: selectedIcon,
      };

      const categoryId = await FirestoreService.createCategory(categoryData);
      
      // Add the new category to the list
      const newCategory = {
        ...categoryData,
        id: categoryId,
        createdAt: new Date() as any
      };
      
      setCategories([...categories, newCategory]);
      onSelectCategory(newCategoryName.trim());
      
      // Reset form and close modal
      setNewCategoryName('');
      setSelectedIcon('restaurant');
      setSelectedColor(AVAILABLE_COLORS[0]);
      setShowAddModal(false);
    } catch (error) {
      console.error('Error creating category:', error);
      Alert.alert('Error', 'Failed to create category');
    }
  };

  return (
    <View style={styles.container}>
      {/* Category Selector */}
      <ScrollView horizontal showsHorizontalScrollIndicator={false}>
        <View style={styles.categoryContainer}>
          {categories.map((category) => (
            <TouchableOpacity
              key={category.id}
              style={[
                styles.categoryButton,
                selectedCategory === category.name && styles.activeCategoryButton,
              ]}
              onPress={() => onSelectCategory(category.name)}
            >
              <View style={styles.categoryContent}>
                <View style={[
                  styles.categoryIconContainer,
                  { backgroundColor: category.color + '20' }
                ]}>
                  <Ionicons 
                    name={category.icon as any} 
                    size={20} 
                    color={category.color} 
                  />
                </View>
                <Text
                  style={[
                    styles.categoryText,
                    selectedCategory === category.name && styles.activeCategoryText,
                  ]}
                >
                  {category.name}
                </Text>
              </View>
            </TouchableOpacity>
          ))}
          
          {/* Add New Category Button */}
          <TouchableOpacity
            style={styles.addCategoryButton}
            onPress={() => setShowAddModal(true)}
          >
            <View style={styles.addCategoryContent}>
              <View style={styles.addIconContainer}>
                <Ionicons name="add" size={20} color="#4A90E2" />
              </View>
              <Text style={styles.addCategoryText}>New</Text>
            </View>
          </TouchableOpacity>
        </View>
      </ScrollView>

      {/* Add Category Modal */}
      <Modal
        visible={showAddModal}
        animationType="slide"
        transparent={true}
        onRequestClose={() => setShowAddModal(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalContainer}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Create New Category</Text>
              <TouchableOpacity onPress={() => setShowAddModal(false)}>
                <Ionicons name="close" size={24} color="#666" />
              </TouchableOpacity>
            </View>

            <View style={styles.modalContent}>
              {/* Category Name Input */}
              <View style={styles.inputGroup}>
                <Text style={styles.inputLabel}>Category Name</Text>
                <TextInput
                  style={styles.textInput}
                  value={newCategoryName}
                  onChangeText={setNewCategoryName}
                  placeholder="Enter category name"
                  maxLength={20}
                />
              </View>

              {/* Icon Selector */}
              <View style={styles.inputGroup}>
                <Text style={styles.inputLabel}>Select Icon</Text>
                <FlatList
                  data={AVAILABLE_ICONS}
                  horizontal
                  showsHorizontalScrollIndicator={false}
                  keyExtractor={(item) => item}
                  renderItem={({ item }) => (
                    <TouchableOpacity
                      style={[
                        styles.iconButton,
                        selectedIcon === item && styles.selectedIconButton,
                      ]}
                      onPress={() => setSelectedIcon(item)}
                    >
                      <Ionicons
                        name={item as any}
                        size={24}
                        color={selectedIcon === item ? 'white' : '#666'}
                      />
                    </TouchableOpacity>
                  )}
                  style={styles.iconList}
                />
              </View>

              {/* Color Selector */}
              <View style={styles.inputGroup}>
                <Text style={styles.inputLabel}>Select Color</Text>
                <FlatList
                  data={AVAILABLE_COLORS}
                  horizontal
                  showsHorizontalScrollIndicator={false}
                  keyExtractor={(item) => item}
                  renderItem={({ item }) => (
                    <TouchableOpacity
                      style={[
                        styles.colorButton,
                        { backgroundColor: item },
                        selectedColor === item && styles.selectedColorButton,
                      ]}
                      onPress={() => setSelectedColor(item)}
                    />
                  )}
                  style={styles.colorList}
                />
              </View>

              {/* Preview */}
              <View style={styles.previewContainer}>
                <Text style={styles.previewLabel}>Preview</Text>
                <View style={styles.preview}>
                  <View style={[
                    styles.previewIconContainer,
                    { backgroundColor: selectedColor + '20' }
                  ]}>
                    <Ionicons
                      name={selectedIcon as any}
                      size={24}
                      color={selectedColor}
                    />
                  </View>
                  <Text style={styles.previewText}>
                    {newCategoryName || 'Category Name'}
                  </Text>
                </View>
              </View>

              {/* Create Button */}
              <TouchableOpacity
                style={styles.createButton}
                onPress={handleCreateCategory}
              >
                <Text style={styles.createButtonText}>Create Category</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginVertical: 10,
  },
  categoryContainer: {
    flexDirection: 'row',
    paddingHorizontal: 5,
  },
  categoryButton: {
    marginHorizontal: 5,
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: '#e0e0e0',
    backgroundColor: 'white',
  },
  activeCategoryButton: {
    borderColor: '#4A90E2',
    backgroundColor: '#4A90E2',
  },
  categoryContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  categoryIconContainer: {
    width: 30,
    height: 30,
    borderRadius: 15,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 8,
  },
  categoryText: {
    fontSize: 14,
    color: '#333',
  },
  activeCategoryText: {
    color: 'white',
    fontWeight: 'bold',
  },
  addCategoryButton: {
    marginHorizontal: 5,
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: '#4A90E2',
    borderStyle: 'dashed',
    backgroundColor: 'white',
  },
  addCategoryContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  addIconContainer: {
    width: 30,
    height: 30,
    borderRadius: 15,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 8,
    backgroundColor: '#4A90E220',
  },
  addCategoryText: {
    fontSize: 14,
    color: '#4A90E2',
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalContainer: {
    width: '90%',
    backgroundColor: 'white',
    borderRadius: 15,
    overflow: 'hidden',
    maxHeight: '80%',
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 15,
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  modalTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  modalContent: {
    padding: 15,
  },
  inputGroup: {
    marginBottom: 20,
  },
  inputLabel: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 8,
  },
  textInput: {
    borderWidth: 1,
    borderColor: '#e0e0e0',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
  },
  iconList: {
    marginTop: 10,
    maxHeight: 70,
  },
  iconButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 10,
    backgroundColor: '#f0f0f0',
  },
  selectedIconButton: {
    backgroundColor: '#4A90E2',
  },
  colorList: {
    marginTop: 10,
    maxHeight: 70,
  },
  colorButton: {
    width: 30,
    height: 30,
    borderRadius: 15,
    marginRight: 10,
    borderWidth: 1,
    borderColor: '#e0e0e0',
  },
  selectedColorButton: {
    borderWidth: 2,
    borderColor: '#333',
  },
  previewContainer: {
    marginTop: 10,
    marginBottom: 20,
  },
  previewLabel: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 8,
  },
  preview: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 15,
    borderRadius: 10,
    backgroundColor: '#f8f9fa',
    borderWidth: 1,
    borderColor: '#e0e0e0',
  },
  previewIconContainer: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 10,
  },
  previewText: {
    fontSize: 16,
    color: '#333',
  },
  createButton: {
    backgroundColor: '#4A90E2',
    borderRadius: 8,
    padding: 15,
    alignItems: 'center',
  },
  createButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default CategorySelector;