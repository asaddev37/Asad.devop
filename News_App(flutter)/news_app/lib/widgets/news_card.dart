import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../models/news_model.dart';
import '../screens/news_view_screen.dart';
import '../services/news_service.dart';
import '../utils/animations.dart';

class NewsCard extends StatelessWidget {
  final NewsModel news;
  final VoidCallback? onFavoriteChanged;

  const NewsCard({super.key, required this.news, this.onFavoriteChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          SlideRoute(page: NewsViewScreen(url: news.newsUrl)),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 5,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: news.newsImgUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: AppColors.electricBlue),
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    'images/placeholder.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: AppColors.secondaryGradient,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          news.newsHeading,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Consumer<NewsService>(
                        builder: (context, newsService, child) {
                          final isFavorite = newsService.newsList
                              .firstWhere(
                                (item) => item.newsUrl == news.newsUrl,
                            orElse: () => news,
                          )
                              .isFavorite ||
                              newsService.carouselNewsList
                                  .firstWhere(
                                    (item) => item.newsUrl == news.newsUrl,
                                orElse: () => news,
                              )
                                  .isFavorite;
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: isFavorite
                                      ? AppColors.neonPink.withOpacity(0.5)
                                      : Colors.transparent,
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? AppColors.neonPink : Colors.white,
                              ),
                              onPressed: () {
                                print('Heart tapped: ${news.newsUrl}');
                                newsService.toggleFavorite(news);
                                if (onFavoriteChanged != null) {
                                  onFavoriteChanged!();
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}