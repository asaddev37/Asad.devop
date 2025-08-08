import React from 'react';
import { View, Text, Dimensions, StyleSheet } from 'react-native';
import { BarChart as BarChartKit } from 'react-native-chart-kit';
import { useThemeColor } from '../../src/hooks/useThemeColor';

interface BarChartProps {
  data: {
    labels: string[];
    datasets: {
      data: number[];
      colors?: ((opacity: number) => string)[];
      strokeWidth?: number;
    }[];
    barColors?: string[];
  };
  title?: string;
  height?: number;
  width?: number;
  yAxisSuffix?: string;
  yAxisLabel?: string;
  xAxisLabel?: string;
  backgroundColor?: string;
  showValuesOnTopOfBars?: boolean;
  formatYLabel?: (label: string) => string;
  formatXLabel?: (label: string) => string;
  isDarkMode?: boolean;
}

const screenWidth = Dimensions.get('window').width;

export function BarChart({
  data,
  title,
  height = 220,
  width = screenWidth - 40,
  yAxisSuffix = '',
  yAxisLabel = '',
  xAxisLabel = '',
  backgroundColor,
  showValuesOnTopOfBars = false,
  formatYLabel,
  formatXLabel,
  isDarkMode,
}: BarChartProps) {
  const bgColor = isDarkMode ? '#121212' : '#fff';
  const textColor = isDarkMode ? '#fff' : '#000';
  const accentColor = isDarkMode ? '#4A90E2' : '#1e90ff';

  const chartConfig = {
    backgroundGradientFrom: backgroundColor || bgColor,
    backgroundGradientTo: backgroundColor || bgColor,
    decimalPlaces: 0,
    color: (opacity = 1) => `rgba(74, 144, 226, ${opacity})`,
    labelColor: (opacity = 1) => textColor,
    style: {
      borderRadius: 16,
    },
    propsForDots: {
      r: '6',
      strokeWidth: '2',
      stroke: accentColor,
    },
    barPercentage: 0.7,
    useShadowColorFromDataset: false,
    formatYLabel: formatYLabel,
    formatXLabel: formatXLabel,
  };

  // Convert string colors to color functions if needed
  const processedData = {
    ...data,
    datasets: data.datasets.map(dataset => ({
      ...dataset,
      colors: dataset.colors ? dataset.colors.map(color => 
        typeof color === 'string' ? ((opacity: number) => color) : color
      ) : undefined
    }))
  };

  return (
    <View style={[styles.container, { backgroundColor: backgroundColor || bgColor }]}>
      {title && <Text style={[styles.title, { color: textColor }]}>{title}</Text>}
      <BarChartKit
        data={processedData}
        width={width}
        height={height}
        yAxisSuffix={yAxisSuffix}
        yAxisLabel={yAxisLabel}
        xAxisLabel={xAxisLabel}
        chartConfig={chartConfig}
        style={styles.chart}
        showValuesOnTopOfBars={showValuesOnTopOfBars}
        fromZero
        withInnerLines={true}
        showBarTops={true}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    borderRadius: 16,
    padding: 8,
    marginVertical: 4,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 4,
  },
  title: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 16,
    textAlign: 'center',
  },
  chart: {
    marginVertical: 8,
    borderRadius: 16,
  },
});