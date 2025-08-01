import axios from 'axios';

// OpenWeatherMap API configuration
const API_KEY = 'abadeda8375c606d10bb61456aebb85c';
const BASE_URL = 'https://api.openweathermap.org/data/2.5';
const GEOCODING_URL = 'https://api.openweathermap.org/geo/1.0';
const USE_MOCK_DATA = false; // Set to false to use the real API

// Mock data for development
const MOCK_WEATHER_DATA = {
  current: {
    temp: 25,
    feels_like: 27,
    humidity: 65,
    pressure: 1012,
    weather: [{ main: 'Clear', description: 'clear sky', icon: '01d' }],
    wind_speed: 3.6,
    visibility: 10000,
    sunrise: Math.floor(Date.now() / 1000) - 3600 * 4,
    sunset: Math.floor(Date.now() / 1000) + 3600 * 4,
    name: 'Sample City'
  },
  daily: Array(7).fill().map((_, i) => ({
    dt: Math.floor(Date.now() / 1000) + (i * 86400),
    temp: { day: 25 + i, night: 20 + i },
    weather: [{ main: 'Clear', description: 'clear sky', icon: '01d' }]
  }))
};

console.log('Weather Service: Using', USE_MOCK_DATA ? 'MOCK DATA' : 'REAL API');

// Get current weather and forecast data by city name
const getWeatherData = async (cityName) => {
  // Return mock data if enabled
  if (USE_MOCK_DATA) {
    console.log('Using mock weather data');
    return MOCK_WEATHER_DATA;
  }
  
  try {
    // First, get coordinates for the city
    const geoResponse = await axios.get(
      `${GEOCODING_URL}/direct?q=${encodeURIComponent(cityName)}&limit=1&appid=${API_KEY}`
    );
    
    if (!geoResponse.data || geoResponse.data.length === 0) {
      throw new Error('City not found');
    }
    
    const { lat, lon } = geoResponse.data[0];
    
    // Get current weather by coordinates (more reliable)
    const currentResponse = await axios.get(
      `${BASE_URL}/weather?lat=${lat}&lon=${lon}&appid=${API_KEY}&units=metric`
    );

    // Get 5-day/3-hour forecast by coordinates
    const forecastResponse = await axios.get(
      `${BASE_URL}/forecast?lat=${lat}&lon=${lon}&appid=${API_KEY}&units=metric`
    );

    // Process forecast data to get daily forecast
    const dailyForecast = processForecastData(forecastResponse.data.list);

    return {
      current: {
        ...currentResponse.data.main,
        weather: currentResponse.data.weather,
        wind_speed: currentResponse.data.wind.speed,
        visibility: currentResponse.data.visibility,
        name: currentResponse.data.name,
        dt: currentResponse.data.dt,
        sys: currentResponse.data.sys,
      },
      daily: dailyForecast,
      city: currentResponse.data.name,
      country: currentResponse.data.sys?.country || ''
    };
  } catch (error) {
    console.error('Error fetching weather data:', error);
    throw error;
  }
};

// Process 3-hour forecast data to get daily forecast
const processForecastData = (forecastList) => {
  const dailyData = [];
  const days = {};
  
  // Group forecast by date
  forecastList.forEach(item => {
    const date = new Date(item.dt * 1000).toDateString();
    if (!days[date]) {
      days[date] = {
        temp: { day: item.main.temp, night: item.main.temp },
        weather: item.weather,
        dt: item.dt,
        humidity: item.main.humidity,
        wind_speed: item.wind.speed,
        temp_min: item.main.temp_min,
        temp_max: item.main.temp_max,
        count: 1
      };
    } else {
      // Update min/max temperatures and average other values
      const day = days[date];
      day.temp.day = (day.temp.day * day.count + item.main.temp) / (day.count + 1);
      day.temp.night = (day.temp.night * day.count + item.main.temp) / (day.count + 1);
      day.temp_min = Math.min(day.temp_min, item.main.temp_min);
      day.temp_max = Math.max(day.temp_max, item.main.temp_max);
      day.humidity = (day.humidity * day.count + item.main.humidity) / (day.count + 1);
      day.wind_speed = (day.wind_speed * day.count + item.wind.speed) / (day.count + 1);
      day.count += 1;
      
      // Update weather condition to the most frequent one (simplified)
      if (day.count % 3 === 0) {
        day.weather = item.weather;
      }
    }
  });
  
  // Convert to array and limit to 5 days
  Object.values(days).slice(0, 5).forEach(day => {
    dailyData.push({
      ...day,
      temp: {
        day: day.temp.day,
        night: day.temp.night,
        min: day.temp_min,
        max: day.temp_max
      }
    });
  });
  
  return dailyData;
};

// Search for cities by name
const searchCities = async (query) => {
  try {
    if (!query || query.trim().length < 2) {
      return [];
    }
    
    const response = await axios.get(
      `${GEOCODING_URL}/direct?q=${encodeURIComponent(query)}&limit=5&appid=${API_KEY}`
    );
    
    if (!response.data || response.data.length === 0) {
      return [];
    }
    
    return response.data.map(city => ({
      name: city.name,
      country: city.country,
      lat: city.lat,
      lon: city.lon,
      state: city.state || ''
    }));
  } catch (error) {
    console.error('Error searching cities:', error);
    throw error;
  }
};

// Get weather by city name (alias for getWeatherData for backward compatibility)
const getWeatherByCity = getWeatherData;

export { getWeatherData, searchCities, getWeatherByCity };
