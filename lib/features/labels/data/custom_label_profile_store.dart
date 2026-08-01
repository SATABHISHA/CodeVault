import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../../core/platform/platform_capabilities.dart';
import '../../sync/data/android_cache_database.dart';
import '../../windows_desktop/data/local_database.dart';

class CustomLabelProfile {
  const CustomLabelProfile({required this.widthMm, required this.heightMm});

  final double widthMm;
  final double heightMm;

  Map<String, double> toJson() => {'width_mm': widthMm, 'height_mm': heightMm};

  static CustomLabelProfile? fromJson(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    final width = value['width_mm'];
    final height = value['height_mm'];
    if (width is! num || height is! num || width <= 0 || height <= 0) {
      return null;
    }
    return CustomLabelProfile(
      widthMm: width.toDouble(),
      heightMm: height.toDouble(),
    );
  }
}

class CustomLabelProfileStore {
  const CustomLabelProfileStore();

  static const recordPrefix = 'custom-label-profiles:';

  Future<List<CustomLabelProfile>> load({
    required String tenantId,
    required String userId,
  }) async {
    final encoded = await _read(tenantId: tenantId, userId: userId);
    if (encoded == null || encoded.isEmpty) return const [];
    final decoded = jsonDecode(encoded);
    if (decoded is! List) return const [];
    return decoded
        .map(CustomLabelProfile.fromJson)
        .whereType<CustomLabelProfile>()
        .toList();
  }

  Future<void> save({
    required String tenantId,
    required String userId,
    required List<CustomLabelProfile> profiles,
  }) => _write(
    tenantId: tenantId,
    userId: userId,
    encoded: jsonEncode(profiles.map((profile) => profile.toJson()).toList()),
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
