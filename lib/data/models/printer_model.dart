import '../../domain/entities/enums/printer_enums.dart';
import '../../domain/entities/printer.dart';

/// Data model for [Printer] with SQLite serialization.
///
/// Extends the domain entity to add [fromMap]/[toMap] methods
/// for database operations. This keeps the domain layer pure
/// while enabling data layer serialization.
class PrinterModel extends Printer {
  const PrinterModel({
    super.id,
    required super.name,
    required super.type,
    required super.protocol,
    required super.connectionMethod,
    super.btMacAddress,
    super.wifiIp,
    super.wifiPort,
    super.isDefault,
    super.createdAt,
  });

  /// Creates a [PrinterModel] from a SQLite row map.
  ///
  /// Column names match the DDL schema exactly.
  factory PrinterModel.fromMap(Map<String, dynamic> map) {
    return PrinterModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: PrinterType.fromString(map['type'] as String),
      protocol: PrinterProtocol.fromString(map['protocol'] as String),
      connectionMethod:
          ConnectionMethod.fromString(map['connection_method'] as String),
      btMacAddress: map['bt_mac_address'] as String?,
      wifiIp: map['wifi_ip'] as String?,
      wifiPort: (map['wifi_port'] as int?) ?? 9100,
      isDefault: (map['is_default'] as int?) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  /// Converts this model to a SQLite-compatible map.
  ///
  /// The `id` field is excluded when null (auto-generated on INSERT).
  /// The `created_at` field is excluded to use the DDL DEFAULT.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'type': type.toDbString(),
      'protocol': protocol.toDbString(),
      'connection_method': connectionMethod.toDbString(),
      'bt_mac_address': btMacAddress,
      'wifi_ip': wifiIp,
      'wifi_port': wifiPort,
      'is_default': isDefault ? 1 : 0,
    };
    if (id != null) {
      map['id'] = id;
    }
    if (createdAt != null) {
      map['created_at'] = createdAt!.toIso8601String();
    }
    return map;
  }

  /// Creates a [PrinterModel] from a domain [Printer] entity.
  factory PrinterModel.fromEntity(Printer printer) {
    return PrinterModel(
      id: printer.id,
      name: printer.name,
      type: printer.type,
      protocol: printer.protocol,
      connectionMethod: printer.connectionMethod,
      btMacAddress: printer.btMacAddress,
      wifiIp: printer.wifiIp,
      wifiPort: printer.wifiPort,
      isDefault: printer.isDefault,
      createdAt: printer.createdAt,
    );
  }
}
