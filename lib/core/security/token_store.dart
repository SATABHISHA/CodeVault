import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class TokenStore {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> delete();
}

class SecureTokenStore implements TokenStore {
  const SecureTokenStore([this.storage = const FlutterSecureStorage()]);
  final FlutterSecureStorage storage;
  static const key = 'access_token';
  @override
  Future<String?> read() => storage.read(key: key);
  @override
  Future<void> write(String token) => storage.write(key: key, value: token);
  @override
  Future<void> delete() => storage.delete(key: key);

  Future<String?> readKey(String key) => storage.read(key: key);
  Future<void> writeKey(String key, String value) =>
      storage.write(key: key, value: value);
}
