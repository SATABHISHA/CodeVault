// Native (Windows / Android) token store implementation.
// This file is compiled on all non-web platforms.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'token_store.dart';

/// Returns a native secure-storage-backed token store.
TokenStore createTokenStore() => const SecureTokenStore();
