abstract class UseCase<R, Params> {
  Future<R> call(Params params);
}

class NoParams {
  const NoParams();
}
