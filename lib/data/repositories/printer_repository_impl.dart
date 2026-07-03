import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/printer.dart';
import '../../domain/repositories/printer_repository.dart';
import '../datasources/local/printer_local_datasource.dart';
import '../models/printer_model.dart';

/// Triển khai thực tế của PrinterRepository, cầu nối giữa Domain Layer và Data Layer.
class PrinterRepositoryImpl implements PrinterRepository {
  final PrinterLocalDataSource localDataSource;

  PrinterRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Printer>>> getAllPrinters() async {
    try {
      final printerModels = await localDataSource.getAllPrinters();
      return Right(printerModels);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Printer>> getPrinterById(int id) async {
    try {
      final printerModel = await localDataSource.getPrinterById(id);
      return Right(printerModel);
    } on NotFoundException catch (e) {
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Printer?>> getDefaultPrinter() async {
    try {
      final printerModel = await localDataSource.getDefaultPrinter();
      return Right(printerModel);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> addPrinter(Printer printer) async {
    try {
      final printerModel = PrinterModel.fromEntity(printer);
      final id = await localDataSource.insertPrinter(printerModel);
      return Right(id);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePrinter(Printer printer) async {
    try {
      final printerModel = PrinterModel.fromEntity(printer);
      await localDataSource.updatePrinter(printerModel);
      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePrinter(int id) async {
    try {
      await localDataSource.deletePrinter(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setDefaultPrinter(int id) async {
    try {
      await localDataSource.setDefaultPrinter(id);
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
