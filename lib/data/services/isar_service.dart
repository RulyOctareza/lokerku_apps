import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/job_application.dart';
import '../models/template.dart';
import '../models/user_settings.dart';

/// Isar Database Service
/// Handles all local database operations
class IsarService {
  static Isar? _isar;

  /// Get Isar instance (singleton)
  static Future<Isar> get db async {
    if (_isar != null && _isar!.isOpen) {
      return _isar!;
    }
    return await _initialize();
  }

  /// Initialize Isar database
  static Future<Isar> _initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [JobApplicationSchema, TemplateSchema, UserSettingsSchema],
      directory: dir.path,
      name: 'lokerku_db',
    );

    // Seed default templates if empty
    await _seedDefaultTemplates();
    // Initialize user settings if empty
    await _initializeSettings();

    return _isar!;
  }

  /// Seed default templates on first run
  static Future<void> _seedDefaultTemplates() async {
    final isar = await db;
    final count = await isar.templates.count();
    if (count == 0) {
      await isar.writeTxn(() async {
        await isar.templates.putAll(DefaultTemplates.getAll());
      });
    }
  }

  /// Initialize user settings on first run
  static Future<void> _initializeSettings() async {
    final isar = await db;
    final settings = await isar.userSettings.get(1);
    if (settings == null) {
      await isar.writeTxn(() async {
        await isar.userSettings.put(UserSettings.getDefault());
      });
    }
  }

  /// Close database
  static Future<void> close() async {
    if (_isar != null && _isar!.isOpen) {
      await _isar!.close();
      _isar = null;
    }
  }
}
