import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/prefs_keys.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SharedPreferences _prefs;

  AuthRepositoryImpl(this._remoteDataSource, this._prefs);

  Future<Either<Failure, User>> _persistSession(
    Map<String, dynamic> rawEnvelope,
  ) async {
    final data = rawEnvelope['data'] is Map
        ? Map<String, dynamic>.from(rawEnvelope['data'] as Map)
        : <String, dynamic>{};

    final token = data['token'] as String?;
    if (token != null && token.isNotEmpty) {
      await _prefs.setString(PrefsKey.accessToken.value, token);
    }
    final refreshToken = data['refresh_token'] as String?;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _prefs.setString(PrefsKey.refreshToken.value, refreshToken);
    }

    final userJson = data['user'] is Map
        ? Map<String, dynamic>.from(data['user'] as Map)
        : data;
    final user = UserModel.fromJson(userJson);
    await _prefs.setString(PrefsKey.userProfile.value, jsonEncode(user.toJson()));

    return Right(user);
  }

  @override
  Future<Either<Failure, User>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final raw = await _remoteDataSource.login(
        identifier: identifier,
        password: password,
      );
      return await _persistSession(raw);
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      return Left(NetworkFailure.fromDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final raw = await _remoteDataSource.register(
        username: username,
        email: email,
        password: password,
      );
      return await _persistSession(raw);
    } on ConflictException catch (e) {
      return Left(ConflictFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      return Left(NetworkFailure.fromDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getMe() async {
    try {
      final raw = await _remoteDataSource.getMe();
      final data = raw['data'] is Map ? raw['data'] as Map : {};
      final user = UserModel.fromJson(Map<String, dynamic>.from(data));
      await _prefs.setString(PrefsKey.userProfile.value, jsonEncode(user.toJson()));
      return Right(user);
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      return Left(NetworkFailure.fromDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Best-effort — always clear the local session below regardless of
      // whether the server call succeeded.
    }
    await _prefs.remove(PrefsKey.accessToken.value);
    await _prefs.remove(PrefsKey.refreshToken.value);
    await _prefs.remove(PrefsKey.userProfile.value);
    return const Right(null);
  }
}
