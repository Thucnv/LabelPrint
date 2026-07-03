/// Print-related enumerations for the Label Print app.
///
/// Each enum provides [toDbString] and [fromDbString] methods
/// for database serialization matching the SQLite CHECK constraints.

import 'printer_enums.dart' as printer_enums;

/// Standard paper sizes with physical dimensions in millimeters.
enum PaperSize {
  A5,
  A6,
  A7,
  A8,
  custom;

  /// Get available paper sizes for a given printer type.
  static List<PaperSize> getAvailableSizesForPrinterType(printer_enums.PrinterType printerType) {
    switch (printerType) {
      case printer_enums.PrinterType.label:
        // Label printers typically use smaller sizes
        return [PaperSize.A5, PaperSize.A6, PaperSize.A7, PaperSize.A8, PaperSize.custom];
      case printer_enums.PrinterType.receipt:
        // Receipt printers can use larger sizes
        return [PaperSize.A5, PaperSize.A6, PaperSize.custom];
    }
  }

  /// Width in millimeters for the paper size.
  int get widthMm {
    switch (this) {
      case PaperSize.A5:
        return 148;
      case PaperSize.A6:
        return 105;
      case PaperSize.A7:
        return 74;
      case PaperSize.A8:
        return 52;
      case PaperSize.custom:
        return 0;
    }
  }

  /// Height in millimeters for the paper size.
  int get heightMm {
    switch (this) {
      case PaperSize.A5:
        return 210;
      case PaperSize.A6:
        return 148;
      case PaperSize.A7:
        return 105;
      case PaperSize.A8:
        return 74;
      case PaperSize.custom:
        return 0;
    }
  }

  /// Database string representation.
  String toDbString() {
    switch (this) {
      case PaperSize.A5:
        return 'A5';
      case PaperSize.A6:
        return 'A6';
      case PaperSize.A7:
        return 'A7';
      case PaperSize.A8:
        return 'A8';
      case PaperSize.custom:
        return 'CUSTOM';
    }
  }

  /// Creates a [PaperSize] from a database string value.
  ///
  /// Throws [ArgumentError] if the value doesn't match any known size.
  static PaperSize fromDbString(String value) {
    switch (value.toUpperCase()) {
      case 'A5':
        return PaperSize.A5;
      case 'A6':
        return PaperSize.A6;
      case 'A7':
        return PaperSize.A7;
      case 'A8':
        return PaperSize.A8;
      case 'CUSTOM':
        return PaperSize.custom;
      default:
        throw ArgumentError('Unknown PaperSize: $value');
    }
  }
}

/// The type of paper media loaded in the printer.
enum PaperType {
  label,
  continuous,
  blackMark;

  /// Database string representation.
  String toDbString() {
    switch (this) {
      case PaperType.label:
        return 'LABEL';
      case PaperType.continuous:
        return 'CONTINUOUS';
      case PaperType.blackMark:
        return 'BLACK_MARK';
    }
  }

  /// Creates a [PaperType] from a database string value.
  ///
  /// Throws [ArgumentError] if the value doesn't match any known type.
  static PaperType fromDbString(String value) {
    switch (value.toUpperCase()) {
      case 'LABEL':
        return PaperType.label;
      case 'CONTINUOUS':
        return PaperType.continuous;
      case 'BLACK_MARK':
        return PaperType.blackMark;
      default:
        throw ArgumentError('Unknown PaperType: $value');
    }
  }
}

/// Print orientation for the document.
enum Orientation {
  portrait,
  landscape;

  /// Database string representation.
  String toDbString() {
    switch (this) {
      case Orientation.portrait:
        return 'PORTRAIT';
      case Orientation.landscape:
        return 'LANDSCAPE';
    }
  }

  /// Creates an [Orientation] from a database string value.
  ///
  /// Throws [ArgumentError] if the value doesn't match any known orientation.
  static Orientation fromDbString(String value) {
    switch (value.toUpperCase()) {
      case 'PORTRAIT':
        return Orientation.portrait;
      case 'LANDSCAPE':
        return Orientation.landscape;
      default:
        throw ArgumentError('Unknown Orientation: $value');
    }
  }
}

/// The scaling mode used when rendering content to the print area.
enum ScalingMode {
  fitWidth,
  fitHeight,
  custom;

  /// Database string representation.
  String toDbString() {
    switch (this) {
      case ScalingMode.fitWidth:
        return 'FIT_WIDTH';
      case ScalingMode.fitHeight:
        return 'FIT_HEIGHT';
      case ScalingMode.custom:
        return 'CUSTOM';
    }
  }

  /// Creates a [ScalingMode] from a database string value.
  ///
  /// Throws [ArgumentError] if the value doesn't match any known mode.
  static ScalingMode fromDbString(String value) {
    switch (value.toUpperCase()) {
      case 'FIT_WIDTH':
        return ScalingMode.fitWidth;
      case 'FIT_HEIGHT':
        return ScalingMode.fitHeight;
      case 'CUSTOM':
        return ScalingMode.custom;
      default:
        throw ArgumentError('Unknown ScalingMode: $value');
    }
  }
}

/// The type of document being printed.
enum DocumentType {
  barcode,
  qr,
  label,
  shippingLabel,
  deliveryNote,
  receipt,
  pdf,
  image;

  /// Database string representation matching the DDL CHECK constraint.
  String toDbString() {
    switch (this) {
      case DocumentType.barcode:
        return 'BARCODE';
      case DocumentType.qr:
        return 'QR';
      case DocumentType.label:
        return 'LABEL';
      case DocumentType.shippingLabel:
        return 'SHIPPING_LABEL';
      case DocumentType.deliveryNote:
        return 'DELIVERY_NOTE';
      case DocumentType.receipt:
        return 'RECEIPT';
      case DocumentType.pdf:
        return 'PDF';
      case DocumentType.image:
        return 'IMAGE';
    }
  }

  /// Creates a [DocumentType] from a database string value.
  ///
  /// Throws [ArgumentError] if the value doesn't match any known type.
  static DocumentType fromDbString(String value) {
    switch (value.toUpperCase()) {
      case 'BARCODE':
        return DocumentType.barcode;
      case 'QR':
        return DocumentType.qr;
      case 'LABEL':
        return DocumentType.label;
      case 'SHIPPING_LABEL':
        return DocumentType.shippingLabel;
      case 'DELIVERY_NOTE':
        return DocumentType.deliveryNote;
      case 'RECEIPT':
        return DocumentType.receipt;
      case 'PDF':
        return DocumentType.pdf;
      case 'IMAGE':
        return DocumentType.image;
      default:
        throw ArgumentError('Unknown DocumentType: $value');
    }
  }
}

/// The current status of a print job.
enum JobStatus {
  pending,
  printing,
  success,
  failed;

  /// Database string representation matching the DDL CHECK constraint.
  String toDbString() {
    switch (this) {
      case JobStatus.pending:
        return 'PENDING';
      case JobStatus.printing:
        return 'PRINTING';
      case JobStatus.success:
        return 'SUCCESS';
      case JobStatus.failed:
        return 'FAILED';
    }
  }

  /// Creates a [JobStatus] from a database string value.
  ///
  /// Throws [ArgumentError] if the value doesn't match any known status.
  static JobStatus fromDbString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return JobStatus.pending;
      case 'PRINTING':
        return JobStatus.printing;
      case 'SUCCESS':
        return JobStatus.success;
      case 'FAILED':
        return JobStatus.failed;
      default:
        throw ArgumentError('Unknown JobStatus: $value');
    }
  }
}
