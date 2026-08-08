import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/label_field_config.dart';
import '../domain/dynamic_label_field.dart';
import '../../windows_desktop/data/local_database.dart';
import 'part_repository.dart';

/// A [PartRepository] implementation that reads and writes to the local
/// SQLite/Drift database. Used on Windows (offline-first) only.
class LocalPartRepository implements PartRepository {
  LocalPartRepository(this._db);
  final LocalDatabase _db;
  static const _labelFieldConfigPrefix = 'part-label-config:';
  static const _dynamicFieldsPrefix = 'part-dynamic-fields:';
  static const _scanValueSourcePrefix = 'part-scan-source:';

  // ── helpers ──────────────────────────────────────────────────────────────

  String _configKey(String partId) => '$_labelFieldConfigPrefix$partId';
  String _dynamicFieldsKey(String partId) => '$_dynamicFieldsPrefix$partId';
  String _scanValueSourceKey(String partId) => '$_scanValueSourcePrefix$partId';

  PartRecord _fromRow(
    Part row, {
    String? configJson,
    String? dynamicFieldsJson,
    String? scanValueSource,
  }) => PartRecord(
    id: row.id,
    number: row.description ?? row.id, // description stores the part number
    name: row.item,
    model: row.model ?? '',
    drCode: row.defaultDrCode ?? '',
    packQuantity: row.defaultPackQuantity,
    barcodeType: row.barcodeType,
    version: 1,
    labelCompanyName: row.labelCompanyName ?? '',
    labelCompanyAddress: row.labelCompanyAddress ?? '',
    labelFieldSettings: LabelFieldConfig.fromEncodedJson(configJson),
    dynamicFields: DynamicLabelField.listFromDynamic(dynamicFieldsJson),
    scanValueSource: scanValueSource ?? 'encoded_text',
  );

  Future<Map<String, String>> _loadSettingsByPartIds(
    String tenantId,
    Iterable<String> partIds,
    String keyPrefix,
  ) async {
    final scoped = partIds.toSet();
    if (scoped.isEmpty) return const {};
    final rows =
        await (_db.select(_db.localSettings)..where(
              (t) => t.companyId.equals(tenantId) & t.key.like('$keyPrefix%'),
            ))
            .get();
    final result = <String, String>{};
    for (final row in rows) {
      if (!row.key.startsWith(keyPrefix)) continue;
      final partId = row.key.substring(keyPrefix.length);
      if (scoped.contains(partId)) {
        result[partId] = row.value;
      }
    }
    return result;
  }

  Future<void> _saveLabelFieldConfig(
    String tenantId,
    String partId,
    Object? rawConfig,
  ) {
    final encoded = LabelFieldConfig.toEncodedJson(
      LabelFieldConfig.fromDynamic(rawConfig),
    );
    return _db
        .into(_db.localSettings)
        .insertOnConflictUpdate(
          LocalSettingsCompanion.insert(
            companyId: tenantId,
            key: _configKey(partId),
            value: encoded,
          ),
        );
  }

  Future<void> _saveDynamicFields(
    String tenantId,
    String partId,
    Object? rawFields,
  ) => _db
      .into(_db.localSettings)
      .insertOnConflictUpdate(
        LocalSettingsCompanion.insert(
          companyId: tenantId,
          key: _dynamicFieldsKey(partId),
          value: jsonEncode(
            DynamicLabelField.listToJson(
              DynamicLabelField.listFromDynamic(rawFields),
            ),
          ),
        ),
      );

  Future<void> _saveScanValueSource(
    String tenantId,
    String partId,
    Object? rawValue,
  ) => _db
      .into(_db.localSettings)
      .insertOnConflictUpdate(
        LocalSettingsCompanion.insert(
          companyId: tenantId,
          key: _scanValueSourceKey(partId),
          value: rawValue is String && rawValue.isNotEmpty
              ? rawValue
              : 'encoded_text',
        ),
      );

  // ── interface ─────────────────────────────────────────────────────────────

  @override
  Future<List<PartRecord>> list(String tenantId, {String search = ''}) async {
    final query = _db.select(_db.parts)
      ..where((t) => t.companyId.equals(tenantId) & t.active.equals(true));

    if (search.isNotEmpty) {
      query.where((t) => t.item.like('%$search%') | t.model.like('%$search%'));
    }

    final rows = await query.get();
    final ids = rows.map((row) => row.id);
    final configs = await _loadSettingsByPartIds(
      tenantId,
      ids,
      _labelFieldConfigPrefix,
    );
    final dynamicFields = await _loadSettingsByPartIds(
      tenantId,
      ids,
      _dynamicFieldsPrefix,
    );
    final scanValueSources = await _loadSettingsByPartIds(
      tenantId,
      ids,
      _scanValueSourcePrefix,
    );
    return rows
        .map(
          (row) => _fromRow(
            row,
            configJson: configs[row.id],
            dynamicFieldsJson: dynamicFields[row.id],
            scanValueSource: scanValueSources[row.id],
          ),
        )
        .toList();
  }

