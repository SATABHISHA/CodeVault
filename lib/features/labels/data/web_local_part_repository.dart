import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter/foundation.dart';
import '../../sync/data/android_cache_database.dart';
import '../domain/label_field_config.dart';
import '../domain/dynamic_label_field.dart';
import 'part_repository.dart';

class WebLocalPartRepository implements PartRepository {
  WebLocalPartRepository();
  final Map<String, AndroidCacheDatabase> _databases = {};

  AndroidCacheDatabase _db(String tenantId) {
    return _databases.putIfAbsent(tenantId, () {
      if (kIsWeb) return AndroidCacheDatabase.forWeb(tenantId);
      return AndroidCacheDatabase(tenantId);
    });
  }

  PartRecord _fromRow(CachedPart row) {
    final payload = jsonDecode(row.payloadJson) as Map<String, dynamic>;
    final labelProfile = labelProfileFromDynamic(
      payload['label_profile'],
      widthMm: payload['label_width_mm'],
      heightMm: payload['label_height_mm'],
    );
    return PartRecord(
      id: row.id,
      number: payload['part_number'] as String? ?? row.id,
      name: payload['item_name'] as String? ?? '',
      model: payload['item_model'] as String? ?? '',
      drCode: payload['default_dr_code'] as String? ?? '',
      packQuantity: payload['default_pack_quantity'] as int? ?? 1,
      barcodeType: payload['barcode_type'] as String? ?? 'code128',
      version: row.serverVersion,
      labelCompanyName: payload['label_company_name'] as String? ?? '',
      labelCompanyAddress: payload['label_company_address'] as String? ?? '',
      labelFieldSettings: LabelFieldConfig.fromDynamic(
        payload['label_field_config'],
      ),
      dynamicFields: DynamicLabelField.listFromDynamic(
        payload['dynamic_label_fields'],
      ),
      scanValueSource:
          payload['scan_value_source'] as String? ?? 'encoded_text',
      labelLayout: labelLayoutFromDynamic(
        payload['label_layout'] ?? payload['label_layout_config'],
      ),
      labelWidthMm: labelProfile.widthMm,
      labelHeightMm: labelProfile.heightMm,
      codeWidthScale: normalizeLabelCodeScale(payload['code_width_scale']),
      codeHeightScale: normalizeLabelCodeScale(payload['code_height_scale']),
      stickersPerRow: normalizeStickersPerRow(payload['stickers_per_row']),
      includeBorder: normalizeIncludeBorder(payload['include_border']),
    );
  }

  @override
  Future<List<PartRecord>> list(String tenantId, {String search = ''}) async {
    final db = _db(tenantId);
    final query = db.select(db.cachedParts)
      ..where((t) => t.tenantId.equals(tenantId) & t.deleted.equals(false));

    final rows = await query.get();

    // In-memory search since data is in JSON blob
    if (search.isNotEmpty) {
      final s = search.toLowerCase();
      return rows
          .map(_fromRow)
          .where(
            (part) =>
                part.name.toLowerCase().contains(s) ||
                part.number.toLowerCase().contains(s) ||
                part.model.toLowerCase().contains(s),
          )
          .toList();
    }

    return rows.map(_fromRow).toList();
  }

  @override
  Future<PartRecord> create(String tenantId, Map<String, dynamic> data) async {
    const uuid = Uuid();
    final id = uuid.v4();
    final normalized = normalizePartMutationPayload(data);
    final payload = {
      'id': id,
      'tenant_id': tenantId,
      'part_number': normalized['part_number'],
      'item_name': normalized['item_name'],
      'item_model': normalized['item_model'],
      'default_dr_code': normalized['default_dr_code'],
      'default_pack_quantity': normalized['default_pack_quantity'],
      'barcode_type': normalized['barcode_type'],
      'label_company_name': normalized['label_company_name'],
      'label_company_address': normalized['label_company_address'],
      'label_field_config': normalized['label_field_config'],
      'dynamic_label_fields': normalized['dynamic_label_fields'],
      'scan_value_source': normalized['scan_value_source'] ?? 'encoded_text',
      'label_layout':
          normalized['label_layout'] ??
          labelLayoutToJson(labelLayoutFromDynamic(null)),
      'label_profile': labelProfileToJson(
        labelProfileFromDynamic(normalized['label_profile']),
      ),
      'code_width_scale': normalizeLabelCodeScale(
        normalized['code_width_scale'],
      ),
      'code_height_scale': normalizeLabelCodeScale(
        normalized['code_height_scale'],
      ),
      'stickers_per_row': normalizeStickersPerRow(
        normalized['stickers_per_row'],
      ),
      'include_border': normalizeIncludeBorder(normalized['include_border']),
    };

    final db = _db(tenantId);
    await db
        .into(db.cachedParts)
        .insert(
          CachedPartsCompanion.insert(
            id: id,
            tenantId: tenantId,
            payloadJson: jsonEncode(payload),
            serverVersion: 1,
            deleted: const Value(false),
            updatedAt: DateTime.now(),
          ),
        );

    final row = await (db.select(
      db.cachedParts,
    )..where((t) => t.tenantId.equals(tenantId) & t.id.equals(id))).getSingle();
    return _fromRow(row);
  }

