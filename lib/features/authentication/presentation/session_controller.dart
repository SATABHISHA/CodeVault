import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSession {
  const AppSession({this.authenticated = false, this.permissions = const {}});
  final bool authenticated;
  final Set<String> permissions;
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
}

final sessionProvider = NotifierProvider<SessionController, AppSession>(
  SessionController.new,
);
