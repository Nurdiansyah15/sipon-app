import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/article.dart';

abstract class ArticleRepository {
  Future<Either<Failure, List<Article>>> getRecentArticles({int limit = 6});
}
