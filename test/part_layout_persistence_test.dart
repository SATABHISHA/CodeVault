import 'dart:convert';
import 'dart:io';

import 'package:codevault/features/labels/data/local_part_repository.dart';
import 'package:codevault/features/labels/data/part_repository.dart';
import 'package:codevault/features/labels/domain/label_layout.dart';
import 'package:codevault/features/sync/application/web_local_export_service.dart';
import 'package:codevault/features/sync/data/android_cache_database.dart';
import 'package:codevault/features/windows_desktop/application/local_backup_service.dart';
import 'package:codevault/features/windows_desktop/data/local_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('PartRecord accepts API layout objects and legacy missing layouts', () {
    final record = PartRecord.fromJson({
      'id': 'part-1',
      'part_number': 'P-1',
      'item_name': 'Item',
      'label_layout': {
        'singleCompanyName': {'x': 0.31, 'y': 0.27, 'rotation': 0.4},
      },
    });
    final position = record.labelLayout.positionFor(
      LabelLayoutElement.singleCompanyName,
    );
    expect(position.x, 0.31);
    expect(position.y, 0.27);
    expect(position.rotation, 0.4);

    final legacy = PartRecord.fromJson({
      'id': 'part-2',
      'part_number': 'P-2',
      'item_name': 'Legacy item',
    });
    expect(
      legacy.labelLayout.positionFor(LabelLayoutElement.singleCompanyName).x,
      LabelLayout.defaults()
          .positionFor(LabelLayoutElement.singleCompanyName)
          .x,
    );
  });

  test('cloud mutation payload serializes the layout as a JSON object', () {
    final layout = LabelLayout.defaults().copyWithElement(
      LabelLayoutElement.dualCompanyName,
      const LabelLayoutPosition(x: 0.48, y: 0.16, rotation: 0.3),
    );
    final payload = normalizePartMutationPayload({
      'part_number': 'P-API',
      'label_layout_config': layout.toEncodedJson(),
    });

    expect(payload, isNot(contains('label_layout_config')));
    expect(payload['label_layout'], isA<Map<String, dynamic>>());
    final restored = labelLayoutFromDynamic(payload['label_layout']);
    final position = restored.positionFor(LabelLayoutElement.dualCompanyName);
    expect(position.x, 0.48);
    expect(position.rotation, 0.3);
  });

  test('Windows Part Master persists its layout in local settings', () async {
    final database = LocalDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await _insertCompany(database, 'tenant-1');
    final repository = LocalPartRepository(database);
    final created = await repository.create('tenant-1', {
      'part_number': 'P-100',
      'item_name': 'Bearing',
      'label_layout': {
        'dualPartNumber': {'x': 0.51, 'y': 0.43, 'rotation': 0.2},
      },
    });

    expect(
      created.labelLayout.positionFor(LabelLayoutElement.dualPartNumber).x,
      0.51,
    );
    final setting =
        await (database.select(database.localSettings)..where(
              (row) => row.key.equals('part-label-layout:${created.id}'),
            ))
            .getSingle();
    expect(setting.value, contains('dualPartNumber'));

    final updatedLayout = created.labelLayout.copyWithElement(
      LabelLayoutElement.dualPartNumber,
      const LabelLayoutPosition(x: 0.77, y: 0.12, rotation: 1.1),
    );
    await repository.update('tenant-1', created, {
      'label_layout': updatedLayout.toJsonObject(),
    });
    final restored = (await repository.list('tenant-1')).single;
    final restoredPosition = restored.labelLayout.positionFor(
      LabelLayoutElement.dualPartNumber,
    );
    expect(restoredPosition.x, 0.77);
    expect(restoredPosition.rotation, 1.1);
  });

  test('Windows merge backup restores per-part layouts', () async {
    final directory = await Directory.systemTemp.createTemp(
      'codevault-part-layout-backup-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final sourceFile = File('${directory.path}/source.sqlite');
    final source = LocalDatabase.forTesting(NativeDatabase(sourceFile));
    await _insertCompany(source, 'tenant-1');
    await LocalPartRepository(source).create('tenant-1', {
      'part_number': 'P-200',
      'item_name': 'Seal',
      'label_profile': {'width_mm': 80.0, 'height_mm': 16.0},
      'label_layout': {
        'singlePartNumber': {'x': 0.63, 'y': 0.19, 'rotation': 0.5},
      },
    });
    await source.close();

    final backup = File('${directory.path}/part-layout.cvbackup');
    const backupService = LocalBackupService();
    await backupService.create(
      companyId: 'tenant-1',
      database: sourceFile,
      destination: backup,
    );

    final target = LocalDatabase.forTesting(NativeDatabase.memory());
    addTearDown(target.close);
    await _insertCompany(target, 'tenant-1');
    final report = await backupService.merge(source: backup, target: target);
    expect(report['parts'], 1);
    expect(report['local_settings'], greaterThanOrEqualTo(1));
    final restored = (await LocalPartRepository(
      target,
    ).list('tenant-1')).single;
    final position = restored.labelLayout.positionFor(
      LabelLayoutElement.singlePartNumber,
    );
    expect(position.x, 0.63);
    expect(position.rotation, 0.5);
    expect(restored.labelWidthMm, 80);
    expect(restored.labelHeightMm, 16);
  });

  test(
    'web cache import backfills a missing layout without replacing part data',
    () async {
      final source = AndroidCacheDatabase.forTesting(NativeDatabase.memory());
      final target = AndroidCacheDatabase.forTesting(NativeDatabase.memory());
      addTearDown(source.close);
      addTearDown(target.close);
      final updatedAt = DateTime.utc(2026, 8, 12);
      await source
          .into(source.cachedParts)
          .insert(
            CachedPartsCompanion.insert(
              id: 'part-1',
              tenantId: 'tenant-1',
              payloadJson: jsonEncode({
                'part_number': 'P-300',
                'item_name': 'Imported name',
                'label_layout': {
                  'singleItemName': {'x': 0.71, 'y': 0.34, 'rotation': 0.9},
                },
                'label_profile': {'width_mm': 80.0, 'height_mm': 16.0},
                'code_width_scale': 1.35,
                'code_height_scale': 0.75,
                'stickers_per_row': 5,
                'include_border': false,
              }),
              serverVersion: 2,
              updatedAt: updatedAt,
            ),
          );
      await source
          .into(source.cachedParts)
          .insert(
            CachedPartsCompanion.insert(
              id: 'part-2',
              tenantId: 'tenant-1',
              payloadJson: jsonEncode({
                'part_number': 'P-301',
                'item_name': 'Imported second part',
                'label_layout': {
                  'singleItemName': {'x': 0.82, 'y': 0.44, 'rotation': 1.2},
                },
                'label_profile': {'width_mm': 60.0, 'height_mm': 150.0},
                'code_width_scale': 1.8,
                'code_height_scale': 1.7,
                'stickers_per_row': 4,
                'include_border': false,
              }),
              serverVersion: 2,
              updatedAt: updatedAt,
            ),
          );
      await target
          .into(target.cachedParts)
          .insert(
            CachedPartsCompanion.insert(
              id: 'part-1',
              tenantId: 'tenant-1',
              payloadJson: jsonEncode({
                'part_number': 'P-300',
                'item_name': 'Keep target name',
                'label_layout': null,
              }),
              serverVersion: 3,
              updatedAt: updatedAt,
            ),
          );
      await target
          .into(target.cachedParts)
          .insert(
            CachedPartsCompanion.insert(
              id: 'part-2',
              tenantId: 'tenant-1',
              payloadJson: jsonEncode({
                'part_number': 'P-301',
                'item_name': 'Keep second target',
                'label_layout': {
                  'singleItemName': {'x': 0.22, 'y': 0.24, 'rotation': 0.1},
                },
                'label_profile': {'width_mm': 38.0, 'height_mm': 25.0},
                'code_width_scale': 0.8,
                'code_height_scale': 0.9,
                'stickers_per_row': 2,
                'include_border': true,
              }),
              serverVersion: 4,
              updatedAt: updatedAt,
            ),
          );

      final bytes = await WebLocalExportService(
        source,
      ).export('tenant-1', 4, ownerUserId: 'user-1');
      await WebLocalExportService(target).import(
        bytes,
        tenantId: 'tenant-1',
        currentUserId: 'user-1',
        serverGeneration: 4,
      );

      final row = await (target.select(
        target.cachedParts,
      )..where((candidate) => candidate.id.equals('part-1'))).getSingle();
      final payload = jsonDecode(row.payloadJson) as Map<String, dynamic>;
      expect(payload['item_name'], 'Keep target name');
      final restored = labelLayoutFromDynamic(payload['label_layout']);
      final position = restored.positionFor(LabelLayoutElement.singleItemName);
      expect(position.x, 0.71);
      expect(position.rotation, 0.9);
      expect(payload['label_profile'], {'width_mm': 80.0, 'height_mm': 16.0});
      expect(payload['code_width_scale'], 1.35);
      expect(payload['code_height_scale'], 0.75);
      expect(payload['stickers_per_row'], 5);
      expect(payload['include_border'], isFalse);

      final secondRow = await (target.select(
        target.cachedParts,
      )..where((candidate) => candidate.id.equals('part-2'))).getSingle();
      final secondPayload =
          jsonDecode(secondRow.payloadJson) as Map<String, dynamic>;
      expect(secondPayload['item_name'], 'Keep second target');
      final preserved = labelLayoutFromDynamic(secondPayload['label_layout']);
      final preservedPosition = preserved.positionFor(
        LabelLayoutElement.singleItemName,
      );
      expect(preservedPosition.x, 0.22);
      expect(preservedPosition.rotation, 0.1);
      expect(secondPayload['label_profile'], {
        'width_mm': 38.0,
        'height_mm': 25.0,
      });
      expect(secondPayload['code_width_scale'], 0.8);
      expect(secondPayload['code_height_scale'], 0.9);
      expect(secondPayload['stickers_per_row'], 2);
      expect(secondPayload['include_border'], isTrue);
    },
  );
}

Future<void> _insertCompany(LocalDatabase database, String id) => database
    .into(database.companies)
    .insert(CompaniesCompanion.insert(id: id, name: 'Test company'));
