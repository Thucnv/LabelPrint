import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../entities/printer_config.dart';
import '../../repositories/config_repository.dart';
import '../usecase.dart';

/// Retrieves the printer configuration for a given printer ID.
///
/// Returns null (wrapped in Right) if no configuration exists yet.
class GetConfig extends UseCase<PrinterConfig?, int> {
  final ConfigRepository repository;

  GetConfig(this.repository);

  @override
  Future<Either<Failure, PrinterConfig?>> call(int params) {
    return repository.getConfigByPrinterId(params);
  }
}
