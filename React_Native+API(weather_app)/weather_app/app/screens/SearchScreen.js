import React, { useState, useEffect, useContext } from 'react';
import { View, Text, TextInput, StyleSheet, FlatList, TouchableOpacity, ActivityIndicator } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../../contexts/ThemeContext';
import { UserContext } from '../../contexts/UserContext';
import { searchCities, getWeatherByCity } from '../../services/weatherService';

const SearchScreen = ({ navigation }) => {
  const { colors, styles } = useTheme();
  const { user, addLocation, removeLocation } = useContext(UserContext);
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState([]);
  const [isSearching, setIsSearching] = useState(false);
  const [recentSearches, setRecentSearches] = useState([]);
  const [isLoading, setIsLoading] = useState(false);

  // Load recent searches from storage
  useEffect(() => {
    // In a real app, you would load this from AsyncStorage
    setRecentSearches(user?.locations || []);
  }, [user?.locations]);

  // Search for cities when the query changes (with debounce)
  useEffect(() => {
    const searchTimeout = setTimeout(async () => {
      if (searchQuery.trim().length > 2) {
        await handleSearch(searchQuery);
      } else {
        setSearchResults([]);
      }
    }, 500);

    return () => clearTimeout(searchTimeout);
  }, [searchQuery]);

  // Handle city search
  const handleSearch = async (query) => {
    if (!query.trim()) {
      setSearchResults([]);
      return;
    }

    try {
      setIsSearching(true);
      const results = await searchCities(query);
      setSearchResults(results);
    } catch (error) {
      console.error('Error searching cities:', error);
      setSearchResults([]);
    } finally {
      setIsSearching(false);
    }
  };

  // Handle city selection
  const handleCitySelect = async (city) => {
    try {
      setIsLoading(true);
      // Add to recent searches
      await addLocation({
        id: `${city.lat},${city.lon}`,
        name: city.name,
        country: city.country,
        state: city.state,
        lat: city.lat,
        lon: city.lon,
      });
      
      // Navigate to home with the selected city
      navigation.navigate('Home', { 
        city: { 
          name: city.name,
          lat: city.lat,
          lon: city.lon 
        } 
      });
    } catch (error) {
      console.error('Error selecting city:', error);
    } finally {
      setIsLoading(false);
    }
  };

  // Check if a city is in saved locations
  const isCitySaved = (city) => {
    return user?.locations?.some(loc => 
      loc.lat === city.lat && loc.lon === city.lon
    );
  };

  // Toggle save/remove city
  const toggleSaveCity = async (city) => {
    const cityData = {
      id: `${city.lat},${city.lon}`,
      name: city.name,
      country: city.country,
      state: city.state,
      lat: city.lat,
      lon: city.lon,
    };

    if (isCitySaved(city)) {
      await removeLocation(cityData.id);
    } else {
      await addLocation(cityData);
    }
  };

  // Render search result item
  const renderSearchResult = ({ item }) => {
    const isSaved = isCitySaved(item);
    
    return (
      <TouchableOpacity 
        style={[localStyles.resultItem, { borderBottomColor: colors.border }]}
        onPress={() => handleCitySelect(item)}
      >
        <View style={localStyles.resultContent}>
          <Ionicons 
            name="location" 
            size={20} 
            color={colors.primary} 
            style={localStyles.resultIcon}
          />
          <View>
            <Text style={[localStyles.resultName, { color: colors.text }]}>
              {item.name}{item.state ? `, ${item.state}` : ''}
            </Text>
            <Text style={[localStyles.resultCountry, { color: colors.text }]}>
              {item.country}
            </Text>
          </View>
        </View>
        <TouchableOpacity 
          onPress={() => toggleSaveCity(item)}
          style={localStyles.saveButton}
        >
          <Ionicons 
            name={isSaved ? 'bookmark' : 'bookmark-outline'} 
            size={24} 
            color={isSaved ? colors.primary : colors.text} 
          />
        </TouchableOpacity>
      </TouchableOpacity>
    );
  };

  // Render recent search item
  const renderRecentSearch = ({ item }) => (
    <TouchableOpacity 
      style={[localStyles.recentItem, { backgroundColor: colors.card }]}
      onPress={() => handleCitySelect(item)}
    >
      <Ionicons 
        name="time" 
        size={20} 
        color={colors.primary} 
        style={localStyles.recentIcon}
      />
      <Text style={[localStyles.recentText, { color: colors.text }]}>
        {item.name}{item.state ? `, ${item.state}` : ''}, {item.country}
      </Text>
    </TouchableOpacity>
  );

  return (
    <View style={[styles.container, { backgroundColor: colors.background }]}>
      {/* Search Bar */}
      <View style={[localStyles.searchContainer, { backgroundColor: colors.card }]}>
        <Ionicons 
          name="search" 
          size={24} 
          color={colors.text} 
          style={localStyles.searchIcon}
        />
        <TextInput
          style={[localStyles.searchInput, { color: colors.text }]}
          placeholder="Search for a city..."
          placeholderTextColor={colors.text + '80'}
          value={searchQuery}
          onChangeText={setSearchQuery}
          autoCapitalize="words"
          autoCorrect={false}
        />
        {isSearching && (
          <ActivityIndicator 
            size="small" 
            color={colors.primary} 
            style={localStyles.loadingIndicator}
          />
        )}
      </View>

      {isLoading ? (
        <View style={localStyles.loadingContainer}>
          <ActivityIndicator size="large" color={colors.primary} />
        </View>
      ) : searchQuery ? (
        // Search Results
        <FlatList
          data={searchResults}
          renderItem={renderSearchResult}
          keyExtractor={(item, index) => `${item.lat},${item.lon},${index}`}
          keyboardShouldPersistTaps="handled"
          ListEmptyComponent={
            searchQuery.trim().length > 0 && !isSearching ? (
              <Text style={[localStyles.noResults, { color: colors.text }]}>
                No results found for "{searchQuery}"
              </Text>
            ) : null
          }
          contentContainerStyle={localStyles.resultsList}
        />
      ) : (
        // Recent Searches
        <View style={localStyles.recentSearches}>
          <Text style={[localStyles.sectionTitle, { color: colors.text }]}>
            Recent Searches
          </Text>
          {recentSearches.length > 0 ? (
            <FlatList
              data={recentSearches}
              renderItem={renderRecentSearch}
              keyExtractor={(item, index) => `${item.id || index}`}
              contentContainerStyle={localStyles.recentList}
            />
          ) : (
            <View style={localStyles.emptyState}>
              <Ionicons 
                name="time-outline" 
                size={48} 
                color={colors.text + '80'} 
                style={localStyles.emptyIcon}
              />
              <Text style={[localStyles.emptyText, { color: colors.text + '80' }]}>
                Your recent searches will appear here
              </Text>
            </View>
          )}
        </View>
      )}
    </View>
  );
};

