import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../../core/platform/platform_capabilities.dart';
import '../../sync/data/android_cache_database.dart';
import '../../windows_desktop/data/local_database.dart';
import '../domain/code_type_visibility.dart';

class CodeTypeVisibilityStore {
  const CodeTypeVisibilityStore();

  static const recordPrefix = 'visible-code-types:';

  Future<Set<String>> load({
    required String tenantId,
    required String userId,
  }) async {
    final encoded = await _read(tenantId: tenantId, userId: userId);
    if (encoded == null || encoded.isEmpty) {
      return Set.of(CodeTypeVisibility.all);
    }
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! List) return Set.of(CodeTypeVisibility.all);
      return CodeTypeVisibility.sanitize(decoded.whereType<String>());
    } on FormatException {
      return Set.of(CodeTypeVisibility.all);
    }
  }

  Future<void> save({
    required String tenantId,
    required String userId,
    required Set<String> visibleTypes,
  }) => _write(
    tenantId: tenantId,
    userId: userId,
    encoded: jsonEncode(CodeTypeVisibility.sanitize(visibleTypes).toList()),
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
