/// Supported barcode types for the Label Print app.
enum BarcodeType {
  code128,
  ean13,
  ean8,
  upcA;

  /// Human-readable display name.
  String get displayName {
    switch (this) {
      case BarcodeType.code128:
        return 'Code 128';
      case BarcodeType.ean13:
        return 'EAN-13';
      case BarcodeType.ean8:
        return 'EAN-8';
      case BarcodeType.upcA:
        return 'UPC-A';
    }
  }

  /// Converts the enum to a string that matches standard naming.
  String toDbString() {
    switch (this) {
      case BarcodeType.code128:
        return 'CODE_128';
      case BarcodeType.ean13:
        return 'EAN_13';
      case BarcodeType.ean8:
        return 'EAN_8';
      case BarcodeType.upcA:
        return 'UPC_A';
    }
  }

  /// Creates a [BarcodeType] from a string.
  static BarcodeType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'CODE_128':
      case 'CODE128':
        return BarcodeType.code128;
      case 'EAN_13':
      case 'EAN13':
        return BarcodeType.ean13;
      case 'EAN_8':
      case 'EAN8':
        return BarcodeType.ean8;
      case 'UPC_A':
      case 'UPCA':
        return BarcodeType.upcA;
      default:
        throw ArgumentError('Unknown BarcodeType: $value');
    }
  }
}
