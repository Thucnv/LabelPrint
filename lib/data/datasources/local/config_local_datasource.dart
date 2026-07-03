import '../../../core/errors/exceptions.dart';
import '../../models/printer_config_model.dart';
import 'database_helper.dart';

/// Abstract interface for printer config local data source operations.
abstract class ConfigLocalDataSource {
  /// Retrieves the configuration for a printer by [printerId].
  ///
  /// Returns null if no configuration has been saved yet.
  Future<PrinterConfigModel?> getConfigByPrinterId(int printerId);

  /// Inserts a new printer configuration.
  ///
  /// Throws [DatabaseException] if the insert fails.
  Future<int> insertConfig(PrinterConfigModel config);

  /// Updates an existing printer configuration.
  ///
  /// Throws [DatabaseException] if the update fails.
  Future<void> updateConfig(PrinterConfigModel config);

  /// Deletes configurations for a given [printerId].
  ///
  /// Throws [DatabaseException] if the delete fails.
  Future<void> deleteConfigByPrinterId(int printerId);
}

/// SQLite implementation of [ConfigLocalDataSource].
class ConfigLocalDataSourceImpl implements ConfigLocalDataSource {
  final DatabaseHelper databaseHelper;

  ConfigLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<PrinterConfigModel?> getConfigByPrinterId(int printerId) async {
    try {
      final db = await databaseHelper.database;
      final maps = await db.query(
        'printer_configs',
        where: 'printer_id = ?',
        whereArgs: [printerId],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return PrinterConfigModel.fromMap(maps.first);
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to retrieve config for printer $printerId: ${e.toString()}',
      );
    }
  }

  @override
  Future<int> insertConfig(PrinterConfigModel config) async {
    try {
      final db = await databaseHelper.database;
      return await db.insert('printer_configs', config.toMap());
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to insert config: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateConfig(PrinterConfigModel config) async {
    try {
      final db = await databaseHelper.database;
      final count = await db.update(
        'printer_configs',
        config.toMap(),
        where: 'id = ?',
        whereArgs: [config.id],
      );
      if (count == 0) {
        throw NotFoundException(
          message: 'Config with id ${config.id} not found for update',
        );
      }
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to update config: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteConfigByPrinterId(int printerId) async {
    try {
      final db = await databaseHelper.database;
      await db.delete(
        'printer_configs',
        where: 'printer_id = ?',
        whereArgs: [printerId],
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to delete config: ${e.toString()}',
      );
    }
  }
}
