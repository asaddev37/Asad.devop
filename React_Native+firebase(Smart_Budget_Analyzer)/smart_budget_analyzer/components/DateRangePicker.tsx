import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Modal,
  ScrollView,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import DateTimePicker from '@react-native-community/datetimepicker';

interface DateRangePickerProps {
  startDate: Date;
  endDate: Date;
  onDateChange: (startDate: Date, endDate: Date) => void;
}

type PeriodOption = {
  label: string;
  getDates: () => { start: Date; end: Date };
};

const DateRangePicker: React.FC<DateRangePickerProps> = ({
  startDate,
  endDate,
  onDateChange,
}) => {
  const [showModal, setShowModal] = useState(false);
  const [tempStartDate, setTempStartDate] = useState(startDate);
  const [tempEndDate, setTempEndDate] = useState(endDate);
  const [showStartPicker, setShowStartPicker] = useState(false);
  const [showEndPicker, setShowEndPicker] = useState(false);
  const [customPeriod, setCustomPeriod] = useState(false);

  // Get current date without time
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  // Predefined period options
  const periodOptions: PeriodOption[] = [
    {
      label: 'This Month',
      getDates: () => {
        const start = new Date(today.getFullYear(), today.getMonth(), 1);
        const end = new Date(today.getFullYear(), today.getMonth() + 1, 0);
        return { start, end };
      },
    },
    {
      label: 'Next Month',
      getDates: () => {
        const start = new Date(today.getFullYear(), today.getMonth() + 1, 1);
        const end = new Date(today.getFullYear(), today.getMonth() + 2, 0);
        return { start, end };
      },
    },
    {
      label: 'This Quarter',
      getDates: () => {
        const currentQuarter = Math.floor(today.getMonth() / 3);
        const start = new Date(today.getFullYear(), currentQuarter * 3, 1);
        const end = new Date(today.getFullYear(), (currentQuarter + 1) * 3, 0);
        return { start, end };
      },
    },
    {
      label: 'Next Quarter',
      getDates: () => {
        const currentQuarter = Math.floor(today.getMonth() / 3);
        const start = new Date(today.getFullYear(), (currentQuarter + 1) * 3, 1);
        const end = new Date(today.getFullYear(), (currentQuarter + 2) * 3, 0);
        return { start, end };
      },
    },
    {
      label: 'This Year',
      getDates: () => {
        const start = new Date(today.getFullYear(), 0, 1);
        const end = new Date(today.getFullYear(), 11, 31);
        return { start, end };
      },
    },
    {
      label: 'Next Year',
      getDates: () => {
        const start = new Date(today.getFullYear() + 1, 0, 1);
        const end = new Date(today.getFullYear() + 1, 11, 31);
        return { start, end };
      },
    },
    {
      label: 'Custom Period',
      getDates: () => {
        return { start: tempStartDate, end: tempEndDate };
      },
    },
  ];

  const handlePeriodSelect = (option: PeriodOption) => {
    if (option.label === 'Custom Period') {
      setCustomPeriod(true);
      return;
    }
    
    setCustomPeriod(false);
    const { start, end } = option.getDates();
    setTempStartDate(start);
    setTempEndDate(end);
  };

  const handleStartDateChange = (event: any, selectedDate?: Date) => {
    setShowStartPicker(false);
    if (selectedDate) {
      setTempStartDate(selectedDate);
      
      // If start date is after end date, adjust end date
      if (selectedDate > tempEndDate) {
        const newEndDate = new Date(selectedDate);
        newEndDate.setMonth(selectedDate.getMonth() + 1);
        setTempEndDate(newEndDate);
      }
    }
  };

  const handleEndDateChange = (event: any, selectedDate?: Date) => {
    setShowEndPicker(false);
    if (selectedDate) {
      // If end date is before start date, don't update
      if (selectedDate < tempStartDate) {
        return;
      }
      setTempEndDate(selectedDate);
    }
  };

  const handleSave = () => {
    onDateChange(tempStartDate, tempEndDate);
    setShowModal(false);
  };

  const formatDate = (date: Date) => {
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    });
  };

  // Determine if current date range matches any predefined period
  const getCurrentPeriodLabel = () => {
    for (const option of periodOptions) {
      if (option.label === 'Custom Period') continue;
      
      const { start, end } = option.getDates();
      if (
        start.getFullYear() === startDate.getFullYear() &&
        start.getMonth() === startDate.getMonth() &&
        start.getDate() === startDate.getDate() &&
        end.getFullYear() === endDate.getFullYear() &&
        end.getMonth() === endDate.getMonth() &&
        end.getDate() === endDate.getDate()
      ) {
        return option.label;
      }
    }
    
    return 'Custom Period';
  };

  return (
    <View style={styles.container}>
      <TouchableOpacity
        style={styles.dateRangeButton}
        onPress={() => setShowModal(true)}
      >
        <View style={styles.dateRangeContent}>
          <Ionicons name="calendar" size={20} color="#4A90E2" style={styles.calendarIcon} />
          <View>
            <Text style={styles.periodLabel}>{getCurrentPeriodLabel()}</Text>
            <Text style={styles.dateRangeText}>
              {formatDate(startDate)} - {formatDate(endDate)}
            </Text>
          </View>
          <Ionicons name="chevron-down" size={16} color="#666" />
        </View>
      </TouchableOpacity>

      <Modal
        visible={showModal}
        animationType="slide"
        transparent={true}
        onRequestClose={() => setShowModal(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalContainer}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Select Budget Period</Text>
              <TouchableOpacity onPress={() => setShowModal(false)}>
                <Ionicons name="close" size={24} color="#666" />
              </TouchableOpacity>
            </View>

            <ScrollView style={styles.modalContent}>
              {/* Predefined Periods */}
              <View style={styles.periodOptionsContainer}>
                {periodOptions.map((option) => (
                  <TouchableOpacity
                    key={option.label}
                    style={[
                      styles.periodOption,
                      (option.label === 'Custom Period' && customPeriod) ||
                      (option.label === getCurrentPeriodLabel() && !customPeriod)
                        ? styles.selectedPeriodOption
                        : null,
                    ]}
                    onPress={() => handlePeriodSelect(option)}
                  >
                    <Text
                      style={[
                        styles.periodOptionText,
                        (option.label === 'Custom Period' && customPeriod) ||
                        (option.label === getCurrentPeriodLabel() && !customPeriod)
                          ? styles.selectedPeriodOptionText
                          : null,
                      ]}
                    >
                      {option.label}
                    </Text>
                  </TouchableOpacity>
                ))}
              </View>

              {/* Custom Date Range */}
              {customPeriod && (
                <View style={styles.customDateContainer}>
                  <Text style={styles.customDateLabel}>Custom Date Range</Text>
                  
                  <View style={styles.datePickerRow}>
                    <View style={styles.datePickerContainer}>
                      <Text style={styles.datePickerLabel}>Start Date</Text>
                      <TouchableOpacity
                        style={styles.datePickerButton}
                        onPress={() => setShowStartPicker(true)}
                      >
                        <Text style={styles.datePickerButtonText}>
                          {formatDate(tempStartDate)}
                        </Text>
                        <Ionicons name="calendar-outline" size={18} color="#4A90E2" />
                      </TouchableOpacity>
                    </View>

                    <View style={styles.datePickerContainer}>
                      <Text style={styles.datePickerLabel}>End Date</Text>
                      <TouchableOpacity
                        style={styles.datePickerButton}
                        onPress={() => setShowEndPicker(true)}
                      >
                        <Text style={styles.datePickerButtonText}>
                          {formatDate(tempEndDate)}
                        </Text>
                        <Ionicons name="calendar-outline" size={18} color="#4A90E2" />
                      </TouchableOpacity>
                    </View>
                  </View>

                  {showStartPicker && (
                    <DateTimePicker
                      value={tempStartDate}
                      mode="date"
                      display="default"
                      onChange={handleStartDateChange}
                    />
                  )}

                  {showEndPicker && (
                    <DateTimePicker
                      value={tempEndDate}
                      mode="date"
                      display="default"
                      onChange={handleEndDateChange}
                      minimumDate={tempStartDate}
                    />
                  )}
                </View>
              )}

              {/* Save Button */}
              <TouchableOpacity style={styles.saveButton} onPress={handleSave}>
                <Text style={styles.saveButtonText}>Apply</Text>
              </TouchableOpacity>
            </ScrollView>
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
  dateRangeButton: {
    borderWidth: 1,
    borderColor: '#e0e0e0',
    borderRadius: 8,
    padding: 12,
    backgroundColor: 'white',
  },
  dateRangeContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  calendarIcon: {
    marginRight: 10,
  },
  periodLabel: {
    fontSize: 14,
    color: '#4A90E2',
    fontWeight: 'bold',
  },
  dateRangeText: {
    fontSize: 14,
    color: '#666',
    marginTop: 2,
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
  periodOptionsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    marginBottom: 20,
  },
  periodOption: {
    width: '48%',
    padding: 12,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#e0e0e0',
    marginBottom: 10,
    alignItems: 'center',
    backgroundColor: 'white',
  },
  selectedPeriodOption: {
    borderColor: '#4A90E2',
    backgroundColor: '#4A90E2',
  },
  periodOptionText: {
    fontSize: 14,
    color: '#333',
  },
  selectedPeriodOptionText: {
    color: 'white',
    fontWeight: 'bold',
  },
  customDateContainer: {
    marginBottom: 20,
  },
  customDateLabel: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 10,
  },
  datePickerRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  datePickerContainer: {
    width: '48%',
  },
  datePickerLabel: {
    fontSize: 14,
    color: '#666',
    marginBottom: 5,
  },
  datePickerButton: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#e0e0e0',
    borderRadius: 8,
    padding: 10,
    backgroundColor: 'white',
  },
  datePickerButtonText: {
    fontSize: 14,
    color: '#333',
  },
  saveButton: {
    backgroundColor: '#4A90E2',
    borderRadius: 8,
    padding: 15,
    alignItems: 'center',
    marginTop: 10,
  },
  saveButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default DateRangePicker;