import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  final String username;
  final String email;
  final String password;

  RegisterParams({
    required this.username,
    required this.email,
    required this.password,
  });
}

class RegisterUseCase implements UseCase<Either<Failure, User>, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) {
    return repository.register(
      username: params.username,
      email: params.email,
      password: params.password,
    );
  }
}
