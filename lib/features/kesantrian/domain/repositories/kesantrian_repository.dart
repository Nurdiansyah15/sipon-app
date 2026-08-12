import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/santri_profile.dart';

abstract class KesantrianRepository {
  /// Returns `Right(null)` when the current user has no santri record yet —
  /// the backend's 404 for this endpoint is an expected "not registered"
  /// state, not a failure (mirrors sipon-ui's handling).
  Future<Either<Failure, SantriProfile?>> getMyProfile();
}
