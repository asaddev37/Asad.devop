import React from 'react';
import { NavigationContainer } from "@react-navigation/native";
import { 
  createBottomTabNavigator, 
  BottomTabNavigationOptions,
  BottomTabBarButtonProps 
} from "@react-navigation/bottom-tabs";
import { 
  createDrawerNavigator, 
  DrawerNavigationOptions 
} from "@react-navigation/drawer";
import { 
  createStackNavigator, 
  CardStyleInterpolators, 
  StackCardInterpolationProps,
  StackNavigationOptions
} from "@react-navigation/stack";
import { 
  Easing, 
  TouchableOpacity, 
  StyleProp, 
  ViewStyle,
  View,
  Text
} from 'react-native';
import Icon from "react-native-vector-icons/MaterialIcons";

// Import screens
import { DashboardScreen } from "../screens/DashboardScreen";
import { TasksScreen } from "../screens/TasksScreen";
import { CalendarScreen } from "../screens/CalendarScreen";
import { StatsScreen } from "../screens/StatsScreen";
import { SettingsScreen } from "../screens/SettingsScreen";
import { TaskFormScreen } from "../screens/TaskFormScreen";
import DrawerContent from "../components/DrawerContent";

type TabParamList = {
  Dashboard: undefined;
  Tasks: undefined;
  Calendar: undefined;
  Stats: undefined;
};

type DrawerParamList = {
  Main: undefined;
  Settings: undefined;
};

type RootStackParamList = {
  Home: undefined;
  TaskForm: undefined;
};

const Tab = createBottomTabNavigator<TabParamList>();
const Drawer = createDrawerNavigator<DrawerParamList>();
const Stack = createStackNavigator<RootStackParamList>();

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

// Custom tab bar button component to handle the touchable with proper typing
const CustomTabBarButton: React.FC<BottomTabBarButtonProps> = (props) => {
  const { children, onPress, style, ...restProps } = props;
  const buttonStyle = style as StyleProp<ViewStyle>;
  
  // Filter out delayLongPress to prevent type issues
  const { delayLongPress, ...filteredProps } = restProps as any;
  
  // Get the route name from the accessibility label
  const routeName = props.accessibilityLabel || '';
  let iconName = 'home';
  
  switch (routeName) {
    case "Dashboard":
      iconName = "home";
      break;
    case "Tasks":
      iconName = "check-box";
      break;
    case "Calendar":
      iconName = "event";
      break;
    case "Stats":
      iconName = "bar-chart";
      break;
  }
  
  return (
    <TouchableOpacity
      {...filteredProps}
      activeOpacity={0.7}
      onPress={onPress}
      style={[buttonStyle, { 
        transform: [{ scale: restProps.accessibilityState?.selected ? 1.1 : 1 }],
        justifyContent: 'center',
        alignItems: 'center',
        flex: 1,
      }]}
    >
      <View style={{ alignItems: 'center' }}>
        <Icon 
          name={iconName} 
          size={24} 
          color={restProps.accessibilityState?.selected ? "#8B5CF6" : "#6B7280"} 
        />
        {children}
      </View>
    </TouchableOpacity>
  );
};

const TabNavigator = () => {
  const screenOptions = ({ route }: { route: any }): BottomTabNavigationOptions => ({
    tabBarIcon: ({ focused, color, size }) => {
      let iconName = 'home';
      
      if (route.name === 'Dashboard') {
        iconName = 'home';
      } else if (route.name === 'Tasks') {
        iconName = 'check-box';
      } else if (route.name === 'Calendar') {
        iconName = 'event';
      } else if (route.name === 'Stats') {
        iconName = 'bar-chart';
      }
      
      return <Icon name={iconName} size={size} color={color} />;
    },
    tabBarActiveTintColor: "#8B5CF6",
    tabBarInactiveTintColor: "#6B7280",
    tabBarStyle: {
      backgroundColor: "#FFFFFF",
      borderTopWidth: 1,
      borderTopColor: "#E5E7EB",
      height: 60,
      paddingBottom: 5,
      paddingTop: 5,
    },
    headerShown: false,
    tabBarButton: (props) => (
      <CustomTabBarButton {...props} accessibilityLabel={route.name} />
    )
  });

  return (
    <Tab.Navigator screenOptions={screenOptions}>
      <Tab.Screen
        name="Dashboard"
        component={DashboardScreen}
        options={{
          title: "Dashboard",
        }}
      />
      <Tab.Screen
        name="Tasks"
        component={TasksScreen}
        options={{
          title: "Tasks",
        }}
      />
      <Tab.Screen
        name="Calendar"
        component={CalendarScreen}
        options={{
          title: "Calendar",
        }}
      />
      <Tab.Screen
        name="Stats"
        component={StatsScreen}
        options={{
          title: "Stats",
        }}
      />
    </Tab.Navigator>
  );
};


const DrawerNavigator = () => {
  const drawerScreenOptions: DrawerNavigationOptions = {
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
    drawerType: "slide",
    overlayColor: "rgba(0, 0, 0, 0.5)",
  };

  const sceneContainerStyle = {
    backgroundColor: "#F9FAFB",
  };

  return (
    <Drawer.Navigator
      drawerContent={(props) => <DrawerContent {...props} />}
      screenOptions={{
        ...drawerScreenOptions,
        drawerStyle: {
          ...(drawerScreenOptions.drawerStyle as object),
          backgroundColor: "#F9FAFB",
          width: 280,
        },
      }}
    >
      <Drawer.Screen
        name="Main"
        component={TabNavigator}
        options={{
          title: "TaskFlow",
        }}
      />
      <Drawer.Screen
        name="Settings"
        component={SettingsScreen}
      />
    </Drawer.Navigator>
  );
};



const RootStack = () => {
  return (
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
          cardStyleInterpolator: CardStyleInterpolators.forModalPresentationIOS,
          transitionSpec: {
            open: {
              animation: "timing",
              config: {
                duration: 300,
                easing: Easing.out(Easing.cubic),
              },
            },
            close: {
              animation: "timing",
              config: {
                duration: 250,
                easing: Easing.in(Easing.cubic),
              },
            },
          },
        }}
      />
    </Stack.Navigator>
  );
};

const AppNavigator = () => {
  return (
    <NavigationContainer>
      <RootStack />
    </NavigationContainer>
  );
};

export default AppNavigator;
