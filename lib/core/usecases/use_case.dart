/// Compry — Use Case base interface
/// Clean Architecture — Domain layer
library;

import 'package:equatable/equatable.dart';

/// Base use case with params
abstract interface class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Base use case without params
abstract interface class UseCaseNoParams<Type> {
  Future<Type> call();
}

/// Base stream use case with params
abstract interface class StreamUseCase<Type, Params> {
  Stream<Type> call(Params params);
}

/// Base stream use case without params
abstract interface class StreamUseCaseNoParams<Type> {
  Stream<Type> call();
}

/// No parameters placeholder
final class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
