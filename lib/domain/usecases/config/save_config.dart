import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../entities/printer_config.dart';
import '../../repositories/config_repository.dart';
import '../usecase.dart';

/// Saves or updates a printer configuration.
///
/// If the config has no ID, it is inserted as a new record.
/// If the config has an ID, the existing record is updated.
class SaveConfig extends UseCase<void, PrinterConfig> {
  final ConfigRepository repository;

  SaveConfig(this.repository);

  @override
  Future<Either<Failure, void>> call(PrinterConfig params) async {
    if (params.id != null) {
      return repository.updateConfig(params);
    }

    final existingResult = await repository.getConfigByPrinterId(params.printerId);
    return existingResult.fold(
      (failure) => Left(failure),
      (existingConfig) {
        if (existingConfig != null) {
          final configToUpdate = params.copyWith(id: existingConfig.id);
          return repository.updateConfig(configToUpdate);
        } else {
          return repository.saveConfig(params);
        }
      },
    );
  }
}
