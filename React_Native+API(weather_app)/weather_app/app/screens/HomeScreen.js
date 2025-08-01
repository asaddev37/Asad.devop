import React, { useState, useEffect, useRef, useContext, useMemo } from 'react';
import { 
  View, 
  Text, 
  StyleSheet, 
  ScrollView, 
  RefreshControl, 
  TouchableOpacity, 
  Animated, 
  StatusBar,
  SafeAreaView,
  Image,
  Dimensions,
  Platform
} from 'react-native';

const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get('window');
const isIOS = Platform.OS === 'ios';
import { useTheme } from '../../contexts/ThemeContext';
import { UserContext } from '../../contexts/UserContext';
import { getWeatherByCity } from '../../services/weatherService';
import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import * as Location from 'expo-location';
import { DrawerActions, useNavigation, useNavigationState } from '@react-navigation/native';

const HomeScreen = () => {
  const { colors, isDark, toggleTheme } = useTheme();
  const { user } = useContext(UserContext);
  const [refreshing, setRefreshing] = useState(false);
  const [currentWeather, setCurrentWeather] = useState(null);
  const [forecast, setForecast] = useState([]);
  const [location, setLocation] = useState('Loading...');
  const [error, setError] = useState('');
  const scrollY = useRef(new Animated.Value(0)).current;
  const navigation = useNavigation();
  
  // Use the styles function with current theme colors
  const styles = useMemo(() => stylesFn(colors), [colors]);
  
  // Get the current route name
  const currentRoute = useNavigationState(state => state?.routes[state.index]?.name);
  
  // Navigation functions using drawer navigation
  const navigateToSearch = () => {
    if (currentRoute !== 'search') {
      navigation.dispatch(DrawerActions.jumpTo('search'));
    }
  };
  
  const navigateToSettings = () => {
    if (currentRoute !== 'settings') {
      navigation.dispatch(DrawerActions.jumpTo('settings'));
    }
  };
  
  const navigateToHome = () => {
    if (currentRoute !== 'home') {
      navigation.dispatch(DrawerActions.jumpTo('home'));
    }
  };
  
  // Header animation
  const headerTranslateY = scrollY.interpolate({
    inputRange: [0, 100],
    outputRange: [0, -50],
    extrapolate: 'clamp',
  });

  // Load weather data
  const loadWeatherData = async () => {
    try {
      setRefreshing(true);
      setError('');
      
      // Default to a city if location is not available
      const defaultCity = 'London';
      
      try {
        // First try to get current location
        const isLocationEnabled = await Location.hasServicesEnabledAsync();
        if (isLocationEnabled) {
          const { status } = await Location.requestForegroundPermissionsAsync();
          if (status === 'granted') {
            const location = await Location.getCurrentPositionAsync({});
            const { latitude, longitude } = location.coords;
            
            // Get location name
            const [place] = await Location.reverseGeocodeAsync({ 
              latitude, 
              longitude,
              // Request additional address details
              includeCountry: true,
              includePostalCode: false,
              includeRegion: true
            });
            
            // Try to get the most specific location name available
            const locationName = [
              place.city,
              place.region,
              place.country
            ].filter(Boolean).join(', ') || defaultCity;
            
            setLocation(locationName);
            
            // Get weather data by city name
            const weatherData = await getWeatherByCity(place.city || defaultCity);
            setCurrentWeather({
              ...weatherData.current,
              name: weatherData.city || locationName
            });
            setForecast(weatherData.daily || []);
            return;
          }
        }
      } catch (locationError) {
        console.warn('Error getting location, using default city:', locationError);
      }
      
      // Fallback to default city if location fails
      try {
        setLocation(defaultCity);
        const weatherData = await getWeatherByCity(defaultCity);
        setCurrentWeather({
          ...weatherData.current,
          name: weatherData.city || defaultCity
        });
        setForecast(weatherData.daily || []);
      } catch (weatherError) {
        console.error('Error loading default weather data:', weatherError);
        setError('Failed to load weather data. Please check your connection and try again.');
      }
      
    } catch (error) {
      console.error('Error in loadWeatherData:', error);
      setError('An unexpected error occurred. Please try again.');
    } finally {
      setRefreshing(false);
    }
  };

  // Load default weather data for a default city
  const loadDefaultWeatherData = async () => {
    try {
      const weatherData = await getWeatherByCity('London');
      setCurrentWeather(weatherData.current);
      setForecast(weatherData.daily || []);
      setLocation(weatherData.city || 'London');
    } catch (error) {
      console.error('Error loading default weather data:', error);
      setError('Failed to load weather data for default location.');
    }
  };

  // Load data on component mount
  useEffect(() => {
    loadWeatherData();
  }, []);

  // Format temperature based on user preference
  const formatTemperature = (temp) => {
    if (!temp && temp !== 0) return '--';
    if (user?.preferences?.temperatureUnit === 'fahrenheit') {
      return `${Math.round((temp * 9/5) + 32)}°F`;
    }
    return `${Math.round(temp)}°`;
  };

  // Format wind speed based on user preference
  const formatWindSpeed = (speed) => {
    if (!speed && speed !== 0) return '--';
    if (user?.preferences?.windSpeedUnit === 'mph') {
      return `${(speed * 0.621371).toFixed(1)} mph`;
    } else if (user?.preferences?.windSpeedUnit === 'ms') {
      return `${speed.toFixed(1)} m/s`;
    }
    return `${(speed * 3.6).toFixed(1)} km/h`;
  };

  // Format visibility
  const formatVisibility = (meters) => {
    if (!meters) return '--';
    return meters >= 1000 ? `${(meters / 1000).toFixed(1)} km` : `${meters} m`;
  };

  // Weather icon mapping
  const weatherIcons = {
    '01d': 'sunny',
    '01n': 'moon',
    '02d': 'partly-sunny',
    '02n': 'cloudy-night',
    '03d': 'cloud',
    '03n': 'cloud',
    '04d': 'cloudy',
    '04n': 'cloudy',
    '09d': 'rainy',
    '09n': 'rainy',
    '10d': 'rainy',
    '10n': 'rainy',
    '11d': 'thunderstorm',
    '11n': 'thunderstorm',
    '13d': 'snow',
    '13n': 'snow',
    '50d': 'cloudy',
    '50n': 'cloudy'
  };

  // Gradient colors based on weather condition
  const weatherGradients = {
    '01d': ['#FFD700', '#FF8C00'], // Clear day
    '01n': ['#0F2027', '#203A43', '#2C5364'], // Clear night
    '02d': ['#a8c0ff', '#3f2b96'], // Few clouds day
    '02n': ['#0F2027', '#203A43', '#2C5364'], // Few clouds night
    '03d': ['#bdc3c7', '#2c3e50'], // Scattered clouds
    '03n': ['#0F2027', '#203A43', '#2C5364'], // Scattered clouds night
    '04d': ['#bdc3c7', '#2c3e50'], // Broken clouds
    '04n': ['#0F2027', '#203A43', '#2C5364'], // Broken clouds night
    '09d': ['#4b6cb7', '#182848'], // Rain
    '09n': ['#0F2027', '#203A43'], // Rain night
    '10d': ['#4b6cb7', '#182848'], // Rain
    '10n': ['#0F2027', '#203A43'], // Rain night
    '11d': ['#1f4037', '#1f4037', '#1f4037'], // Thunderstorm
    '11n': ['#0F2027', '#203A43'], // Thunderstorm night
    '13d': ['#E0EAFC', '#CFDEF3'], // Snow
    '13n': ['#0F2027', '#203A43'], // Snow night
    '50d': ['#bdc3c7', '#2c3e50'], // Mist
    '50n': ['#0F2027', '#203A43'] // Mist night
  };

  // Get weather icon based on condition code
  const getWeatherIcon = (conditionCode) => {
    return weatherIcons[conditionCode] || 'help';
  };

  // Get gradient colors for weather condition
  const getWeatherGradient = (conditionCode) => {
    return weatherGradients[conditionCode] || ['#4b6cb7', '#182848'];
  };

  // Render the header with gradient and weather info
  const renderHeader = () => {
    const weatherCondition = currentWeather?.weather?.[0]?.icon || '01d';
    const gradient = getWeatherGradient(weatherCondition);
    const temp = currentWeather ? Math.round(currentWeather.temp) : '--';
    const description = currentWeather?.weather?.[0]?.description || 'Loading...';
    const city = currentWeather?.name || location.split(',')[0] || 'Current Location';
    
    const dateString = new Date().toLocaleDateString('en-US', { 
      weekday: 'long',
      month: 'long',
      day: 'numeric',
      year: 'numeric'
    });

    return (
      <LinearGradient
        colors={gradient}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
        style={styles.headerGradient}
      >
        <View style={styles.headerContainer}>
          <View style={styles.appBar}>
            <TouchableOpacity 
              onPress={() => navigation.dispatch(DrawerActions.toggleDrawer())}
              style={styles.menuButton}
            >
              <Ionicons name="menu" size={28} color="rgba(255,255,255,0.9)" />
            </TouchableOpacity>
            
            <TouchableOpacity 
              onPress={toggleTheme}
              style={styles.themeButton}
            >
              <Ionicons 
                name={isDark ? 'sunny' : 'moon'} 
                size={24} 
                color="rgba(255,255,255,0.9)" 
              />
            </TouchableOpacity>
          </View>

          <View style={styles.locationContainer}>
            <Text style={styles.locationText} numberOfLines={1}>
              {city}
            </Text>
            <Text style={styles.dateText}>
              {dateString}
            </Text>
          </View>
          
          <View style={styles.currentWeatherContainer}>
            <Ionicons 
              name={getWeatherIcon(weatherCondition)} 
              size={80} 
              color="rgba(255,255,255,0.95)" 
              style={styles.weatherIcon}
            />
            <Text style={styles.temperature}>{temp}°</Text>
          </View>
          <Text style={styles.weatherDescription}>
            {description.charAt(0).toUpperCase() + description.slice(1)}
          </Text>
        </View>
      </LinearGradient>
    );
  };
  
  // Render 5-day forecast
  const renderForecast = () => {
    if (!forecast || forecast.length === 0) return null;
    
    return (
      <View style={styles.forecastContainer}>
        <Text style={styles.forecastTitle}>5-Day Forecast</Text>
        {forecast.slice(0, 5).map((day, index) => {
          const date = new Date(day.dt * 1000);
          const dayName = date.toLocaleDateString('en-US', { weekday: 'short' });
          const tempMax = Math.round(day.temp?.max || day.temp?.day || day.temp);
          const tempMin = Math.round(day.temp?.min || day.temp?.night || day.temp);
          const weatherIcon = day.weather?.[0]?.icon || '01d';
          
          return (
            <View key={index} style={styles.forecastItem}>
              <Text style={styles.forecastDay}>
                {index === 0 ? 'Today' : dayName}
              </Text>
              <Ionicons 
                name={getWeatherIcon(weatherIcon)}
                size={30}
                color={colors.primary}
                style={styles.forecastIcon}
              />
              <View style={styles.forecastTemps}>
                <Text style={styles.forecastTempHigh}>{tempMax}°</Text>
                <Text style={styles.forecastTempLow}>{tempMin}°</Text>
              </View>
            </View>
          );
        })}
      </View>
    );
  };

  // Render weather details (humidity, pressure, wind, visibility)
  const renderWeatherDetails = () => (
    <View style={styles.weatherDetails}>
      <View style={styles.detailItem}>
        <Ionicons name="water" size={24} color={colors.primary} />
        <Text style={[styles.detailValue, { color: colors.text }]}>
          {currentWeather?.humidity}%
        </Text>
        <Text style={[styles.detailLabel, { color: colors.textSecondary }]}>
          Humidity
        </Text>
      </View>
      
      <View style={styles.detailItem}>
        <Ionicons name="speedometer" size={24} color={colors.primary} />
        <Text style={[styles.detailValue, { color: colors.text }]}>
          {currentWeather?.pressure} hPa
        </Text>
        <Text style={[styles.detailLabel, { color: colors.textSecondary }]}>
          Pressure
        </Text>
      </View>
      
      <View style={styles.detailItem}>
        <Ionicons name="speedometer-outline" size={24} color={colors.primary} />
        <Text style={[styles.detailValue, { color: colors.text }]}>
          {currentWeather?.wind_speed ? formatWindSpeed(currentWeather.wind_speed) : '--'}
        </Text>
        <Text style={[styles.detailLabel, { color: colors.textSecondary }]}>
          Wind
        </Text>
      </View>
      
      <View style={styles.detailItem}>
        <Ionicons name="eye" size={24} color={colors.primary} />
        <Text style={[styles.detailValue, { color: colors.text }]}>
          {currentWeather?.visibility ? formatVisibility(currentWeather.visibility) : '--'}
        </Text>
        <Text style={[styles.detailLabel, { color: colors.textSecondary }]}>
          Visibility
        </Text>
      </View>
    </View>
  );

  // Get time-based greeting
  const getGreeting = () => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  };

  // Render loading/error state
  if (!currentWeather) {
    return (
      <View style={[styles.container, { backgroundColor: colors.background }]}>
        <Text style={[styles.loadingText, { color: colors.text }]}>
          {error || 'Loading weather data...'}
        </Text>
      </View>
    );
  }

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: colors.background }]}>
      <StatusBar 
        barStyle="light-content"
        backgroundColor="transparent"
        translucent
      />
      
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={loadWeatherData}
            colors={['#fff']}
            tintColor="#fff"
          />
        }
      >
        {renderHeader()}
        {renderForecast()}
        
        {error ? (
          <View style={styles.errorContainer}>
            <Text style={styles.errorText}>{error}</Text>
          </View>
        ) : null}
      </ScrollView>
      
      {/* Footer Navigation */}
      <View style={[styles.footer, { backgroundColor: colors.card, borderTopColor: colors.border }]}>
        <TouchableOpacity 
          style={[styles.footerButton, { borderTopWidth: 3, borderTopColor: colors.primary }]}
          onPress={navigateToHome}
        >
          <View style={styles.footerIconContainer}>
            <Ionicons name="home" size={24} color={colors.primary} />
          </View>
          <Text style={[styles.footerText, { color: colors.primary, fontWeight: '600' }]}>Home</Text>
        </TouchableOpacity>
        
        <TouchableOpacity 
          style={styles.footerButton}
          onPress={navigateToSearch}
        >
          <View style={styles.footerIconContainer}>
            <Ionicons name="search" size={24} color={colors.text} />
          </View>
          <Text style={[styles.footerText, { color: colors.text }]}>Search</Text>
        </TouchableOpacity>
        
        <TouchableOpacity 
          style={styles.footerButton}
          onPress={navigateToSettings}
        >
          <View style={styles.footerIconContainer}>
            <Ionicons name="settings-outline" size={24} color={colors.text} />
          </View>
          <Text style={[styles.footerText, { color: colors.text }]}>Settings</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
};

