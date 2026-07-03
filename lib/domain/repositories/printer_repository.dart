import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../entities/printer.dart';

/// Repository interface for printer CRUD operations.
///
/// This abstract class defines the contract that the data layer must
/// implement. It lives in the domain layer and has no knowledge of
/// the underlying data source (SQLite, API, etc.).
abstract class PrinterRepository {
  /// Retrieves all registered printers.
  Future<Either<Failure, List<Printer>>> getAllPrinters();

  /// Retrieves a single printer by its [id].
  Future<Either<Failure, Printer>> getPrinterById(int id);

  /// Retrieves the default printer, or null if none is set.
  Future<Either<Failure, Printer?>> getDefaultPrinter();

  /// Adds a new printer and returns its auto-generated ID.
  Future<Either<Failure, int>> addPrinter(Printer printer);

  /// Updates an existing printer's details.
  Future<Either<Failure, void>> updatePrinter(Printer printer);

  /// Deletes a printer by its [id].
  ///
  /// This will cascade-delete associated printer configs due to
  /// the ON DELETE CASCADE constraint.
  Future<Either<Failure, void>> deletePrinter(int id);

  /// Sets the printer with the given [id] as the default.
  ///
  /// Any previously default printer will be unset.
  Future<Either<Failure, void>> setDefaultPrinter(int id);
}
