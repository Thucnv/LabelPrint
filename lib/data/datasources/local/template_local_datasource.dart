import '../../../core/errors/exceptions.dart';
import '../../models/template_model.dart';
import 'database_helper.dart';

/// Abstract interface for template local data source operations.
abstract class TemplateLocalDataSource {
  /// Retrieves all templates from the database.
  Future<List<TemplateModel>> getAllTemplates();

  /// Retrieves a single template by its [id], including its associated config.
  ///
  /// Throws [NotFoundException] if no template with the given ID exists.
  Future<TemplateModel> getTemplateById(int id);

  /// Inserts a new template and returns its auto-generated ID.
  ///
  /// Throws [DatabaseException] if the insert fails.
  Future<int> insertTemplate(TemplateModel template);

  /// Updates an existing template.
  ///
  /// Throws [DatabaseException] if the update fails.
  Future<void> updateTemplate(TemplateModel template);

  /// Deletes a template by its [id].
  ///
  /// Throws [DatabaseException] if the delete fails.
  Future<void> deleteTemplate(int id);
}

/// SQLite implementation of [TemplateLocalDataSource].
class TemplateLocalDataSourceImpl implements TemplateLocalDataSource {
  final DatabaseHelper databaseHelper;

  TemplateLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<TemplateModel>> getAllTemplates() async {
    try {
      final db = await databaseHelper.database;
      // LEFT JOIN to include the associated config if it exists
      final maps = await db.rawQuery('''
        SELECT t.*, 
               pc.id AS pc_id, pc.printer_id AS pc_printer_id, 
               pc.paper_size AS pc_paper_size, pc.paper_type AS pc_paper_type,
               pc.orientation AS pc_orientation,
               pc.margin_top AS pc_margin_top, pc.margin_left AS pc_margin_left,
               pc.margin_right AS pc_margin_right,
               pc.print_darkness AS pc_print_darkness, pc.print_speed AS pc_print_speed,
               pc.scaling_mode AS pc_scaling_mode, pc.scaling_value AS pc_scaling_value,
               pc.custom_width_mm AS pc_custom_width_mm, pc.custom_height_mm AS pc_custom_height_mm
        FROM templates t
        LEFT JOIN printer_configs pc ON t.config_id = pc.id
        ORDER BY t.updated_at DESC
      ''');
      return maps.map((map) {
        Map<String, dynamic>? configMap;
        if (map['pc_id'] != null) {
          configMap = _extractConfigMap(map);
        }
        return TemplateModel.fromMap(map, configMap: configMap);
      }).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to retrieve templates: ${e.toString()}',
      );
    }
  }

  @override
  Future<TemplateModel> getTemplateById(int id) async {
    try {
      final db = await databaseHelper.database;
      final maps = await db.rawQuery('''
        SELECT t.*, 
               pc.id AS pc_id, pc.printer_id AS pc_printer_id, 
               pc.paper_size AS pc_paper_size, pc.paper_type AS pc_paper_type,
               pc.orientation AS pc_orientation,
               pc.margin_top AS pc_margin_top, pc.margin_left AS pc_margin_left,
               pc.margin_right AS pc_margin_right,
               pc.print_darkness AS pc_print_darkness, pc.print_speed AS pc_print_speed,
               pc.scaling_mode AS pc_scaling_mode, pc.scaling_value AS pc_scaling_value,
               pc.custom_width_mm AS pc_custom_width_mm, pc.custom_height_mm AS pc_custom_height_mm
        FROM templates t
        LEFT JOIN printer_configs pc ON t.config_id = pc.id
        WHERE t.id = ?
        LIMIT 1
      ''', [id]);

      if (maps.isEmpty) {
        throw NotFoundException(message: 'Template with id $id not found');
      }

      final map = maps.first;
      Map<String, dynamic>? configMap;
      if (map['pc_id'] != null) {
        configMap = _extractConfigMap(map);
      }
      return TemplateModel.fromMap(map, configMap: configMap);
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to retrieve template: ${e.toString()}',
      );
    }
  }

  @override
  Future<int> insertTemplate(TemplateModel template) async {
    try {
      final db = await databaseHelper.database;
      return await db.insert('templates', template.toMap());
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to insert template: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateTemplate(TemplateModel template) async {
    try {
      final db = await databaseHelper.database;
      final count = await db.update(
        'templates',
        template.toMap(),
        where: 'id = ?',
        whereArgs: [template.id],
      );
      if (count == 0) {
        throw NotFoundException(
          message: 'Template with id ${template.id} not found for update',
        );
      }
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to update template: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteTemplate(int id) async {
    try {
      final db = await databaseHelper.database;
      await db.delete(
        'templates',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to delete template: ${e.toString()}',
      );
    }
  }

  /// Extracts the printer config columns from a joined row map.
  ///
  /// The JOIN aliases config columns with the `pc_` prefix to avoid
  /// name collisions with the template columns.
  Map<String, dynamic> _extractConfigMap(Map<String, dynamic> joinedMap) {
    return {
      'id': joinedMap['pc_id'],
      'printer_id': joinedMap['pc_printer_id'],
      'paper_size': joinedMap['pc_paper_size'],
      'paper_type': joinedMap['pc_paper_type'],
      'orientation': joinedMap['pc_orientation'],
      'margin_top': joinedMap['pc_margin_top'],
      'margin_left': joinedMap['pc_margin_left'],
      'margin_right': joinedMap['pc_margin_right'],
      'print_darkness': joinedMap['pc_print_darkness'],
      'print_speed': joinedMap['pc_print_speed'],
      'scaling_mode': joinedMap['pc_scaling_mode'],
      'scaling_value': joinedMap['pc_scaling_value'],
      'custom_width_mm': joinedMap['pc_custom_width_mm'],
      'custom_height_mm': joinedMap['pc_custom_height_mm'],
    };
  }
}
