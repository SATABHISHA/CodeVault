enum PrinterLanguage { zpl, tspl, epl, cpcl, godex, raster }

class PrintRequest {
  const PrintRequest({
    required this.jobId,
    required this.content,
    required this.copies,
  });
  final String jobId;
  final String content;
  final int copies;
}

class PrintReceipt {
  const PrintReceipt({required this.jobId, required this.message});
  final String jobId;
  final String message;
}

abstract interface class WindowsPrinterAdapter {
  String get name;
  PrinterLanguage get language;
  Future<void> testConnection();
  Future<PrintReceipt> print(PrintRequest request);
}

class MockPrinterAdapter implements WindowsPrinterAdapter {
  @override
  String get name => 'CodeVault Mock Printer';
  @override
  PrinterLanguage get language => PrinterLanguage.zpl;
  final List<PrintRequest> jobs = [];
  @override
  Future<void> testConnection() async {}
  @override
  Future<PrintReceipt> print(PrintRequest request) async {
    if (request.copies < 1) throw ArgumentError.value(request.copies, 'copies');
    jobs.add(request);
    return PrintReceipt(jobId: request.jobId, message: 'Mock print accepted');
  }
}
