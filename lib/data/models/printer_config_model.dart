import '../../domain/entities/enums/print_enums.dart';
import '../../domain/entities/printer_config.dart';

/// Data model for [PrinterConfig] with SQLite serialization.
///
/// Extends the domain entity to add [fromMap]/[toMap] methods
/// for database operations.
class PrinterConfigModel extends PrinterConfig {
  const PrinterConfigModel({
    super.id,
    required super.printerId,
    super.paperSize,
    super.paperType,
    super.orientation,
    super.marginTop,
    super.marginLeft,
    super.marginRight,
    super.printDarkness,
    super.printSpeed,
    super.scalingMode,
    super.scalingValue,
    super.customWidthMm,
    super.customHeightMm,
    super.labelGap,
  });

  /// Creates a [PrinterConfigModel] from a SQLite row map.
  ///
  /// Column names match the DDL schema exactly.
  factory PrinterConfigModel.fromMap(Map<String, dynamic> map) {
    return PrinterConfigModel(
      id: map['id'] as int?,
      printerId: map['printer_id'] as int,
      paperSize: map['paper_size'] != null
          ? PaperSize.fromDbString(map['paper_size'] as String)
          : PaperSize.A6,
      paperType: map['paper_type'] != null
          ? PaperType.fromDbString(map['paper_type'] as String)
          : PaperType.label,
      orientation: map['orientation'] != null
          ? Orientation.fromDbString(map['orientation'] as String)
          : Orientation.portrait,
      marginTop: (map['margin_top'] as num?)?.toDouble() ?? 0.0,
      marginLeft: (map['margin_left'] as num?)?.toDouble() ?? 0.0,
      marginRight: (map['margin_right'] as num?)?.toDouble() ?? 0.0,
      printDarkness: (map['print_darkness'] as int?) ?? 8,
      printSpeed: (map['print_speed'] as num?)?.toDouble() ?? 4.0,
      scalingMode: map['scaling_mode'] != null
          ? ScalingMode.fromDbString(map['scaling_mode'] as String)
          : ScalingMode.fitWidth,
      scalingValue: (map['scaling_value'] as int?) ?? 100,
      customWidthMm: map['custom_width_mm'] as int?,
      customHeightMm: map['custom_height_mm'] as int?,
      labelGap: (map['label_gap'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Converts this model to a SQLite-compatible map.
  ///
  /// The `id` field is excluded when null (auto-generated on INSERT).
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'printer_id': printerId,
      'paper_size': paperSize.toDbString(),
      'paper_type': paperType.toDbString(),
      'orientation': orientation.toDbString(),
      'margin_top': marginTop,
      'margin_left': marginLeft,
      'margin_right': marginRight,
      'print_darkness': printDarkness,
      'print_speed': printSpeed,
      'scaling_mode': scalingMode.toDbString(),
      'scaling_value': scalingValue,
      'custom_width_mm': customWidthMm,
      'custom_height_mm': customHeightMm,
      'label_gap': labelGap,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Creates a [PrinterConfigModel] from a domain [PrinterConfig] entity.
  factory PrinterConfigModel.fromEntity(PrinterConfig config) {
    return PrinterConfigModel(
      id: config.id,
      printerId: config.printerId,
      paperSize: config.paperSize,
      paperType: config.paperType,
      orientation: config.orientation,
      marginTop: config.marginTop,
      marginLeft: config.marginLeft,
      marginRight: config.marginRight,
      printDarkness: config.printDarkness,
      printSpeed: config.printSpeed,
      scalingMode: config.scalingMode,
      scalingValue: config.scalingValue,
      customWidthMm: config.customWidthMm,
      customHeightMm: config.customHeightMm,
      labelGap: config.labelGap,
    );
  }
}
