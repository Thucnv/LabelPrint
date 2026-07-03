import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../entities/template.dart';

/// Repository interface for template CRUD operations.
abstract class TemplateRepository {
  /// Retrieves all saved templates.
  Future<Either<Failure, List<Template>>> getAllTemplates();

  /// Retrieves a single template by its [id].
  Future<Either<Failure, Template>> getTemplateById(int id);

  /// Saves a new template and returns its auto-generated ID.
  Future<Either<Failure, int>> saveTemplate(Template template);

  /// Deletes a template by its [id].
  ///
  /// This will cascade-delete associated template items due to
  /// the ON DELETE CASCADE constraint.
  Future<Either<Failure, void>> deleteTemplate(int id);
}
