import { NativeStackNavigationProp } from '@react-navigation/native-stack';

export type RootStackParamList = {
  Loading: undefined;
  Home: undefined;
  Login: undefined;
  Signup: undefined;
};

export type NavigationProps = NativeStackNavigationProp<RootStackParamList>;
