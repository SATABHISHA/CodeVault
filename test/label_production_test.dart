import 'package:codevault/features/printers/domain/browser_printing.dart';
import 'package:codevault/features/labels/domain/dynamic_label_field.dart';
import 'package:codevault/features/labels/domain/label_field_config.dart';
import 'package:codevault/features/labels/domain/label_layout.dart';
import 'package:codevault/shared/widgets/barcode_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';

void main() {
  test('deep black weights use stroked PDF glyphs', () {
    expect(
      pdfTextRenderingMode(LabelFontWeight.black),
      PdfTextRenderingMode.fill,
    );
    expect(
      pdfTextRenderingMode(LabelFontWeight.extraBlack),
      PdfTextRenderingMode.fillAndStroke,
    );
    expect(
      pdfTextRenderingMode(LabelFontWeight.ultraBlack),
      PdfTextRenderingMode.fillAndStroke,
    );
    expect(pdfTextStrokeWidth(LabelFontWeight.black), isNull);
    expect(pdfTextStrokeWidth(LabelFontWeight.extraBlack), 0.12);
    expect(pdfTextStrokeWidth(LabelFontWeight.ultraBlack), 0.22);
  });

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

  test('serial field settings remain compatible with saved part masters', () {
    final legacy = LabelFieldConfig.fromJsonObject({
      'partNumber': {'visible': true, 'font_size': 12},
    });
    expect(legacy[LabelFieldKey.serialNumber]!.visible, isTrue);
    expect(legacy[LabelFieldKey.serialNumber]!.fontSize, 10);

    final settings = LabelFieldConfig.defaults();
    settings[LabelFieldKey.serialNumber] = const LabelFieldSetting(
      visible: false,
      fontSize: 15,
    );
    final restored = LabelFieldConfig.fromEncodedJson(
      LabelFieldConfig.toEncodedJson(settings),
    );
    expect(restored[LabelFieldKey.serialNumber]!.visible, isFalse);
    expect(restored[LabelFieldKey.serialNumber]!.fontSize, 15);
  });

  test('serial field positions round-trip and extend legacy layouts', () {
    final legacy = LabelLayout.fromEncodedJson(
      '{"singlePartNumber":{"x":0.4,"y":0.2,"rotation":0.0}}',
    );
    expect(legacy.positions[LabelLayoutElement.singleSerialNumber], isNotNull);
    expect(legacy.positions[LabelLayoutElement.dualSerialNumber], isNotNull);

    final customized = legacy
        .copyWithElement(
          LabelLayoutElement.singleSerialNumber,
          const LabelLayoutPosition(x: 1.7, y: .44, rotation: .8),
        )
        .copyWithElement(
          LabelLayoutElement.dualSerialNumber,
          const LabelLayoutPosition(x: .38, y: .71, rotation: -.5),
        );
    final restored = LabelLayout.fromEncodedJson(customized.toEncodedJson());
    expect(restored.positionFor(LabelLayoutElement.singleSerialNumber).x, 1.7);
    expect(
      restored.positionFor(LabelLayoutElement.singleSerialNumber).rotation,
      .8,
    );
    expect(restored.positionFor(LabelLayoutElement.dualSerialNumber).y, .71);
    expect(
      restored.positionFor(LabelLayoutElement.dualSerialNumber).rotation,
      -.5,
    );
  });

  test('PDF supports hiding the serial-number label', () async {
    final settings = LabelFieldConfig.defaults();
    settings[LabelFieldKey.serialNumber] = const LabelFieldSetting(
      visible: false,
      fontSize: 10,
    );
    final bytes = await const BrowserPdfGenerator().generate(
      BrowserLabelDocument(
        title: 'PART NO: P-1',
        content: 'P-1-001',
        widthMm: 100,
        heightMm: 30,
        symbology: 'data_matrix',
        partNumber: 'P-1',
        serialNumber: '001',
        dualSideCodes: true,
        fieldSettings: settings,
      ),
    );
    expect(bytes.take(4), equals('%PDF'.codeUnits));
  });

  test('dynamic label fields round-trip and render in the PDF', () async {
    const fields = [
      DynamicLabelField(
        id: 'batch',
        label: 'Batch',
        value: 'B-2608',
        fontSize: 12,
        x: .62,
        y: .35,
        rotation: .75,
      ),
      DynamicLabelField(
        id: 'hidden',
        label: 'Internal',
        value: 'SECRET',
        visible: false,
      ),
    ];
    final restored = DynamicLabelField.listFromDynamic(
      DynamicLabelField.listToJson(fields),
    );
    expect(restored, hasLength(2));
    expect(restored.first.label, 'Batch');
    expect(restored.first.fontSize, 12);
    expect(restored.first.x, .62);
    expect(restored.first.y, .35);
    expect(restored.first.rotation, .75);
    expect(restored.last.visible, isFalse);

    final bytes = await const BrowserPdfGenerator().generate(
      const BrowserLabelDocument(
        title: 'PART NO: P-1',
        content: 'P-1-B-2608',
        widthMm: 100,
        heightMm: 30,
        symbology: 'data_matrix',
        dualSideCodes: true,
        dynamicFields: fields,
        previewCanvasWidth: 600,
        previewCanvasHeight: 180,
        resolvedLayoutRects: {
          LabelLayoutElement.dualLeftCode: LabelLayoutRect(
            left: .02,
            top: .2,
            width: .16,
            height: .52,
          ),
          LabelLayoutElement.dualCompanyName: LabelLayoutRect(
            left: .35,
            top: .04,
            width: .3,
            height: .08,
          ),
        },
        resolvedDynamicRects: {
          'batch': LabelLayoutRect(left: .7, top: .3, width: .25, height: .08),
        },
      ),
    );
    expect(bytes.take(4), equals('%PDF'.codeUnits));
  });

  test(
    'PDF renders independent date/time and field typography controls',
    () async {
      final settings = LabelFieldConfig.defaults();
      settings[LabelFieldKey.partNumber] = const LabelFieldSetting(
        visible: true,
        fontSize: 60,
        showCaption: false,
        fontStyle: LabelFontStyle.italic,
        fontWeight: LabelFontWeight.regular,
      );
      settings[LabelFieldKey.date] = const LabelFieldSetting(
        visible: true,
        fontSize: 18,
        showCaption: false,
        fontStyle: LabelFontStyle.italic,
        fontWeight: LabelFontWeight.medium,
      );
      settings[LabelFieldKey.time] = const LabelFieldSetting(
        visible: true,
        fontSize: 16,
        showCaption: true,
        fontWeight: LabelFontWeight.black,
      );

      for (final dualSideCodes in [false, true]) {
        final bytes = await const BrowserPdfGenerator().generate(
          BrowserLabelDocument(
            title: 'PART NO: P-1',
            content: 'P-1-001',
            widthMm: 100,
            heightMm: 30,
            symbology: 'data_matrix',
            partNumber: 'P-1',
            model: 'M-1',
            port: 'PORT 1',
            dateText: '12-08-2026',
            timeText: '21:30:00',
            dualSideCodes: dualSideCodes,
            fieldSettings: settings,
            dynamicFields: const [
              DynamicLabelField(
                id: 'batch',
                label: 'Batch',
                value: 'B-1',
                fontSize: 60,
                showCaption: false,
                fontStyle: LabelFontStyle.italic,
                fontWeight: LabelFontWeight.semiBold,
              ),
            ],
          ),
        );
        expect(bytes.take(4), equals('%PDF'.codeUnits));
      }
    },
  );

  test('layout positions preserve extended horizontal dragging', () {
    const position = LabelLayoutPosition(x: 1.75, y: .5, rotation: 1.2);
    expect(position.clamp().x, 1.75);
    expect(position.clamp().y, .5);
    expect(position.clamp().rotation, 1.2);

    const rotatedEdge = LabelLayoutPosition(x: -.12, y: -.08, rotation: 1.57);
    expect(rotatedEdge.clamp().x, -.12);
    expect(rotatedEdge.clamp().y, -.08);
  });

  test('PDF rotation preserves the live preview direction', () {
    expect(pdfRotationFromPreview(1.2), -1.2);
    expect(pdfRotationFromPreview(-.75), .75);
    expect(pdfRotationFromPreview(0), 0);
  });

  test('part and serial values increment once per pack label', () {
    expect(incrementLabelNumber('001', 2), '003');
    expect(incrementLabelNumber('PART-009', 2), 'PART-011');
    expect(incrementLabelNumber('NO-NUMBER', 2), 'NO-NUMBER');

    const document = BrowserLabelDocument(
      title: 'PART NO: 009',
      content: 'original-encoded-text',
      widthMm: 100,
      heightMm: 30,
      partNumber: '009',
      serialNumber: '001',
      scanValueSource: 'encoded_text',
      encodedDrCode: 'NR',
      encodedYearMonth: '2608',
      autoIncrementPartNumber: true,
      partNumberIncrement: 2,
      autoIncrementSerialNumber: true,
      serialNumberIncrement: 5,
    );

    expect(document.stickerValuesAt(0).partNumber, '009');
    expect(document.stickerValuesAt(0).serialNumber, '001');
    expect(document.stickerValuesAt(0).content, 'original-encoded-text');
    expect(document.stickerValuesAt(2).partNumber, '013');
    expect(document.stickerValuesAt(2).serialNumber, '011');
    expect(document.stickerValuesAt(2).content, '00013NRE26080000011');
  });

  test('disabled increments preserve the exact encoded content', () {
    const document = BrowserLabelDocument(
      title: 'PART NO: 009',
      content: '  custom encoded value  ',
      widthMm: 100,
      heightMm: 30,
      partNumber: '009',
      serialNumber: '001',
      scanValueSource: 'encoded_text',
      encodedDrCode: 'NR',
      encodedYearMonth: '2608',
    );

    expect(document.stickerValuesAt(4).partNumber, '009');
    expect(document.stickerValuesAt(4).serialNumber, '001');
    expect(document.stickerValuesAt(4).content, '  custom encoded value  ');
  });

  test('new QR text combines part, DR, model, MMYY and serial', () {
    const document = BrowserLabelDocument(
      title: 'Part',
      content: '00PN10NRMX0826001',
      widthMm: 100,
      heightMm: 30,
      partNumber: 'PN10',
      serialNumber: '001',
      scanValueSource: 'new_encoded_qrcode_text',
      encodedDrCode: 'NR',
      encodedItemModel: 'MX',
      encodedYearMonth: '2608',
      autoIncrementSerialNumber: true,
      serialNumberIncrement: 2,
    );

    expect(document.stickerValuesAt(0).content, '00PN10NRMX0826001');
    expect(document.stickerValuesAt(2).content, '00PN10NRMX0826005');
  });

  test('selected part or serial scan source changes on every label', () {
    const partDocument = BrowserLabelDocument(
      title: 'PART NO: P-007',
      content: 'P-007',
      widthMm: 100,
      heightMm: 30,
      partNumber: 'P-007',
      serialNumber: '001',
      scanValueSource: 'part_number',
      autoIncrementPartNumber: true,
      partNumberIncrement: 3,
    );
    const serialDocument = BrowserLabelDocument(
      title: 'PART NO: P-007',
      content: '001',
      widthMm: 100,
      heightMm: 30,
      partNumber: 'P-007',
      serialNumber: '001',
      scanValueSource: 'serial_number',
      autoIncrementSerialNumber: true,
      serialNumberIncrement: 2,
    );

    expect(partDocument.stickerValuesAt(2).content, 'P-013');
    expect(serialDocument.stickerValuesAt(2).content, '005');
  });

  test('PDF generator renders incremented pack labels', () async {
    final bytes = await const BrowserPdfGenerator().generate(
      const BrowserLabelDocument(
        title: 'PART NO: 100',
        content: '00100NRE26080000001',
        widthMm: 100,
        heightMm: 30,
        symbology: 'data_matrix',
        partNumber: '100',
        serialNumber: '001',
        packQty: 3,
        stickersPerRow: 2,
        scanValueSource: 'encoded_text',
        encodedDrCode: 'NR',
        encodedYearMonth: '2608',
        autoIncrementPartNumber: true,
        autoIncrementSerialNumber: true,
      ),
    );

    expect(bytes.take(4), equals('%PDF'.codeUnits));
  });

  test('native PDF honors printer margins without scaling labels', () async {
    final bytes = await const BrowserPdfGenerator().generate(
      const BrowserLabelDocument(
        title: 'PART NO: P-1',
        content: 'P-1',
        widthMm: 100,
        heightMm: 30,
        packQty: 2,
        stickersPerRow: 2,
      ),
      pageFormat: const PdfPageFormat(
        210 * PdfPageFormat.mm,
        297 * PdfPageFormat.mm,
        marginAll: 3 * PdfPageFormat.mm,
      ),
    );
    expect(bytes.take(4), equals('%PDF'.codeUnits));
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
