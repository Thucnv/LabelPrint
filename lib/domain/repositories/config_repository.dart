import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../entities/printer_config.dart';

/// Repository interface for printer configuration operations.
///
/// Each printer has at most one configuration record.
abstract class ConfigRepository {
  /// Retrieves the configuration for a printer by [printerId].
  ///
  /// Returns null if no configuration has been saved yet.
  Future<Either<Failure, PrinterConfig?>> getConfigByPrinterId(int printerId);

  /// Saves a new printer configuration.
  Future<Either<Failure, void>> saveConfig(PrinterConfig config);

  /// Updates an existing printer configuration.
  Future<Either<Failure, void>> updateConfig(PrinterConfig config);
}
