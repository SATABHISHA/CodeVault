import 'package:codevault/features/labels/data/local_part_repository.dart';
import 'package:codevault/features/labels/data/part_repository.dart';
import 'package:codevault/features/labels/domain/label_code_size.dart';
import 'package:codevault/features/printers/domain/browser_printing.dart';
import 'package:codevault/features/windows_desktop/data/local_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('legacy and malformed Part Master code sizes resolve safely', () {
    final legacy = PartRecord.fromJson({
      'id': 'legacy',
      'part_number': 'P-1',
      'item_name': 'Legacy part',
    });
    expect(legacy.codeWidthScale, defaultLabelCodeScale);
    expect(legacy.codeHeightScale, defaultLabelCodeScale);

    final restored = PartRecord.fromJson({
      'id': 'sized',
      'part_number': 'P-2',
      'item_name': 'Sized part',
      'code_width_scale': '1.75',
      'code_height_scale': 0.1,
    });
    expect(restored.codeWidthScale, 1.75);
    expect(restored.codeHeightScale, minLabelCodeScale);
    expect(normalizeLabelCodeScale(double.nan), defaultLabelCodeScale);
    expect(normalizeLabelCodeScale(99), maxLabelCodeScale);
  });

  test(
    'Part Master mutation payload normalizes independent code dimensions',
    () {
      final payload = normalizePartMutationPayload({
        'part_number': 'P-API',
        'code_width_scale': '0.5',
        'code_height_scale': 3,
      });

      expect(payload['code_width_scale'], 0.5);
      expect(payload['code_height_scale'], maxLabelCodeScale);
    },
  );

  test('Windows Part Master persists and updates code dimensions', () async {
    final database = LocalDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await database
        .into(database.companies)
        .insert(CompaniesCompanion.insert(id: 'tenant-1', name: 'Company'));
    final repository = LocalPartRepository(database);

    final created = await repository.create('tenant-1', {
      'part_number': 'P-100',
      'item_name': 'Bearing',
      'code_width_scale': 1.4,
      'code_height_scale': 0.6,
    });
    expect(created.codeWidthScale, 1.4);
    expect(created.codeHeightScale, 0.6);

    final setting =
        await (database.select(database.localSettings)
              ..where((row) => row.key.equals('part-code-size:${created.id}')))
            .getSingle();
    expect(setting.value, contains('"code_width_scale":1.4'));

    await repository.update('tenant-1', created, {'code_width_scale': 0.4});
    final restored = (await repository.list('tenant-1')).single;
    expect(restored.codeWidthScale, 0.4);
    expect(restored.codeHeightScale, 0.6);
  });

  test('PDF accepts dynamic width and height for every code type', () async {
    expect(clampLabelCodeDimension(base: 90, scale: 2, maximum: 100), 100);
    expect(clampLabelCodeDimension(base: 40, scale: 0.25, maximum: 100), 10);
    expect(clampLabelCodeDimension(base: 40, scale: 2, maximum: 35), 35);

    for (final symbology in ['code128', 'qr', 'data_matrix']) {
      final bytes = await const BrowserPdfGenerator().generate(
        BrowserLabelDocument(
          title: 'PART NO: P-1',
          content: 'P-1-001',
          widthMm: 100,
          heightMm: 30,
          symbology: symbology,
          codeWidthScale: 0.25,
          codeHeightScale: 2,
        ),
      );
      expect(bytes.take(4), equals('%PDF'.codeUnits), reason: symbology);
    }

    final dualBytes = await const BrowserPdfGenerator().generate(
      const BrowserLabelDocument(
        title: 'PART NO: P-2',
        content: 'P-2-001',
        widthMm: 100,
        heightMm: 30,
        symbology: 'data_matrix',
        dualSideCodes: true,
        codeWidthScale: 1.8,
        codeHeightScale: 0.5,
      ),
    );
    expect(dualBytes.take(4), equals('%PDF'.codeUnits));
  });
}
