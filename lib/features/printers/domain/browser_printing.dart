import 'dart:typed_data';
import 'dart:math' as math;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:barcode/barcode.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../labels/domain/label_field_config.dart';
import '../../labels/domain/label_layout.dart';
import '../../labels/domain/label_typography.dart';

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
    this.port = '',
    this.dateText = '',
    this.timeText = '',
    this.dualSideCodes = false,
    this.packQty = 1,
    this.stickersPerRow = 1,
    this.includeBorder = true,
    this.layout,
    this.fieldSettings,
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
  final String port;
  final String dateText;
  final String timeText;
  final bool dualSideCodes;
  final int packQty;
  final int stickersPerRow;
  final bool includeBorder;
  final LabelLayout? layout;
  final Map<LabelFieldKey, LabelFieldSetting>? fieldSettings;
}

class BrowserPdfGenerator {
  const BrowserPdfGenerator();

  // Label Studio font sizes are Flutter logical pixels. Using those values as
  // PDF points makes the printed text roughly twice as large as the preview
  // and causes independently positioned rows to overlap. This conversion is
  // shared by every platform because they all print this document.
  Future<Uint8List> generate(BrowserLabelDocument label) async {
    final document = pw.Document();
    final labelFont = pw.Font.ttf(
      await rootBundle.load(LabelTypography.fontAsset),
    );
    final resolvedLayout = label.layout ?? LabelLayout.defaults();
    final twinCodes = label.dualSideCodes && label.symbology != 'code128';

    // ── Label dimensions in PDF points ──────────────────────────────────────
    final wPt = label.widthMm * PdfPageFormat.mm;
    final hPt = label.heightMm * PdfPageFormat.mm;

    // ── A4 page dimensions (no margins) ─────────────────────────────────────
    // Always use A4 so the print dialog shows the stickers at exact physical
    // size without scaling. Stickers are laid out starting from the top-left.
    const a4W = 210.0 * PdfPageFormat.mm;
    const a4H = 297.0 * PdfPageFormat.mm;

    // How many sticker rows fit on one A4 page?
    final rowsPerPage = (a4H / hPt).floor().clamp(1, 9999);

    // ── Dynamic font scaling based on label height ───────────────────────────
    // Scale fonts so they retain the same proportions as the live preview.
    // The configured values are preview pixels, not typographic points.
    final fontScale = (label.heightMm / 30.0).clamp(0.5, 2.0) * 0.6;
    final settings = LabelFieldConfig.mergeWithDefaults(label.fieldSettings);
    bool visible(LabelFieldKey key) => settings[key]!.visible;
    double scaledFont(
      LabelFieldKey key, {
      double min = 2.0,
      double max = 14.0,
    }) => (settings[key]!.fontSize * fontScale).clamp(min, max);

    final fCompany = scaledFont(LabelFieldKey.companyName, min: 2.5);
    final fAddress = scaledFont(LabelFieldKey.companyAddress);
    final fPart = scaledFont(LabelFieldKey.partNumber, min: 2.5);
    final fItem = scaledFont(LabelFieldKey.itemName);
    final fModel = scaledFont(LabelFieldKey.model);
    final fPort = scaledFont(LabelFieldKey.port);
    final fDateTime = scaledFont(LabelFieldKey.dateTime);
    final fContent = scaledFont(LabelFieldKey.codeData);

    // Match preview proportions: keep inner canvas relatively large.
    final pad = (math.min(wPt, hPt) * 0.06).clamp(1.2, 4.0);

    final innerW = wPt - pad * 2;
    final innerH = hPt - pad * 2;
    // Use the same geometry intent as live preview.
    final twinSide = math.max(8.0, math.min(innerH * 0.52, innerW * 0.20));
    final centerW = (innerW - (twinSide * 2) - (innerW * 0.04)).clamp(
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
    final showDateTime =
        visible(LabelFieldKey.dateTime) &&
        (label.dateText.isNotEmpty || label.timeText.isNotEmpty);
    // ── Barcode sizing ───────────────────────────────────────────────────────
    final barcodeH = math.min(innerH * 0.42, innerW * 0.45);
    final barcodeW = label.symbology == 'code128'
        ? innerW * .92
        : math.min(innerW * .45, barcodeH);
    final singleTextW = math.max(innerW * .50, innerW * .78);
    final singleFontPeak = [
      fCompany,
      fAddress,
      fPart,
      fItem,
      fModel,
      fPort,
      fDateTime,
      fContent,
    ].reduce(math.max);
    final dualFontPeak = [
      fCompany,
      fPart,
      fItem,
      fModel,
      fPort,
      fDateTime,
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
      final normalized = resolvedLayout.positionFor(element);
      final freeW = math.max(0.0, innerW - width);
      final freeH = math.max(0.0, innerH - height);
      return pw.Positioned(
        left: freeW * normalized.x,
        top: freeH * normalized.y,
        child: pw.SizedBox(width: width, height: height, child: child),
      );
    }

    // ── Single sticker widget ────────────────────────────────────────────────
    // Uses FIXED width × height and clips content. Never grows beyond bounds.
    pw.Widget buildSticker() => pw.ClipRect(
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
                  width: twinSide,
                  height: twinSide,
                  child: _buildSquareCode(label: label, side: twinSide),
                ),
              if (visible(LabelFieldKey.companyName))
                positionedElement(
                  element: LabelLayoutElement.dualCompanyName,
                  width: centerW,
                  height: dualLineH,
                  child: pw.Text(
                    label.company.isEmpty
                        ? 'COMPANY'
                        : label.company.toUpperCase(),
                    textAlign: pw.TextAlign.center,
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: pw.TextStyle(
                      font: labelFont,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: fCompany,
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
                    'MODEL: ${label.model.trim().isEmpty ? '-' : label.model.trim().toUpperCase()}',
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: pw.TextStyle(
                      font: labelFont,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: fModel,
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
                    label.port.trim().toUpperCase(),
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: pw.TextStyle(
                      font: labelFont,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: fPort,
                      letterSpacing: LabelTypography.textTracking,
                    ),
                  ),
                ),
              if (showDateTime)
                positionedElement(
                  element: LabelLayoutElement.dualDateTime,
                  width: centerW,
                  height: dualLineH,
                  child: pw.Text(
                    'DATE: ${label.dateText.isEmpty ? '-' : label.dateText}    TIME: ${label.timeText.isEmpty ? '-' : label.timeText}',
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: pw.TextStyle(
                      font: labelFont,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: fDateTime,
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
                    'PART NO: ${label.partNumber.isEmpty ? '-' : label.partNumber}',
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: pw.TextStyle(
                      font: labelFont,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: fPart,
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
                    label.itemName,
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: pw.TextStyle(
                      font: labelFont,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: fItem,
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
                    label.content,
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: pw.TextStyle(
                      font: labelFont,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: fContent,
                      letterSpacing: LabelTypography.textTracking,
                    ),
                  ),
                ),
              if (visible(LabelFieldKey.barcode))
                positionedElement(
                  element: LabelLayoutElement.dualRightCode,
                  width: twinSide,
                  height: twinSide,
                  child: _buildSquareCode(label: label, side: twinSide),
                ),
            ] else ...[
              if (visible(LabelFieldKey.companyName))
                positionedElement(
                  element: LabelLayoutElement.singleCompanyName,
                  width: singleTextW,
                  height: singleLineH,
                  child: pw.Text(
                    label.company,
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: pw.TextStyle(
                      font: labelFont,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: fCompany,
                    ),
                  ),
                ),
              if (visible(LabelFieldKey.companyAddress) &&
                  label.companyAddress.isNotEmpty)
                positionedElement(
                  element: LabelLayoutElement.singleCompanyAddress,
                  width: singleTextW,
                  height: singleLineH,
                  child: pw.Text(
                    label.companyAddress,
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: pw.TextStyle(
                      font: labelFont,
                      fontSize: fAddress,
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
                    label.title,
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: pw.TextStyle(
                      font: labelFont,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: fPart,
                    ),
                  ),
                ),
              if (showItem)
                positionedElement(
                  element: LabelLayoutElement.singleItemName,
                  width: singleTextW,
                  height: singleLineH,
                  child: pw.Text(
                    'ITEM: ${label.itemName}',
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: pw.TextStyle(font: labelFont, fontSize: fItem),
                  ),
                ),
              if (showSingleModelPort)
                positionedElement(
                  element: LabelLayoutElement.singleModelPort,
                  width: singleTextW,
                  height: singleLineH,
                  child: pw.Text(
                    showModel
                        ? 'MODEL: ${label.model.isEmpty ? '-' : label.model}${showPort ? '    ${label.port}' : ''}'
                        : label.port,
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: pw.TextStyle(
                      font: labelFont,
                      fontSize: math.max(fModel, fPort),
                    ),
                  ),
                ),
              if (showDateTime)
                positionedElement(
                  element: LabelLayoutElement.singleDateTime,
                  width: singleTextW,
                  height: singleLineH,
                  child: pw.Text(
                    'DATE: ${label.dateText.isEmpty ? '-' : label.dateText}    TIME: ${label.timeText.isEmpty ? '-' : label.timeText}',
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: pw.TextStyle(font: labelFont, fontSize: fDateTime),
                  ),
                ),
              if (visible(LabelFieldKey.barcode))
                positionedElement(
                  element: LabelLayoutElement.singleBarcode,
                  width: barcodeW,
                  height: barcodeH,
                  child: pw.BarcodeWidget(
                    barcode: _barcodeFor(label.symbology),
                    data: label.content,
                    drawText: false,
                  ),
                ),
              if (visible(LabelFieldKey.codeData))
                positionedElement(
                  element: LabelLayoutElement.singleCodeData,
                  width: singleTextW,
                  height: codeLineH,
                  child: pw.Text(
                    label.content,
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: pw.TextStyle(font: labelFont, fontSize: fContent),
                  ),
                ),
            ],
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
        for (int c = 0; c < label.stickersPerRow; c++) {
          if (stickerIdx < label.packQty) {
            rowCells.add(buildSticker());
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
          pageFormat: const PdfPageFormat(a4W, a4H, marginAll: 0),
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

  pw.Widget _buildSquareCode({
    required BrowserLabelDocument label,
    required double side,
  }) => pw.SizedBox(
    width: side,
    height: side,
    child: pw.BarcodeWidget(
      barcode: _barcodeFor(
        label.symbology == 'code128' ? 'qr' : label.symbology,
      ),
      data: label.content,
      drawText: false,
    ),
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
