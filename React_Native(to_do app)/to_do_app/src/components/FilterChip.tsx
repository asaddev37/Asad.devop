import type React from "react"
import { TouchableOpacity, Text, StyleSheet } from "react-native"
import Icon from "react-native-vector-icons/MaterialIcons"

interface FilterChipProps {
  label: string
  icon: string
  active: boolean
  onPress: () => void
}

export const FilterChip: React.FC<FilterChipProps> = ({ label, icon, active, onPress }) => {
  return (
    <TouchableOpacity style={[styles.chip, active && styles.activeChip]} onPress={onPress}>
      <Icon name={icon} size={16} color={active ? "#FFFFFF" : "#6B7280"} style={styles.icon} />
      <Text style={[styles.label, active && styles.activeLabel]}>{label}</Text>
    </TouchableOpacity>
  )
}

const styles = StyleSheet.create({
  chip: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "#FFFFFF",
    borderRadius: 20,
    paddingHorizontal: 12,
    paddingVertical: 8,
    marginRight: 8,
    borderWidth: 1,
    borderColor: "#E5E7EB",
  },
  activeChip: {
    backgroundColor: "#8B5CF6",
    borderColor: "#8B5CF6",
  },
  icon: {
    marginRight: 4,
  },
  label: {
    fontSize: 14,
    color: "#6B7280",
    fontWeight: "500",
  },
  activeLabel: {
    color: "#FFFFFF",
  },
})
