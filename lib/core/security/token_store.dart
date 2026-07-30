import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_interop';

abstract interface class TokenStore {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> delete();

  /// Returns the right implementation for the current platform.
  factory TokenStore.create() {
    if (kIsWeb) return const WebTokenStore();
    return const SecureTokenStore();
  }
}

/// Web implementation: stores the token in localStorage.
class WebTokenStore implements TokenStore {
  const WebTokenStore();
  static const _key = 'access_token';

  @override
  Future<String?> read() async {
    final val = _localStorage[_key];
    return val?.isEmpty ?? true ? null : val;
  }

  @override
  Future<void> write(String token) async {
    _localStorage[_key] = token;
  }

  @override
  Future<void> delete() async {
    _localStorage.remove(_key);
  }

  // Simple accessor to window.localStorage via dart:html fallback
  static final _localStorage = _LocalStorage();
}

class _LocalStorage {
  String? operator [](String key) => _get(key);
  void operator []=(String key, String value) => _set(key, value);
  void remove(String key) => _remove(key);

  String? _get(String key) {
    // Using dart:html via conditional import pattern
    try {
      return _jsLocalStorageGet(key);
    } catch (_) {
      return null;
    }
  }

  void _set(String key, String value) {
    try {
      _jsLocalStorageSet(key, value);
    } catch (_) {}
  }

  void _remove(String key) {
    try {
      _jsLocalStorageRemove(key);
    } catch (_) {}
  }
}

@JS('window.localStorage.getItem')
external JSString? _jsGet(JSString key);

@JS('window.localStorage.setItem')
external void _jsSet(JSString key, JSString value);

@JS('window.localStorage.removeItem')
external void _jsRemove(JSString key);

String? _jsLocalStorageGet(String key) =>
    _jsGet(key.toJS)?.toDart;

void _jsLocalStorageSet(String key, String value) =>
    _jsSet(key.toJS, value.toJS);

void _jsLocalStorageRemove(String key) =>
    _jsRemove(key.toJS);

/// Native implementation (Android / Windows): uses the OS secure keystore.
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

  Future<String?> readKey(String k) => storage.read(key: k);
  Future<void> writeKey(String k, String value) =>
      storage.write(key: k, value: value);
}
