import 'package:drift/drift.dart';

import '../../sync/data/android_cache_database.dart';
import '../domain/wireless_printing.dart';

class DriftPrintJobRepository implements PrintJobRepository {
  const DriftPrintJobRepository(this.database);
  final AndroidCacheDatabase database;
  @override
  Future<PrintDeliveryState?> state(String tenantId, String jobId) async {
    final row =
        await (database.select(database.androidPrintJobs)..where(
              (item) => item.tenantId.equals(tenantId) & item.id.equals(jobId),
            ))
            .getSingleOrNull();
    return row == null ? null : PrintDeliveryState.values.byName(row.state);
  }

  @override
  Future<void> save(
    WirelessPrintRequest request,
    PrintDeliveryState state, {
    String? error,
  }) => database
      .into(database.androidPrintJobs)
      .insertOnConflictUpdate(
        AndroidPrintJobsCompanion.insert(
          id: request.jobId,
          tenantId: request.tenantId,
          printerId: request.printer.id,
          payload: request.content,
          quantity: request.quantity,
          state: state.name,
          resultUncertain: Value(state == PrintDeliveryState.uncertain),
          attempts: const Value(1),
          lastError: Value(error),
        ),
      );
}
