import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../entities/printer.dart';
import '../../repositories/printer_repository.dart';
import '../usecase.dart';

/// Updates an existing printer's details.
class UpdatePrinter extends UseCase<void, Printer> {
  final PrinterRepository repository;

  UpdatePrinter(this.repository);

  @override
  Future<Either<Failure, void>> call(Printer params) {
    return repository.updatePrinter(params);
  }
}
