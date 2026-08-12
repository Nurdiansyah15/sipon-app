import '../../domain/entities/article.dart';

class ArticleModel extends Article {
  ArticleModel({
    required super.id,
    required super.title,
    super.categoryName,
    super.author,
    super.thumbnailUrl,
    super.publishedAt,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      categoryName: json['category_name'] as String?,
      author: json['author'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      publishedAt: DateTime.tryParse(json['published_at']?.toString() ?? ''),
    );
  }
}
