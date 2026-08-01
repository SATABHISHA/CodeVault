import 'package:codevault/features/printers/domain/browser_printing.dart';
import 'package:codevault/shared/widgets/barcode_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PDF generator produces Code 128, QR and Data Matrix labels', () async {
    for (final symbology in ['code128', 'qr', 'data_matrix']) {
      final bytes = await const BrowserPdfGenerator().generate(
        BrowserLabelDocument(
          title: 'PART NO: 518446800118',
          content: '00518446800118NRE0261107260000165',
          widthMm: 100,
          heightMm: 30,
          symbology: symbology,
          itemName: 'ALL',
          model: 'MODEL-1',
        ),
      );
      expect(bytes, isNotEmpty, reason: symbology);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    }
  });

  test('dual-code PDF supports every configured label size', () async {
    for (final size in [
      (38.0, 25.0),
      (80.0, 16.0),
      (100.0, 30.0),
      (60.0, 150.0),
    ]) {
      final bytes = await const BrowserPdfGenerator().generate(
        BrowserLabelDocument(
          title: 'PART NO: P-1',
          content: '00P1NRE026080000001',
          widthMm: size.$1,
          heightMm: size.$2,
          symbology: 'data_matrix',
          company: 'SS ENTERPRISE',
          model: 'M26',
          partNumber: 'P-1',
          port: 'PORT 1',
          dateText: '01-08-2026',
          timeText: '13:55:40',
          dualSideCodes: true,
        ),
      );
      expect(bytes.take(4), equals('%PDF'.codeUnits), reason: '$size');
    }
  });

  testWidgets('live code preview paints every supported symbology', (
    tester,
  ) async {
    for (final symbology in CodeSymbology.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 260,
            height: 120,
            child: BarcodeView(
              data: '00518446800118NRE0261107260000165',
              symbology: symbology,
            ),
          ),
        ),
      );
      expect(find.byType(CustomPaint), findsWidgets);
    }
  });
}
