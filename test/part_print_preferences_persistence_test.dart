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
      'serial_number': '0098',
      'auto_increment_serial_number': true,
      'serial_number_increment': 2,
      'dual_side_codes': false,
      'auto_date_time': false,
    });
    expect(configured.stickersPerRow, 5);
    expect(configured.includeBorder, isFalse);
    expect(configured.serialNumber, '0098');
    expect(configured.autoIncrementSerialNumber, isTrue);
    expect(configured.serialNumberIncrement, 2);
    expect(configured.dualSideCodes, isFalse);
    expect(configured.autoDateTime, isFalse);

    final legacy = PartRecord.fromJson({
      'id': 'part-2',
      'part_number': 'P-2',
      'item_name': 'Legacy',
    });
    expect(legacy.stickersPerRow, null);
    expect(legacy.includeBorder, isTrue);
    expect(legacy.serialNumber, '001');
    expect(legacy.autoIncrementSerialNumber, isFalse);
    expect(legacy.dualSideCodes, isTrue);
    expect(legacy.autoDateTime, isTrue);
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
      'serial_number': '0017',
      'auto_increment_serial_number': true,
      'serial_number_increment': 3,
      'dual_side_codes': false,
      'auto_date_time': false,
    });
    expect(created.stickersPerRow, 5);
    expect(created.includeBorder, isFalse);
    expect(created.serialNumber, '0017');
    expect(created.autoIncrementSerialNumber, isTrue);
    expect(created.serialNumberIncrement, 3);
    expect(created.dualSideCodes, isFalse);
    expect(created.autoDateTime, isFalse);

    final setting =
        await (database.select(database.localSettings)..where(
              (row) => row.key.equals('part-print-preferences:${created.id}'),
            ))
            .getSingle();
    expect(jsonDecode(setting.value), {
      'stickers_per_row': 5,
      'include_border': false,
      'serial_number': '0017',
      'auto_increment_serial_number': true,
      'serial_number_increment': 3,
      'dual_side_codes': false,
      'auto_date_time': false,
    });

    await repository.update('tenant-1', created, {
      'stickers_per_row': 3,
      'include_border': true,
      'serial_number': '0042',
      'auto_increment_serial_number': false,
      'serial_number_increment': 5,
      'dual_side_codes': true,
      'auto_date_time': true,
    });
    final restored = (await repository.list('tenant-1')).single;
    expect(restored.stickersPerRow, 3);
    expect(restored.includeBorder, isTrue);
    expect(restored.serialNumber, '0042');
    expect(restored.autoIncrementSerialNumber, isFalse);
    expect(restored.serialNumberIncrement, 5);
    expect(restored.dualSideCodes, isTrue);
    expect(restored.autoDateTime, isTrue);
  });
}
