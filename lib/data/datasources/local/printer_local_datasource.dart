import 'package:sqflite/sqflite.dart' hide DatabaseException;

import '../../../core/errors/exceptions.dart';
import '../../models/printer_model.dart';
import 'database_helper.dart';

/// Abstract interface for printer local data source operations.
abstract class PrinterLocalDataSource {
  /// Retrieves all printers from the database.
  Future<List<PrinterModel>> getAllPrinters();

  /// Retrieves a single printer by its [id].
  ///
  /// Throws [NotFoundException] if no printer with the given ID exists.
  Future<PrinterModel> getPrinterById(int id);

  /// Retrieves the default printer, or null if none is set.
  Future<PrinterModel?> getDefaultPrinter();

  /// Inserts a new printer and returns its auto-generated ID.
  ///
  /// Throws [DatabaseException] if the insert fails.
  Future<int> insertPrinter(PrinterModel printer);

  /// Updates an existing printer's details.
  ///
  /// Throws [DatabaseException] if the update fails.
  Future<void> updatePrinter(PrinterModel printer);

  /// Deletes a printer by its [id].
  ///
  /// Throws [DatabaseException] if the delete fails.
  Future<void> deletePrinter(int id);

  /// Sets the printer with [id] as the default, unsetting any previous default.
  ///
  /// Throws [DatabaseException] if the operation fails.
  Future<void> setDefaultPrinter(int id);
}

/// SQLite implementation of [PrinterLocalDataSource].
class PrinterLocalDataSourceImpl implements PrinterLocalDataSource {
  final DatabaseHelper databaseHelper;

  PrinterLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<PrinterModel>> getAllPrinters() async {
    try {
      final db = await databaseHelper.database;
      final maps = await db.query(
        'printers',
        orderBy: 'created_at DESC',
      );
      return maps.map((map) => PrinterModel.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to retrieve printers: ${e.toString()}',
      );
    }
  }

  @override
  Future<PrinterModel> getPrinterById(int id) async {
    try {
      final db = await databaseHelper.database;
      final maps = await db.query(
        'printers',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) {
        throw NotFoundException(message: 'Printer with id $id not found');
      }
      return PrinterModel.fromMap(maps.first);
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to retrieve printer: ${e.toString()}',
      );
    }
  }

  @override
  Future<PrinterModel?> getDefaultPrinter() async {
    try {
      final db = await databaseHelper.database;
      final maps = await db.query(
        'printers',
        where: 'is_default = ?',
        whereArgs: [1],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return PrinterModel.fromMap(maps.first);
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to retrieve default printer: ${e.toString()}',
      );
    }
  }

  @override
  Future<int> insertPrinter(PrinterModel printer) async {
    try {
      final db = await databaseHelper.database;
      return await db.insert(
        'printers',
        printer.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to insert printer: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updatePrinter(PrinterModel printer) async {
    try {
      final db = await databaseHelper.database;
      final count = await db.update(
        'printers',
        printer.toMap(),
        where: 'id = ?',
        whereArgs: [printer.id],
      );
      if (count == 0) {
        throw NotFoundException(
          message: 'Printer with id ${printer.id} not found for update',
        );
      }
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to update printer: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deletePrinter(int id) async {
    try {
      final db = await databaseHelper.database;
      await db.delete(
        'printers',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to delete printer: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> setDefaultPrinter(int id) async {
    try {
      final db = await databaseHelper.database;
      await db.transaction((txn) async {
        // Unset all current defaults
        await txn.update(
          'printers',
          {'is_default': 0},
          where: 'is_default = ?',
          whereArgs: [1],
        );
        // Set the new default
        final count = await txn.update(
          'printers',
          {'is_default': 1},
          where: 'id = ?',
          whereArgs: [id],
        );
        if (count == 0) {
          throw NotFoundException(
            message: 'Printer with id $id not found',
          );
        }
      });
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to set default printer: ${e.toString()}',
      );
    }
  }
}
