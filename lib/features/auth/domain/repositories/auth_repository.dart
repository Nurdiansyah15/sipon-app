import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String identifier,
    required String password,
  });

  Future<Either<Failure, User>> register({
    required String username,
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> getMe();

  Future<Either<Failure, void>> logout();
}
