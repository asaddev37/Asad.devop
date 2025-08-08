import React from 'react';
import { View, Text, StyleSheet, Dimensions, ScrollView } from 'react-native';
import { Transaction, Budget, DashboardStats } from '../../src/services/firestoreService';
import { PieChart } from './PieChart';
import { BarChart } from './BarChart';
import { LineChart } from './LineChart';
import { ProgressChart } from './ProgressChart';
import { getCategoryData, getIncomeVsExpenseData, getMonthlyData, getBudgetProgressData } from './ChartUtils';
import { useThemeColor } from '../../src/hooks/useThemeColor';

interface DashboardChartsProps {
  transactions: Transaction[];
  dashboardStats: DashboardStats | null;
  isDarkMode: boolean;
  shouldShowFinancialInfo: boolean;
}

const { width } = Dimensions.get('window');

export const DashboardCharts: React.FC<DashboardChartsProps> = ({
  transactions,
  dashboardStats,
  isDarkMode,
  shouldShowFinancialInfo
}) => {
  const textColor = useThemeColor('text', isDarkMode);
  const backgroundColor = useThemeColor('background', isDarkMode);
  const cardBackgroundColor = useThemeColor('card', isDarkMode);

  if (!shouldShowFinancialInfo) {
    return (
      <View style={styles.section}>
        <Text style={[styles.sectionTitle, { color: textColor }]}>
          Data Visualization
        </Text>
        <View style={[styles.chartCard, { backgroundColor: cardBackgroundColor }]}>
          <Text style={[styles.privacyMessage, { color: textColor }]}>
            Charts are hidden in privacy mode. Tap the eye icon to show financial information.
          </Text>
        </View>
      </View>
    );
  }

  if (!dashboardStats || transactions.length === 0) {
    return (
      <View style={styles.section}>
        <Text style={[styles.sectionTitle, { color: textColor }]}>
          Data Visualization
        </Text>
        <View style={[styles.chartCard, { backgroundColor: cardBackgroundColor }]}>
          <Text style={[styles.emptyText, { color: textColor }]}>
            No data available for charts
          </Text>
          <Text style={[styles.emptySubtext, { color: textColor }]}>
            Add transactions to see visualizations
          </Text>
        </View>
      </View>
    );
  }

  // Prepare data for charts
  const categoryData = getCategoryData(transactions);
  const incomeVsExpenseData = getIncomeVsExpenseData(dashboardStats.totalIncome, dashboardStats.totalExpenses);
  const monthlyData = getMonthlyData(transactions);
  const budgetProgressData = getBudgetProgressData(dashboardStats.budgetProgress);

  return (
    <View style={styles.section}>
      <Text style={[styles.sectionTitle, { color: textColor }]}>
        Data Visualization
      </Text>
      
      {/* Category Spending Distribution */}
      <View style={[styles.chartCard, { backgroundColor: cardBackgroundColor }]}>
        <Text style={[styles.chartTitle, { color: textColor }]}>
          Category Spending Distribution
        </Text>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.chartScrollContainer}>
          <PieChart 
            data={categoryData}
            isDarkMode={isDarkMode}
            hasLegend={true}
            width={width * 0.85}
            height={200}
          />
        </ScrollView>
      </View>

      {/* Income vs Expenses */}
      <View style={[styles.chartCard, { backgroundColor: cardBackgroundColor }]}>
        <Text style={[styles.chartTitle, { color: textColor }]}>
          Income vs Expenses
        </Text>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.chartScrollContainer}>
          <BarChart 
            data={incomeVsExpenseData}
            isDarkMode={isDarkMode}
            width={width * 0.85}
            height={200}
          />
        </ScrollView>
      </View>

      {/* Monthly Spending Trends */}
      <View style={[styles.chartCard, { backgroundColor: cardBackgroundColor }]}>
        <Text style={[styles.chartTitle, { color: textColor }]}>
          Monthly Spending Trends
        </Text>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.chartScrollContainer}>
          <LineChart 
            data={monthlyData}
            isDarkMode={isDarkMode}
            width={width * 0.85}
            height={200}
          />
        </ScrollView>
      </View>

      {/* Budget Progress */}
      {dashboardStats.budgetProgress.length > 0 && (
        <View style={[styles.chartCard, { backgroundColor: cardBackgroundColor }]}>
          <Text style={[styles.chartTitle, { color: textColor }]}>
            Budget Progress
          </Text>
          <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.chartScrollContainer}>
            <ProgressChart 
              data={budgetProgressData}
              isDarkMode={isDarkMode}
              width={width * 0.85}
              height={200}
            />
          </ScrollView>
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  section: {
    marginBottom: 20,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 15,
    paddingHorizontal: 15,
  },
  chartCard: {
    borderRadius: 12,
    padding: 15,
    marginHorizontal: 15,
    marginBottom: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  chartScrollContainer: {
    paddingBottom: 5,
    alignItems: 'center',
    justifyContent: 'center',
    minWidth: '100%',
  },
  chartTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 10,
    textAlign: 'center',
  },
  emptyText: {
    fontSize: 16,
    fontWeight: 'bold',
    textAlign: 'center',
    marginTop: 20,
  },
  emptySubtext: {
    fontSize: 14,
    textAlign: 'center',
    marginTop: 10,
    marginBottom: 20,
    opacity: 0.7,
  },
  privacyMessage: {
    fontSize: 14,
    textAlign: 'center',
    marginVertical: 20,
    opacity: 0.7,
  },
});