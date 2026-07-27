import '../../../core/network/api_client.dart';

class BillingService {
  BillingService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Future<List<dynamic>> tenants() async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/administration/overview',
    );
    return List<dynamic>.from(
      (response.data!['data'] as Map<String, dynamic>)['tenants'] as List? ??
          const [],
    );
  }

  Future<List<dynamic>> payments(String tenant) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/tenants/$tenant/payments',
    );
    final page = response.data!['data'] as Map<String, dynamic>;
    return List<dynamic>.from(page['data'] as List? ?? const []);
  }

  Future<void> recordPayment(String tenant, Map<String, dynamic> data) async =>
      _client.dio.post<void>('/tenants/$tenant/payments', data: data);

  Future<Map<String, dynamic>?> smtp() async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/platform/smtp',
    );
    return response.data!['data'] as Map<String, dynamic>?;
  }

  Future<void> saveSmtp(Map<String, dynamic> data) async =>
      _client.dio.put<void>('/platform/smtp', data: data);

  Future<void> testSmtp(String recipient) async => _client.dio.post<void>(
    '/platform/smtp/test',
    data: {'recipient': recipient},
  );
}
