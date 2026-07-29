import 'package:flutter/foundation.dart';

abstract final class ApiEnvironment {
  static const _productionUrl = String.fromEnvironment('API_URL');
  static const _androidLanUrl = String.fromEnvironment('ANDROID_LAN_API_URL');

  static String resolve({
    bool? isWebOverride,
    TargetPlatform? platformOverride,
    bool? releaseOverride,
  }) {
    final isWebPlatform = isWebOverride ?? kIsWeb;
    final platform = platformOverride ?? defaultTargetPlatform;
    final release = releaseOverride ?? kReleaseMode;

    if (platform == TargetPlatform.windows && !isWebPlatform) return '';
    if (_productionUrl.isNotEmpty) return _normalize(_productionUrl);
    if (release) {
      throw StateError(
        'API_URL must be supplied with --dart-define for release builds.',
      );
    }
    // if (isWebPlatform) return 'https://codevault.sroy.es/api/v1';
    if (isWebPlatform) return 'http://127.0.0.1:8000/api/v1';
    if (platform == TargetPlatform.android) {
      return _normalize(
        // _androidLanUrl.isEmpty ? 'https://codevault.sroy.es/api/v1' : _androidLanUrl,
        _androidLanUrl.isEmpty ? 'http://127.0.0.1:8000/api/v1' : _androidLanUrl,
      );
    }
    // return 'https://codevault.sroy.es/api/v1'; 
    return 'http://127.0.0.1:8000/api/v1';
  }

  static String _normalize(String value) =>
      value.replaceFirst(RegExp(r'/$'), '');
}
