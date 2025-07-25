import { NavigationContainer } from "@react-navigation/native"
import { createBottomTabNavigator } from "@react-navigation/bottom-tabs"
import { createDrawerNavigator } from "@react-navigation/drawer"
import { createStackNavigator, CardStyleInterpolators } from "@react-navigation/stack"
import Icon from "react-native-vector-icons/MaterialIcons"
import { Easing } from "react-native"
import { TouchableOpacity } from "react-native"

import { DashboardScreen } from "../screens/DashboardScreen"
import { TasksScreen } from "../screens/TasksScreen"
import { CalendarScreen } from "../screens/CalendarScreen"
import { StatsScreen } from "../screens/StatsScreen"
import { SettingsScreen } from "../screens/SettingsScreen"
import { TaskFormScreen } from "../screens/TaskFormScreen"
import { DrawerContent } from "../components/DrawerContent"

const Tab = createBottomTabNavigator()
const Drawer = createDrawerNavigator()
const Stack = createStackNavigator()

// Custom transition configurations
const customTransitionConfig = {
  animation: "spring" as const,
  config: {
    stiffness: 1000,
    damping: 500,
    mass: 3,
    overshootClamping: true,
    restDisplacementThreshold: 0.01,
    restSpeedThreshold: 0.01,
  },
}

const slideFromRightConfig = {
  cardStyleInterpolator: CardStyleInterpolators.forHorizontalIOS,
  transitionSpec: {
    open: {
      animation: "timing" as const,
      config: {
        duration: 300,
        easing: Easing.out(Easing.cubic),
      },
    },
    close: {
      animation: "timing" as const,
      config: {
        duration: 250,
        easing: Easing.in(Easing.cubic),
      },
    },
  },
}

const modalConfig = {
  cardStyleInterpolator: CardStyleInterpolators.forModalPresentationIOS,
  transitionSpec: {
    open: {
      animation: "timing" as const,
      config: {
        duration: 300,
        easing: Easing.out(Easing.cubic),
      },
    },
    close: {
      animation: "timing" as const,
      config: {
        duration: 250,
        easing: Easing.in(Easing.cubic),
      },
    },
  },
}

const TabNavigator = () => (
  <Tab.Navigator
    screenOptions={({ route }) => ({
      tabBarIcon: ({ focused, color, size }) => {
        let iconName: string

        switch (route.name) {
          case "Dashboard":
            iconName = "home"
            break
          case "Tasks":
            iconName = "check-box"
            break
          case "Calendar":
            iconName = "event"
            break
          case "Stats":
            iconName = "bar-chart"
            break
          default:
            iconName = "home"
        }

        return <Icon name={iconName} size={size} color={color} />
      },
      tabBarActiveTintColor: "#8B5CF6",
      tabBarInactiveTintColor: "#6B7280",
      tabBarStyle: {
        backgroundColor: "#FFFFFF",
        borderTopWidth: 1,
        borderTopColor: "#E5E7EB",
        paddingBottom: 5,
        paddingTop: 5,
        height: 60,
      },
      headerShown: false,
      // Tab press animation
      tabBarButton: (props) => (
        <TouchableOpacity
          {...props}
          activeOpacity={0.7}
          style={[props.style, { transform: [{ scale: props.accessibilityState?.selected ? 1.1 : 1 }] }]}
        />
      ),
    })}
  >
    <Tab.Screen
      name="Dashboard"
      component={DashboardScreen}
      options={{
        ...slideFromRightConfig,
      }}
    />
    <Tab.Screen
      name="Tasks"
      component={TasksScreen}
      options={{
        ...slideFromRightConfig,
      }}
    />
    <Tab.Screen
      name="Calendar"
      component={CalendarScreen}
      options={{
        ...slideFromRightConfig,
      }}
    />
    <Tab.Screen
      name="Stats"
      component={StatsScreen}
      options={{
        ...slideFromRightConfig,
      }}
    />
  </Tab.Navigator>
)

const DrawerNavigator = () => (
  <Drawer.Navigator
    drawerContent={(props) => <DrawerContent {...props} />}
    screenOptions={{
      headerShown: true,
      headerStyle: {
        backgroundColor: "#FFFFFF",
        elevation: 1,
        shadowOpacity: 0.1,
      },
      headerTintColor: "#1F2937",
      headerTitleStyle: {
        fontWeight: "600",
      },
      drawerStyle: {
        backgroundColor: "#FFFFFF",
        width: 280,
      },
      // Drawer animation
      drawerType: "slide",
      overlayColor: "rgba(0, 0, 0, 0.5)",
      sceneContainerStyle: {
        backgroundColor: "#F9FAFB",
      },
    }}
  >
    <Drawer.Screen
      name="Main"
      component={TabNavigator}
      options={{
        title: "TaskFlow",
        ...slideFromRightConfig,
      }}
    />
    <Drawer.Screen
      name="Settings"
      component={SettingsScreen}
      options={{
        ...slideFromRightConfig,
      }}
    />
  </Drawer.Navigator>
)

const AppNavigator = () => (
  <NavigationContainer>
    <Stack.Navigator
      screenOptions={{
        headerShown: false,
        gestureEnabled: true,
        gestureDirection: "horizontal",
      }}
    >
      <Stack.Screen
        name="Home"
        component={DrawerNavigator}
        options={{
          ...slideFromRightConfig,
        }}
      />
      <Stack.Screen
        name="TaskForm"
        component={TaskFormScreen}
        options={{
          presentation: "modal",
          headerShown: true,
          headerTitle: "Add Task",
          headerStyle: {
            backgroundColor: "#FFFFFF",
          },
          headerTintColor: "#1F2937",
          ...modalConfig,
        }}
      />
    </Stack.Navigator>
  </NavigationContainer>
)

export default AppNavigator
