import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../domain/label_code_size.dart';
import '../domain/label_field_config.dart';
import '../domain/dynamic_label_field.dart';
import '../domain/label_layout.dart';

export '../domain/label_code_size.dart';

const double defaultLabelWidthMm = 100.0;
const double defaultLabelHeightMm = 30.0;
const double maxLabelWidthMm = 210.0;
const double maxLabelHeightMm = 297.0;

int? normalizeStickersPerRow(Object? value) {
  final parsed = switch (value) {
    int number => number,
    num number => number.toInt(),
    String text => int.tryParse(text.trim()),
    _ => null,
  };
  return parsed != null && parsed >= 1 && parsed <= 999 ? parsed : null;
}

bool normalizeIncludeBorder(Object? value) => switch (value) {
  bool enabled => enabled,
  num number => number != 0,
  String text => !const {
    'false',
    '0',
    'off',
    'no',
  }.contains(text.trim().toLowerCase()),
  _ => true,
};

bool normalizePartBool(Object? value, {required bool fallback}) => switch (value) {
  bool enabled => enabled,
  num number => number != 0,
  String text when const {'true', '1', 'on', 'yes'}.contains(text.trim().toLowerCase()) => true,
  String text when const {'false', '0', 'off', 'no'}.contains(text.trim().toLowerCase()) => false,
  _ => fallback,
};

int normalizePositiveIncrement(Object? value) {
  final parsed = value is num ? value.toInt() : int.tryParse('$value'.trim());
  return parsed != null && parsed > 0 ? parsed : 1;
}

typedef LabelProfileDimensions = ({double widthMm, double heightMm});

double? _validLabelDimension(Object? value, double maximum) {
  final parsed = switch (value) {
    num number => number.toDouble(),
    String text => double.tryParse(text.trim()),
    _ => null,
  };
  if (parsed == null || !parsed.isFinite || parsed <= 0 || parsed > maximum) {
    return null;
  }
  return parsed;
}

/// Reads the per-Part Master sticker dimensions while keeping legacy records
/// (which did not contain a profile) on the historical 100 x 30 mm default.
LabelProfileDimensions labelProfileFromDynamic(
  Object? value, {
  Object? widthMm,
  Object? heightMm,
}) {
  Object? decoded = value;
  try {
    if (value is String && value.trim().isNotEmpty) decoded = jsonDecode(value);
  } on FormatException {
    decoded = null;
  }
  final map = decoded is Map ? decoded : const <Object?, Object?>{};
  final width = _validLabelDimension(
    map['width_mm'] ?? map['widthMm'] ?? widthMm,
    maxLabelWidthMm,
  );
  final height = _validLabelDimension(
    map['height_mm'] ?? map['heightMm'] ?? heightMm,
    maxLabelHeightMm,
  );
  if (width == null || height == null) {
    return (widthMm: defaultLabelWidthMm, heightMm: defaultLabelHeightMm);
  }
  return (widthMm: width, heightMm: height);
}

Map<String, double> labelProfileToJson(LabelProfileDimensions profile) => {
  'width_mm': profile.widthMm,
  'height_mm': profile.heightMm,
};

({double widthScale, double heightScale}) labelCodeScalesFromDynamic(
  Object? value,
) {
  Object? decoded = value;
  try {
    if (value is String && value.trim().isNotEmpty) {
      decoded = jsonDecode(value);
    }
  } on FormatException {
    decoded = null;
  }
  if (decoded is! Map) {
    return (
      widthScale: defaultLabelCodeScale,
      heightScale: defaultLabelCodeScale,
    );
  }
  return (
    widthScale: normalizeLabelCodeScale(decoded['code_width_scale']),
    heightScale: normalizeLabelCodeScale(decoded['code_height_scale']),
  );
}

/// Accepts both the object returned by the API and the encoded value stored in
/// local settings. Malformed or legacy records safely fall back to the default
/// layout instead of making the whole Part Master list unreadable.
LabelLayout labelLayoutFromDynamic(Object? value) {
  if (value is LabelLayout) return value;
  try {
    if (value is String) return LabelLayout.fromEncodedJson(value);
    if (value is Map) return LabelLayout.fromEncodedJson(jsonEncode(value));
  } on FormatException {
    // A corrupt optional layout must not prevent the part itself from loading.
  }
  return LabelLayout.defaults();
}

extension LabelLayoutJsonObject on LabelLayout {
  /// JSON-ready representation for Part Master API/cache payloads.
  Map<String, dynamic> toJsonObject() =>
      jsonDecode(toEncodedJson()) as Map<String, dynamic>;
}

Map<String, dynamic> labelLayoutToJson(LabelLayout layout) =>
    layout.toJsonObject();

