import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  final String identifier;
  final String password;

  LoginParams({required this.identifier, required this.password});
}

class LoginUseCase implements UseCase<Either<Failure, User>, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) {
    return repository.login(
      identifier: params.identifier,
      password: params.password,
    );
  }
}
