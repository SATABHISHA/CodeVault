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
}

class BrowserPdfGenerator {
  const BrowserPdfGenerator();
  Future<Uint8List> generate(BrowserLabelDocument label) async {
    final document = pw.Document();
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          label.widthMm * PdfPageFormat.mm,
          label.heightMm * PdfPageFormat.mm,
          marginAll: 2 * PdfPageFormat.mm,
        ),
        build: (context) => pw.Container(
          decoration: pw.BoxDecoration(border: pw.Border.all(width: .4)),
          padding: const pw.EdgeInsets.all(4),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      label.company,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                    if (label.companyAddress.isNotEmpty)
                      pw.Text(
                        label.companyAddress,
                        style: const pw.TextStyle(fontSize: 6),
                      ),
                    if (label.model.isNotEmpty)
                      pw.Text(
                        'MODEL: ${label.model}',
                        style: const pw.TextStyle(fontSize: 7),
                      ),
                    if (label.itemName.isNotEmpty)
                      pw.Text(
                        'ITEM: ${label.itemName}',
                        style: const pw.TextStyle(fontSize: 7),
                      ),
                    pw.Text(
                      label.title,
                      style: const pw.TextStyle(fontSize: 7),
                    ),
                    pw.FittedBox(
                      fit: pw.BoxFit.scaleDown,
                      child: pw.Text(
                        label.content,
                        maxLines: 1,
                        style: const pw.TextStyle(fontSize: 6),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 4),
              pw.SizedBox(
                width: label.symbology == 'code128'
                    ? label.widthMm * PdfPageFormat.mm * .38
                    : label.heightMm * PdfPageFormat.mm * .65,
                height: label.heightMm * PdfPageFormat.mm * .65,
                child: pw.BarcodeWidget(
                  barcode: switch (label.symbology) {
                    'qr' => Barcode.qrCode(),
                    'data_matrix' => Barcode.dataMatrix(),
                    _ => Barcode.code128(),
                  },
                  data: label.content,
                  // Human-readable content is rendered in the bounded details
                  // column. BarcodeWidget's text is intentionally disabled as
                  // long industrial values can extend beyond the physical page.
                  drawText: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