  @override
  Future<PartRecord> update(
    String tenantId,
    PartRecord part,
    Map<String, dynamic> data,
  ) async {
    final db = _db(tenantId);
    final normalized = normalizePartMutationPayload(data);
    final existing =
        await (db.select(
              db.cachedParts,
            )..where((t) => t.tenantId.equals(tenantId) & t.id.equals(part.id)))
            .getSingle();

    final payload = jsonDecode(existing.payloadJson) as Map<String, dynamic>;
    if (normalized.containsKey('part_number')) {
      payload['part_number'] = normalized['part_number'];
    }
    if (normalized.containsKey('item_name')) {
      payload['item_name'] = normalized['item_name'];
    }
    if (normalized.containsKey('item_model')) {
      payload['item_model'] = normalized['item_model'];
    }
    if (normalized.containsKey('default_dr_code')) {
      payload['default_dr_code'] = normalized['default_dr_code'];
    }
    if (normalized.containsKey('default_pack_quantity')) {
      payload['default_pack_quantity'] = normalized['default_pack_quantity'];
    }
    if (normalized.containsKey('barcode_type')) {
      payload['barcode_type'] = normalized['barcode_type'];
    }
    if (normalized.containsKey('label_company_name')) {
      payload['label_company_name'] = normalized['label_company_name'];
    }
    if (normalized.containsKey('label_company_address')) {
      payload['label_company_address'] = normalized['label_company_address'];
    }
    if (normalized.containsKey('label_field_config')) {
      payload['label_field_config'] = normalized['label_field_config'];
    }
    if (normalized.containsKey('dynamic_label_fields')) {
      payload['dynamic_label_fields'] = normalized['dynamic_label_fields'];
    }
    if (normalized.containsKey('scan_value_source')) {
      payload['scan_value_source'] = normalized['scan_value_source'];
    }
    if (normalized.containsKey('label_layout')) {
      payload['label_layout'] = normalized['label_layout'];
      payload.remove('label_layout_config');
    }
    if (normalized.containsKey('label_profile')) {
      payload['label_profile'] = normalized['label_profile'];
      payload
        ..remove('label_width_mm')
        ..remove('label_height_mm');
    }
    if (normalized.containsKey('code_width_scale')) {
      payload['code_width_scale'] = normalized['code_width_scale'];
    }
    if (normalized.containsKey('code_height_scale')) {
      payload['code_height_scale'] = normalized['code_height_scale'];
    }
    if (normalized.containsKey('stickers_per_row')) {
      payload['stickers_per_row'] = normalized['stickers_per_row'];
    }
    if (normalized.containsKey('include_border')) {
      payload['include_border'] = normalized['include_border'];
    }

    final changed =
        await (db.update(
              db.cachedParts,
            )..where((t) => t.tenantId.equals(tenantId) & t.id.equals(part.id)))
            .write(
              CachedPartsCompanion(
                payloadJson: Value(jsonEncode(payload)),
                updatedAt: Value(DateTime.now()),
              ),
            );
    if (changed != 1) {
      throw StateError('The selected part no longer exists in this company.');
    }

    final row =
        await (db.select(
              db.cachedParts,
            )..where((t) => t.tenantId.equals(tenantId) & t.id.equals(part.id)))
            .getSingle();
    return _fromRow(row);
  }

  @override
  Future<void> delete(String tenantId, String id) async {
    final db = _db(tenantId);
    await (db.update(
      db.cachedParts,
    )..where((t) => t.tenantId.equals(tenantId) & t.id.equals(id))).write(
      CachedPartsCompanion(
        deleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