const stylesFn = (colors) => StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingBottom: 20,
  },
  headerGradient: {
    borderBottomLeftRadius: 30,
    borderBottomRightRadius: 30,
    paddingTop: StatusBar.currentHeight + 10,
    paddingBottom: 30,
    marginBottom: 20,
    overflow: 'hidden',
  },
  headerContainer: {
    paddingHorizontal: 24,
    paddingBottom: 20,
  },
  appBar: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 25,
  },
  headerTimeContainer: {
    backgroundColor: 'rgba(255, 255, 255, 0.15)',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 16,
  },
  headerTimeText: {
    color: 'rgba(255, 255, 255, 0.95)',
    fontSize: 14,
    fontWeight: '600',
  },
  menuButton: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: 'rgba(255, 255, 255, 0.15)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  themeButton: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: 'rgba(255, 255, 255, 0.15)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  locationContainer: {
    marginBottom: 25,
  },
  locationTextContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 4,
  },
  locationIconContainer: {
    marginRight: 8,
    padding: 6,
    backgroundColor: 'rgba(255, 255, 255, 0.15)',
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
  },
  locationText: {
    color: 'rgba(255, 255, 255, 0.95)',
    fontSize: 24,
    fontWeight: '700',
    maxWidth: '80%',
  },
  dateText: {
    color: 'rgba(255, 255, 255, 0.8)',
    fontSize: 15,
    marginLeft: 36, // Match icon container width + margin
  },
  currentWeatherContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 30,
  },
  tempContainer: {
    flex: 1,
  },
  temperature: {
    fontSize: 72,
    fontWeight: '800',
    color: 'rgba(255, 255, 255, 0.95)',
    lineHeight: 80,
    textShadowColor: 'rgba(0, 0, 0, 0.15)',
    textShadowOffset: { width: 1, height: 1 },
    textShadowRadius: 5,
  },
  weatherDescription: {
    color: 'rgba(255, 255, 255, 0.9)',
    fontSize: 18,
    marginTop: 4,
    textTransform: 'capitalize',
    fontWeight: '500',
    textAlign: 'center',
    marginBottom: 20,
  },
  weatherIconContainer: {
    width: 140,
    height: 140,
    justifyContent: 'center',
    alignItems: 'center',
  },
  weatherContainer: {
    padding: 20,
    borderRadius: 20,
    margin: 20,
    overflow: 'hidden',
  },
  forecastContainer: {
    marginTop: 20,
    paddingHorizontal: 20,
    backgroundColor: '#fff',
    marginHorizontal: 20,
    borderRadius: 20,
    padding: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 3,
  },
  forecastTitle: {
    fontSize: 20,
    fontWeight: '700',
    color: '#333',
    marginBottom: 15,
    marginLeft: 5,
  },
  forecastItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  forecastDay: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    width: 80,
  },
  forecastIcon: {
    width: 50,
    textAlign: 'center',
  },
  forecastTemps: {
    flexDirection: 'row',
    alignItems: 'center',
    width: 80,
    justifyContent: 'flex-end',
  },
  forecastTempHigh: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    width: 30,
    textAlign: 'right',
  },
  forecastTempLow: {
    fontSize: 14,
    color: '#888',
    width: 30,
    textAlign: 'right',
  },
  errorContainer: {
    margin: 20,
    padding: 15,
    backgroundColor: '#ffebee',
    borderRadius: 12,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  errorText: {
    color: '#d32f2f',
    textAlign: 'center',
    fontSize: 14,
  },
  retryButtonText: {
    color: '#fff',
    fontWeight: '600',
  },
  // Footer Styles
  footer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    alignItems: 'center',
    height: 75,
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: colors.card,
    borderTopWidth: 1,
    borderTopColor: colors.border,
    elevation: 10,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    paddingBottom: Platform.OS === 'ios' ? 20 : 10,
    paddingTop: 8,
  },
  footerButton: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 8,
    borderRadius: 8,
    marginHorizontal: 6,
  },
  footerIconContainer: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: 'transparent',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 4,
  },
  footerText: {
    fontSize: 12,
    marginTop: 2,
    textAlign: 'center',
    fontWeight: '500',
  },
});

export default HomeScreen;
