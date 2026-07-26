enum AndroidPrinterTransport {
  bluetoothClassic,
  ble,
  wifi,
  rawTcp,
  systemPrint,
  vendorSdk,
  usbOtg,
}

enum AndroidPrinterLanguage {
  escPos,
  tspl,
  tspl2,
  zpl,
  epl,
  cpcl,
  ezpl,
  pdf,
  raster,
}

enum PrintDeliveryState { queued, sending, completed, failed, uncertain }

class PrinterDescriptor {
  const PrinterDescriptor({
    required this.id,
    required this.name,
    required this.transport,
    required this.address,
    this.connected = false,
  });
  final String id;
  final String name;
  final AndroidPrinterTransport transport;
  final String address;
  final bool connected;
}

class WirelessPrintRequest {
  const WirelessPrintRequest({
    required this.jobId,
    required this.tenantId,
    required this.printer,
    required this.language,
    required this.content,
    required this.quantity,
  });
  final String jobId;
  final String tenantId;
  final PrinterDescriptor printer;
  final AndroidPrinterLanguage language;
  final String content;
  final int quantity;
}

class WirelessPrintResult {
  const WirelessPrintResult({
    required this.jobId,
    required this.state,
    this.message,
  });
  final String jobId;
  final PrintDeliveryState state;
  final String? message;
}

abstract interface class PrinterDiscoveryService {
  Stream<List<PrinterDescriptor>> discover(AndroidPrinterTransport transport);
  Future<void> stop();
}

abstract interface class PrinterConnectionService {
  Future<void> connect(PrinterDescriptor printer);
  Future<void> disconnect(PrinterDescriptor printer);
  Future<bool> test(PrinterDescriptor printer);
}

abstract interface class PrinterLanguageAdapter {
  AndroidPrinterLanguage get language;
  Future<List<int>> encode(String content, {required int quantity});
}

abstract interface class LabelRasterizer {
  Future<List<int>> rasterize(
    String content, {
    required int widthDots,
    required int heightDots,
  });
}

abstract interface class PrintTransport {
  Future<WirelessPrintResult> send(
    WirelessPrintRequest request,
    List<int> bytes,
  );
}

abstract interface class PrintJobRepository {
  Future<PrintDeliveryState?> state(String tenantId, String jobId);
  Future<void> save(
    WirelessPrintRequest request,
    PrintDeliveryState state, {
    String? error,
  });
}

class AmbiguousPrintResult implements Exception {
  const AmbiguousPrintResult(this.message);
  final String message;
}

class RetryConfirmationRequired implements Exception {
  const RetryConfirmationRequired(this.jobId);
  final String jobId;
}

class WirelessPrinterService {
  const WirelessPrinterService({
    required this.repository,
    required this.transport,
    required this.adapters,
  });
  final PrintJobRepository repository;
  final PrintTransport transport;
  final Map<AndroidPrinterLanguage, PrinterLanguageAdapter> adapters;

  Future<WirelessPrintResult> print(
    WirelessPrintRequest request, {
    bool confirmUncertainRetry = false,
  }) async {
    if (request.quantity < 1) {
      throw ArgumentError.value(request.quantity, 'quantity');
    }
    final prior = await repository.state(request.tenantId, request.jobId);
    if (prior == PrintDeliveryState.completed) {
      return WirelessPrintResult(
        jobId: request.jobId,
        state: prior!,
        message: 'Duplicate job suppressed',
      );
    }
    if (prior == PrintDeliveryState.uncertain && !confirmUncertainRetry) {
      throw RetryConfirmationRequired(request.jobId);
    }
    final adapter = adapters[request.language];
    if (adapter == null) {
      throw StateError('No adapter for ${request.language.name}.');
    }
    await repository.save(request, PrintDeliveryState.sending);
    try {
      final bytes = await adapter.encode(
        request.content,
        quantity: request.quantity,
      );
      final result = await transport.send(request, bytes);
      await repository.save(request, result.state, error: result.message);
      return result;
    } on AmbiguousPrintResult catch (error) {
      await repository.save(
        request,
        PrintDeliveryState.uncertain,
        error: error.message,
      );
      return WirelessPrintResult(
        jobId: request.jobId,
        state: PrintDeliveryState.uncertain,
        message: error.message,
      );
    } catch (error) {
      await repository.save(
        request,
        PrintDeliveryState.failed,
        error: error.toString(),
      );
      rethrow;
    }
  }
}

class TextCommandAdapter implements PrinterLanguageAdapter {
  const TextCommandAdapter(this.language);
  @override
  final AndroidPrinterLanguage language;
  @override
  Future<List<int>> encode(String content, {required int quantity}) async =>
      '$language|copies=$quantity|$content'.codeUnits;
}
