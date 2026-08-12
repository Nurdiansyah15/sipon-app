import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/article_repository.dart';
import '../datasources/article_remote_data_source.dart';
import '../models/article_model.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleRemoteDataSource _remoteDataSource;

  ArticleRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Article>>> getRecentArticles({int limit = 6}) async {
    try {
      final raw = await _remoteDataSource.getRecentArticles(limit: limit);
      final data = raw['data'];
      final items = data is List ? data : (data is Map ? data['items'] : null);
      final list = (items as List? ?? const [])
          .map((e) => ArticleModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return Right(list);
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      return Left(NetworkFailure.fromDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
