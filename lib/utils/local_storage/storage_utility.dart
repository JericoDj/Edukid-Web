import 'package:get_storage/get_storage.dart';

class MyStorageUtility {
  GetStorage? _storage;

  // Singleton instance
  static final MyStorageUtility _instance = MyStorageUtility._internal();

  MyStorageUtility._internal();

  // Factory constructor for singleton pattern
  factory MyStorageUtility() {
    return _instance;
  }

  // Initialize GetStorage
  static Future<void> init(String bucketName) async {
    await GetStorage.init(bucketName);
    _instance._storage = GetStorage(bucketName); // Initialize _storage
  }

  // Generic method to save data
  Future<void> saveData<My>(String key, My value) async {
    _ensureInitialized();
    await _storage!.write(key, value);
  }

  // Generic method to read data
  My? readData<My>(String key) {
    _ensureInitialized();
    return _storage!.read<My>(key);
  }

  // Generic method to remove data
  Future<void> removeData(String key) async {
    _ensureInitialized();
    await _storage!.remove(key);
  }

  // Clear all data in storage
  Future<void> clearAll() async {
    _ensureInitialized();
    await _storage!.erase();
  }

  // Ensure storage is initialized
  void _ensureInitialized() {
    if (_storage == null) {
      throw Exception('Storage has not been initialized.');
    }
  }

  // Check if the storage is initialized
  bool _isInitialized() {
    return _storage != null;
  }
}
