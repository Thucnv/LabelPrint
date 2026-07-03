/// Printer-related enumerations for the Label Print app.
///
/// Each enum maps to the corresponding CHECK constraint values
/// in the SQLite database schema.

/// The type of printer: label or receipt.
enum PrinterType {
  label,
  receipt;

  /// Human-readable display name.
  String get displayName {
    switch (this) {
      case PrinterType.label:
        return 'Label';
      case PrinterType.receipt:
        return 'Receipt';
    }
  }

  /// Database string representation matching the DDL CHECK constraint.
  String toDbString() {
    switch (this) {
      case PrinterType.label:
        return 'LABEL';
      case PrinterType.receipt:
        return 'RECEIPT';
    }
  }

  /// Creates a [PrinterType] from a database string value.
  ///
  /// Throws [ArgumentError] if the value doesn't match any known type.
  static PrinterType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'LABEL':
        return PrinterType.label;
      case 'RECEIPT':
        return PrinterType.receipt;
      default:
        throw ArgumentError('Unknown PrinterType: $value');
    }
  }
}

/// The communication protocol used by the printer.
enum PrinterProtocol {
  tspl,
  escPos;

  /// Human-readable display name.
  String get displayName {
    switch (this) {
      case PrinterProtocol.tspl:
        return 'TSPL';
      case PrinterProtocol.escPos:
        return 'ESC/POS';
    }
  }

  /// Database string representation matching the DDL CHECK constraint.
  String toDbString() {
    switch (this) {
      case PrinterProtocol.tspl:
        return 'TSPL';
      case PrinterProtocol.escPos:
        return 'ESC_POS';
    }
  }

  /// Creates a [PrinterProtocol] from a database string value.
  ///
  /// Throws [ArgumentError] if the value doesn't match any known protocol.
  static PrinterProtocol fromString(String value) {
    switch (value.toUpperCase()) {
      case 'TSPL':
        return PrinterProtocol.tspl;
      case 'ESC_POS':
        return PrinterProtocol.escPos;
      default:
        throw ArgumentError('Unknown PrinterProtocol: $value');
    }
  }
}

/// The connection method used to communicate with the printer.
enum ConnectionMethod {
  bluetooth,
  wifi;

  /// Human-readable display name.
  String get displayName {
    switch (this) {
      case ConnectionMethod.bluetooth:
        return 'Bluetooth';
      case ConnectionMethod.wifi:
        return 'Wi-Fi';
    }
  }

  /// Database string representation matching the DDL CHECK constraint.
  String toDbString() {
    switch (this) {
      case ConnectionMethod.bluetooth:
        return 'BLUETOOTH';
      case ConnectionMethod.wifi:
        return 'WIFI';
    }
  }

  /// Creates a [ConnectionMethod] from a database string value.
  ///
  /// Throws [ArgumentError] if the value doesn't match any known method.
  static ConnectionMethod fromString(String value) {
    switch (value.toUpperCase()) {
      case 'BLUETOOTH':
        return ConnectionMethod.bluetooth;
      case 'WIFI':
        return ConnectionMethod.wifi;
      default:
        throw ArgumentError('Unknown ConnectionMethod: $value');
    }
  }
}

/// The current operational status of a printer.
///
/// This is a runtime status, not persisted in the database.
enum PrinterStatus {
  ready,
  idle,
  error,
  notConfigured;

  /// Human-readable display name.
  String get displayName {
    switch (this) {
      case PrinterStatus.ready:
        return 'Ready';
      case PrinterStatus.idle:
        return 'Idle';
      case PrinterStatus.error:
        return 'Error';
      case PrinterStatus.notConfigured:
        return 'Not Configured';
    }
  }

  /// Creates a [PrinterStatus] from a string value.
  ///
  /// Throws [ArgumentError] if the value doesn't match any known status.
  static PrinterStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'READY':
        return PrinterStatus.ready;
      case 'IDLE':
        return PrinterStatus.idle;
      case 'ERROR':
        return PrinterStatus.error;
      case 'NOT_CONFIGURED':
        return PrinterStatus.notConfigured;
      default:
        throw ArgumentError('Unknown PrinterStatus: $value');
    }
  }
}
