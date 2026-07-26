import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

QueryExecutor openWebDatabase(String tenantId) => LazyDatabase(() async {
  if (!RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(tenantId)) {
    throw ArgumentError.value(tenantId, 'tenantId', 'Expected a UUID');
  }
  final result = await WasmDatabase.open(
    databaseName: 'codevault-$tenantId',
    sqlite3Uri: Uri.parse('assets/web/sqlite3.wasm'),
    driftWorkerUri: Uri.parse('assets/web/drift_worker.js'),
  );
  return result.resolvedExecutor;
});
