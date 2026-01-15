import 'package:result_dart/result_dart.dart';

abstract interface class UseCase<
  T extends Object,
  F extends Exception,
  Params
> {
  AsyncResultDart<T, F> call(Params params);
}

class NoParams {
  const NoParams();
}
