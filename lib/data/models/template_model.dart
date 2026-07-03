import '../../domain/entities/printer_config.dart';
import '../../domain/entities/template.dart';
import 'printer_config_model.dart';

/// Data model for [Template] with SQLite serialization.
///
/// Extends the domain entity to add [fromMap]/[toMap] methods
/// for database operations.
class TemplateModel extends Template {
  const TemplateModel({
    super.id,
    required super.name,
    required super.widthMm,
    required super.heightMm,
    super.createdAt,
    super.updatedAt,
    super.config,
  });

  /// Creates a [TemplateModel] from a SQLite row map.
  ///
  /// Column names match the DDL schema exactly.
  /// Optionally accepts a [configMap] for the associated [PrinterConfig].
  factory TemplateModel.fromMap(
    Map<String, dynamic> map, {
    Map<String, dynamic>? configMap,
  }) {
    return TemplateModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      widthMm: map['width_mm'] as int,
      heightMm: map['height_mm'] as int,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      config:
          configMap != null ? PrinterConfigModel.fromMap(configMap) : null,
    );
  }

  /// Converts this model to a SQLite-compatible map.
  ///
  /// The `id` field is excluded when null (auto-generated on INSERT).
  /// The `config` association is stored as `config_id` foreign key.
  /// Timestamps are excluded to use DDL DEFAULTs on INSERT.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'width_mm': widthMm,
      'height_mm': heightMm,
      'config_id': config?.id,
    };
    if (id != null) {
      map['id'] = id;
    }
    if (createdAt != null) {
      map['created_at'] = createdAt!.toIso8601String();
    }
    // Always set updated_at on save
    map['updated_at'] = (updatedAt ?? DateTime.now()).toIso8601String();
    return map;
  }

  /// Creates a [TemplateModel] from a domain [Template] entity.
  factory TemplateModel.fromEntity(Template template) {
    return TemplateModel(
      id: template.id,
      name: template.name,
      widthMm: template.widthMm,
      heightMm: template.heightMm,
      createdAt: template.createdAt,
      updatedAt: template.updatedAt,
      config: template.config,
    );
  }
}
