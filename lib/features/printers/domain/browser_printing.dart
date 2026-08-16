import 'dart:typed_data';
import 'dart:math' as math;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:barcode/barcode.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../labels/domain/label_field_config.dart';
import '../../labels/domain/label_code_size.dart';
import '../../labels/domain/dynamic_label_field.dart';
import '../../labels/domain/label_layout.dart';
import '../../labels/domain/label_typography.dart';

/// Flutter's preview canvas has a downward-positive Y axis, while PDF uses an
/// upward-positive Y axis. Negating the angle preserves the visual direction.
double pdfRotationFromPreview(double previewRotation) => -previewRotation;

double clampLabelCodeDimension({
  required double base,
  required double scale,
  required double maximum,
}) {
  if (!base.isFinite || !maximum.isFinite || base <= 0 || maximum <= 0) {
    return 0;
  }
  final minimum = math.min(2.0, maximum);
  return (base * normalizeLabelCodeScale(scale))
      .clamp(minimum, maximum)
      .toDouble();
}

/// Increments the last numeric segment while preserving its minimum width.
/// Examples: `001` + 2 -> `003`, `PART-009` + 2 -> `PART-011`.
String incrementLabelNumber(String value, int increment) {
  if (increment == 0) return value;
  final matches = RegExp(r'\d+').allMatches(value).toList();
  if (matches.isEmpty) return value;
  final match = matches.last;
  final digits = match.group(0)!;
  final next = BigInt.parse(digits) + BigInt.from(increment);
  if (next.isNegative) return value;
  final replacement = next.toString().padLeft(digits.length, '0');
  return value.replaceRange(match.start, match.end, replacement);
}

class BrowserLabelDocument {
  const BrowserLabelDocument({
    required this.title,
    required this.content,
    required this.widthMm,
    required this.heightMm,
    this.symbology = 'code128',
    this.company = '',
    this.companyAddress = '',
    this.itemName = '',
    this.model = '',
    this.partNumber = '',
    this.serialNumber = '',
    this.port = '',
    this.dateText = '',
    this.timeText = '',
    this.dualSideCodes = false,
    this.packQty = 1,
    this.stickersPerRow = 1,
    this.includeBorder = true,
    this.layout,
    this.fieldSettings,
    this.dynamicFields = const [],
    this.resolvedLayoutRects = const {},
    this.resolvedDynamicRects = const {},
    this.previewCanvasHeight,
    this.scanValueSource = 'encoded_text',
    this.encodedDrCode = '',
    this.encodedYearMonth,
    this.encodedItemModel = '',
    this.autoIncrementPartNumber = false,
    this.partNumberIncrement = 1,
    this.autoIncrementSerialNumber = false,
    this.serialNumberIncrement = 1,
    this.codeWidthScale = defaultLabelCodeScale,
    this.codeHeightScale = defaultLabelCodeScale,
  });
  final String title;
  final String content;
  final double widthMm;
  final double heightMm;
  final String symbology;
  final String company;
  final String companyAddress;
  final String itemName;
  final String model;
  final String partNumber;
  final String serialNumber;
  final String port;
  final String dateText;
  final String timeText;
  final bool dualSideCodes;
  final int packQty;
  final int stickersPerRow;
  final bool includeBorder;
  final LabelLayout? layout;
  final Map<LabelFieldKey, LabelFieldSetting>? fieldSettings;
  final List<DynamicLabelField> dynamicFields;
  final Map<LabelLayoutElement, LabelLayoutRect> resolvedLayoutRects;
  final Map<String, LabelLayoutRect> resolvedDynamicRects;
  final double? previewCanvasHeight;
  final String scanValueSource;
  final String encodedDrCode;
  final String? encodedYearMonth;
  final String encodedItemModel;
  final bool autoIncrementPartNumber;
  final int partNumberIncrement;
  final bool autoIncrementSerialNumber;
  final int serialNumberIncrement;
  final double codeWidthScale;
  final double codeHeightScale;

