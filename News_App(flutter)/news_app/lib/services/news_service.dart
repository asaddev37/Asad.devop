import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/news_model.dart';
import '../services/database_helper.dart';

class NewsService with ChangeNotifier {
  List<NewsModel> _newsList = [];
  List<NewsModel> _carouselNewsList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<NewsModel> get newsList => _newsList;
  List<NewsModel> get carouselNewsList => _carouselNewsList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  late Box<NewsModel> _newsBox;

  NewsService() {
    _initBox();
  }

  Future<void> _initBox() async {
    _newsBox = await Hive.openBox<NewsModel>('newsBox');
    // Load cached news on init
    if (_newsBox.isNotEmpty) {
      _newsList = _newsBox.values.toList();
      notifyListeners();
    }
  }

  Future<void> fetchNews(String query, {bool isCarousel = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final String apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      _errorMessage = 'API key is missing. Please check your .env file.';
      _isLoading = false;
      _loadCachedNews(isCarousel);
      notifyListeners();
      return;
    }

    final String yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .split('T')[0];
    final String url =
        'https://newsapi.org/v2/everything?q=$query&from=$yesterday&to=$yesterday&sortBy=popularity&apiKey=$apiKey';

    print('Fetching news: query=$query, isCarousel=$isCarousel');
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timed out. Please try again.');
        },
      );

      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          final news = (data['articles'] as List)
              .map((article) => NewsModel.fromMap(article))
              .toList();
          // Load existing favorites from SQFLite
          final favorites = await DatabaseHelper().getFavorites();
          final favoriteUrls = favorites.map((f) => f.newsUrl).toSet();
          print('Favorites found: ${favoriteUrls.length}');
          // Mark fetched news as favorite if in favorites
          for (var item in news) {
            if (favoriteUrls.contains(item.newsUrl)) {
              item.isFavorite = true;
            }
          }
          if (isCarousel) {
            _carouselNewsList = news;
          } else {
            _newsList = news;
            // Cache news in Hive
            await _newsBox.clear();
            await _newsBox.addAll(_newsList);
          }
        } catch (e) {
          _errorMessage = 'Error parsing news data: $e';
          _loadCachedNews(isCarousel);
        }
      } else {
        switch (response.statusCode) {
          case 401:
            _errorMessage = 'Invalid API key. Please check your News API key.';
            break;
          case 429:
            _errorMessage = 'API rate limit exceeded. Please try again later.';
            break;
          default:
            _errorMessage = 'Failed to load news (Error ${response.statusCode}).';
        }
        _loadCachedNews(isCarousel);
      }
    } catch (e) {
      _errorMessage = e.toString().contains('timed out')
          ? 'Request timed out. Please check your connection.'
          : 'Unable to connect to the news server: $e';
      _loadCachedNews(isCarousel);
    }

    _isLoading = false;
    notifyListeners();
  }

  void _loadCachedNews(bool isCarousel) {
    if (!isCarousel && _newsBox.isNotEmpty) {
      _newsList = _newsBox.values.toList();
    }
    if (isCarousel && _newsBox.isNotEmpty) {
      _carouselNewsList = _newsBox.values.toList();
    }
  }

  Future<void> toggleFavorite(NewsModel news) async {
    try {
      final dbHelper = DatabaseHelper();
      final isCurrentlyFavorite = news.isFavorite;
      final updatedNews = NewsModel(
        newsHeading: news.newsHeading,
        newsDescription: news.newsDescription,
        newsImgUrl: news.newsImgUrl,
        newsUrl: news.newsUrl,
        isFavorite: !isCurrentlyFavorite,
      );

      print('Toggling favorite: ${news.newsUrl}, isFavorite: ${updatedNews.isFavorite}');
      if (isCurrentlyFavorite) {
        await dbHelper.removeFavorite(news.newsUrl);
      } else {
        await dbHelper.addFavorite(updatedNews);
      }

      // Update in-memory lists
      _newsList = _newsList.map((item) {
        return item.newsUrl == news.newsUrl ? updatedNews : item;
      }).toList();
      _carouselNewsList = _carouselNewsList.map((item) {
        return item.newsUrl == news.newsUrl ? updatedNews : item;
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error toggling favorite: $e');
      _errorMessage = 'Failed to update favorite: $e';
      notifyListeners();
    }
  }

  Future<List<NewsModel>> getFavorites() async {
    try {
      final favorites = await DatabaseHelper().getFavorites();
      print('Returning favorites: ${favorites.length} items');
      return favorites;
    } catch (e) {
      print('Error fetching favorites: $e');
      return [];
    }
  }
}