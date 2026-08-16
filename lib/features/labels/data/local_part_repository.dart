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
  static const _labelLayoutPrefix = 'part-label-layout:';
  static const _labelProfilePrefix = 'part-label-profile:';
  static const _codeSizePrefix = 'part-code-size:';
  static const _printPreferencesPrefix = 'part-print-preferences:';

  // ── helpers ──────────────────────────────────────────────────────────────

  String _configKey(String partId) => '$_labelFieldConfigPrefix$partId';
  String _dynamicFieldsKey(String partId) => '$_dynamicFieldsPrefix$partId';
  String _scanValueSourceKey(String partId) => '$_scanValueSourcePrefix$partId';
  String _labelLayoutKey(String partId) => '$_labelLayoutPrefix$partId';
  String _labelProfileKey(String partId) => '$_labelProfilePrefix$partId';
  String _codeSizeKey(String partId) => '$_codeSizePrefix$partId';
  String _printPreferencesKey(String partId) =>
      '$_printPreferencesPrefix$partId';

  PartRecord _fromRow(
    Part row, {
    String? configJson,
    String? dynamicFieldsJson,
    String? scanValueSource,
    String? labelLayoutJson,
    String? labelProfileJson,
    String? codeSizeJson,
    String? printPreferencesJson,
  }) {
    final labelProfile = labelProfileFromDynamic(labelProfileJson);
    final codeSize = labelCodeScalesFromDynamic(codeSizeJson);
    Map<String, dynamic> printPreferences = const {};
    try {
      if (printPreferencesJson != null) {
        printPreferences =
            jsonDecode(printPreferencesJson) as Map<String, dynamic>;
      }
    } catch (_) {
      // Legacy/corrupt optional preferences use backward-compatible defaults.
    }
    return PartRecord(
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
      labelLayout: labelLayoutFromDynamic(labelLayoutJson),
      labelWidthMm: labelProfile.widthMm,
      labelHeightMm: labelProfile.heightMm,
      codeWidthScale: codeSize.widthScale,
      codeHeightScale: codeSize.heightScale,
      stickersPerRow: normalizeStickersPerRow(
        printPreferences['stickers_per_row'],
      ),
      includeBorder: normalizeIncludeBorder(printPreferences['include_border']),
      serialNumber: printPreferences['serial_number'] as String? ?? '001',
      autoIncrementSerialNumber: normalizePartBool(
        printPreferences['auto_increment_serial_number'], fallback: false),
      serialNumberIncrement: normalizePositiveIncrement(
        printPreferences['serial_number_increment']),
      dualSideCodes: normalizePartBool(
        printPreferences['dual_side_codes'], fallback: true),
      autoDateTime: normalizePartBool(
        printPreferences['auto_date_time'], fallback: true),
    );
  }

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

  Future<void> _saveLabelLayout(
    String tenantId,
    String partId,
    Object? rawLayout,
  ) => _db
      .into(_db.localSettings)
      .insertOnConflictUpdate(
        LocalSettingsCompanion.insert(
          companyId: tenantId,
          key: _labelLayoutKey(partId),
          value: labelLayoutFromDynamic(rawLayout).toEncodedJson(),
        ),
      );

  Future<void> _saveLabelProfile(
    String tenantId,
    String partId,
    Object? rawProfile,
  ) => _db
      .into(_db.localSettings)
      .insertOnConflictUpdate(
        LocalSettingsCompanion.insert(
          companyId: tenantId,
          key: _labelProfileKey(partId),
          value: jsonEncode(
            labelProfileToJson(labelProfileFromDynamic(rawProfile)),
          ),
        ),
      );

  Future<void> _saveCodeSize(
    String tenantId,
    String partId, {
    required Object? widthScale,
    required Object? heightScale,
  }) => _db
      .into(_db.localSettings)
      .insertOnConflictUpdate(
        LocalSettingsCompanion.insert(
          companyId: tenantId,
          key: _codeSizeKey(partId),
          value: jsonEncode({
            'code_width_scale': normalizeLabelCodeScale(widthScale),
            'code_height_scale': normalizeLabelCodeScale(heightScale),
          }),
        ),
      );

  Future<void> _savePrintPreferences(
    String tenantId,
    String partId, {
    required Object? stickersPerRow,
    required Object? includeBorder,
    Object? serialNumber,
    Object? autoIncrementSerialNumber,
    Object? serialNumberIncrement,
    Object? dualSideCodes,
    Object? autoDateTime,
  }) => _db
      .into(_db.localSettings)
      .insertOnConflictUpdate(
        LocalSettingsCompanion.insert(
          companyId: tenantId,
          key: _printPreferencesKey(partId),
          value: jsonEncode({
            'stickers_per_row': normalizeStickersPerRow(stickersPerRow),
            'include_border': normalizeIncludeBorder(includeBorder),
            'serial_number': serialNumber is String ? serialNumber : '001',
            'auto_increment_serial_number': normalizePartBool(
              autoIncrementSerialNumber, fallback: false),
            'serial_number_increment': normalizePositiveIncrement(
              serialNumberIncrement),
            'dual_side_codes': normalizePartBool(dualSideCodes, fallback: true),
            'auto_date_time': normalizePartBool(autoDateTime, fallback: true),
          }),
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
    final labelLayouts = await _loadSettingsByPartIds(
      tenantId,
      ids,
      _labelLayoutPrefix,
    );
    final labelProfiles = await _loadSettingsByPartIds(
      tenantId,
      ids,
      _labelProfilePrefix,
    );
    final codeSizes = await _loadSettingsByPartIds(
      tenantId,
      ids,
      _codeSizePrefix,
    );
    final printPreferences = await _loadSettingsByPartIds(
      tenantId,
      ids,
      _printPreferencesPrefix,
    );
    return rows
        .map(
          (row) => _fromRow(
            row,
            configJson: configs[row.id],
            dynamicFieldsJson: dynamicFields[row.id],
            scanValueSource: scanValueSources[row.id],
            labelLayoutJson: labelLayouts[row.id],
            labelProfileJson: labelProfiles[row.id],
            codeSizeJson: codeSizes[row.id],
            printPreferencesJson: printPreferences[row.id],
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
    await _saveLabelLayout(
      tenantId,
      id,
      data['label_layout'] ?? data['label_layout_config'],
    );
    await _saveLabelProfile(tenantId, id, data['label_profile']);
    await _saveCodeSize(
      tenantId,
      id,
      widthScale: data['code_width_scale'],
      heightScale: data['code_height_scale'],
    );
    await _savePrintPreferences(
      tenantId,
      id,
      stickersPerRow: data['stickers_per_row'],
      includeBorder: data['include_border'],
      serialNumber: data['serial_number'],
      autoIncrementSerialNumber: data['auto_increment_serial_number'],
      serialNumberIncrement: data['serial_number_increment'],
      dualSideCodes: data['dual_side_codes'],
      autoDateTime: data['auto_date_time'],
    );
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
    final labelLayout =
        await (_db.select(_db.localSettings)..where(
              (t) =>
                  t.companyId.equals(tenantId) &
                  t.key.equals(_labelLayoutKey(id)),
            ))
            .getSingleOrNull();
    final labelProfile =
        await (_db.select(_db.localSettings)..where(
              (t) =>
                  t.companyId.equals(tenantId) &
                  t.key.equals(_labelProfileKey(id)),
            ))
            .getSingleOrNull();
    final codeSize =
        await (_db.select(_db.localSettings)..where(
              (t) =>
                  t.companyId.equals(tenantId) & t.key.equals(_codeSizeKey(id)),
            ))
            .getSingleOrNull();
    final printPreferences =
        await (_db.select(_db.localSettings)..where(
              (t) =>
                  t.companyId.equals(tenantId) &
                  t.key.equals(_printPreferencesKey(id)),
            ))
            .getSingleOrNull();
    return _fromRow(
      row,
      configJson: config?.value,
      dynamicFieldsJson: dynamicFields?.value,
      scanValueSource: scanValueSource?.value,
      labelLayoutJson: labelLayout?.value,
      labelProfileJson: labelProfile?.value,
      codeSizeJson: codeSize?.value,
      printPreferencesJson: printPreferences?.value,
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
    if (data.containsKey('label_layout') ||
        data.containsKey('label_layout_config')) {
      await _saveLabelLayout(
        tenantId,
        part.id,
        data['label_layout'] ?? data['label_layout_config'],
      );
    }
    if (data.containsKey('label_profile')) {
      await _saveLabelProfile(tenantId, part.id, data['label_profile']);
    }
    if (data.containsKey('code_width_scale') ||
        data.containsKey('code_height_scale')) {
      await _saveCodeSize(
        tenantId,
        part.id,
        widthScale: data['code_width_scale'] ?? part.codeWidthScale,
        heightScale: data['code_height_scale'] ?? part.codeHeightScale,
      );
    }
    if (const {
      'stickers_per_row',
      'include_border',
      'serial_number',
      'auto_increment_serial_number',
      'serial_number_increment',
      'dual_side_codes',
      'auto_date_time',
    }.any(data.containsKey)) {
      await _savePrintPreferences(
        tenantId,
        part.id,
        stickersPerRow: data['stickers_per_row'] ?? part.stickersPerRow,
        includeBorder: data['include_border'] ?? part.includeBorder,
        serialNumber: data['serial_number'] ?? part.serialNumber,
        autoIncrementSerialNumber: data['auto_increment_serial_number'] ?? part.autoIncrementSerialNumber,
        serialNumberIncrement: data['serial_number_increment'] ?? part.serialNumberIncrement,
        dualSideCodes: data['dual_side_codes'] ?? part.dualSideCodes,
        autoDateTime: data['auto_date_time'] ?? part.autoDateTime,
      );
    }
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
    final labelLayout =
        await (_db.select(_db.localSettings)..where(
              (t) =>
                  t.companyId.equals(tenantId) &
                  t.key.equals(_labelLayoutKey(part.id)),
            ))
            .getSingleOrNull();
    final labelProfile =
        await (_db.select(_db.localSettings)..where(
              (t) =>
                  t.companyId.equals(tenantId) &
                  t.key.equals(_labelProfileKey(part.id)),
            ))
            .getSingleOrNull();
    final codeSize =
        await (_db.select(_db.localSettings)..where(
              (t) =>
                  t.companyId.equals(tenantId) &
                  t.key.equals(_codeSizeKey(part.id)),
            ))
            .getSingleOrNull();
    final printPreferences =
        await (_db.select(_db.localSettings)..where(
              (t) =>
                  t.companyId.equals(tenantId) &
                  t.key.equals(_printPreferencesKey(part.id)),
            ))
            .getSingleOrNull();
    return _fromRow(
      row,
      configJson: config?.value,
      dynamicFieldsJson: dynamicFields?.value,
      scanValueSource: scanValueSource?.value,
      labelLayoutJson: labelLayout?.value,
      labelProfileJson: labelProfile?.value,
      codeSizeJson: codeSize?.value,
      printPreferencesJson: printPreferences?.value,
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
                  t.key.equals(_scanValueSourceKey(id)) |
                  t.key.equals(_labelLayoutKey(id)) |
                  t.key.equals(_labelProfileKey(id)) |
                  t.key.equals(_codeSizeKey(id)) |
                  t.key.equals(_printPreferencesKey(id))),
        ))
        .go();
  }
}
