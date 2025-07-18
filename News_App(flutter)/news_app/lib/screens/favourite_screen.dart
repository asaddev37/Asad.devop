import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../models/news_model.dart';
import '../services/news_service.dart';
import '../widgets/news_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<NewsModel>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = Provider.of<NewsService>(context, listen: false).getFavorites();
    print('FavoritesScreen init: Loading favorites');
  }

  void _refreshFavorites() {
    setState(() {
      _favoritesFuture = Provider.of<NewsService>(context, listen: false).getFavorites();
    });
    print('FavoritesScreen: Refreshing favorites');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.secondaryGradient),
        child: FutureBuilder<List<NewsModel>>(
          future: _favoritesFuture,
          builder: (context, snapshot) {
            print('FavoritesScreen FutureBuilder: connectionState=${snapshot.connectionState}');
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.neonPink),
              );
            }
            if (snapshot.hasError) {
              print('Favorites error: ${snapshot.error}');
              return Center(
                child: Text(
                  'Error loading favorites: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              );
            }
            final favorites = snapshot.data ?? [];
            print('Favorites loaded: ${favorites.length} items');
            if (favorites.isEmpty) {
              return const Center(
                child: Text(
                  'No favorites yet!',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }
            return ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                return NewsCard(
                  news: favorites[index],
                  onFavoriteChanged: _refreshFavorites,
                );
              },
            );
          },
        ),
      ),
    );
  }
}