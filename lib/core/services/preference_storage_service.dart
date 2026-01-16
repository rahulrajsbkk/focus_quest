import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

/// Service for storing simple preferences using Sembast.
///
/// This service provides a simple key-value store for app preferences
/// like theme mode, sync settings, etc.
class PreferenceStorageService {
  factory PreferenceStorageService() => _instance;
  PreferenceStorageService._();

  static final PreferenceStorageService _instance =
      PreferenceStorageService._();

  Database? _database;
  final _store = StoreRef<String, String>.main();

  /// Initialize the database
  Future<void> init() async {
    if (_database != null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDir.path, 'preferences.db');
    _database = await databaseFactoryIo.openDatabase(dbPath);
  }

  /// Get a string preference value
  Future<String?> getString(String key) async {
    await init();
    final record = await _store.record(key).get(_database!);
    return record;
  }

  /// Set a string preference value
  Future<void> setString(String key, String value) async {
    await init();
    await _store.record(key).put(_database!, value);
  }

  /// Get a boolean preference value
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    await init();
    final record = await _store.record(key).get(_database!);
    if (record == null) return defaultValue;
    return record == 'true';
  }

  /// Set a boolean preference value
  Future<void> setBool(String key, {required bool value}) async {
    await init();
    await _store.record(key).put(_database!, value.toString());
  }

  /// Get an integer preference value
  Future<int> getInt(String key, {int defaultValue = 0}) async {
    await init();
    final record = await _store.record(key).get(_database!);
    if (record == null) return defaultValue;
    return int.tryParse(record) ?? defaultValue;
  }

  /// Set an integer preference value
  Future<void> setInt(String key, int value) async {
    await init();
    await _store.record(key).put(_database!, value.toString());
  }

  /// Remove a preference
  Future<void> remove(String key) async {
    await init();
    await _store.record(key).delete(_database!);
  }

  /// Close the database
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
