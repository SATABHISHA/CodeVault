import '../../../core/network/api_client.dart';

class ManagedRequestInput {
  const ManagedRequestInput({
    required this.type,
    required this.contactName,
    required this.email,
    required this.phone,
    required this.scope,
    required this.reason,
    this.notes,
    this.restorePreference,
    this.platform = 'android',
    this.deviceName = 'CodeVault Android',
  });
  final String type;
  final String contactName;
  final String email;
  final String phone;
  final List<String> scope;
  final String reason;
  final String? notes;
  final String? restorePreference;
  final String platform;
  final String deviceName;
  Map<String, Object?> toJson() => {
    'request_type': type,
    'contact_name': contactName,
    'email': email,
    'phone': phone,
    'platform': platform,
    'device_name': deviceName,
    'requested_scope': scope,
    'reason': reason,
    'notes': notes,
    if (type == 'restore') 'restore_preference': restorePreference,
  };
}

class ManagedRequestService {
  ManagedRequestService(this.client);
  final ApiClient client;
  Future<String> submit(String tenantId, ManagedRequestInput input) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/tenants/$tenantId/managed-requests',
      data: input.toJson(),
    );
    return ((response.data!['data'] as Map<String, dynamic>)['id'] as String);
  }
}
