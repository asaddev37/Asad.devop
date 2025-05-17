import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../constants/colors.dart';
import '../models/news_model.dart';
import '../services/news_service.dart';
import '../widgets/news_card.dart';
import '../widgets/custom_loading.dart';

class NewsScreen extends StatefulWidget {
  final String category;

  const NewsScreen({super.key, required this.category});

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    Provider.of<NewsService>(context, listen: false).fetchNews(widget.category);
  }

  void _onRefresh() async {
    await Provider.of<NewsService>(context, listen: false).fetchNews(widget.category);
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final newsService = Provider.of<NewsService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.toUpperCase()),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.secondaryGradient),
        child: SmartRefresher(
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: newsService.isLoading
              ? const CustomLoading()
              : newsService.errorMessage != null
              ? _buildErrorWidget(newsService.errorMessage!)
              : _buildNewsList(newsService.newsList),
        ),
      ),
    );
  }

  Widget _buildNewsList(List<NewsModel> newsList) {
    final filteredNews = newsList.where((news) => news.newsImgUrl.isNotEmpty).toList();

    return ListView.builder(
      itemCount: filteredNews.length,
      itemBuilder: (context, index) {
        return NewsCard(news: filteredNews[index]);
      },
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