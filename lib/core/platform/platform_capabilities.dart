import 'package:flutter/foundation.dart';

enum AppPlatform { windows, android, web, unsupported }

class PlatformCapabilities {
  const PlatformCapabilities(this.platform);

  factory PlatformCapabilities.current() {
    if (kIsWeb) return const PlatformCapabilities(AppPlatform.web);
    return switch (defaultTargetPlatform) {
      TargetPlatform.windows => const PlatformCapabilities(AppPlatform.windows),
      TargetPlatform.android => const PlatformCapabilities(AppPlatform.android),
      _ => const PlatformCapabilities(AppPlatform.unsupported),
    };
  }

  final AppPlatform platform;
  bool get isWindows => platform == AppPlatform.windows;
  bool get isAndroid => platform == AppPlatform.android;
  bool get isWeb => platform == AppPlatform.web;
  bool get supportsLocalBackup => true;
  bool get supportsWirelessPrinting => isAndroid;
  bool get supportsBrowserPrint => isWeb;
  bool get supportsWindowsPrinting => isWindows;
}