  ({String partNumber, String serialNumber, String content}) stickerValuesAt(
    int index,
  ) {
    final safeIndex = index < 0 ? 0 : index;
    if (safeIndex == 0) {
      return (
        partNumber: partNumber,
        serialNumber: serialNumber,
        content: content,
      );
    }
    final resolvedPartNumber = autoIncrementPartNumber
        ? incrementLabelNumber(partNumber, partNumberIncrement * safeIndex)
        : partNumber;
    final resolvedSerialNumber = autoIncrementSerialNumber
        ? incrementLabelNumber(serialNumber, serialNumberIncrement * safeIndex)
        : serialNumber;
    final partChanged = resolvedPartNumber != partNumber;
    final serialChanged = resolvedSerialNumber != serialNumber;
    final resolvedContent = switch (scanValueSource) {
      'part_number' when partChanged => resolvedPartNumber,
      'serial_number' when serialChanged => resolvedSerialNumber,
      'encoded_text'
          when encodedYearMonth != null && (partChanged || serialChanged) =>
        '00$resolvedPartNumber${encodedDrCode}E$encodedYearMonth${resolvedSerialNumber.padLeft(7, '0')}',
      'new_encoded_qrcode_text'
          when encodedYearMonth != null && (partChanged || serialChanged) =>
        '00$resolvedPartNumber$encodedDrCode$encodedItemModel${encodedYearMonth!.substring(2)}${encodedYearMonth!.substring(0, 2)}$resolvedSerialNumber',
      _ => content,
    };
    return (
      partNumber: resolvedPartNumber,
      serialNumber: resolvedSerialNumber,
      content: resolvedContent,
    );
  }
}

class BrowserPdfGenerator {
  const BrowserPdfGenerator();

