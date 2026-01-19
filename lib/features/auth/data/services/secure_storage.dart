import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final _secureStorage = const FlutterSecureStorage();

  static const _jwtKey = 'jwt';

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _jwtKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _jwtKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _jwtKey);
  }

  Future<void> clearStorage() async {
    await _secureStorage.deleteAll();
  }
}