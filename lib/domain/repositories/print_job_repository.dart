import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../entities/enums/print_enums.dart';
import '../entities/print_job.dart';

/// Repository interface for print job operations.
abstract class PrintJobRepository {
  /// Retrieves all print jobs, ordered by most recent first.
  Future<Either<Failure, List<PrintJob>>> getAllJobs();

  /// Creates a new print job and returns its auto-generated ID.
  Future<Either<Failure, int>> createJob(PrintJob job);

  /// Updates the status of an existing print job.
  ///
  /// Used to transition jobs through the lifecycle:
  /// PENDING → PRINTING → SUCCESS/FAILED.
  Future<Either<Failure, void>> updateJobStatus(int id, JobStatus status);
}