Map<String, dynamic> normalizePartMutationPayload(Map<String, dynamic> data) {
  final normalized = <String, dynamic>{...data};
  if (data.containsKey('label_profile') ||
      data.containsKey('label_width_mm') ||
      data.containsKey('label_height_mm')) {
    normalized['label_profile'] = labelProfileToJson(
      labelProfileFromDynamic(
        data['label_profile'],
        widthMm: data['label_width_mm'],
        heightMm: data['label_height_mm'],
      ),
    );
    normalized
      ..remove('label_width_mm')
      ..remove('label_height_mm');
  }
  if (data.containsKey('code_width_scale')) {
    normalized['code_width_scale'] = normalizeLabelCodeScale(
      data['code_width_scale'],
    );
  }
  if (data.containsKey('code_height_scale')) {
    normalized['code_height_scale'] = normalizeLabelCodeScale(
      data['code_height_scale'],
    );
  }
  if (data.containsKey('stickers_per_row')) {
    normalized['stickers_per_row'] = normalizeStickersPerRow(
      data['stickers_per_row'],
    );
  }
  if (data.containsKey('include_border')) {
    normalized['include_border'] = normalizeIncludeBorder(
      data['include_border'],
    );
  }
  if (data.containsKey('auto_increment_serial_number')) {
    normalized['auto_increment_serial_number'] = normalizePartBool(
      data['auto_increment_serial_number'],
      fallback: false,
    );
  }
  if (data.containsKey('serial_number_increment')) {
    normalized['serial_number_increment'] = normalizePositiveIncrement(
      data['serial_number_increment'],
    );
  }
  if (data.containsKey('dual_side_codes')) {
    normalized['dual_side_codes'] = normalizePartBool(
      data['dual_side_codes'],
      fallback: true,
    );
  }
  if (data.containsKey('auto_date_time')) {
    normalized['auto_date_time'] = normalizePartBool(
      data['auto_date_time'],
      fallback: true,
    );
  }
  if (data.containsKey('label_layout') ||
      data.containsKey('label_layout_config')) {
    final raw = data['label_layout'] ?? data['label_layout_config'];
    normalized['label_layout'] = labelLayoutToJson(labelLayoutFromDynamic(raw));
    normalized.remove('label_layout_config');
  }
  return normalized;
}

class PartRecord {
  PartRecord({
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
    Map<LabelFieldKey, LabelFieldSetting>? labelFieldSettings,
    List<DynamicLabelField>? dynamicFields,
    this.scanValueSource = 'encoded_text',
    LabelLayout? labelLayout,
    double labelWidthMm = defaultLabelWidthMm,
    double labelHeightMm = defaultLabelHeightMm,
    double codeWidthScale = defaultLabelCodeScale,
    double codeHeightScale = defaultLabelCodeScale,
    int? stickersPerRow,
    this.includeBorder = true,
    this.serialNumber = '001',
    this.autoIncrementSerialNumber = false,
    this.serialNumberIncrement = 1,
    this.dualSideCodes = true,
    this.autoDateTime = true,
  }) : labelFieldSettings = LabelFieldConfig.mergeWithDefaults(
         labelFieldSettings,
       ),
       dynamicFields = List.unmodifiable(dynamicFields ?? const []),
       labelLayout = labelLayout ?? LabelLayout.defaults(),
       labelWidthMm =
           _validLabelDimension(labelWidthMm, maxLabelWidthMm) ??
           defaultLabelWidthMm,
       labelHeightMm =
           _validLabelDimension(labelHeightMm, maxLabelHeightMm) ??
           defaultLabelHeightMm,
       codeWidthScale = normalizeLabelCodeScale(codeWidthScale),
       codeHeightScale = normalizeLabelCodeScale(codeHeightScale),
       stickersPerRow = normalizeStickersPerRow(stickersPerRow);

  factory PartRecord.fromJson(Map<String, dynamic> json) {
    final dynamic configValue =
        json['label_field_config'] ?? json['label_config'];
    final dynamic layoutValue =
        json['label_layout'] ?? json['label_layout_config'];
    final labelProfile = labelProfileFromDynamic(
      json['label_profile'],
      widthMm: json['label_width_mm'],
      heightMm: json['label_height_mm'],
    );
    return PartRecord(
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
      labelFieldSettings: LabelFieldConfig.fromDynamic(configValue),
      dynamicFields: DynamicLabelField.listFromDynamic(
        json['dynamic_label_fields'],
      ),
      scanValueSource: json['scan_value_source'] as String? ?? 'encoded_text',
      labelLayout: labelLayoutFromDynamic(layoutValue),
      labelWidthMm: labelProfile.widthMm,
      labelHeightMm: labelProfile.heightMm,
      codeWidthScale: normalizeLabelCodeScale(json['code_width_scale']),
      codeHeightScale: normalizeLabelCodeScale(json['code_height_scale']),
      stickersPerRow: normalizeStickersPerRow(json['stickers_per_row']),
      includeBorder: normalizeIncludeBorder(json['include_border']),
      serialNumber: json['serial_number'] as String? ?? '001',
      autoIncrementSerialNumber: normalizePartBool(
        json['auto_increment_serial_number'], fallback: false),
      serialNumberIncrement: normalizePositiveIncrement(
        json['serial_number_increment']),
      dualSideCodes: normalizePartBool(json['dual_side_codes'], fallback: true),
      autoDateTime: normalizePartBool(json['auto_date_time'], fallback: true),
    );
  }

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
  final Map<LabelFieldKey, LabelFieldSetting> labelFieldSettings;
  final List<DynamicLabelField> dynamicFields;
  final String scanValueSource;
  final LabelLayout labelLayout;
  final double labelWidthMm;
  final double labelHeightMm;
  final double codeWidthScale;
  final double codeHeightScale;
  final int? stickersPerRow;
  final bool includeBorder;
  final String serialNumber;
  final bool autoIncrementSerialNumber;
  final int serialNumberIncrement;
  final bool dualSideCodes;
  final bool autoDateTime;
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
    final payload = normalizePartMutationPayload(data);
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/tenants/$tenantId/parts',
      data: payload,
    );
    return PartRecord.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<PartRecord> update(
    String tenantId,
    PartRecord part,
    Map<String, dynamic> data,
  ) async {
    final payload = normalizePartMutationPayload(data);
    final response = await _client.dio.put<Map<String, dynamic>>(
      '/tenants/$tenantId/parts/${part.id}',
      data: {...payload, 'version': part.version},
    );
    return PartRecord.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> delete(String tenantId, String id) =>
      _client.dio.delete<void>('/tenants/$tenantId/parts/$id').then((_) {});
}
