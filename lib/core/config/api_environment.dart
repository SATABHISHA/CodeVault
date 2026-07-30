abstract final class ApiEnvironment {
  static const String liveUrl = 'https://codevault.sroy.es/api/v1';

  static String resolve({
    bool? isWebOverride,
    dynamic platformOverride,
    bool? releaseOverride,
  }) {
    return liveUrl;
  }
}
