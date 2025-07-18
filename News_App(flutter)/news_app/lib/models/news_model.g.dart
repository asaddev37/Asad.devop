// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_model.dart';

class NewsModelAdapter extends TypeAdapter<NewsModel> {
  @override
  final int typeId = 0;

  @override
  NewsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int,dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NewsModel(
      newsHeading: fields[0] as String,
      newsDescription: fields[1] as String,
      newsImgUrl: fields[2] as String,
      newsUrl: fields[3] as String,
      isFavorite: fields[4] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, NewsModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.newsHeading)
      ..writeByte(1)
      ..write(obj.newsDescription)
      ..writeByte(2)
      ..write(obj.newsImgUrl)
      ..writeByte(3)
      ..write(obj.newsUrl)
      ..writeByte(4)
      ..write(obj.isFavorite);
  }
}