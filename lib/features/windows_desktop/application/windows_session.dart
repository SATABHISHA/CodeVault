class WindowsSession {
  WindowsSession._();
  static String? companyId;
  static String? userId;
  static String? role;
  static String companyName = '';
  static String companyAddress = '';
  static Set<String> permissions = const {};

  static void clear() {
    companyId = null;
    userId = null;
    role = null;
    companyName = '';
    companyAddress = '';
    permissions = const {};
  }
}