  @override
  Future<PartRecord> create(String tenantId, Map<String, dynamic> data) async {
    const uuid = Uuid();
    final id = uuid.v4();
    await _db
        .into(_db.parts)
        .insert(
          PartsCompanion.insert(
            id: id,
            companyId: tenantId,
            item: data['item_name'] as String? ?? '',
            model: Value(data['item_model'] as String?),
            description: Value(data['part_number'] as String?),
            defaultDrCode: Value(data['default_dr_code'] as String?),
            defaultPackQuantity: Value(
              data['default_pack_quantity'] as int? ?? 1,
            ),
            barcodeType: Value(data['barcode_type'] as String? ?? 'code128'),
            labelCompanyName: Value(data['label_company_name'] as String?),
            labelCompanyAddress: Value(
              data['label_company_address'] as String?,
            ),
            active: const Value(true),
          ),
        );
    await _saveLabelFieldConfig(tenantId, id, data['label_field_config']);
    await _saveDynamicFields(tenantId, id, data['dynamic_label_fields']);
    await _saveScanValueSource(tenantId, id, data['scan_value_source']);
    final row = await (_db.select(
      _db.parts,
    )..where((t) => t.id.equals(id))).getSingle();
    final config =
        await (_db.select(_db.localSettings)..where(
              (t) =>
                  t.companyId.equals(tenantId) & t.key.equals(_configKey(id)),
            ))
            .getSingleOrNull();
    final dynamicFields =
        await (_db.select(_db.localSettings)..where(
              (t) =>
                  t.companyId.equals(tenantId) &
                  t.key.equals(_dynamicFieldsKey(id)),
            ))
            .getSingleOrNull();
    final scanValueSource =
        await (_db.select(_db.localSettings)..where(
              (t) =>
                  t.companyId.equals(tenantId) &
                  t.key.equals(_scanValueSourceKey(id)),
            ))
            .getSingleOrNull();
    return _fromRow(
      row,
      configJson: config?.value,
      dynamicFieldsJson: dynamicFields?.value,
      scanValueSource: scanValueSource?.value,
    );
  }

  @override
  Future<PartRecord> update(
    String tenantId,
    PartRecord part,
    Map<String, dynamic> data,
  ) async {
    final changed =
        await (_db.update(_db.parts)..where(
              (t) => t.companyId.equals(tenantId) & t.id.equals(part.id),
            ))
            .write(
              PartsCompanion(
                item: Value(data['item_name'] as String? ?? part.name),
                model: Value(data['item_model'] as String?),
                description: Value(data['part_number'] as String?),
                defaultDrCode: Value(data['default_dr_code'] as String?),
                defaultPackQuantity: Value(
                  data['default_pack_quantity'] as int? ?? part.packQuantity,
                ),
                barcodeType: Value(
                  data['barcode_type'] as String? ?? part.barcodeType,
                ),
                labelCompanyName: Value(data['label_company_name'] as String?),
                labelCompanyAddress: Value(
                  data['label_company_address'] as String?,
                ),
                updatedAt: Value(DateTime.now()),
              ),
            );
    if (changed != 1) {
      throw StateError('The selected part no longer exists in this company.');
    }
    await _saveLabelFieldConfig(tenantId, part.id, data['label_field_config']);
    await _saveDynamicFields(tenantId, part.id, data['dynamic_label_fields']);
    await _saveScanValueSource(tenantId, part.id, data['scan_value_source']);
    final row =
        await (_db.select(_db.parts)..where(
              (t) => t.companyId.equals(tenantId) & t.id.equals(part.id),
            ))
            .getSingle();
    final config =
        await (_db.select(_db.localSettings)..where(
              (t) =>
                  t.companyId.equals(tenantId) &
                  t.key.equals(_configKey(part.id)),
            ))
            .getSingleOrNull();
    final dynamicFields =
        await (_db.select(_db.localSettings)..where(
              (t) =>
                  t.companyId.equals(tenantId) &
                  t.key.equals(_dynamicFieldsKey(part.id)),
            ))
            .getSingleOrNull();
    final scanValueSource =
        await (_db.select(_db.localSettings)..where(
              (t) =>
                  t.companyId.equals(tenantId) &
                  t.key.equals(_scanValueSourceKey(part.id)),
            ))
            .getSingleOrNull();
    return _fromRow(
      row,
      configJson: config?.value,
      dynamicFieldsJson: dynamicFields?.value,
      scanValueSource: scanValueSource?.value,
    );
  }

  @override
  Future<void> delete(String tenantId, String id) async {
    await (_db.delete(_db.parts)..where((t) => t.id.equals(id))).go();
    await (_db.delete(_db.localSettings)..where(
          (t) =>
              t.companyId.equals(tenantId) &
              (t.key.equals(_configKey(id)) |
                  t.key.equals(_dynamicFieldsKey(id)) |
                  t.key.equals(_scanValueSourceKey(id))),
        ))
        .go();
  }
}
