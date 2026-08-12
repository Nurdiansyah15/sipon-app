import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/article.dart';
import '../repositories/article_repository.dart';

class GetRecentArticlesUseCase
    implements UseCase<Either<Failure, List<Article>>, NoParams> {
  final ArticleRepository repository;

  GetRecentArticlesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Article>>> call(NoParams params) {
    return repository.getRecentArticles();
  }
}
