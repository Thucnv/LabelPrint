import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../entities/template.dart';
import '../../repositories/template_repository.dart';
import '../usecase.dart';

/// Saves a layout as a reusable template and returns its auto-generated ID.
class SaveAsTemplate extends UseCase<int, Template> {
  final TemplateRepository repository;

  SaveAsTemplate(this.repository);

  @override
  Future<Either<Failure, int>> call(Template params) {
    return repository.saveTemplate(params);
  }
}
