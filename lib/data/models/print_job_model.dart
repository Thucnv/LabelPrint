import '../../domain/entities/enums/print_enums.dart';
import '../../domain/entities/print_job.dart';

/// Data model for [PrintJob] with SQLite serialization.
///
/// Extends the domain entity to add [fromMap]/[toMap] methods
/// for database operations.
class PrintJobModel extends PrintJob {
  const PrintJobModel({
    super.id,
    required super.printerId,
    required super.jobName,
    required super.documentType,
    super.totalPages,
    super.copies,
    super.status,
    super.createdAt,
  });

  /// Creates a [PrintJobModel] from a SQLite row map.
  ///
  /// Column names match the DDL schema exactly.
  factory PrintJobModel.fromMap(Map<String, dynamic> map) {
    return PrintJobModel(
      id: map['id'] as int?,
      printerId: map['printer_id'] as int,
      jobName: map['job_name'] as String,
      documentType:
          DocumentType.fromDbString(map['document_type'] as String),
      totalPages: (map['total_pages'] as int?) ?? 1,
      copies: (map['copies'] as int?) ?? 1,
      status: map['status'] != null
          ? JobStatus.fromDbString(map['status'] as String)
          : JobStatus.pending,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  /// Converts this model to a SQLite-compatible map.
  ///
  /// The `id` field is excluded when null (auto-generated on INSERT).
  /// The `created_at` field is excluded to use the DDL DEFAULT.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'printer_id': printerId,
      'job_name': jobName,
      'document_type': documentType.toDbString(),
      'total_pages': totalPages,
      'copies': copies,
      'status': status.toDbString(),
    };
    if (id != null) {
      map['id'] = id;
    }
    if (createdAt != null) {
      map['created_at'] = createdAt!.toIso8601String();
    }
    return map;
  }

  /// Creates a [PrintJobModel] from a domain [PrintJob] entity.
  factory PrintJobModel.fromEntity(PrintJob job) {
    return PrintJobModel(
      id: job.id,
      printerId: job.printerId,
      jobName: job.jobName,
      documentType: job.documentType,
      totalPages: job.totalPages,
      copies: job.copies,
      status: job.status,
      createdAt: job.createdAt,
    );
  }
}
