class Article {
  final String id;
  final String title;
  final String? categoryName;
  final String? author;
  final String? thumbnailUrl;
  final DateTime? publishedAt;

  Article({
    required this.id,
    required this.title,
    this.categoryName,
    this.author,
    this.thumbnailUrl,
    this.publishedAt,
  });
}
