import { Transaction } from '../../src/services/firestoreService';
import { Timestamp } from 'firebase/firestore';

// Color palette for charts
export const CHART_COLORS = [
  '#4A90E2', // Blue
  '#E57373', // Red
  '#81C784', // Green
  '#FFD54F', // Yellow
  '#7986CB', // Indigo
  '#FF8A65', // Orange
  '#9575CD', // Purple
  '#4DB6AC', // Teal
  '#F06292', // Pink
  '#A1887F', // Brown
];

// Format currency based on user's preferred currency
export const formatCurrency = (amount: number, currency = 'USD'): string => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency,
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(amount);
};

// Format percentage
export const formatPercentage = (value: number): string => {
  return `${Math.round(value)}%`;
};

// Get month name from date
export const getMonthName = (date: Date): string => {
  return date.toLocaleString('default', { month: 'short' });
};

// Group transactions by category and calculate totals
export const getCategoryData = (transactions: Transaction[]): { name: string; value: number; color: string }[] => {
  const expenseTransactions = transactions.filter(t => t.amount < 0);
  
  // Group by category
  const categoryMap = new Map<string, number>();
  
  expenseTransactions.forEach(transaction => {
    const category = transaction.category;
    const amount = Math.abs(transaction.amount);
    
    if (categoryMap.has(category)) {
      categoryMap.set(category, categoryMap.get(category)! + amount);
    } else {
      categoryMap.set(category, amount);
    }
  });
  
  // Convert to array format needed for pie chart
  const result = Array.from(categoryMap.entries()).map(([name, value], index) => ({
    name,
    value,
    color: CHART_COLORS[index % CHART_COLORS.length],
  }));
  
  // Sort by value (highest first)
  return result.sort((a, b) => b.value - a.value);
};

// Group transactions by month for line chart
export const getMonthlyData = (transactions: Transaction[], months = 6): { labels: string[]; datasets: { data: number[] }[] } => {
  const now = new Date();
  const monthLabels: string[] = [];
  const incomeData: number[] = [];
  const expenseData: number[] = [];
  
  // Generate last X months
  for (let i = months - 1; i >= 0; i--) {
    const month = new Date(now.getFullYear(), now.getMonth() - i, 1);
    monthLabels.push(getMonthName(month));
  }
  
  // Initialize data arrays with zeros
  for (let i = 0; i < months; i++) {
    incomeData.push(0);
    expenseData.push(0);
  }
  
  // Process transactions
  transactions.forEach(transaction => {
    const transactionDate = transaction.date.toDate();
    const transactionMonth = transactionDate.getMonth();
    const transactionYear = transactionDate.getFullYear();
    
    // Check if transaction is within our time range
    for (let i = 0; i < months; i++) {
      const month = new Date(now.getFullYear(), now.getMonth() - (months - 1) + i, 1);
      
      if (transactionMonth === month.getMonth() && transactionYear === month.getFullYear()) {
        if (transaction.amount > 0) {
          incomeData[i] += transaction.amount;
        } else {
          expenseData[i] += Math.abs(transaction.amount);
        }
        break;
      }
    }
  });
  
  return {
    labels: monthLabels,
    datasets: [
      {
        data: incomeData,
      },
      {
        data: expenseData,
      },
    ],
  };
};

// Calculate budget progress data for progress chart
export const getBudgetProgressData = (budgetProgress: any[]): { labels: string[]; data: number[]; colors: string[] } => {
  const result = {
    labels: [] as string[],
    data: [] as number[],
    colors: [] as string[],
  };
  
  // Define category to color mapping
  const categoryColors: {[key: string]: string} = {
    'Food & Dining': '#4A90E2', // Blue
    'Transportation': '#E57373', // Red
    'Education': '#81C784', // Green
    'Clothes': '#FFD54F', // Yellow
    'Healthcare': '#7986CB', // Indigo
    'Entertainment': '#FF8A65', // Orange
    'Housing': '#9575CD', // Purple
    'Utilities': '#4DB6AC', // Teal
    'Shopping': '#F06292', // Pink
    'Other': '#A1887F', // Brown
  };
  
  budgetProgress.forEach((budget, index) => {
    // Calculate progress (as a decimal between 0-1)
    const progress = budget.percentage / 100;
    
    // Add to result
    result.labels.push(budget.category);
    result.data.push(progress);
    
    // Use category-specific color if available, otherwise use the default color from CHART_COLORS
    const color = categoryColors[budget.category] || CHART_COLORS[index % CHART_COLORS.length];
    result.colors.push(color);
  });
  
  return result;
};

// Get income vs expense data for bar chart
export const getIncomeVsExpenseData = (totalIncome: number, totalExpenses: number): { labels: string[]; datasets: { data: number[] }[]; barColors: string[] } => {
  // For income vs expense comparison, we'll use a simple bar chart with two bars
  return {
    labels: ['Income', 'Expenses'],
    datasets: [
      {
        data: [totalIncome, totalExpenses],
      },
    ],
    barColors: ['#4A90E2', '#E57373'],
  };
};