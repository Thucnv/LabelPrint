import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Singleton helper for managing the SQLite database lifecycle.
///
/// Handles database creation, schema migration, and provides
/// access to the database instance. Uses the exact DDL schema
/// from the BRD specification.
class DatabaseHelper {
  static const String _databaseName = 'label_print.db';
  static const int _databaseVersion = 2;

  // Singleton instance
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal();

  /// Returns the singleton instance of [DatabaseHelper].
  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  /// Returns the database instance, creating it if necessary.
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initializes the database, creating the file and schema if needed.
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Enables foreign key support for every connection.
  ///
  /// SQLite does not enforce foreign keys by default; this must
  /// be enabled per-connection via PRAGMA.
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Creates all tables using the exact DDL from the BRD.
  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    // ── Printers ──────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE printers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT CHECK(type IN ('LABEL', 'RECEIPT')) NOT NULL,
        protocol TEXT CHECK(protocol IN ('TSPL', 'ESC_POS')) NOT NULL,
        connection_method TEXT CHECK(connection_method IN ('BLUETOOTH', 'WIFI')) NOT NULL,
        bt_mac_address TEXT UNIQUE,
        wifi_ip TEXT,
        wifi_port INTEGER DEFAULT 9100,
        is_default INTEGER CHECK(is_default IN (0, 1)) DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // ── Printer Configs ───────────────────────────────────────
    batch.execute('''
      CREATE TABLE printer_configs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        printer_id INTEGER NOT NULL,
        paper_size TEXT DEFAULT 'A6',
        paper_type TEXT DEFAULT 'LABEL',
        orientation TEXT CHECK(orientation IN ('PORTRAIT', 'LANDSCAPE')) DEFAULT 'PORTRAIT',
        margin_top REAL DEFAULT 0.0,
        margin_left REAL DEFAULT 0.0,
        margin_right REAL DEFAULT 0.0,
        print_darkness INTEGER DEFAULT 8,
        print_speed REAL DEFAULT 4.0,
        scaling_mode TEXT CHECK(scaling_mode IN ('FIT_WIDTH', 'FIT_HEIGHT', 'CUSTOM')) DEFAULT 'FIT_WIDTH',
        scaling_value INTEGER DEFAULT 100,
        custom_width_mm INTEGER,
        custom_height_mm INTEGER,
        FOREIGN KEY(printer_id) REFERENCES printers(id) ON DELETE CASCADE
      )
    ''');

    // ── Print Jobs ────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE print_jobs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        printer_id INTEGER NOT NULL,
        job_name TEXT NOT NULL,
        document_type TEXT CHECK(document_type IN ('BARCODE', 'QR', 'LABEL', 'SHIPPING_LABEL', 'DELIVERY_NOTE', 'RECEIPT', 'PDF', 'IMAGE')) NOT NULL,
        total_pages INTEGER DEFAULT 1,
        copies INTEGER DEFAULT 1,
        status TEXT CHECK(status IN ('PENDING', 'PRINTING', 'SUCCESS', 'FAILED')) DEFAULT 'PENDING',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(printer_id) REFERENCES printers(id)
      )
    ''');

    // ── Print History ─────────────────────────────────────────
    batch.execute('''
      CREATE TABLE print_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        job_id INTEGER NOT NULL,
        printed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        success_pages INTEGER DEFAULT 0,
        error_log TEXT,
        FOREIGN KEY(job_id) REFERENCES print_jobs(id) ON DELETE CASCADE
      )
    ''');

    // ── Templates ─────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE templates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        width_mm INTEGER NOT NULL,
        height_mm INTEGER NOT NULL,
        config_id INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(config_id) REFERENCES printer_configs(id) ON DELETE SET NULL
      )
    ''');

    // ── Template Items ────────────────────────────────────────
    batch.execute('''
      CREATE TABLE template_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        template_id INTEGER NOT NULL,
        type TEXT CHECK(type IN ('TEXT', 'BARCODE', 'QR', 'IMAGE', 'SHAPE')) NOT NULL,
        pos_x REAL NOT NULL,
        pos_y REAL NOT NULL,
        width REAL NOT NULL,
        height REAL NOT NULL,
        content TEXT,
        style_metadata TEXT,
        FOREIGN KEY(template_id) REFERENCES templates(id) ON DELETE CASCADE
      )
    ''');

    // ── App Settings ──────────────────────────────────────────
    batch.execute('''
      CREATE TABLE app_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        setting_key TEXT UNIQUE NOT NULL,
        setting_value TEXT NOT NULL
      )
    ''');

    await batch.commit(noResult: true);
  }

  /// Handles database version upgrades.
  ///
  /// Add migration logic here when the schema evolves.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add label_gap column to printer_configs table
      await db.execute('ALTER TABLE printer_configs ADD COLUMN label_gap REAL DEFAULT 0.0');
    }
  }

  /// Closes the database connection.
  ///
  /// Call this when the app is shutting down or in tests.
  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
      _database = null;
    }
  }

  /// Resets the singleton for testing purposes.
  ///
  /// This should only be called in tests.
  static void resetInstance() {
    _database = null;
    _instance = null;
  }
}
