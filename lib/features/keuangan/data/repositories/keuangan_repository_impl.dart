import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/billing_summary.dart';
import '../../domain/repositories/keuangan_repository.dart';
import '../datasources/keuangan_remote_data_source.dart';
import '../models/billing_summary_model.dart';

class KeuanganRepositoryImpl implements KeuanganRepository {
  final KeuanganRemoteDataSource _remoteDataSource;

  KeuanganRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, BillingSummary>> getMySummary() async {
    try {
      final raw = await _remoteDataSource.getMySummary();
      final data = raw['data'] is Map ? raw['data'] as Map : raw;
      return Right(BillingSummaryModel.fromJson(Map<String, dynamic>.from(data)));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      return Left(NetworkFailure.fromDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
