// Web-only localStorage implementation of TokenStore.
// This file is only compiled when targeting web platforms.

import 'dart:js_interop';

import 'token_store.dart';

class WebTokenStore implements TokenStore {
  const WebTokenStore();
  static const _key = 'access_token';

  @override
  Future<String?> read() async {
    final val = _jsGet(_key.toJS)?.toDart;
    return (val == null || val.isEmpty) ? null : val;
  }

  @override
  Future<void> write(String token) async {
    _jsSet(_key.toJS, token.toJS);
  }

  @override
  Future<void> delete() async {
    _jsRemove(_key.toJS);
  }
}

@JS('window.localStorage.getItem')
external JSString? _jsGet(JSString key);

@JS('window.localStorage.setItem')
external void _jsSet(JSString key, JSString value);

@JS('window.localStorage.removeItem')
external void _jsRemove(JSString key);

/// Returns a web-compatible token store backed by localStorage.
TokenStore createTokenStore() => const WebTokenStore();
