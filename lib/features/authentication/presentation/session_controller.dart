import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSession {
  const AppSession({
    this.authenticated = false,
    this.permissions = const {},
    this.userId,
    this.tenantId,
    this.mustChangePassword = false,
    this.deviceId,
    this.role = '',
    this.companyName = '',
    this.companyAddress = '',
  });
  final bool authenticated;
  final Set<String> permissions;
  final String? userId;
  final String? tenantId;
  final bool mustChangePassword;
  final String? deviceId;
  final String role;
  final String companyName;
  final String companyAddress;
}

class SessionController extends Notifier<AppSession> {
  @override
  AppSession build() => const AppSession();
  void signIn() => state = const AppSession(
    authenticated: true,
    permissions: {
      'parts.read',
      'support_requests.read',
      'backup_requests.create',
    },
  );
  void signOut() => state = const AppSession();
  void signInRemote({
    required String userId,
    required String? tenantId,
    required bool mustChangePassword,
    required Set<String> permissions,
    required String deviceId,
    String role = '',
    String companyName = '',
    String companyAddress = '',
  }) => state = AppSession(
    authenticated: true,
    userId: userId,
    tenantId: tenantId,
    mustChangePassword: mustChangePassword,
    permissions: permissions,
    deviceId: deviceId,
    role: role,
    companyName: companyName,
    companyAddress: companyAddress,
  );
  void passwordChanged() => state = AppSession(
    authenticated: state.authenticated,
    permissions: state.permissions,
    userId: state.userId,
    tenantId: state.tenantId,
    deviceId: state.deviceId,
    role: state.role,
    companyName: state.companyName,
    companyAddress: state.companyAddress,
  );
}

final sessionProvider = NotifierProvider<SessionController, AppSession>(
  SessionController.new,
);
