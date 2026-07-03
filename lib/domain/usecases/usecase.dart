import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/errors/failures.dart';

/// Base class for all use cases in the application.
///
/// Each use case represents a single business operation and follows
/// the Single Responsibility Principle. Use cases are called by
/// the presentation layer (e.g., BLoC/Cubit) and delegate to
/// repository interfaces.
///
/// [Type] is the return type on success.
/// [Params] is the input parameter type.
abstract class UseCase<Type, Params> {
  /// Executes the use case with the given [params].
  ///
  /// Returns [Right] with the result on success,
  /// or [Left] with a [Failure] on error.
  Future<Either<Failure, Type>> call(Params params);
}

/// Parameter class for use cases that require no input.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
