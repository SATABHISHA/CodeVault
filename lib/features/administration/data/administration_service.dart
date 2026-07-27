import '../../../core/network/api_client.dart';

class AdministrationService {
  AdministrationService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Future<Map<String, dynamic>> overview() async =>
      (await _client.dio.get<Map<String, dynamic>>(
            '/administration/overview',
          )).data!['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> users(String tenantId) async => {
    'data': (await _client.dio.get<Map<String, dynamic>>(
      '/administration/tenants/$tenantId/users',
    )).data!['data'],
  };

  Future<Map<String, dynamic>> createTenant(Map<String, dynamic> data) async =>
      (await _client.dio.post<Map<String, dynamic>>(
            '/administration/tenants',
            data: data,
          )).data!['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> createSuperadmin(
    Map<String, dynamic> data,
  ) async =>
      (await _client.dio.post<Map<String, dynamic>>(
            '/administration/superadmins',
            data: data,
          )).data!['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> createUser(
    String tenantId,
    Map<String, dynamic> data,
  ) async =>
      (await _client.dio.post<Map<String, dynamic>>(
            '/administration/tenants/$tenantId/users',
            data: data,
          )).data!['data']
          as Map<String, dynamic>;

  Future<void> tenantStatus(String id, String status) async => _client.dio
      .put<void>('/administration/tenants/$id', data: {'status': status});

  Future<void> superadminStatus(String id, String status) async => _client.dio
      .put<void>('/administration/superadmins/$id', data: {'status': status});

  Future<void> userStatus(
    String tenantId,
    String userId,
    String status,
  ) async => _client.dio.put<void>(
    '/administration/tenants/$tenantId/users/$userId',
    data: {'status': status},
  );

  Future<String> resetPassword(String userId) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/users/$userId/temporary-password',
    );
    return (response.data!['data']
            as Map<String, dynamic>)['temporary_password']
        as String;
  }
}
