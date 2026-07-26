import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class BrowserLabelDocument {
  const BrowserLabelDocument({
    required this.title,
    required this.content,
    required this.widthMm,
    required this.heightMm,
  });
  final String title;
  final String content;
  final double widthMm;
  final double heightMm;
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
        build: (context) => pw.Center(
          child: pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(
                label.title,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text(label.content),
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
