import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../entities/printer.dart';
import '../../repositories/printer_repository.dart';
import '../usecase.dart';

/// Retrieves the currently set default printer.
///
/// Returns null (wrapped in Right) if no default printer has been set.
class GetDefaultPrinter extends UseCase<Printer?, NoParams> {
  final PrinterRepository repository;

  GetDefaultPrinter(this.repository);

  @override
  Future<Either<Failure, Printer?>> call(NoParams params) {
    return repository.getDefaultPrinter();
  }
}
