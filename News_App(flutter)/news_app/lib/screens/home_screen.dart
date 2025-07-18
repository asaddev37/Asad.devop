import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../constants/colors.dart';
import '../models/news_model.dart';
import '../services/news_service.dart';
import '../services/database_helper.dart';
import '../widgets/news_card.dart';
import '../widgets/category_button.dart';
import '../widgets/custom_loading.dart';
import '../screens/news_screen.dart';
import '../screens/settings_screen.dart';
import '../utils/animations.dart';
import 'favourite_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final List<String> categories = ['Top News', 'Anime', 'Sports', 'Finance', 'Entertainment'];

  @override
  void initState() {
    super.initState();
    // Defer API calls to avoid main thread overload
    Future.delayed(Duration.zero, () async {
      final newsService = Provider.of<NewsService>(context, listen: false);
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      print('HomeScreen init: Fetching anime news');
      await newsService.fetchNews('anime');
      print('HomeScreen init: Fetching carousel news for ${settingsProvider.carouselTopic}');
      await Future.delayed(const Duration(milliseconds: 500));
      await newsService.fetchNews(settingsProvider.carouselTopic, isCarousel: true);
    });
  }

  void _onRefresh() async {
    final newsService = Provider.of<NewsService>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    print('Refreshing: Fetching anime news');
    await newsService.fetchNews('anime');
    print('Refreshing: Fetching carousel news for ${settingsProvider.carouselTopic}');
    await Future.delayed(const Duration(milliseconds: 500));
    await newsService.fetchNews(settingsProvider.carouselTopic, isCarousel: true);
    _refreshController.refreshCompleted();
  }

  void _handleSearch() {
    String query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        SlideRoute(page: NewsScreen(category: query)),
      );
      _searchController.clear();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome, ${settingsProvider.nickname}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Theme(
            data: Theme.of(context).copyWith(
              popupMenuTheme: PopupMenuThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.menu, color: AppColors.neonPink),
              onSelected: (value) {
                if (value == 'settings') {
                  Navigator.pushNamed(context, '/settings');
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  height: 40, // Explicit height
                  value: 'settings',
                  child: SizedBox(
                    width: 150, // Explicit width
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: AppColors.neonPink),
                        const SizedBox(width: 8),
                        const Text('Settings', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.secondaryGradient),
        child: SmartRefresher(
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 20),
                _buildCategoryBar(),
                const SizedBox(height: 20),
                Consumer<NewsService>(
                  builder: (context, newsService, child) {
                    print('NewsService state: isLoading=${newsService.isLoading}, newsList=${newsService.newsList.length}, carouselList=${newsService.carouselNewsList.length}');
                    if (newsService.isLoading) {
                      return const CustomLoading();
                    }
                    if (newsService.errorMessage != null) {
                      return _buildErrorWidget(newsService.errorMessage!);
                    }
                    return _buildNewsContent(newsService.carouselNewsList, newsService.newsList);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FavoritesScreen()),
          );
        },
        backgroundColor: AppColors.neonPink,
        tooltip: 'Favorite News',  // Add this line
        child: const Icon(Icons.favorite, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonPink.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search news or country...',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _handleSearch(),
            ),
          ),
          GestureDetector(
            onTap: _handleSearch,
            child: const Text(
              'Search',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return CategoryButton(category: categories[index]);
        },
      ),
    );
  }

  Widget _buildNewsContent(List<NewsModel> carouselNews, List<NewsModel> newsList) {
    final filteredCarouselNews = carouselNews.where((news) => news.newsImgUrl.isNotEmpty).toList();
    final filteredNews = newsList.where((news) => news.newsImgUrl.isNotEmpty).toList();

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: CarouselSlider(
            options: CarouselOptions(
              height: 250,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.8,
              enlargeFactor: 0.3,
            ),
            items: filteredCarouselNews.take(5).map((news) {
              return ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250, maxWidth: 400),
                child: NewsCard(news: news),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Latest News',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: filteredNews.length,
          itemBuilder: (context, index) {
            return NewsCard(news: filteredNews[index]);
          },
        ),
      ],
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/error.json',
            width: 150,
            height: 150,
            repeat: true,  // Ensures animation loops
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Please check your internet connection\nor try again later',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _onRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonPink,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}