import 'package:codevault/features/labels/data/local_part_repository.dart';
import 'package:codevault/features/labels/data/part_repository.dart';
import 'package:codevault/features/windows_desktop/data/local_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test(
    'PartRecord reads a per-part label profile and defaults legacy data',
    () {
      final profiled = PartRecord.fromJson({
        'id': 'part-1',
        'part_number': 'P-1',
        'item_name': 'Item',
        'label_profile': {'width_mm': 80, 'height_mm': 16},
      });
      expect(profiled.labelWidthMm, 80);
      expect(profiled.labelHeightMm, 16);

      final legacy = PartRecord.fromJson({
        'id': 'part-2',
        'part_number': 'P-2',
        'item_name': 'Legacy item',
      });
      expect(legacy.labelWidthMm, defaultLabelWidthMm);
      expect(legacy.labelHeightMm, defaultLabelHeightMm);
    },
  );

  test('part mutation payload normalizes label dimensions', () {
    final payload = normalizePartMutationPayload({
      'part_number': 'P-API',
      'label_profile': {'width_mm': '38', 'height_mm': 25},
    });

    expect(payload['label_profile'], {'width_mm': 38.0, 'height_mm': 25.0});
    expect(payload, isNot(contains('label_width_mm')));
    expect(payload, isNot(contains('label_height_mm')));
  });

  test('Windows Part Master saves and restores its label profile', () async {
    final database = LocalDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await database
        .into(database.companies)
        .insert(CompaniesCompanion.insert(id: 'tenant-1', name: 'Company'));
    final repository = LocalPartRepository(database);

    final created = await repository.create('tenant-1', {
      'part_number': 'P-100',
      'item_name': 'Bearing',
      'label_profile': {'width_mm': 80.0, 'height_mm': 16.0},
    });
    expect(created.labelWidthMm, 80);
    expect(created.labelHeightMm, 16);

    final setting =
        await (database.select(database.localSettings)..where(
              (row) => row.key.equals('part-label-profile:${created.id}'),
            ))
            .getSingle();
    expect(setting.value, contains('80.0'));
    expect(setting.value, contains('16.0'));

    await repository.update('tenant-1', created, {
      'label_profile': {'width_mm': 60.0, 'height_mm': 150.0},
    });
    final restored = (await repository.list('tenant-1')).single;
    expect(restored.labelWidthMm, 60);
    expect(restored.labelHeightMm, 150);
  });
}
