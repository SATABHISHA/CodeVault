import 'package:codevault/features/sync/data/android_cache_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Drift Wasm browser database persists after reopen', () async {
    if (!kIsWeb) return;
    const tenantId = '11111111-1111-4111-8111-111111111111';
    final first = AndroidCacheDatabase.forWeb(tenantId);
    await first
        .into(first.cachedParts)
        .insertOnConflictUpdate(
          CachedPartsCompanion.insert(
            id: '22222222-2222-4222-8222-222222222222',
            tenantId: tenantId,
            payloadJson: '{"name":"Persistent"}',
            serverVersion: 1,
            updatedAt: DateTime.utc(2026, 7, 26),
          ),
        );
    await first.close();

    final reopened = AndroidCacheDatabase.forWeb(tenantId);
    final row = await (reopened.select(
      reopened.cachedParts,
    )..where((item) => item.tenantId.equals(tenantId))).getSingle();
    expect(row.payloadJson, contains('Persistent'));
    await reopened.delete(reopened.cachedParts).go();
    await reopened.close();
  });
}
