import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/enums/print_enums.dart';
import '../../domain/entities/print_job.dart';
import '../../domain/repositories/print_job_repository.dart';
import '../datasources/local/print_job_local_datasource.dart';
import '../models/print_job_model.dart';

/// Triển khai thực tế của PrintJobRepository.
class PrintJobRepositoryImpl implements PrintJobRepository {
  final PrintJobLocalDataSource localDataSource;

  PrintJobRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<PrintJob>>> getAllJobs() async {
    try {
      final jobModels = await localDataSource.getAllJobs();
      return Right(jobModels);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> createJob(PrintJob job) async {
    try {
      final jobModel = PrintJobModel.fromEntity(job);
      final id = await localDataSource.insertJob(jobModel);
      return Right(id);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateJobStatus(int id, JobStatus status) async {
    try {
      await localDataSource.updateJobStatus(id, status.toDbString());
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
