/// Base class for all custom exceptions in the application.
///
/// Exceptions are thrown by data sources and caught by repository
/// implementations, which convert them into [Failure] objects
/// returned via [Either].
class AppException implements Exception {
  /// A human-readable description of the exception.
  final String message;

  /// An optional machine-readable error code.
  final String? code;

  const AppException({required this.message, this.code});

  @override
  String toString() => 'AppException(message: $message, code: $code)';
}

/// Exception thrown when a database operation fails.
class DatabaseException extends AppException {
  const DatabaseException({required super.message, super.code});

  @override
  String toString() => 'DatabaseException(message: $message, code: $code)';
}

/// Exception thrown when a network or device connection fails.
class ConnectionException extends AppException {
  const ConnectionException({required super.message, super.code});

  @override
  String toString() => 'ConnectionException(message: $message, code: $code)';
}

/// Exception thrown when input validation fails.
class ValidationException extends AppException {
  const ValidationException({required super.message, super.code});

  @override
  String toString() => 'ValidationException(message: $message, code: $code)';
}

/// Exception thrown when a printer operation fails.
class PrinterException extends AppException {
  const PrinterException({required super.message, super.code});

  @override
  String toString() => 'PrinterException(message: $message, code: $code)';
}

/// Exception thrown when Bluetooth communication fails.
class BluetoothException extends AppException {
  const BluetoothException({required super.message, super.code});

  @override
  String toString() => 'BluetoothException(message: $message, code: $code)';
}

/// Exception thrown when a requested resource is not found.
class NotFoundException extends AppException {
  const NotFoundException({required super.message, super.code});

  @override
  String toString() => 'NotFoundException(message: $message, code: $code)';
}
