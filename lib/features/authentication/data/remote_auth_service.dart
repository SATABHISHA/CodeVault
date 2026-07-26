import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/security/token_store.dart';

class RemoteSession {
  const RemoteSession({
    required this.userId,
    required this.tenantId,
    required this.mustChangePassword,
    required this.permissions,
  });
  final String userId;
  final String tenantId;
  final bool mustChangePassword;
  final Set<String> permissions;
}

class RemoteAuthService {
  RemoteAuthService({ApiClient? client, TokenStore? tokenStore})
    : client = client ?? ApiClient(),
      tokenStore = tokenStore ?? const SecureTokenStore();
  final ApiClient client;
  final TokenStore tokenStore;

  Future<RemoteSession> login({
    required String login,
    required String password,
    required String deviceName,
    required String platform,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'login': login,
        'password': password,
        'device_name': deviceName,
        'platform': platform,
      },
    );
    final envelope = response.data!['data'] as Map<String, dynamic>;
    await tokenStore.write(envelope['token'] as String);
    final me = await client.dio.get<Map<String, dynamic>>('/me');
    final user = me.data!['data'] as Map<String, dynamic>;
    final tenantId = user['tenant_id'] as String?;
    if (tenantId == null) {
      throw StateError('Android login requires a tenant-scoped account.');
    }
    return RemoteSession(
      userId: user['id'] as String,
      tenantId: tenantId,
      mustChangePassword: envelope['must_change_password'] as bool? ?? false,
      permissions: {
        for (final role in (user['roles'] as List? ?? const []))
          for (final permission
              in ((role as Map<String, dynamic>)['permissions'] as List? ??
                  const []))
            (permission as Map<String, dynamic>)['name'] as String,
      },
    );
  }

  Future<void> logout() async {
    try {
      await client.dio.post<void>('/auth/logout');
    } on DioException {
      rethrow;
    } finally {
      await tokenStore.delete();
    }
  }
}
