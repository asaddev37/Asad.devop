import React, { useState, useEffect, useContext } from 'react';
import { View, Text, StyleSheet, ScrollView, RefreshControl, Image, TouchableOpacity } from 'react-native';
import { useTheme } from '../../contexts/ThemeContext';
import { UserContext } from '../../contexts/UserContext';
import { getWeatherData } from '../../services/weatherService';
import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import * as Location from 'expo-location';

const HomeScreen = ({ navigation }) => {
  const { colors, styles } = useTheme();
  const { user } = useContext(UserContext);
  const [refreshing, setRefreshing] = useState(false);
  const [currentWeather, setCurrentWeather] = useState(null);
  const [forecast, setForecast] = useState([]);
  const [location, setLocation] = useState('Loading...');
  const [error, setError] = useState('');

  // Get user's current location and weather data
  const loadWeatherData = async () => {
    try {
      setRefreshing(true);
      setError('');
      
      // Check if location services are enabled
      const isLocationEnabled = await Location.hasServicesEnabledAsync();
      if (!isLocationEnabled) {
        setError('Location services are disabled. Please enable them in your device settings.');
        return;
      }

      // Request location permission
      let { status } = await Location.requestForegroundPermissionsAsync();
      if (status !== 'granted') {
        setError('Location permission is required to show weather for your current location.');
        // Set a default location
        setLocation('New York, US');
        // Try to load weather for default location
        await loadWeatherForDefaultLocation();
        return;
      }

      // Get current position with timeout
      let location;
      try {
        location = await Promise.race([
          Location.getCurrentPositionAsync({
            accuracy: Location.Accuracy.Low, // Lower accuracy for faster response
            timeout: 10000 // 10 second timeout
          }),
          new Promise((_, reject) => 
            setTimeout(() => reject(new Error('Location request timed out')), 10000)
          )
        ]);
      } catch (locationError) {
        console.warn('Error getting location:', locationError);
        setError('Could not get your current location. Using default location.');
        setLocation('New York, US');
        await loadWeatherForDefaultLocation();
        return;
      }

      const { latitude, longitude } = location.coords;
      
      // Get address from coordinates
      try {
        let address = await Location.reverseGeocodeAsync({ latitude, longitude });
        if (address && address[0]) {
          const { city, region, country } = address[0];
          setLocation(`${city || ''}${city && region ? ', ' : ''}${region || ''}${(city || region) && country ? ', ' : ''}${country || ''}`);
        }
      } catch (addressError) {
        console.warn('Error getting address:', addressError);
        setLocation('Your Location');
      }

      // Fetch weather data
      try {
        console.log('Fetching weather data...');
        const weatherData = await getWeatherData(latitude, longitude);
        console.log('Weather data received in HomeScreen:', JSON.stringify({
          current: weatherData.current ? 'exists' : 'missing',
          daily: weatherData.daily ? `array with ${weatherData.daily.length} items` : 'missing'
        }, null, 2));
        
        if (!weatherData || !weatherData.current) {
          throw new Error('Invalid weather data received');
        }
        
        setCurrentWeather(weatherData.current);
        
        // Safely handle daily forecast data
        const dailyForecast = Array.isArray(weatherData.daily) 
          ? weatherData.daily.slice(0, 5) 
          : [];
          
        console.log(`Setting forecast with ${dailyForecast.length} items`);
        setForecast(dailyForecast);
        
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

  // Load weather for default location (New York)
  const loadWeatherForDefaultLocation = async () => {
    try {
      const defaultLat = 40.7128; // New York
      const defaultLon = -74.0060;
      const weatherData = await getWeatherData(defaultLat, defaultLon);
      setCurrentWeather(weatherData.current);
      setForecast(weatherData.daily.slice(0, 5));
    } catch (error) {
      console.error('Error loading default weather data:', error);
      setError('Failed to load weather data for default location.');
    }
  };

  // Load weather data on component mount
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

  // Format time based on user preference
  const formatTime = (timestamp) => {
    const date = new Date(timestamp * 1000);
    if (user?.preferences?.timeFormat === '12h') {
      return date.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true });
    }
    return date.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: false });
  };

  // Get weather icon based on condition code
  const getWeatherIcon = (conditionCode) => {
    // This is a simplified version - you'll want to map all possible condition codes
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

  if (!currentWeather) {
    return (
      <View style={[localStyles.container, { backgroundColor: colors.background }]}>
        <Text style={[localStyles.loadingText, { color: colors.text }]}>
          {error || 'Loading weather data...'}
        </Text>
      </View>
    );
  }

  return (
    <ScrollView
      style={[styles.container, { backgroundColor: colors.background }]}
      refreshControl={
        <RefreshControl
          refreshing={refreshing}
          onRefresh={loadWeatherData}
          colors={[colors.primary]}
          tintColor={colors.primary}
        />
      }
    >
      {/* Header with greeting and location */}
      <View style={localStyles.header}>
        <Text style={[localStyles.greeting, { color: colors.text }]}>
          {`Hello, ${user?.name || 'Guest'}`}
        </Text>
        <View style={localStyles.locationContainer}>
          <Ionicons name="location" size={20} color={colors.primary} />
          <Text style={[localStyles.location, { color: colors.text }]}>{location}</Text>
        </View>
      </View>

      {/* Current weather card */}
      <LinearGradient
        colors={colors.gradient}
        style={localStyles.weatherCard}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
      >
        <Text style={localStyles.temperature}>
          {formatTemperature(currentWeather.temp)}
        </Text>
        <View style={localStyles.weatherInfo}>
          <Ionicons 
            name={getWeatherIcon(currentWeather.weather[0].icon)} 
            size={48} 
            color="white" 
          />
          <Text style={localStyles.weatherDescription}>
            {currentWeather.weather[0].description}
          </Text>
        </View>
        <Text style={localStyles.feelsLike}>
          Feels like: {formatTemperature(currentWeather.feels_like)}
        </Text>
      </LinearGradient>

      {/* Additional weather details */}
      <View style={[styles.card, localStyles.detailsCard]}>
        <View style={localStyles.detailRow}>
          <View style={localStyles.detailItem}>
            <Ionicons name="water" size={24} color={colors.primary} />
            <Text style={[localStyles.detailText, { color: colors.text }]}>
              {currentWeather.humidity}%
            </Text>
            <Text style={[localStyles.detailLabel, { color: colors.text }]}>Humidity</Text>
          </View>
          <View style={localStyles.detailItem}>
            <Ionicons name="speedometer" size={24} color={colors.primary} />
            <Text style={[localStyles.detailText, { color: colors.text }]}>
              {currentWeather.pressure} hPa
            </Text>
            <Text style={[localStyles.detailLabel, { color: colors.text }]}>Pressure</Text>
          </View>
          <View style={localStyles.detailItem}>
            <Ionicons name="eye" size={24} color={colors.primary} />
            <Text style={[localStyles.detailText, { color: colors.text }]}>
              {currentWeather.visibility / 1000} km
            </Text>
            <Text style={[localStyles.detailLabel, { color: colors.text }]}>Visibility</Text>
          </View>
        </View>
        <View style={localStyles.detailRow}>
          <View style={localStyles.detailItem}>
            <Ionicons name="speedometer-outline" size={24} color={colors.primary} />
            <Text style={[localStyles.detailText, { color: colors.text }]}>
              {formatWindSpeed(currentWeather.wind_speed)}
            </Text>
            <Text style={[localStyles.detailLabel, { color: colors.text }]}>Wind</Text>
          </View>
          <View style={localStyles.detailItem}>
            <Ionicons name="sunny" size={24} color={colors.primary} />
            <Text style={[localStyles.detailText, { color: colors.text }]}>
              {formatTime(currentWeather.sunrise)}
            </Text>
            <Text style={[localStyles.detailLabel, { color: colors.text }]}>Sunrise</Text>
          </View>
          <View style={localStyles.detailItem}>
            <Ionicons name="moon" size={24} color={colors.primary} />
            <Text style={[localStyles.detailText, { color: colors.text }]}>
              {formatTime(currentWeather.sunset)}
            </Text>
            <Text style={[localStyles.detailLabel, { color: colors.text }]}>Sunset</Text>
          </View>
        </View>
      </View>

      {/* 5-day forecast */}
      <Text style={[styles.subheading, { marginTop: 16, marginBottom: 8 }]}>
        5-Day Forecast
      </Text>
      <View style={[styles.card, localStyles.forecastContainer]}>
        {forecast.map((day, index) => (
          <View key={index} style={localStyles.forecastItem}>
            <Text style={[localStyles.forecastDay, { color: colors.text }]}>
              {new Date(day.dt * 1000).toLocaleDateString('en-US', { weekday: 'short' })}
            </Text>
            <Ionicons 
              name={getWeatherIcon(day.weather[0].icon)} 
              size={24} 
              color={colors.primary} 
            />
            <View style={localStyles.forecastTemps}>
              <Text style={[localStyles.forecastTempHigh, { color: colors.text }]}>
                {formatTemperature(day.temp.max)}
              </Text>
              <Text style={[localStyles.forecastTempLow, { color: colors.text }]}>
                {formatTemperature(day.temp.min)}
              </Text>
            </View>
          </View>
        ))}
      </View>
    </ScrollView>
  );
};

