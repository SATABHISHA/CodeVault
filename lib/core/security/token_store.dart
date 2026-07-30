// Conditional import: on web, uses localStorage via dart:js_interop.
// On all other platforms (Windows, Android), uses flutter_secure_storage.
import 'token_store_io.dart'
    if (dart.library.js_interop) 'token_store_web.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

export 'token_store_io.dart'
    if (dart.library.js_interop) 'token_store_web.dart'
    show createTokenStore;

abstract interface class TokenStore {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> delete();

  /// Returns the correct TokenStore for the current platform:
  /// - Web   → WebTokenStore (localStorage)
  /// - Other → SecureTokenStore (OS keystore)
  factory TokenStore.create() => createTokenStore();
}

/// Native implementation (Android / Windows): uses the OS secure keystore.
class SecureTokenStore implements TokenStore {
  const SecureTokenStore([this.storage = const FlutterSecureStorage()]);
  final FlutterSecureStorage storage;
  static const _key = 'access_token';

  @override
  Future<String?> read() => storage.read(key: _key);
  @override
  Future<void> write(String token) => storage.write(key: _key, value: token);
  @override
  Future<void> delete() => storage.delete(key: _key);

  Future<String?> readKey(String k) => storage.read(key: k);
  Future<void> writeKey(String k, String value) =>
      storage.write(key: k, value: value);
}
