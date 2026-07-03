import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/template.dart';
import '../../domain/repositories/template_repository.dart';
import '../datasources/local/template_local_datasource.dart';
import '../models/template_model.dart';

/// Triển khai thực tế của TemplateRepository.
class TemplateRepositoryImpl implements TemplateRepository {
  final TemplateLocalDataSource localDataSource;

  TemplateRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Template>>> getAllTemplates() async {
    try {
      final templateModels = await localDataSource.getAllTemplates();
      return Right(templateModels);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Template>> getTemplateById(int id) async {
    try {
      final templateModel = await localDataSource.getTemplateById(id);
      return Right(templateModel);
    } on NotFoundException catch (e) {
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> saveTemplate(Template template) async {
    try {
      final templateModel = TemplateModel.fromEntity(template);
      final id = await localDataSource.insertTemplate(templateModel);
      return Right(id);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTemplate(int id) async {
    try {
      await localDataSource.deleteTemplate(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
