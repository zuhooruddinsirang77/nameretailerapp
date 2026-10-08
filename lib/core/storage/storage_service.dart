import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'cached_user';
  static const String _keyShortlist = 'saved_shortlist_ids';

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  StorageService({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences prefs,
  })  : _secureStorage = secureStorage,
        _prefs = prefs;

  static Future<StorageService> create() async {
    const secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(),
    );
    final prefs = await SharedPreferences.getInstance();
    return StorageService(secureStorage: secureStorage, prefs: prefs);
  }

  // Token management
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _keyToken, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyToken);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _keyToken);
  }

  // User cache
  Future<void> saveUser(Map<String, dynamic> userMap) async {
    await _prefs.setString(_keyUser, jsonEncode(userMap));
  }

  Map<String, dynamic>? getUser() {
    final raw = _prefs.getString(_keyUser);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteUser() async {
    await _prefs.remove(_keyUser);
  }

  // Shortlist (Bookmarked domain IDs)
  List<String> getShortlist() {
    return _prefs.getStringList(_keyShortlist) ?? [];
  }

  Future<void> saveShortlist(List<String> ids) async {
    await _prefs.setStringList(_keyShortlist, ids);
  }

  // Clear all session data on logout
  Future<void> clearAuth() async {
    await deleteToken();
    await deleteUser();
  }
}
