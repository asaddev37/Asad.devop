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
  Image
} from 'react-native';
import { useTheme } from '../../contexts/ThemeContext';
import { UserContext } from '../../contexts/UserContext';
import { getWeatherData } from '../../services/weatherService';
import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import * as Location from 'expo-location';
import { DrawerActions } from '@react-navigation/native';

const HomeScreen = ({ navigation }) => {
  const { colors, isDark, toggleTheme } = useTheme();
  const { user } = useContext(UserContext);
  const [refreshing, setRefreshing] = useState(false);
  const [currentWeather, setCurrentWeather] = useState(null);
  const [forecast, setForecast] = useState([]);
  const [location, setLocation] = useState('Loading...');
  const [error, setError] = useState('');
  const scrollY = useRef(new Animated.Value(0)).current;
  
  // Use the styles function with current theme colors
  const styles = useMemo(() => stylesFn(colors), [colors]);
  
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
      
      const isLocationEnabled = await Location.hasServicesEnabledAsync();
      if (!isLocationEnabled) {
        setError('Location services are disabled. Please enable them in your device settings.');
        return;
      }

      let { status } = await Location.requestForegroundPermissionsAsync();
      if (status !== 'granted') {
        setError('Location permission is required to show weather for your current location.');
        await loadWeatherForDefaultLocation();
        return;
      }

      let location;
      try {
        location = await Promise.race([
          Location.getCurrentPositionAsync({
            accuracy: Location.Accuracy.Low,
            timeout: 10000
          }),
          new Promise((_, reject) => 
            setTimeout(() => reject(new Error('Location request timed out')), 10000)
          )
        ]);
      } catch (locationError) {
        console.warn('Error getting location:', locationError);
        setError('Could not get your current location. Using default location.');
        await loadWeatherForDefaultLocation();
        return;
      }

      const { latitude, longitude } = location.coords;
      
      try {
        let address = await Location.reverseGeocodeAsync({ latitude, longitude });
        if (address?.[0]) {
          const { city, region, country } = address[0];
          setLocation(`${city || ''}${city && region ? ', ' : ''}${region || ''}${(city || region) && country ? ', ' : ''}${country || ''}`.trim() || 'Your Location');
        }
      } catch (addressError) {
        console.warn('Error getting address:', addressError);
        setLocation('Your Location');
      }

      try {
        const weatherData = await getWeatherData(latitude, longitude);
        if (!weatherData?.current) {
          throw new Error('Invalid weather data received');
        }
        setCurrentWeather(weatherData.current);
        setForecast(Array.isArray(weatherData.daily) ? weatherData.daily.slice(0, 5) : []);
      } catch (weatherError) {
        console.error('Error in weather data processing:', weatherError);
        setError('Failed to load weather data. Please try again later.');
      }
    } catch (error) {
      console.error('Error in loadWeatherData:', error);
      if (!error.message.includes('Location services are disabled') && 
          !error.message.includes('Location permission')) {
        setError('An unexpected error occurred. Please try again.');
      }
    } finally {
      setRefreshing(false);
    }
  };

  // Load default location (New York)
  const loadWeatherForDefaultLocation = async () => {
    try {
      const weatherData = await getWeatherData(40.7128, -74.0060);
      setCurrentWeather(weatherData.current);
      setForecast(weatherData.daily?.slice(0, 5) || []);
      setLocation('New York, US');
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
    if (user?.preferences?.temperatureUnit === 'fahrenheit') {
      return `${Math.round((temp * 9/5) + 32)}°F`;
    }
    return `${Math.round(temp)}°C`;
  };

  // Format wind speed based on user preference
  const formatWindSpeed = (speed) => {
    if (user?.preferences?.windSpeedUnit === 'mph') {
      return `${(speed * 0.621371).toFixed(1)} mph`;
    } else if (user?.preferences?.windSpeedUnit === 'ms') {
      return `${speed.toFixed(1)} m/s`;
    }
    return `${speed.toFixed(1)} km/h`;
  };

  // Get weather icon based on condition code
  const getWeatherIcon = (conditionCode) => {
    const iconMap = {
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
      '50n': 'cloudy',
    };
    return iconMap[conditionCode] || 'help';
  };

  // Render the app bar with menu button
  const renderAppBar = () => (
    <View style={[
      styles.appBar,
      { 
        backgroundColor: colors.card,
        shadowColor: isDark ? '#000' : '#888',
      }
    ]}>
      <View style={styles.appBarContent}>
        <TouchableOpacity 
          onPress={() => navigation.dispatch(DrawerActions.toggleDrawer())}
          style={[styles.menuButton, { backgroundColor: colors.primary + '15' }]}
        >
          <Ionicons name="menu" size={28} color={colors.primary} />
        </TouchableOpacity>
        
        <View style={styles.headerContent}>
          <Text style={[styles.headerGreeting, { color: colors.text }]}>
            {getGreeting()}
          </Text>
          <Text style={[styles.headerTitle, { color: colors.text }]}>
            {user?.name || 'Welcome Back'}
          </Text>
        </View>
        
        <TouchableOpacity 
          onPress={toggleTheme}
          style={[styles.themeButton, { backgroundColor: colors.primary + '15' }]}
        >
          <Ionicons 
            name={isDark ? 'sunny' : 'moon'} 
            size={24} 
            color={colors.primary} 
          />
        </TouchableOpacity>
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

  // Gradient colors based on theme
  const gradientColors = isDark 
    ? [
        colors.background,
        '#1a1a2e',
        '#16213e',
      ]
    : [
        '#f8f9fa',
        '#e9ecef',
        '#dee2e6',
      ];

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: colors.background }]}>
      <StatusBar 
        barStyle={isDark ? 'light-content' : 'dark-content'} 
        backgroundColor="transparent"
        translucent
      />
      <LinearGradient
        colors={gradientColors}
        style={StyleSheet.absoluteFillObject}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
      />
      {renderAppBar()}
      <ScrollView
        style={styles.container}
        contentContainerStyle={styles.scrollContent}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={loadWeatherData}
            colors={[colors.primary]}
            tintColor={colors.primary}
            progressViewOffset={80}
          />
        }
      >
        {/* Weather Card */}
        <LinearGradient
          colors={[
            isDark ? 'rgba(26, 26, 46, 0.9)' : 'rgba(255, 255, 255, 0.9)',
            isDark ? 'rgba(22, 33, 62, 0.9)' : 'rgba(245, 247, 250, 0.9)',
          ]}
          style={[
            styles.weatherCard, 
            { 
              backgroundColor: colors.card,
              borderColor: colors.border,
              shadowColor: isDark ? '#000' : '#888',
              shadowOffset: { width: 0, height: 2 },
              shadowOpacity: 0.1,
              shadowRadius: 8,
              elevation: 3,
            }
          ]}
        >
          <View style={styles.weatherHeader}>
            <View>
              <Text style={[styles.location, { color: colors.text }]}>{location}</Text>
              <Text style={[styles.date, { color: colors.textSecondary }]}>
                {new Date().toLocaleDateString('en-US', { 
                  weekday: 'long', 
                  year: 'numeric', 
                  month: 'long', 
                  day: 'numeric' 
                })}
              </Text>
            </View>
            <View style={[styles.weatherIconContainer, { backgroundColor: colors.primary + '15' }]}>
              <Ionicons 
                name={getWeatherIcon(currentWeather.weather?.[0]?.icon || '01d')} 
                size={40} 
                color={colors.primary} 
              />
            </View>
          </View>

          <View style={styles.currentWeather}>
            <Text style={[styles.temperature, { color: colors.text }]}>
              {formatTemperature(currentWeather.temp)}
            </Text>
            <Text style={[styles.weatherDescription, { color: colors.text }]}>
              {currentWeather.weather?.[0]?.description || 'Clear sky'}
            </Text>
            
            <View style={styles.weatherDetails}>
              <View style={styles.detailItem}>
                <Ionicons name="water" size={20} color={colors.primary} />
                <Text style={[styles.detailValue, { color: colors.text }]}>
                  {currentWeather.humidity}%
                </Text>
                <Text style={[styles.detailLabel, { color: colors.textSecondary }]}>
                  Humidity
                </Text>
              </View>
              
              <View style={styles.detailItem}>
                <Ionicons name="speedometer" size={20} color={colors.primary} />
                <Text style={[styles.detailValue, { color: colors.text }]}>
                  {formatWindSpeed(currentWeather.wind_speed)}
                </Text>
                <Text style={[styles.detailLabel, { color: colors.textSecondary }]}>
                  Wind
                </Text>
              </View>
              
              <View style={styles.detailItem}>
                <Ionicons name="thermometer" size={20} color={colors.primary} />
                <Text style={[styles.detailValue, { color: colors.text }]}>
                  {formatTemperature(currentWeather.feels_like)}
                </Text>
                <Text style={[styles.detailLabel, { color: colors.textSecondary }]}>
                  Feels Like
                </Text>
              </View>
            </View>
          </View>
        </LinearGradient>

        {/* Forecast Section */}
        <View style={[styles.forecastContainer, { backgroundColor: colors.card + '80', borderColor: colors.border }]}>
          <Text style={[styles.forecastTitle, { color: colors.text }]}>
            5-Day Forecast
          </Text>
          
          {forecast.map((day, index) => (
            <View 
              key={index} 
              style={[
                styles.forecastItem, 
                { 
                  borderBottomColor: colors.border + '50',
                  borderBottomWidth: index === forecast.length - 1 ? 0 : 1
                }
              ]}
            >
              <Text style={[styles.forecastDay, { color: colors.text }]}>
                {new Date(day.dt * 1000).toLocaleDateString('en-US', { weekday: 'short' })}
              </Text>
              <Ionicons 
                name={getWeatherIcon(day.weather?.[0]?.icon || '01d')} 
                size={24} 
                color={colors.primary} 
                style={styles.forecastIcon}
              />
              <View style={styles.forecastTempContainer}>
                <Text style={[styles.forecastTemp, { color: colors.text }]}>
                  {formatTemperature(day.temp?.max || day.temp)}
                </Text>
                <Text style={[styles.forecastTemp, { color: colors.textSecondary, marginLeft: 8 }]}>
                  {formatTemperature(day.temp?.min || day.temp)}
                </Text>
              </View>
            </View>
          ))}
        </View>

        {/* Error message */}
        {error ? (
          <View style={styles.errorContainer}>
            <Text style={[styles.errorText, { color: 'red' }]}>{error}</Text>
            <TouchableOpacity 
              style={[styles.retryButton, { backgroundColor: colors.primary }]}
              onPress={loadWeatherData}
            >
              <Text style={styles.retryButtonText}>Retry</Text>
            </TouchableOpacity>
          </View>
        ) : null}
      </ScrollView>
    </SafeAreaView>
  );
};

