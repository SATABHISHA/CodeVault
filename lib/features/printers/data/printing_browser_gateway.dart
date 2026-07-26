import 'dart:typed_data';

import 'package:printing/printing.dart';

import '../domain/browser_printing.dart';

class PrintingBrowserGateway implements BrowserPrintGateway {
  const PrintingBrowserGateway();
  @override
  Future<void> showPrintDialog(Uint8List pdfBytes, String filename) =>
      Printing.layoutPdf(name: filename, onLayout: (format) async => pdfBytes);
  @override
  Future<void> download(Uint8List pdfBytes, String filename) =>
      Printing.sharePdf(bytes: pdfBytes, filename: filename);
}
