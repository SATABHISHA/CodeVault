import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/security/token_store.dart';

class RemoteSession {
  const RemoteSession({
    required this.userId,
    required this.tenantId,
    required this.mustChangePassword,
    required this.permissions,
    required this.deviceId,
    this.role = '',
    this.companyName = '',
    this.companyAddress = '',
  });
  final String userId;
  final String? tenantId;
  final bool mustChangePassword;
  final Set<String> permissions;
  final String deviceId;
  final String role;
  final String companyName;
  final String companyAddress;
}

class RemoteAuthService {
  RemoteAuthService({ApiClient? client, TokenStore? tokenStore})
    : client = client ?? ApiClient(),
      tokenStore = tokenStore ?? TokenStore.create();
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
    final user = envelope['user'] as Map<String, dynamic>;
    final tenantId = user['tenant_id'] as String?;
    final tenant = user['tenant'] as Map<String, dynamic>?;
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
      deviceId: envelope['device_id'] as String,
      role: (user['roles'] as List? ?? const []).isEmpty
          ? ''
          : ((user['roles'] as List).first as Map<String, dynamic>)['name']
                    as String? ??
                '',
      companyName: tenant?['name'] as String? ?? '',
      companyAddress: tenant?['address'] as String? ?? '',
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await client.dio.post<void>(
      '/auth/change-password',
      data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPassword,
      },
    );
  }

  Future<void> forgotPassword(String email) async {
    await client.dio.post<void>(
      '/auth/forgot-password',
      data: {'email': email.trim()},
    );
  }

  /// Windows-only: generates a reset token server-side and returns it
  /// directly without sending an email.
  Future<String?> revealPasswordToken(String email) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/auth/forgot-password/reveal-token',
      data: {'email': email.trim(), 'platform': 'windows'},
    );
    final data = response.data?['data'] as Map<String, dynamic>?;
    return data?['token'] as String?;
  }

  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
  }) async {
    await client.dio.post<void>(
      '/auth/reset-password',
      data: {
        'email': email.trim(),
        'token': token.trim(),
        'password': password,
        'password_confirmation': password,
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
