import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSession {
  const AppSession({
    this.authenticated = false,
    this.permissions = const {},
    this.userId,
    this.tenantId,
    this.mustChangePassword = false,
  });
  final bool authenticated;
  final Set<String> permissions;
  final String? userId;
  final String? tenantId;
  final bool mustChangePassword;
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
    required String tenantId,
    required bool mustChangePassword,
    required Set<String> permissions,
  }) => state = AppSession(
    authenticated: true,
    userId: userId,
    tenantId: tenantId,
    mustChangePassword: mustChangePassword,
    permissions: permissions,
  );
}

final sessionProvider = NotifierProvider<SessionController, AppSession>(
  SessionController.new,
);
