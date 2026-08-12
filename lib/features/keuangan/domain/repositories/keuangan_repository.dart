import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/billing_summary.dart';

abstract class KeuanganRepository {
  Future<Either<Failure, BillingSummary>> getMySummary();
}
