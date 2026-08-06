import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter/foundation.dart';
import '../../sync/data/android_cache_database.dart';
import '../domain/label_field_config.dart';
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
    final payload = {
      'id': id,
      'tenant_id': tenantId,
      'part_number': data['part_number'],
      'item_name': data['item_name'],
      'item_model': data['item_model'],
      'default_dr_code': data['default_dr_code'],
      'default_pack_quantity': data['default_pack_quantity'],
      'barcode_type': data['barcode_type'],
      'label_company_name': data['label_company_name'],
      'label_company_address': data['label_company_address'],
      'label_field_config': data['label_field_config'],
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
    final existing =
        await (db.select(
              db.cachedParts,
            )..where((t) => t.tenantId.equals(tenantId) & t.id.equals(part.id)))
            .getSingle();

    final payload = jsonDecode(existing.payloadJson) as Map<String, dynamic>;
    if (data.containsKey('part_number')) {
      payload['part_number'] = data['part_number'];
    }
    if (data.containsKey('item_name')) {
      payload['item_name'] = data['item_name'];
    }
    if (data.containsKey('item_model')) {
      payload['item_model'] = data['item_model'];
    }
    if (data.containsKey('default_dr_code')) {
      payload['default_dr_code'] = data['default_dr_code'];
    }
    if (data.containsKey('default_pack_quantity')) {
      payload['default_pack_quantity'] = data['default_pack_quantity'];
    }
    if (data.containsKey('barcode_type')) {
      payload['barcode_type'] = data['barcode_type'];
    }
    if (data.containsKey('label_company_name')) {
      payload['label_company_name'] = data['label_company_name'];
    }
    if (data.containsKey('label_company_address')) {
      payload['label_company_address'] = data['label_company_address'];
    }
    if (data.containsKey('label_field_config')) {
      payload['label_field_config'] = data['label_field_config'];
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
