import '../../../core/network/api_client.dart';

class PartRecord {
  const PartRecord({
    required this.id,
    required this.number,
    required this.name,
    required this.model,
    required this.drCode,
    required this.packQuantity,
    required this.barcodeType,
    required this.version,
    this.labelCompanyName = '',
    this.labelCompanyAddress = '',
  });

  factory PartRecord.fromJson(Map<String, dynamic> json) => PartRecord(
    id: json['id'] as String,
    number: json['part_number'] as String,
    name: json['item_name'] as String,
    model: json['item_model'] as String? ?? '',
    drCode: json['default_dr_code'] as String? ?? '',
    packQuantity: json['default_pack_quantity'] as int? ?? 1,
    barcodeType: json['barcode_type'] as String? ?? 'code128',
    version: json['version'] as int? ?? 1,
    labelCompanyName:
        json['label_company_name'] as String? ??
        json['company_name'] as String? ??
        '',
    labelCompanyAddress:
        json['label_company_address'] as String? ??
        json['company_address'] as String? ??
        '',
  );

  final String id;
  final String number;
  final String name;
  final String model;
  final String drCode;
  final int packQuantity;
  final String barcodeType;
  final int version;
  final String labelCompanyName;
  final String labelCompanyAddress;
}

/// Abstract interface — implemented by [CloudPartRepository] (web/mobile) and
/// [LocalPartRepository] (Windows offline).
abstract interface class PartRepository {
  Future<List<PartRecord>> list(String tenantId, {String search = ''});
  Future<PartRecord> create(String tenantId, Map<String, dynamic> data);
  Future<PartRecord> update(
    String tenantId,
    PartRecord part,
    Map<String, dynamic> data,
  );
  Future<void> delete(String tenantId, String id);
}

/// Cloud (Laravel API) implementation. Used on Web and Mobile.
class CloudPartRepository implements PartRepository {
  CloudPartRepository({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  @override
  Future<List<PartRecord>> list(String tenantId, {String search = ''}) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/tenants/$tenantId/parts',
      queryParameters: {'search': search, 'per_page': 100},
    );
    final payload = response.data!['data'] as Map<String, dynamic>;
    return (payload['data'] as List<dynamic>)
        .map((item) => PartRecord.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PartRecord> create(String tenantId, Map<String, dynamic> data) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/tenants/$tenantId/parts',
      data: data,
    );
    return PartRecord.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<PartRecord> update(
    String tenantId,
    PartRecord part,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.dio.put<Map<String, dynamic>>(
      '/tenants/$tenantId/parts/${part.id}',
      data: {...data, 'version': part.version},
    );
    return PartRecord.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> delete(String tenantId, String id) =>
      _client.dio.delete<void>('/tenants/$tenantId/parts/$id').then((_) {});
}