const localStyles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
  },
  searchContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    borderRadius: 12,
    paddingHorizontal: 16,
    marginBottom: 16,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  searchIcon: {
    marginRight: 12,
  },
  searchInput: {
    flex: 1,
    height: 56,
    fontSize: 16,
  },
  loadingIndicator: {
    marginLeft: 8,
  },
  resultsList: {
    paddingBottom: 16,
  },
  resultItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 16,
    borderBottomWidth: 1,
  },
  resultContent: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  resultIcon: {
    marginRight: 12,
  },
  resultName: {
    fontSize: 16,
    fontWeight: '500',
    marginBottom: 2,
  },
  resultCountry: {
    fontSize: 14,
    opacity: 0.7,
  },
  saveButton: {
    padding: 8,
    marginLeft: 8,
  },
  recentSearches: {
    flex: 1,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 12,
  },
  recentList: {
    paddingBottom: 16,
  },
  recentItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    borderRadius: 12,
    marginBottom: 8,
    elevation: 1,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
  },
  recentIcon: {
    marginRight: 12,
  },
  recentText: {
    fontSize: 16,
  },
  emptyState: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 40,
  },
  emptyIcon: {
    marginBottom: 16,
  },
  emptyText: {
    fontSize: 16,
    textAlign: 'center',
  },
  noResults: {
    textAlign: 'center',
    marginTop: 40,
    fontSize: 16,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
});

export default SearchScreen;
