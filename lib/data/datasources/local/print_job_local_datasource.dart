import '../../../core/errors/exceptions.dart';
import '../../models/print_job_model.dart';
import 'database_helper.dart';

/// Abstract interface for print job local data source operations.
abstract class PrintJobLocalDataSource {
  /// Retrieves all print jobs, ordered by most recent first.
  Future<List<PrintJobModel>> getAllJobs();

  /// Retrieves a single print job by its [id].
  ///
  /// Throws [NotFoundException] if no job with the given ID exists.
  Future<PrintJobModel> getJobById(int id);

  /// Inserts a new print job and returns its auto-generated ID.
  ///
  /// Throws [DatabaseException] if the insert fails.
  Future<int> insertJob(PrintJobModel job);

  /// Updates the status of an existing print job.
  ///
  /// Throws [DatabaseException] if the update fails.
  Future<void> updateJobStatus(int id, String status);

  /// Inserts a print history record for a completed job.
  ///
  /// Throws [DatabaseException] if the insert fails.
  Future<int> insertPrintHistory({
    required int jobId,
    required int successPages,
    String? errorLog,
  });

  /// Retrieves print history records for a given [jobId].
  Future<List<Map<String, dynamic>>> getHistoryByJobId(int jobId);
}

/// SQLite implementation of [PrintJobLocalDataSource].
class PrintJobLocalDataSourceImpl implements PrintJobLocalDataSource {
  final DatabaseHelper databaseHelper;

  PrintJobLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<PrintJobModel>> getAllJobs() async {
    try {
      final db = await databaseHelper.database;
      final maps = await db.query(
        'print_jobs',
        orderBy: 'created_at DESC',
      );
      return maps.map((map) => PrintJobModel.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to retrieve print jobs: ${e.toString()}',
      );
    }
  }

  @override
  Future<PrintJobModel> getJobById(int id) async {
    try {
      final db = await databaseHelper.database;
      final maps = await db.query(
        'print_jobs',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) {
        throw NotFoundException(message: 'Print job with id $id not found');
      }
      return PrintJobModel.fromMap(maps.first);
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to retrieve print job: ${e.toString()}',
      );
    }
  }

  @override
  Future<int> insertJob(PrintJobModel job) async {
    try {
      final db = await databaseHelper.database;
      return await db.insert('print_jobs', job.toMap());
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to insert print job: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateJobStatus(int id, String status) async {
    try {
      final db = await databaseHelper.database;
      final count = await db.update(
        'print_jobs',
        {'status': status},
        where: 'id = ?',
        whereArgs: [id],
      );
      if (count == 0) {
        throw NotFoundException(
          message: 'Print job with id $id not found for status update',
        );
      }
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to update job status: ${e.toString()}',
      );
    }
  }

  @override
  Future<int> insertPrintHistory({
    required int jobId,
    required int successPages,
    String? errorLog,
  }) async {
    try {
      final db = await databaseHelper.database;
      return await db.insert('print_history', {
        'job_id': jobId,
        'success_pages': successPages,
        'error_log': errorLog,
      });
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to insert print history: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getHistoryByJobId(int jobId) async {
    try {
      final db = await databaseHelper.database;
      return await db.query(
        'print_history',
        where: 'job_id = ?',
        whereArgs: [jobId],
        orderBy: 'printed_at DESC',
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to retrieve print history: ${e.toString()}',
      );
    }
  }
}
