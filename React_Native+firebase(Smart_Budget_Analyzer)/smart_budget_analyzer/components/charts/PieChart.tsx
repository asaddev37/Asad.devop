import React from 'react';
import { View, Text, Dimensions, StyleSheet } from 'react-native';
import { PieChart as PieChartKit } from 'react-native-chart-kit';
import { useThemeColor } from '../../src/hooks/useThemeColor';

interface PieChartData {
  name: string;
  value: number;
  color: string;
  legendFontColor?: string;
  legendFontSize?: number;
}

interface PieChartProps {
  data: PieChartData[];
  title?: string;
  height?: number;
  width?: number;
  accessor?: string;
  backgroundColor?: string;
  paddingLeft?: string;
  absolute?: boolean;
  hasLegend?: boolean;
  centerText?: string;
  theme?: string;
  isDarkMode?: boolean;
}

const screenWidth = Dimensions.get('window').width;

export function PieChart({
  data,
  title,
  height = 220,
  width = screenWidth - 40,
  accessor = 'value',
  backgroundColor,
  paddingLeft = '0',
  absolute = false,
  hasLegend = true,
  centerText,
  theme,
  isDarkMode,
}: PieChartProps) {
  const chartConfig = {
    backgroundGradientFrom: '#1E2923',
    backgroundGradientTo: '#08130D',
    color: (opacity = 1) => `rgba(26, 255, 146, ${opacity})`,
    strokeWidth: 2,
    barPercentage: 0.5,
    useShadowColorFromDataset: false,
  };

  const bgColor = isDarkMode ? '#121212' : '#fff';
  const textColor = isDarkMode ? '#fff' : '#000';

  // Ensure all data items have legendFontColor set based on theme
  const themedData = data.map(item => ({
    ...item,
    legendFontColor: item.legendFontColor || textColor,
    legendFontSize: item.legendFontSize || 12,
  }));

  return (
    <View style={[styles.container, { backgroundColor: backgroundColor || bgColor }]}>
      {title && <Text style={[styles.title, { color: textColor }]}>{title}</Text>}
      <PieChartKit
        data={themedData}
        width={width}
        height={height}
        chartConfig={chartConfig}
        accessor={accessor}
        backgroundColor={backgroundColor || 'transparent'}
        paddingLeft={paddingLeft}
        absolute={absolute}
        hasLegend={hasLegend}
        center={centerText ? [width / 2, height / 2] : undefined}
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
});