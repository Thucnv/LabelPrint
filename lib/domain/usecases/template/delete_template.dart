import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../repositories/template_repository.dart';
import '../usecase.dart';

/// Deletes a template by its ID.
///
/// This will cascade-delete associated template items in the database.
class DeleteTemplate extends UseCase<void, int> {
  final TemplateRepository repository;

  DeleteTemplate(this.repository);

  @override
  Future<Either<Failure, void>> call(int params) {
    return repository.deleteTemplate(params);
  }
}
