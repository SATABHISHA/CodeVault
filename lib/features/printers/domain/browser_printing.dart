import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:barcode/barcode.dart';

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
    this.packQty = 1,
    this.stickersPerRow = 1,
    this.includeBorder = true,
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
  final int packQty;
  final int stickersPerRow;
  final bool includeBorder;
}

class BrowserPdfGenerator {
  const BrowserPdfGenerator();

  Future<Uint8List> generate(BrowserLabelDocument label) async {
    final document = pw.Document();

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
    final stickersPerPage = rowsPerPage * label.stickersPerRow;

    // ── Dynamic font scaling based on label height ───────────────────────────
    // Scale fonts so they always fit within the label, regardless of size.
    // Base is 100% at 30 mm height; scale linearly with height.
    final scale = (label.heightMm / 30.0).clamp(0.5, 2.0);
    final fCompany  = (8.0 * scale).clamp(4.0, 10.0);
    final fSmall    = (6.0 * scale).clamp(3.5,  8.0);
    final fTitle    = (7.0 * scale).clamp(4.0,  9.0);
    final fContent  = (5.0 * scale).clamp(3.0,  7.0);
    final pad       = (4.0 * scale).clamp(2.0,  6.0);
    final gap       = (3.0 * scale).clamp(1.0,  5.0);

    final innerW = wPt - pad * 2;
    final innerH = hPt - pad * 2;

    // ── Estimate text block height ───────────────────────────────────────────
    final numTextLines = 1                                          // company
        + (label.companyAddress.isNotEmpty ? 1 : 0)
        + 1                                                         // title
        + (label.itemName.isNotEmpty ? 1 : 0)
        + (label.model.isNotEmpty ? 1 : 0)
        + 1;                                                        // content
    final avgLineH = ((fCompany + fSmall + fTitle + fContent) / 4.0);
    final textBlockH = numTextLines * avgLineH + gap * 2;

    // ── Barcode sizing ───────────────────────────────────────────────────────
    // Barcode height = whatever remains after text, clamped to ≥30% of innerH.
    final barcodeH = (innerH - textBlockH).clamp(innerH * 0.30, innerH * 0.68);
    // Code128: full inner width. QR / DataMatrix: square (height = width).
    final barcodeW = label.symbology == 'code128' ? innerW : barcodeH;

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
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisSize: pw.MainAxisSize.min,
          children: [
          pw.Text(
            label.company,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: fCompany),
          ),
          if (label.companyAddress.isNotEmpty)
            pw.Text(
              label.companyAddress,
              style: pw.TextStyle(fontSize: fSmall, color: PdfColors.grey700),
            ),
          pw.Text(
            label.title,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: fTitle),
          ),
          if (label.itemName.isNotEmpty)
            pw.Text(
              'ITEM: ${label.itemName}',
              style: pw.TextStyle(fontSize: fSmall),
            ),
          if (label.model.isNotEmpty)
            pw.Text(
              'MODEL: ${label.model}',
              style: pw.TextStyle(fontSize: fSmall),
            ),
          pw.SizedBox(height: gap),
          // Barcode box — strictly fixed width×height, never expands
          pw.SizedBox(
            width: barcodeW,
            height: barcodeH,
            child: pw.BarcodeWidget(
              barcode: switch (label.symbology) {
                'qr'          => Barcode.qrCode(),
                'data_matrix' => Barcode.dataMatrix(),
                _             => Barcode.code128(),
              },
              data: label.content,
              drawText: false,
            ),
          ),
          pw.SizedBox(height: gap * 0.5),
          pw.Text(
            label.content,
            maxLines: 1,
            overflow: pw.TextOverflow.clip,
            style: pw.TextStyle(fontSize: fContent),
          ),
        ],
        ),
      ),   // Container
    );     // ClipRect

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
