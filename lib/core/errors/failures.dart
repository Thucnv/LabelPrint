import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
///
/// Failures represent expected error conditions that are communicated
/// through the [Either] type from repository methods. They are distinct
/// from exceptions, which represent unexpected errors.
abstract class Failure extends Equatable {
  /// A human-readable description of the failure.
  final String message;

  /// An optional machine-readable error code.
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Failure that occurs during database operations (CRUD, migration, etc.).
class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message, super.code});
}

/// Failure that occurs when a network or device connection fails.
class ConnectionFailure extends Failure {
  const ConnectionFailure({required super.message, super.code});
}

/// Failure that occurs when input validation fails.
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

/// Failure that occurs during printer operations (sending data, status check, etc.).
class PrinterFailure extends Failure {
  const PrinterFailure({required super.message, super.code});
}

/// Failure specific to Bluetooth communication issues.
class BluetoothFailure extends Failure {
  const BluetoothFailure({required super.message, super.code});
}