const stylesFn = (colors) => StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  scrollView: {
    flex: 1,
  },
  header: {
    padding: 20,
    paddingTop: 60,
    paddingBottom: 20,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  headerText: {
    fontSize: 24,
    fontWeight: 'bold',
  },
  menuButton: {
    padding: 8,
  },
  weatherContainer: {
    padding: 20,
    borderRadius: 20,
    margin: 20,
    overflow: 'hidden',
  },
  locationContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 10,
  },
  locationText: {
    fontSize: 18,
    marginLeft: 5,
  },
  currentTemp: {
    fontSize: 64,
    fontWeight: '200',
    marginVertical: 10,
  },
  weatherDescription: {
    fontSize: 18,
    textTransform: 'capitalize',
    marginBottom: 20,
  },
  weatherDetails: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 30,
  },
  detailItem: {
    alignItems: 'center',
  },
  detailValue: {
    fontSize: 18,
    fontWeight: '600',
    marginVertical: 5,
  },
  detailLabel: {
    fontSize: 12,
    opacity: 0.8,
  },
  forecastContainer: {
    margin: 20,
    borderRadius: 20,
    padding: 20,
    borderWidth: 1,
  },
  forecastTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 15,
  },
  forecastItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 15,
    borderBottomWidth: 1,
  },
  forecastDay: {
    fontSize: 16,
    width: 70,
  },
  forecastIcon: {
    width: 40,
    textAlign: 'center',
  },
  forecastTempContainer: {
    flexDirection: 'row',
    width: 100,
    justifyContent: 'flex-end',
  },
  forecastTemp: {
    fontSize: 16,
    fontWeight: '500',
  },
  errorContainer: {
    margin: 20,
    padding: 15,
    borderRadius: 10,
    backgroundColor: '#ffebee',
    alignItems: 'center',
  },
  errorText: {
    marginBottom: 10,
    textAlign: 'center',
  },
  retryButton: {
    paddingVertical: 8,
    paddingHorizontal: 20,
    borderRadius: 20,
  },
  retryButtonText: {
    color: '#fff',
    fontWeight: '600',
  },
});

export default HomeScreen;
