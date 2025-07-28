import axios from 'axios';

// OpenWeatherMap API configuration
const API_KEY = '93d094cb16d6f597f6194d391d476e12'; // This key appears to be invalid
const BASE_URL = 'https://api.openweathermap.org/data/2.5';
const USE_MOCK_DATA = true; // Set to false to try the real API

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

// Get current weather and forecast data
const getWeatherData = async (lat, lon) => {
  // Return mock data if enabled
  if (USE_MOCK_DATA) {
    console.log('Using mock weather data');
    return MOCK_WEATHER_DATA;
  }

  try {
    console.log(`Fetching weather data for lat: ${lat}, lon: ${lon}`);
    
    // Get current weather
    const currentWeatherUrl = `${BASE_URL}/weather?lat=${lat}&lon=${lon}&appid=${API_KEY}&units=metric`;
    console.log('Current Weather URL:', currentWeatherUrl);
    
    const currentWeatherResponse = await axios.get(currentWeatherUrl);
    
    // Get forecast
    const forecastUrl = `${BASE_URL}/onecall?lat=${lat}&lon=${lon}&exclude=minutely,hourly,alerts&appid=${API_KEY}&units=metric`;
    console.log('Forecast URL:', forecastUrl);
    
    const forecastResponse = await axios.get(forecastUrl);

    // Combine the data
    const weatherData = {
      current: {
        ...currentWeatherResponse.data.main,
        weather: currentWeatherResponse.data.weather,
        wind_speed: currentWeatherResponse.data.wind.speed,
        visibility: currentWeatherResponse.data.visibility,
        sunrise: currentWeatherResponse.data.sys.sunrise,
        sunset: currentWeatherResponse.data.sys.sunset,
        name: currentWeatherResponse.data.name,
      },
      daily: forecastResponse.data.daily || []
    };
    
    console.log('Weather data received:', JSON.stringify(weatherData, null, 2));
    return weatherData;
  } catch (error) {
    console.error('Error fetching weather data, falling back to mock data:', error);
    // Return mock data if API fails
    return MOCK_WEATHER_DATA;
  }
};

// Search for cities by name
const searchCities = async (query) => {
  try {
    const response = await axios.get(
      `https://api.openweathermap.org/geo/1.0/direct?q=${query}&limit=5&appid=${API_KEY}`
    );
    return response.data;
  } catch (error) {
    console.error('Error searching cities:', error);
    throw error;
  }
};

// Get weather by city name
const getWeatherByCity = async (cityName) => {
  try {
    const response = await axios.get(
      `${BASE_URL}/weather?q=${cityName}&appid=${API_KEY}&units=metric`
    );
    return response.data;
  } catch (error) {
    console.error('Error getting weather by city:', error);
    throw error;
  }
};

export { getWeatherData, searchCities, getWeatherByCity };
