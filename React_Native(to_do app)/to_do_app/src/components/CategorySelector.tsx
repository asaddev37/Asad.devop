import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, FlatList, Modal } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';

type Category = {
  id: string;
  name: string;
  color: string;
};

type CategorySelectorProps = {
  categories: Category[];
  selectedCategoryId: string;
  onSelectCategory: (categoryId: string) => void;
  onAddCategory: () => void;
};

export const CategorySelector: React.FC<CategorySelectorProps> = ({
  categories,
  selectedCategoryId,
  onSelectCategory,
  onAddCategory,
}) => {
  const [isModalVisible, setIsModalVisible] = useState(false);

  const selectedCategory = categories.find(cat => cat.id === selectedCategoryId) || null;

  const renderCategoryItem = ({ item }: { item: Category }) => (
    <TouchableOpacity
      style={[styles.categoryItem, { borderLeftColor: item.color }]}
      onPress={() => {
        onSelectCategory(item.id);
        setIsModalVisible(false);
      }}
    >
      <View style={[styles.colorDot, { backgroundColor: item.color }]} />
      <Text style={styles.categoryName}>{item.name}</Text>
      {selectedCategoryId === item.id && (
        <MaterialIcons name="check" size={20} color="#3B82F6" style={styles.checkIcon} />
      )}
    </TouchableOpacity>
  );

  return (
    <View style={styles.container}>
      <Text style={styles.label}>Category</Text>
      <TouchableOpacity
        style={styles.selectorButton}
        onPress={() => setIsModalVisible(true)}
      >
        <View style={styles.selectorContent}>
          {selectedCategory ? (
            <>
              <View style={[styles.selectedColor, { backgroundColor: selectedCategory.color }]} />
              <Text style={styles.selectedText}>{selectedCategory.name}</Text>
            </>
          ) : (
            <Text style={styles.placeholderText}>Select a category</Text>
          )}
          <MaterialIcons name="arrow-drop-down" size={24} color="#6B7280" />
        </View>
      </TouchableOpacity>

      <Modal
        visible={isModalVisible}
        animationType="slide"
        transparent={true}
        onRequestClose={() => setIsModalVisible(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Select Category</Text>
              <TouchableOpacity onPress={() => setIsModalVisible(false)}>
                <MaterialIcons name="close" size={24} color="#6B7280" />
              </TouchableOpacity>
            </View>
            
            <FlatList
              data={categories}
              renderItem={renderCategoryItem}
              keyExtractor={(item) => item.id}
              contentContainerStyle={styles.categoryList}
            />
            
            <TouchableOpacity 
              style={styles.addButton}
              onPress={() => {
                setIsModalVisible(false);
                onAddCategory();
              }}
            >
              <MaterialIcons name="add" size={20} color="#3B82F6" />
              <Text style={styles.addButtonText}>Add New Category</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginBottom: 20,
  },
  label: {
    fontSize: 16,
    fontWeight: '600',
    color: '#374151',
    marginBottom: 8,
  },
  selectorButton: {
    borderWidth: 1,
    borderColor: '#E5E7EB',
    borderRadius: 8,
    padding: 12,
    backgroundColor: '#FFFFFF',
  },
  selectorContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  selectedColor: {
    width: 16,
    height: 16,
    borderRadius: 8,
    marginRight: 8,
  },
  selectedText: {
    flex: 1,
    fontSize: 16,
    color: '#111827',
  },
  placeholderText: {
    flex: 1,
    fontSize: 16,
    color: '#9CA3AF',
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'flex-end',
  },
  modalContent: {
    backgroundColor: '#FFFFFF',
    borderTopLeftRadius: 16,
    borderTopRightRadius: 16,
    maxHeight: '70%',
    padding: 16,
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  modalTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#111827',
  },
  categoryList: {
    paddingBottom: 16,
  },
  categoryItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#F3F4F6',
    borderLeftWidth: 4,
  },
  colorDot: {
    width: 12,
    height: 12,
    borderRadius: 6,
    marginRight: 12,
  },
  categoryName: {
    flex: 1,
    fontSize: 16,
    color: '#111827',
  },
  checkIcon: {
    marginLeft: 8,
  },
  addButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 16,
    borderTopWidth: 1,
    borderTopColor: '#F3F4F6',
  },
  addButtonText: {
    marginLeft: 8,
    color: '#3B82F6',
    fontWeight: '500',
    fontSize: 16,
  },
});