  // Label Studio font sizes are Flutter logical pixels. Using those values as
  // PDF points makes the printed text roughly twice as large as the preview
  // and causes independently positioned rows to overlap. This conversion is
  // shared by every platform because they all print this document.
  Future<Uint8List> generate(
    BrowserLabelDocument label, {
    PdfPageFormat? pageFormat,
  }) async {
    final document = pw.Document();
    final labelFont = pw.Font.ttf(
      await rootBundle.load(LabelTypography.fontAsset),
    );
    final resolvedLayout = label.layout ?? LabelLayout.defaults();
    final twinCodes = label.dualSideCodes && label.symbology != 'code128';
    final codeWidthScale = normalizeLabelCodeScale(label.codeWidthScale);
    final codeHeightScale = normalizeLabelCodeScale(label.codeHeightScale);

    // ── Label dimensions in PDF points ──────────────────────────────────────
    final wPt = label.widthMm * PdfPageFormat.mm;
    final hPt = label.heightMm * PdfPageFormat.mm;

    // ── A4 page dimensions (no margins) ─────────────────────────────────────
    // Always use A4 so the print dialog shows the stickers at exact physical
    // size without scaling. Stickers are laid out starting from the top-left.
    final sheetFormat =
        pageFormat ??
        const PdfPageFormat(
          210.0 * PdfPageFormat.mm,
          297.0 * PdfPageFormat.mm,
          marginAll: 0,
        );

    // How many sticker rows fit on one A4 page?
    final rowsPerPage = (sheetFormat.availableHeight / hPt).floor().clamp(
      1,
      9999,
    );
    final columnsPerPage = math.min(
      label.stickersPerRow,
      (sheetFormat.availableWidth / wPt).floor().clamp(1, 9999),
    );

    // Match preview proportions: keep inner canvas relatively large.
    final pad = (math.min(wPt, hPt) * 0.06).clamp(1.2, 4.0);
    final innerW = wPt - pad * 2;
    final innerH = hPt - pad * 2;

    // ── Dynamic font scaling based on label height ───────────────────────────
    // Scale fonts so they retain the same proportions as the live preview.
    // The configured values are preview pixels, not typographic points.
    final fontScale =
        label.previewCanvasHeight != null && label.previewCanvasHeight! > 0
        ? innerH / label.previewCanvasHeight!
        : (label.heightMm / 30.0).clamp(0.5, 2.0) * 0.6;
    final settings = LabelFieldConfig.mergeWithDefaults(label.fieldSettings);
    LabelFieldSetting setting(LabelFieldKey key) => settings[key]!;
    bool visible(LabelFieldKey key) => settings[key]!.visible;
    String fieldText(
      LabelFieldKey key,
      String caption,
      String value, {
      String emptyValue = '-',
    }) {
      final resolvedValue = value.trim().isEmpty ? emptyValue : value.trim();
      return setting(key).showCaption
          ? '$caption: $resolvedValue'
          : resolvedValue;
    }

    pw.FontStyle pdfFontStyle(LabelFontStyle style) =>
        style == LabelFontStyle.italic
        ? pw.FontStyle.italic
        : pw.FontStyle.normal;

    pw.FontWeight pdfFontWeight(LabelFontWeight weight) => switch (weight) {
      LabelFontWeight.regular || LabelFontWeight.medium => pw.FontWeight.normal,
      LabelFontWeight.semiBold ||
      LabelFontWeight.bold ||
      LabelFontWeight.black => pw.FontWeight.bold,
    };

    pw.TextStyle fieldStyle(
      LabelFieldKey key,
      double fontSize, {
      PdfColor? color,
      double? letterSpacing,
    }) => pw.TextStyle(
      font: labelFont,
      fontSize: fontSize,
      fontStyle: pdfFontStyle(setting(key).fontStyle),
      fontWeight: pdfFontWeight(setting(key).fontWeight),
      color: color,
      letterSpacing: letterSpacing,
    );

    double scaledFont(
      LabelFieldKey key, {
      double min = 0.8,
      double max = LabelFieldConfig.maxFontSize,
    }) => (settings[key]!.fontSize * fontScale).clamp(min, max);

    final fCompany = scaledFont(LabelFieldKey.companyName, min: 1.0);
    final fAddress = scaledFont(LabelFieldKey.companyAddress);
    final fPart = scaledFont(LabelFieldKey.partNumber, min: 1.0);
    final fSerial = scaledFont(LabelFieldKey.serialNumber, min: 1.0);
    final fItem = scaledFont(LabelFieldKey.itemName);
    final fModel = scaledFont(LabelFieldKey.model);
    final fPort = scaledFont(LabelFieldKey.port);
    final fDate = scaledFont(LabelFieldKey.date);
    final fTime = scaledFont(LabelFieldKey.time);
    final fContent = scaledFont(LabelFieldKey.codeData);

    // Use the same geometry intent as live preview.
    final twinSide = math.max(8.0, math.min(innerH * 0.52, innerW * 0.20));
    final twinCodeW = clampLabelCodeDimension(
      base: twinSide,
      scale: codeWidthScale,
      maximum: innerW * 0.42,
    );
    final twinCodeH = clampLabelCodeDimension(
      base: twinSide,
      scale: codeHeightScale,
      maximum: innerH * 0.90,
    );
    final centerW = (innerW - (twinCodeW * 2) - (innerW * 0.04)).clamp(
      innerW * 0.35,
      innerW,
    );

    // ── Estimate text block height ───────────────────────────────────────────
    final showItem =
        visible(LabelFieldKey.itemName) && label.itemName.isNotEmpty;
    final showModel = visible(LabelFieldKey.model);
    final showPort =
        visible(LabelFieldKey.port) && label.port.trim().isNotEmpty;
    final showSingleModelPort = showModel || showPort;
    final showDate = visible(LabelFieldKey.date);
    final showTime = visible(LabelFieldKey.time);
    // ── Barcode sizing ───────────────────────────────────────────────────────
    final baseBarcodeH = math.min(innerH * 0.42, innerW * 0.45);
    final baseBarcodeW = label.symbology == 'code128'
        ? innerW * .92
        : math.min(innerW * .45, baseBarcodeH);
    final barcodeW = clampLabelCodeDimension(
      base: baseBarcodeW,
      scale: codeWidthScale,
      maximum: innerW,
    );
    final barcodeH = clampLabelCodeDimension(
      base: baseBarcodeH,
      scale: codeHeightScale,
      maximum: innerH,
    );
    final singleTextW = math.max(innerW * .50, innerW * .78);
    final singleFontPeak = [
      fCompany,
      fAddress,
      fPart,
      fSerial,
      fItem,
      fModel,
      fPort,
      fDate,
      fTime,
      fContent,
    ].reduce(math.max);
    final dualFontPeak = [
      fCompany,
      fPart,
      fSerial,
      fItem,
      fModel,
      fPort,
      fDate,
      fTime,
      fContent,
    ].reduce(math.max);
    // Match the preview's proportional line boxes. Fixed 9/10-point minimums
    // consumed a large part of a 30 mm label and shifted rows into each other.
    final singleLineH = math.max(innerH * .08, singleFontPeak * 1.3);
    final dualLineH = math.max(innerH * .075, dualFontPeak * 1.25);
    final codeLineH = math.max(innerH * .075, fContent * 1.25);
    final dualModelW = centerW * .62;
    final dualPortW = centerW * .34;

    pw.Widget positionedElement({
      required LabelLayoutElement element,
      required double width,
      required double height,
      required pw.Widget child,
    }) {
      final rotation = resolvedLayout.positionFor(element).rotation;
      final isBarcode = {
        LabelLayoutElement.singleBarcode,
        LabelLayoutElement.dualLeftCode,
        LabelLayoutElement.dualRightCode,
      }.contains(element);
      final textAlignment =
          {
            LabelLayoutElement.singleCompanyName,
            LabelLayoutElement.dualCompanyName,
          }.contains(element)
          ? pw.Alignment.center
          : pw.Alignment.centerLeft;
      pw.Widget sizedChild(double resolvedWidth, double resolvedHeight) {
        final content = pw.SizedBox(
          width: resolvedWidth,
          height: resolvedHeight,
          child: isBarcode
              ? child
              : pw.FittedBox(
                  fit: pw.BoxFit.scaleDown,
                  alignment: textAlignment,
                  child: child,
                ),
        );
        return rotation == 0
            ? content
            : pw.Transform.rotate(
                angle: pdfRotationFromPreview(rotation),
                child: content,
              );
      }

      final rect = label.resolvedLayoutRects[element];
      if (rect != null) {
        return pw.Positioned(
          left: innerW * rect.left,
          top: innerH * rect.top,
          child: sizedChild(innerW * rect.width, innerH * rect.height),
        );
      }
      final normalized = resolvedLayout.positionFor(element);
      final freeW = math.max(0.0, innerW - width);
      final freeH = math.max(0.0, innerH - height);
      return pw.Positioned(
        left: freeW * normalized.x,
        top: freeH * normalized.y,
        child: sizedChild(width, height),
      );
    }

    pw.Widget positionedDynamicField(DynamicLabelField field) {
      final rect = label.resolvedDynamicRects[field.id];
      final width = rect == null
          ? (twinCodes ? centerW : singleTextW)
          : innerW * rect.width;
      final height = rect == null
          ? (twinCodes ? dualLineH : singleLineH)
          : innerH * rect.height;
      return pw.Positioned(
        left: rect == null ? (innerW - width) * field.x : innerW * rect.left,
        top: rect == null ? (innerH - height) * field.y : innerH * rect.top,
        child: pw.Transform.rotate(
          angle: pdfRotationFromPreview(field.rotation),
          child: pw.SizedBox(
            width: width,
            height: height,
            child: pw.FittedBox(
              fit: pw.BoxFit.scaleDown,
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                field.showCaption
                    ? '${field.label}: ${field.value}'
                    : field.value,
                maxLines: 1,
                style: pw.TextStyle(
                  font: labelFont,
                  fontStyle: pdfFontStyle(field.fontStyle),
                  fontWeight: pdfFontWeight(field.fontWeight),
                  fontSize: (field.fontSize * fontScale).clamp(
                    0.8,
                    LabelFieldConfig.maxFontSize,
                  ),
                  letterSpacing: LabelTypography.textTracking,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // ── Single sticker widget ────────────────────────────────────────────────
    // Uses FIXED width × height and clips content. Never grows beyond bounds.
    pw.Widget buildSticker(
      ({String partNumber, String serialNumber, String content}) values,
    ) => pw.ClipRect(
      child: pw.Container(
        width: wPt,
        height: hPt,
        decoration: pw.BoxDecoration(
          border: label.includeBorder ? pw.Border.all(width: 0.4) : null,
        ),
        padding: pw.EdgeInsets.all(pad),
        child: pw.Stack(
          children: [
            if (twinCodes) ...[
              if (visible(LabelFieldKey.barcode))
                positionedElement(
                  element: LabelLayoutElement.dualLeftCode,
                  width: twinCodeW,
                  height: twinCodeH,
                  child: _buildCode(
                    symbology: label.symbology,
                    data: values.content,
                  ),
                ),
              if (visible(LabelFieldKey.companyName))
                positionedElement(
                  element: LabelLayoutElement.dualCompanyName,
                  width: centerW,
                  height: dualLineH,
                  child: pw.Text(
                    fieldText(
                      LabelFieldKey.companyName,
                      'COMPANY',
                      label.company.toUpperCase(),
                    ),
                    textAlign: pw.TextAlign.center,
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: fieldStyle(
                      LabelFieldKey.companyName,
                      fCompany,
                      letterSpacing: LabelTypography.companyTracking,
                    ),
                  ),
                ),
              if (showModel)
                positionedElement(
                  element: LabelLayoutElement.dualModel,
                  width: dualModelW,
                  height: dualLineH,
                  child: pw.Text(
                    fieldText(
                      LabelFieldKey.model,
                      'MODEL',
                      label.model.toUpperCase(),
                    ),
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: fieldStyle(
                      LabelFieldKey.model,
                      fModel,
                      letterSpacing: LabelTypography.textTracking,
                    ),
                  ),
                ),
              if (showPort)
                positionedElement(
                  element: LabelLayoutElement.dualPort,
                  width: dualPortW,
                  height: dualLineH,
                  child: pw.Text(
                    fieldText(
                      LabelFieldKey.port,
                      'PORT',
                      label.port.toUpperCase(),
                    ),
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: fieldStyle(
                      LabelFieldKey.port,
                      fPort,
                      letterSpacing: LabelTypography.textTracking,
                    ),
                  ),
                ),
              if (showDate)
                positionedElement(
                  element: LabelLayoutElement.dualDate,
                  width: centerW,
                  height: dualLineH,
                  child: pw.Text(
                    fieldText(LabelFieldKey.date, 'DATE', label.dateText),
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: fieldStyle(
                      LabelFieldKey.date,
                      fDate,
                      letterSpacing: LabelTypography.textTracking,
                    ),
                  ),
                ),
              if (showTime)
                positionedElement(
                  element: LabelLayoutElement.dualTime,
                  width: centerW,
                  height: dualLineH,
                  child: pw.Text(
                    fieldText(LabelFieldKey.time, 'TIME', label.timeText),
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: fieldStyle(
                      LabelFieldKey.time,
                      fTime,
                      letterSpacing: LabelTypography.textTracking,
                    ),
                  ),
                ),
              if (visible(LabelFieldKey.partNumber))
                positionedElement(
                  element: LabelLayoutElement.dualPartNumber,
                  width: centerW,
                  height: dualLineH,
                  child: pw.Text(
                    fieldText(
                      LabelFieldKey.partNumber,
                      'PART NO',
                      values.partNumber,
                    ),
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: fieldStyle(
                      LabelFieldKey.partNumber,
                      fPart,
                      letterSpacing: LabelTypography.textTracking,
                    ),
                  ),
                ),
              if (showItem)
                positionedElement(
                  element: LabelLayoutElement.dualItemName,
                  width: centerW,
                  height: dualLineH,
                  child: pw.Text(
                    fieldText(LabelFieldKey.itemName, 'ITEM', label.itemName),
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: fieldStyle(
                      LabelFieldKey.itemName,
                      fItem,
                      letterSpacing: LabelTypography.textTracking,
                    ),
                  ),
                ),
              if (visible(LabelFieldKey.serialNumber))
                positionedElement(
                  element: LabelLayoutElement.dualSerialNumber,
                  width: centerW,
                  height: dualLineH,
                  child: pw.Text(
                    fieldText(
                      LabelFieldKey.serialNumber,
                      'SERIAL NO',
                      values.serialNumber,
                    ),
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: fieldStyle(
                      LabelFieldKey.serialNumber,
                      fSerial,
                      letterSpacing: LabelTypography.textTracking,
                    ),
                  ),
                ),
              if (visible(LabelFieldKey.codeData))
                positionedElement(
                  element: LabelLayoutElement.dualCodeData,
                  width: centerW,
                  height: dualLineH,
                  child: pw.Text(
                    fieldText(LabelFieldKey.codeData, 'CODE', values.content),
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: fieldStyle(
                      LabelFieldKey.codeData,
                      fContent,
                      letterSpacing: LabelTypography.textTracking,
                    ),
                  ),
                ),
              if (visible(LabelFieldKey.barcode))
                positionedElement(
                  element: LabelLayoutElement.dualRightCode,
                  width: twinCodeW,
                  height: twinCodeH,
                  child: _buildCode(
                    symbology: label.symbology,
                    data: values.content,
                  ),
                ),
            ] else ...[
              if (visible(LabelFieldKey.companyName))
                positionedElement(
                  element: LabelLayoutElement.singleCompanyName,
                  width: singleTextW,
                  height: singleLineH,
                  child: pw.Text(
                    fieldText(
                      LabelFieldKey.companyName,
                      'COMPANY',
                      label.company.toUpperCase(),
                    ),
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: fieldStyle(LabelFieldKey.companyName, fCompany),
                  ),
                ),
              if (visible(LabelFieldKey.companyAddress) &&
                  label.companyAddress.isNotEmpty)
                positionedElement(
                  element: LabelLayoutElement.singleCompanyAddress,
                  width: singleTextW,
                  height: singleLineH,
                  child: pw.Text(
                    fieldText(
                      LabelFieldKey.companyAddress,
                      'ADDRESS',
                      label.companyAddress,
                    ),
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: fieldStyle(
                      LabelFieldKey.companyAddress,
                      fAddress,
                      color: PdfColors.grey700,
                    ),
                  ),
                ),
              if (visible(LabelFieldKey.partNumber))
                positionedElement(
                  element: LabelLayoutElement.singlePartNumber,
                  width: singleTextW,
                  height: singleLineH,
                  child: pw.Text(
                    values.partNumber.isEmpty
                        ? label.title
                        : fieldText(
                            LabelFieldKey.partNumber,
                            'PART NO',
                            values.partNumber,
                          ),
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: fieldStyle(LabelFieldKey.partNumber, fPart),
                  ),
                ),
              if (showItem)
                positionedElement(
                  element: LabelLayoutElement.singleItemName,
                  width: singleTextW,
                  height: singleLineH,
                  child: pw.Text(
                    fieldText(LabelFieldKey.itemName, 'ITEM', label.itemName),
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: fieldStyle(LabelFieldKey.itemName, fItem),
                  ),
                ),
              if (showSingleModelPort)
                positionedElement(
                  element: LabelLayoutElement.singleModelPort,
                  width: singleTextW,
                  height: singleLineH,
                  child: pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        if (showModel)
                          pw.TextSpan(
                            text: fieldText(
                              LabelFieldKey.model,
                              'MODEL',
                              label.model,
                            ),
                            style: fieldStyle(LabelFieldKey.model, fModel),
                          ),
                        if (showModel && showPort)
                          pw.TextSpan(
                            text: '    ',
                            style: fieldStyle(LabelFieldKey.model, fModel),
                          ),
                        if (showPort)
                          pw.TextSpan(
                            text: fieldText(
                              LabelFieldKey.port,
                              'PORT',
                              label.port,
                            ),
                            style: fieldStyle(LabelFieldKey.port, fPort),
                          ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                  ),
                ),
              if (visible(LabelFieldKey.serialNumber))
                positionedElement(
                  element: LabelLayoutElement.singleSerialNumber,
                  width: singleTextW,
                  height: singleLineH,
                  child: pw.Text(
                    fieldText(
                      LabelFieldKey.serialNumber,
                      'SERIAL NO',
                      values.serialNumber,
                    ),
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: fieldStyle(LabelFieldKey.serialNumber, fSerial),
                  ),
                ),
              if (showDate)
                positionedElement(
                  element: LabelLayoutElement.singleDate,
                  width: singleTextW,
                  height: singleLineH,
                  child: pw.Text(
                    fieldText(LabelFieldKey.date, 'DATE', label.dateText),
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: fieldStyle(LabelFieldKey.date, fDate),
                  ),
                ),
              if (showTime)
                positionedElement(
                  element: LabelLayoutElement.singleTime,
                  width: singleTextW,
                  height: singleLineH,
                  child: pw.Text(
                    fieldText(LabelFieldKey.time, 'TIME', label.timeText),
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: fieldStyle(LabelFieldKey.time, fTime),
                  ),
                ),
              if (visible(LabelFieldKey.barcode))
                positionedElement(
                  element: LabelLayoutElement.singleBarcode,
                  width: barcodeW,
                  height: barcodeH,
                  child: pw.BarcodeWidget(
                    barcode: _barcodeFor(label.symbology),
                    data: values.content,
                    drawText: false,
                  ),
                ),
              if (visible(LabelFieldKey.codeData))
                positionedElement(
                  element: LabelLayoutElement.singleCodeData,
                  width: singleTextW,
                  height: codeLineH,
                  child: pw.Text(
                    fieldText(LabelFieldKey.codeData, 'CODE', values.content),
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: fieldStyle(LabelFieldKey.codeData, fContent),
                  ),
                ),
            ],
            for (final field in label.dynamicFields)
              if (field.visible && field.value.trim().isNotEmpty)
                positionedDynamicField(field),
          ],
        ),
      ), // Container
    ); // ClipRect

    // ── Page builder ─────────────────────────────────────────────────────────
    // Divide stickers across A4 pages. Each sticker occupies exactly wPt×hPt
    // starting from (0,0) on the page — no scaling, no centering.
    int stickerIdx = 0;
    while (stickerIdx < label.packQty) {
      final pageStickers = <pw.Widget>[];
      for (int r = 0; r < rowsPerPage; r++) {
        final rowCells = <pw.Widget>[];
        for (int c = 0; c < columnsPerPage; c++) {
          if (stickerIdx < label.packQty) {
            rowCells.add(buildSticker(label.stickerValuesAt(stickerIdx)));
            stickerIdx++;
          } else {
            // Empty cell — keeps row width consistent
            rowCells.add(pw.SizedBox(width: wPt, height: hPt));
          }
        }
        pageStickers.add(
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: rowCells,
          ),
        );
      }

      document.addPage(
        pw.Page(
          // A4, zero margins — stickers print at exact physical size
          pageFormat: sheetFormat,
          build: (ctx) => pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: pageStickers,
          ),
        ),
      );
    }

    return document.save();
  }

  Barcode _barcodeFor(String symbology) => switch (symbology) {
    'qr' => Barcode.qrCode(),
    'data_matrix' => Barcode.dataMatrix(),
    _ => Barcode.code128(),
  };

  pw.Widget _buildCode({required String symbology, required String data}) =>
      pw.BarcodeWidget(
        barcode: _barcodeFor(symbology == 'code128' ? 'qr' : symbology),
        data: data,
        drawText: false,
      );
}

abstract interface class BrowserPrintGateway {
  Future<void> showPrintDialog(Uint8List pdfBytes, String filename);
  Future<void> download(Uint8List pdfBytes, String filename);
}

class PrintAgentPairing {
  const PrintAgentPairing({
    required this.tenantId,
    required this.deviceId,
    required this.publicKey,
    required this.expiresAt,
    this.revokedAt,
  });
  final String tenantId;
  final String deviceId;
  final String publicKey;
  final DateTime expiresAt;
  final DateTime? revokedAt;
  bool get usable => revokedAt == null && expiresAt.isAfter(DateTime.now());
}

class SignedAgentPrintJob {
  const SignedAgentPrintJob({
    required this.id,
    required this.tenantId,
    required this.deviceId,
    required this.payloadHash,
    required this.signature,
    required this.expiresAt,
  });
  final String id;
  final String tenantId;
  final String deviceId;
  final String payloadHash;
  final String signature;
  final DateTime expiresAt;
}

abstract interface class LocalPrintAgentGateway {
  Future<PrintAgentPairing> pair(String tenantId, String oneTimeCode);
  Future<void> revoke(String tenantId, String deviceId);
  Future<String> submit(SignedAgentPrintJob job);
  Stream<String> status(String jobId);
}
