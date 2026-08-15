import 'dart:convert';

import 'package:codevault/features/labels/data/local_part_repository.dart';
import 'package:codevault/features/labels/data/part_repository.dart';
import 'package:codevault/features/windows_desktop/data/local_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('PartRecord restores print preferences and keeps legacy defaults', () {
    final configured = PartRecord.fromJson({
      'id': 'part-1',
      'part_number': 'P-1',
      'item_name': 'Configured',
      'stickers_per_row': 5,
      'include_border': false,
    });
    expect(configured.stickersPerRow, 5);
    expect(configured.includeBorder, isFalse);

    final legacy = PartRecord.fromJson({
      'id': 'part-2',
      'part_number': 'P-2',
      'item_name': 'Legacy',
    });
    expect(legacy.stickersPerRow, null);
    expect(legacy.includeBorder, isTrue);
  });

  test('mutation payload validates print preferences', () {
    final payload = normalizePartMutationPayload({
      'stickers_per_row': '7',
      'include_border': 'false',
    });
    expect(payload['stickers_per_row'], 7);
    expect(payload['include_border'], isFalse);
  });

  test('Windows Part Master saves and restores print preferences', () async {
    final database = LocalDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await database
        .into(database.companies)
        .insert(CompaniesCompanion.insert(id: 'tenant-1', name: 'Company'));
    final repository = LocalPartRepository(database);
    final created = await repository.create('tenant-1', {
      'part_number': 'P-100',
      'item_name': 'Bearing',
      'stickers_per_row': 5,
      'include_border': false,
    });
    expect(created.stickersPerRow, 5);
    expect(created.includeBorder, isFalse);

    final setting =
        await (database.select(database.localSettings)..where(
              (row) => row.key.equals('part-print-preferences:${created.id}'),
            ))
            .getSingle();
    expect(jsonDecode(setting.value), {
      'stickers_per_row': 5,
      'include_border': false,
    });

    await repository.update('tenant-1', created, {
      'stickers_per_row': 3,
      'include_border': true,
    });
    final restored = (await repository.list('tenant-1')).single;
    expect(restored.stickersPerRow, 3);
    expect(restored.includeBorder, isTrue);
  });
}
