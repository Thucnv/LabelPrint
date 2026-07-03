import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/printer_config.dart';
import '../../domain/repositories/config_repository.dart';
import '../datasources/local/config_local_datasource.dart';
import '../models/printer_config_model.dart';

/// Triển khai thực tế của ConfigRepository.
class ConfigRepositoryImpl implements ConfigRepository {
  final ConfigLocalDataSource localDataSource;

  ConfigRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, PrinterConfig?>> getConfigByPrinterId(int printerId) async {
    try {
      final configModel = await localDataSource.getConfigByPrinterId(printerId);
      return Right(configModel);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveConfig(PrinterConfig config) async {
    try {
      final configModel = PrinterConfigModel.fromEntity(config);
      await localDataSource.insertConfig(configModel);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateConfig(PrinterConfig config) async {
    try {
      final configModel = PrinterConfigModel.fromEntity(config);
      await localDataSource.updateConfig(configModel);
      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
