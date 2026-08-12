import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/santri_profile.dart';
import '../repositories/kesantrian_repository.dart';

class GetMySantriProfileUseCase
    implements UseCase<Either<Failure, SantriProfile?>, NoParams> {
  final KesantrianRepository repository;

  GetMySantriProfileUseCase(this.repository);

  @override
  Future<Either<Failure, SantriProfile?>> call(NoParams params) {
    return repository.getMyProfile();
  }
}
