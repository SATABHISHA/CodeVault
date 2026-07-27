import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../data/android_cache_database.dart';
import '../domain/sync_models.dart';

class SyncEngine {
  SyncEngine(this.database, this.remote, {this.safetyExporter, Uuid? uuid})
    : uuid = uuid ?? const Uuid();
  final AndroidCacheDatabase database;
  final SyncRemoteGateway remote;
  final Uuid uuid;
  final AlignmentSafetyExporter? safetyExporter;

  Future<String> queue({
    required String tenantId,
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
    int? baseVersion,
  }) async {
    final id = uuid.v4();
    await database
        .into(database.syncOutbox)
        .insert(
          SyncOutboxCompanion.insert(
            id: id,
            tenantId: tenantId,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            payloadJson: jsonEncode(payload),
            baseVersion: Value(baseVersion),
            idempotencyKey: uuid.v4(),
            syncStatus: Value(switch (operation) {
              'create' => 'pending_create',
              'update' => 'pending_update',
              'delete' => 'pending_delete',
              _ => 'failed',
            }),
          ),
        );
    return id;
  }

  Future<void> resolveConflict(String conflictId, String choice) async {
    final conflict = await (database.select(
      database.syncConflicts,
    )..where((row) => row.id.equals(conflictId))).getSingle();
    if (!const {
      'keep_server',
      'discard_local',
      'reapply_local',
    }.contains(choice)) {
      throw ArgumentError.value(choice, 'choice');
    }
    if (choice == 'reapply_local') {
      final server =
          jsonDecode(conflict.serverPayloadJson) as Map<String, dynamic>;
      await queue(
        tenantId: conflict.tenantId,
        entityType: conflict.entityType,
        entityId: conflict.entityId,
        operation: 'update',
        payload: jsonDecode(conflict.localPayloadJson) as Map<String, dynamic>,
        baseVersion: (server['version'] as num?)?.toInt(),
      );
    }
    await (database.update(
      database.syncConflicts,
    )..where((row) => row.id.equals(conflictId))).write(
      SyncConflictsCompanion(
        resolution: Value(choice),
        resolvedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> synchronize(String tenantId, {bool connected = true}) async {
    if (!connected) return;
    final metadata = await _metadata(tenantId);
    final state = await remote.generation(tenantId);
    if (state.generation != metadata.generation || state.alignmentRequired) {
      final exporter = safetyExporter;
      if (exporter == null) {
        await (database.update(
          database.syncMetadata,
        )..where((row) => row.tenantId.equals(tenantId))).write(
          const SyncMetadataCompanion(
            alignmentStatus: Value('safety_export_required'),
          ),
        );
        throw StateError('A safety export is required before alignment.');
      }
      final safetyReference = await exporter.createSafetyExport(
        tenantId,
        metadata.generation,
      );
      await _realign(
        tenantId,
        metadata.generation,
        state.generation,
        safetyReference,
      );
      await _pull(tenantId);
      if (state.alignmentId != null) {
        await remote.acknowledgeAlignment(
          tenantId,
          state.alignmentId!,
          state.generation,
        );
      }
      await (database.update(
        database.syncMetadata,
      )..where((row) => row.tenantId.equals(tenantId))).write(
        SyncMetadataCompanion(
          alignmentStatus: const Value('aligned'),
          lastAlignmentReport: Value(
            jsonEncode({
              'safety_export': safetyReference,
              'generation': state.generation,
              'completed_at': DateTime.now().toUtc().toIso8601String(),
            }),
          ),
        ),
      );
    } else {
      await _push(tenantId, metadata.generation);
      await _pull(tenantId);
    }
  }

  Future<void> _push(String tenantId, int generation) async {
    final now = DateTime.now();
    final rows =
        await (database.select(database.syncOutbox)
              ..where(
                (row) =>
                    row.tenantId.equals(tenantId) &
                    row.nextAttemptAt.isSmallerOrEqualValue(now),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
            .get();
    if (rows.isEmpty) return;
    try {
      final result = await remote.push(tenantId, [
        for (final row in rows)
          PushMutation(
            id: row.id,
            entityType: row.entityType,
            entityId: row.entityId,
            operation: row.operation,
            payload: jsonDecode(row.payloadJson) as Map<String, dynamic>,
            idempotencyKey: row.idempotencyKey,
            baseVersion: row.baseVersion,
          ),
      ], generation);
      await database.transaction(() async {
        for (final row in rows) {
          if (result.acceptedIds.contains(row.id)) {
            await (database.delete(
              database.syncOutbox,
            )..where((item) => item.id.equals(row.id))).go();
          } else if (result.conflicts.containsKey(row.id)) {
            await database
                .into(database.syncConflicts)
                .insert(
                  SyncConflictsCompanion.insert(
                    id: uuid.v4(),
                    tenantId: tenantId,
                    entityType: row.entityType,
                    entityId: row.entityId,
                    localPayloadJson: row.payloadJson,
                    serverPayloadJson: jsonEncode(result.conflicts[row.id]),
                    reason: 'version_conflict',
                  ),
                );
            await (database.delete(
              database.syncOutbox,
            )..where((item) => item.id.equals(row.id))).go();
          }
        }
      });
    } catch (error) {
      for (final row in rows) {
        final attempts = row.attempts + 1;
        final delay = Duration(seconds: min(300, pow(2, attempts).toInt()));
        await (database.update(
          database.syncOutbox,
        )..where((item) => item.id.equals(row.id))).write(
          SyncOutboxCompanion(
            attempts: Value(attempts),
            nextAttemptAt: Value(now.add(delay)),
            lastError: Value(error.toString()),
          ),
        );
      }
    }
  }

  Future<void> _pull(String tenantId) async {
    var metadata = await _metadata(tenantId);
    var cursor = metadata.pullCursor;
    var hasMore = false;
    do {
      final page = await remote.pull(tenantId, cursor);
      if (page.generation != metadata.generation) {
        await (database.update(
          database.syncMetadata,
        )..where((row) => row.tenantId.equals(tenantId))).write(
          const SyncMetadataCompanion(
            alignmentStatus: Value('safety_export_required'),
          ),
        );
        throw StateError(
          'Server generation changed during pull; restart alignment.',
        );
      }
      await database.transaction(() async {
        for (final change in page.changes.where(
          (item) => item.entityType == 'part',
        )) {
          await database
              .into(database.cachedParts)
              .insertOnConflictUpdate(
                CachedPartsCompanion.insert(
                  id: change.entityId,
                  tenantId: tenantId,
                  payloadJson: jsonEncode(change.payload),
                  serverVersion: change.version,
                  deleted: Value(change.deleted),
                  updatedAt: DateTime.now(),
                ),
              );
        }
        await database
            .into(database.syncMetadata)
            .insertOnConflictUpdate(
              SyncMetadataCompanion.insert(
                tenantId: tenantId,
                pullCursor: Value(page.nextCursor),
                generation: Value(page.generation),
                lastPulledAt: Value(DateTime.now()),
              ),
            );
      });
      cursor = page.nextCursor;
      hasMore = page.hasMore;
    } while (hasMore);
  }

  Future<void> _realign(
    String tenantId,
    int localGeneration,
    int serverGeneration,
    String safetyReference,
  ) async {
    final pending = await (database.select(
      database.syncOutbox,
    )..where((row) => row.tenantId.equals(tenantId))).get();
    await database.transaction(() async {
      for (final row in pending) {
        await database
            .into(database.syncConflicts)
            .insert(
              SyncConflictsCompanion.insert(
                id: uuid.v4(),
                tenantId: tenantId,
                entityType: row.entityType,
                entityId: row.entityId,
                localPayloadJson: row.payloadJson,
                serverPayloadJson: jsonEncode({'generation': serverGeneration}),
                reason: 'tenant_generation_changed',
              ),
            );
      }
      await (database.delete(
        database.syncOutbox,
      )..where((row) => row.tenantId.equals(tenantId))).go();
      await (database.delete(
        database.cachedParts,
      )..where((row) => row.tenantId.equals(tenantId))).go();
      await database
          .into(database.syncMetadata)
          .insertOnConflictUpdate(
            SyncMetadataCompanion.insert(
              tenantId: tenantId,
              pullCursor: const Value(null),
              generation: Value(serverGeneration),
              alignmentStatus: const Value('downloading_authoritative_data'),
              lastAlignmentReport: Value(
                jsonEncode({
                  'safety_export': safetyReference,
                  'from_generation': localGeneration,
                  'to_generation': serverGeneration,
                }),
              ),
            ),
          );
    });
  }

  Future<SyncMetadataData> _metadata(String tenantId) async {
    final existing = await (database.select(
      database.syncMetadata,
    )..where((row) => row.tenantId.equals(tenantId))).getSingleOrNull();
    if (existing != null) return existing;
    await database
        .into(database.syncMetadata)
        .insert(SyncMetadataCompanion.insert(tenantId: tenantId));
    return (database.select(
      database.syncMetadata,
    )..where((row) => row.tenantId.equals(tenantId))).getSingle();
  }
}
