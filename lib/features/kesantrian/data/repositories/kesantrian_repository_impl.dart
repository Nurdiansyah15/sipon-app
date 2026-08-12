import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/santri_profile.dart';
import '../../domain/repositories/kesantrian_repository.dart';
import '../datasources/kesantrian_remote_data_source.dart';
import '../models/santri_profile_model.dart';

class KesantrianRepositoryImpl implements KesantrianRepository {
  final KesantrianRemoteDataSource _remoteDataSource;

  KesantrianRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, SantriProfile?>> getMyProfile() async {
    try {
      final raw = await _remoteDataSource.getMyProfile();
      if (raw == null) return const Right(null);
      final data = raw['data'] is Map ? raw['data'] as Map : raw;
      return Right(SantriProfileModel.fromJson(Map<String, dynamic>.from(data)));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      return Left(NetworkFailure.fromDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
