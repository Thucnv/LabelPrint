import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../entities/printer.dart';
import '../../repositories/printer_repository.dart';
import '../usecase.dart';

/// Registers a new printer and returns its auto-generated ID.
class AddPrinter extends UseCase<int, Printer> {
  final PrinterRepository repository;

  AddPrinter(this.repository);

  @override
  Future<Either<Failure, int>> call(Printer params) {
    return repository.addPrinter(params);
  }
}
