import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../repositories/printer_repository.dart';
import '../usecase.dart';

/// Deletes a printer by its ID.
///
/// This will cascade-delete associated printer configs in the database.
class DeletePrinter extends UseCase<void, int> {
  final PrinterRepository repository;

  DeletePrinter(this.repository);

  @override
  Future<Either<Failure, void>> call(int params) {
    return repository.deletePrinter(params);
  }
}
