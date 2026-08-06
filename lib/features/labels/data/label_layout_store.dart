import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../../core/platform/platform_capabilities.dart';
import '../../sync/data/android_cache_database.dart';
import '../../windows_desktop/data/local_database.dart';
import '../domain/label_layout.dart';

class LabelLayoutStore {
  const LabelLayoutStore();

  static const recordPrefix = 'label-layout:';

  Future<LabelLayout> load({
    required String tenantId,
    required String userId,
  }) async {
    final encoded = await _read(tenantId: tenantId, userId: userId);
    return LabelLayout.fromEncodedJson(encoded);
  }

  Future<void> save({
    required String tenantId,
    required String userId,
    required LabelLayout layout,
  }) => _write(
    tenantId: tenantId,
    userId: userId,
    encoded: layout.toEncodedJson(),
  );

  Future<String?> _read({
    required String tenantId,
    required String userId,
  }) async {
    final key = '$recordPrefix$userId';
    if (PlatformCapabilities.current().isWindows) {
      final database = LocalDatabase(tenantId);
      try {
        return (await (database.select(database.localSettings)..where(
                  (row) => row.companyId.equals(tenantId) & row.key.equals(key),
                ))
                .getSingleOrNull())
            ?.value;
      } finally {
        await database.close();
      }
    }
    final database = kIsWeb
        ? AndroidCacheDatabase.forWeb(tenantId)
        : AndroidCacheDatabase(tenantId);
    try {
      return (await (database.select(database.localLabelPreviews)..where(
                (row) => row.tenantId.equals(tenantId) & row.id.equals(key),
              ))
              .getSingleOrNull())
          ?.definitionJson;
    } finally {
      await database.close();
    }
  }

  Future<void> _write({
    required String tenantId,
    required String userId,
    required String encoded,
  }) async {
    final key = '$recordPrefix$userId';
    if (PlatformCapabilities.current().isWindows) {
      final database = LocalDatabase(tenantId);
      try {
        await database
            .into(database.localSettings)
            .insertOnConflictUpdate(
              LocalSettingsCompanion.insert(
                companyId: tenantId,
                key: key,
                value: encoded,
              ),
            );
      } finally {
        await database.close();
      }
      return;
    }
    final database = kIsWeb
        ? AndroidCacheDatabase.forWeb(tenantId)
        : AndroidCacheDatabase(tenantId);
    try {
      await database
          .into(database.localLabelPreviews)
          .insertOnConflictUpdate(
            LocalLabelPreviewsCompanion.insert(
              id: key,
              tenantId: tenantId,
              definitionJson: encoded,
              updatedAt: Value(DateTime.now()),
            ),
          );
    } finally {
      await database.close();
    }
  }
}
