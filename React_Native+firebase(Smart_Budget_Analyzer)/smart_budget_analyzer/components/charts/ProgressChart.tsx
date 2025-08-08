import React from 'react';
import { View, Text, Dimensions, StyleSheet } from 'react-native';
import { ProgressChart as ProgressChartKit } from 'react-native-chart-kit';
import { useThemeColor } from '../../src/hooks/useThemeColor';

interface ProgressChartProps {
  data: {
    labels?: string[];
    data: number[];
    colors?: string[];
  };
  title?: string;
  height?: number;
  width?: number;
  backgroundColor?: string;
  radius?: number;
  strokeWidth?: number;
  hideLegend?: boolean;
  isDarkMode?: boolean;
}

const screenWidth = Dimensions.get('window').width;

export function ProgressChart({
  data,
  title,
  height = 220,
  width = screenWidth - 40,
  backgroundColor,
  radius = 32,
  strokeWidth = 16,
  hideLegend = false,
  isDarkMode,
}: ProgressChartProps) {
  const bgColor = isDarkMode ? '#121212' : '#fff';
  const textColor = isDarkMode ? '#fff' : '#000';

  const chartConfig = {
    backgroundGradientFrom: backgroundColor || bgColor,
    backgroundGradientTo: backgroundColor || bgColor,
    color: (opacity = 1) => {
      // Use custom colors if provided, otherwise use default gradient
      if (data.colors && data.colors.length > 0) {
        // This won't actually be used since we're providing colors in the data
        return `rgba(74, 144, 226, ${opacity})`;
      }
      
      // Default gradient
      return `rgba(74, 144, 226, ${opacity})`;
    },
    labelColor: (opacity = 1) => textColor,
    strokeWidth,
    useShadowColorFromDataset: false,
  };

  return (
    <View style={[styles.container, { backgroundColor: backgroundColor || bgColor }]}>
      {title && <Text style={[styles.title, { color: textColor }]}>{title}</Text>}
      <ProgressChartKit
        data={data.data}
        width={width}
        height={height}
        strokeWidth={strokeWidth}
        radius={radius}
        chartConfig={chartConfig}
        hideLegend={hideLegend}
        style={styles.chart}
      />
      
      {/* Custom legend if labels are provided and legend is not hidden */}
      {!hideLegend && data.labels && data.labels.length > 0 && (
        <View style={styles.legendContainer}>
          {data.labels.map((label, index) => {
            const color = data.colors && data.colors[index] 
              ? data.colors[index] 
              : `rgba(74, 144, 226, 1)`;
              
            return (
              <View key={index} style={styles.legendItem}>
                <View style={[styles.legendColor, { backgroundColor: color }]} />
                <Text style={[styles.legendText, { color: textColor }]}>
                  {label}: {Math.round(data.data[index] * 100)}%
                </Text>
              </View>
            );
          })}
        </View>
      )}
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
  legendContainer: {
    marginTop: 16,
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'flex-start',
  },
  legendItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginVertical: 4,
  },
  legendColor: {
    width: 16,
    height: 16,
    borderRadius: 8,
    marginRight: 8,
  },
  legendText: {
    fontSize: 14,
  },
});