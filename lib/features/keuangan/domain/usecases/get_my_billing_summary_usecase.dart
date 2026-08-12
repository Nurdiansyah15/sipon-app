import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/billing_summary.dart';
import '../repositories/keuangan_repository.dart';

class GetMyBillingSummaryUseCase
    implements UseCase<Either<Failure, BillingSummary>, NoParams> {
  final KeuanganRepository repository;

  GetMyBillingSummaryUseCase(this.repository);

  @override
  Future<Either<Failure, BillingSummary>> call(NoParams params) {
    return repository.getMySummary();
  }
}
