import 'package:hive/hive.dart';

part 'news_model.g.dart';

@HiveType(typeId: 0)
class NewsModel {
  @HiveField(0)
  final String newsHeading;

  @HiveField(1)
  final String newsDescription;

  @HiveField(2)
  final String newsImgUrl;

  @HiveField(3)
  final String newsUrl;

  @HiveField(4)
  bool isFavorite;

  NewsModel({
    required this.newsHeading,
    required this.newsDescription,
    required this.newsImgUrl,
    required this.newsUrl,
    this.isFavorite = false,
  });

  factory NewsModel.fromMap(Map<String, dynamic> map) {
    return NewsModel(
      newsHeading: map['title'] ?? 'No Title',
      newsDescription: map['description'] ?? 'No Description',
      newsImgUrl: map['urlToImage'] ?? 'https://via.placeholder.com/150',
      newsUrl: map['url'] ?? 'https://www.example.com',
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': newsHeading,
      'description': newsDescription,
      'urlToImage': newsImgUrl,
      'url': newsUrl,
      'isFavorite': isFavorite,
    };
  }

  // SQFLite serialization
  Map<String, dynamic> toSqlMap() {
    return {
      'newsUrl': newsUrl,
      'newsHeading': newsHeading,
      'newsDescription': newsDescription,
      'newsImgUrl': newsImgUrl,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory NewsModel.fromSqlMap(Map<String, dynamic> map) {
    return NewsModel(
      newsUrl: map['newsUrl'] as String,
      newsHeading: map['newsHeading'] as String,
      newsDescription: map['newsDescription'] as String,
      newsImgUrl: map['newsImgUrl'] as String,
      isFavorite: (map['isFavorite'] as int) == 1,
    );
  }
}