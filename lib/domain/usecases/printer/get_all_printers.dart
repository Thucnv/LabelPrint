import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../entities/printer.dart';
import '../../repositories/printer_repository.dart';
import '../usecase.dart';

/// Retrieves all registered printers.
///
/// This use case returns an empty list if no printers are registered,
/// rather than a failure.
class GetAllPrinters extends UseCase<List<Printer>, NoParams> {
  final PrinterRepository repository;

  GetAllPrinters(this.repository);

  @override
  Future<Either<Failure, List<Printer>>> call(NoParams params) {
    return repository.getAllPrinters();
  }
}
