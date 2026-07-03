import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../repositories/printer_repository.dart';
import '../usecase.dart';

/// Sets a printer as the default printer.
///
/// Any previously default printer will be unset first.
class SetDefaultPrinter extends UseCase<void, int> {
  final PrinterRepository repository;

  SetDefaultPrinter(this.repository);

  @override
  Future<Either<Failure, void>> call(int params) {
    return repository.setDefaultPrinter(params);
  }
}
