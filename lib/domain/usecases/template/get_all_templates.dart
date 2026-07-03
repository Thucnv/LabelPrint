import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../entities/template.dart';
import '../../repositories/template_repository.dart';
import '../usecase.dart';

/// Retrieves all saved templates.
class GetAllTemplates extends UseCase<List<Template>, NoParams> {
  final TemplateRepository repository;

  GetAllTemplates(this.repository);

  @override
  Future<Either<Failure, List<Template>>> call(NoParams params) {
    return repository.getAllTemplates();
  }
}