const localStyles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
  },
  loadingText: {
    textAlign: 'center',
    marginTop: 20,
    fontSize: 16,
  },
  header: {
    marginBottom: 24,
  },
  greeting: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  locationContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  location: {
    fontSize: 16,
    marginLeft: 4,
  },
  weatherCard: {
    borderRadius: 16,
    padding: 24,
    marginBottom: 20,
    alignItems: 'center',
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4,
  },
  temperature: {
    fontSize: 72,
    fontWeight: '200',
    color: 'white',
  },
  weatherInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    marginVertical: 8,
  },
  weatherDescription: {
    fontSize: 20,
    color: 'white',
    marginLeft: 8,
    textTransform: 'capitalize',
  },
  feelsLike: {
    fontSize: 16,
    color: 'rgba(255, 255, 255, 0.8)',
    marginTop: 4,
  },
  detailsCard: {
    marginBottom: 20,
  },
  detailRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  detailItem: {
    alignItems: 'center',
    flex: 1,
  },
  detailText: {
    fontSize: 18,
    fontWeight: '600',
    marginVertical: 4,
  },
  detailLabel: {
    fontSize: 12,
    opacity: 0.7,
  },
  forecastContainer: {
    marginBottom: 20,
  },
  forecastItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(0, 0, 0, 0.1)',
  },
  forecastDay: {
    flex: 1,
    fontSize: 16,
  },
  forecastTemps: {
    flexDirection: 'row',
    alignItems: 'center',
    width: 100,
    justifyContent: 'flex-end',
  },
  forecastTempHigh: {
    fontSize: 16,
    fontWeight: '600',
    marginRight: 16,
  },
  forecastTempLow: {
    fontSize: 16,
    opacity: 0.7,
    width: 40,
    textAlign: 'right',
  },
});

export default HomeScreen;
