import '../../../core/network/api_client.dart';

class PlatformProtectionService {
  PlatformProtectionService({ApiClient? client})
    : _client = client ?? ApiClient();
  final ApiClient _client;

  Future<List<dynamic>> requests() async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/platform/managed-requests',
    );
    final page = response.data!['data'] as Map<String, dynamic>;
    return List<dynamic>.from(page['data'] as List? ?? const []);
  }

  Future<List<dynamic>> packages() async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/platform/cloud/backups',
    );
    final page = response.data!['data'] as Map<String, dynamic>;
    return List<dynamic>.from(page['data'] as List? ?? const []);
  }

  Future<void> execute(Map<String, dynamic> request) async {
    await _client.dio.post<void>(
      '/tenants/${request['tenant_id']}/managed-requests/${request['id']}/execute',
    );
  }

  Future<void> resolveTicket(Map<String, dynamic> request) async {
    await _client.dio.put<void>(
      '/tenants/${request['tenant_id']}/managed-requests/${request['id']}/status',
      data: {'status': 'completed', 'note': 'Resolved by platform owner.'},
    );
  }

  Future<void> createBackup(Map<String, dynamic> request) async {
    await execute(request);
    await _client.dio.post<void>(
      '/tenants/${request['tenant_id']}/cloud/backups',
      data: {
        'scope': ['full_tenant_operational_dataset'],
        'support_request_id': request['id'],
        'client_sync_confirmed': true,
      },
    );
  }

  Future<void> restoreMerge(Map<String, dynamic> package) async {
    await _client.dio.post<void>(
      '/tenants/${package['tenant_id']}/cloud/backups/${package['id']}/restore',
      data: {
        'mode': 'merge',
        'scope': ['full_tenant_operational_dataset'],
        'reason': 'Platform owner approved client restore request.',
      },
    );
  }

  Future<void> restoreReplace(
    Map<String, dynamic> package, {
    required String password,
    required String companyName,
    required String reason,
  }) async {
    await _client.dio.post<void>(
      '/tenants/${package['tenant_id']}/cloud/backups/${package['id']}/restore',
      data: {
        'mode': 'replace',
        'scope': ['full_tenant_operational_dataset'],
        'reason': reason,
        'password': password,
        'company_confirmation': companyName,
        'final_confirmation': true,
      },
    );
  }

  Future<void> deletePackage(String id) async {
    await _client.dio.delete<void>(
      '/platform/cloud/backups/$id',
      data: {
        'confirmation': 'DELETE BACKUP',
        'reason': 'Client restore completed and retained local copy confirmed.',
      },
    );
  }
}
