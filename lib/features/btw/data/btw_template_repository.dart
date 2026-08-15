import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/platform/platform_capabilities.dart';
import '../../labels/data/part_repository.dart';
import '../../labels/domain/dynamic_label_field.dart';
import '../../labels/domain/label_field_config.dart';
import '../../sync/data/android_cache_database.dart';
import '../../windows_desktop/data/local_database.dart';

class BtwTemplateRepository implements PartRepository {
  BtwTemplateRepository();

  static const _prefix = 'btw-template:';
  final Map<String, AndroidCacheDatabase> _cacheDatabases = {};

  bool get _windows => PlatformCapabilities.current().isWindows;

  AndroidCacheDatabase _cache(String tenantId) => _cacheDatabases.putIfAbsent(
    tenantId,
    () => kIsWeb
        ? AndroidCacheDatabase.forWeb(tenantId)
        : AndroidCacheDatabase(tenantId),
  );

  @override
  Future<List<PartRecord>> list(String tenantId, {String search = ''}) async {
    final records = <PartRecord>[];
    if (_windows) {
      final database = LocalDatabase(tenantId);
      try {
        final rows =
            await (database.select(database.localSettings)..where(
                  (row) =>
                      row.companyId.equals(tenantId) &
                      row.key.like('$_prefix%'),
                ))
                .get();
        for (final row in rows) {
          records.add(_decode(row.value));
        }
      } finally {
        await database.close();
      }
    } else {
      final database = _cache(tenantId);
      final rows =
          await (database.select(database.localLabelPreviews)..where(
                (row) =>
                    row.tenantId.equals(tenantId) & row.id.like('$_prefix%'),
              ))
              .get();
      for (final row in rows) {
        records.add(_decode(row.definitionJson));
      }
    }
    final term = search.trim().toLowerCase();
    records.sort((a, b) => a.number.compareTo(b.number));
    if (term.isEmpty) return records;
    return records
        .where(
          (record) =>
              record.number.toLowerCase().contains(term) ||
              record.name.toLowerCase().contains(term) ||
              record.model.toLowerCase().contains(term),
        )
        .toList();
  }

  @override
  Future<PartRecord> create(String tenantId, Map<String, dynamic> data) async {
    final record = _fromMutation(const Uuid().v4(), 1, data);
    await _write(tenantId, record);
    return record;
  }

  @override
  Future<PartRecord> update(
    String tenantId,
    PartRecord part,
    Map<String, dynamic> data,
  ) async {
    final record = _fromMutation(part.id, part.version + 1, data);
    await _write(tenantId, record);
    return record;
  }

  @override
  Future<void> delete(String tenantId, String id) async {
    if (_windows) {
      final database = LocalDatabase(tenantId);
      try {
        await (database.delete(database.localSettings)..where(
              (row) =>
                  row.companyId.equals(tenantId) &
                  row.key.equals('$_prefix$id'),
            ))
            .go();
      } finally {
        await database.close();
      }
      return;
    }
    final database = _cache(tenantId);
    await (database.delete(database.localLabelPreviews)..where(
          (row) => row.tenantId.equals(tenantId) & row.id.equals('$_prefix$id'),
        ))
        .go();
  }

  Future<void> _write(String tenantId, PartRecord record) async {
    final encoded = jsonEncode(_toJson(record));
    if (_windows) {
      final database = LocalDatabase(tenantId);
      try {
        await database
            .into(database.localSettings)
            .insertOnConflictUpdate(
              LocalSettingsCompanion.insert(
                companyId: tenantId,
                key: '$_prefix${record.id}',
                value: encoded,
              ),
            );
      } finally {
        await database.close();
      }
      return;
    }
    final database = _cache(tenantId);
    await database
        .into(database.localLabelPreviews)
        .insertOnConflictUpdate(
          LocalLabelPreviewsCompanion.insert(
            id: '$_prefix${record.id}',
            tenantId: tenantId,
            definitionJson: encoded,
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  PartRecord _fromMutation(String id, int version, Map<String, dynamic> data) =>
      PartRecord.fromJson({
        'id': id,
        'part_number': data['part_number'] as String? ?? id,
        'item_name': data['item_name'] as String? ?? 'Imported BTW label',
        'item_model': data['item_model'] as String? ?? '',
        'default_dr_code': data['default_dr_code'] as String? ?? '',
        'default_pack_quantity': data['default_pack_quantity'] as int? ?? 1,
        'barcode_type': data['barcode_type'] as String? ?? 'data_matrix',
        'version': version,
        'label_company_name': data['label_company_name'] as String? ?? '',
        'label_company_address': data['label_company_address'] as String? ?? '',
        'label_field_config': data['label_field_config'],
        'dynamic_label_fields': data['dynamic_label_fields'],
        'scan_value_source':
            data['scan_value_source'] as String? ?? 'encoded_text',
        'label_layout': data['label_layout'],
        'label_profile': data['label_profile'],
        'code_width_scale': data['code_width_scale'],
        'code_height_scale': data['code_height_scale'],
        'stickers_per_row': data['stickers_per_row'],
        'include_border': data['include_border'],
      });

  PartRecord _decode(String encoded) =>
      PartRecord.fromJson(jsonDecode(encoded) as Map<String, dynamic>);

  Map<String, dynamic> _toJson(PartRecord record) => {
    'id': record.id,
    'part_number': record.number,
    'item_name': record.name,
    'item_model': record.model,
    'default_dr_code': record.drCode,
    'default_pack_quantity': record.packQuantity,
    'barcode_type': record.barcodeType,
    'version': record.version,
    'label_company_name': record.labelCompanyName,
    'label_company_address': record.labelCompanyAddress,
    'label_field_config': LabelFieldConfig.toJsonObject(
      record.labelFieldSettings,
    ),
    'dynamic_label_fields': DynamicLabelField.listToJson(record.dynamicFields),
    'scan_value_source': record.scanValueSource,
    'label_layout': labelLayoutToJson(record.labelLayout),
    'label_profile': labelProfileToJson((
      widthMm: record.labelWidthMm,
      heightMm: record.labelHeightMm,
    )),
    'code_width_scale': record.codeWidthScale,
    'code_height_scale': record.codeHeightScale,
    'stickers_per_row': record.stickersPerRow,
    'include_border': record.includeBorder,
  };

  Future<List<Map<String, dynamic>>> exportRecords(String tenantId) async => [
    for (final record in await list(tenantId)) _toJson(record),
  ];

  Future<int> mergeRecords(
    String tenantId,
    Iterable<Map<String, dynamic>> records,
  ) async {
    final existing = {for (final item in await list(tenantId)) item.id: item};
    var added = 0;
    for (final raw in records) {
      final incoming = PartRecord.fromJson(raw);
      if (existing.containsKey(incoming.id)) continue;
      await _write(tenantId, incoming);
      existing[incoming.id] = incoming;
      added++;
    }
    return added;
  }
}
