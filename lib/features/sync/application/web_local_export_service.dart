import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';

import '../data/android_cache_database.dart';
import '../domain/sync_models.dart';

class WebImportReport {
  const WebImportReport({
    required this.cachedParts,
    required this.pendingDrafts,
  });
  final int cachedParts;
  final int pendingDrafts;
}

class PortableAlignmentSafetyExporter implements AlignmentSafetyExporter {
  const PortableAlignmentSafetyExporter(
    this.service,
    this.save, {
    required this.ownerUserId,
  });
  final WebLocalExportService service;
  final Future<String> Function(Uint8List bytes, String filename) save;
  final String ownerUserId;

  @override
  Future<String> createSafetyExport(
    String tenantId,
    int localGeneration,
  ) async {
    final filename = 'codevault-$tenantId-generation-$localGeneration.cvbackup';
    return save(
      await service.export(
        tenantId,
        localGeneration,
        ownerUserId: ownerUserId,
      ),
      filename,
    );
  }
}

class WebLocalExportService {
  const WebLocalExportService(this.database);
  final AndroidCacheDatabase database;

  Future<Uint8List> export(
    String tenantId,
    int generation, {
    required String ownerUserId,
  }) async {
    final parts = await (database.select(
      database.cachedParts,
    )..where((row) => row.tenantId.equals(tenantId))).get();
    final outbox = await (database.select(
      database.syncOutbox,
    )..where((row) => row.tenantId.equals(tenantId))).get();
    final previews = await (database.select(
      database.localLabelPreviews,
    )..where((row) => row.tenantId.equals(tenantId))).get();
    final drafts = await (database.select(
      database.managedRequestDrafts,
    )..where((row) => row.tenantId.equals(tenantId))).get();
    final printLogs = await (database.select(
      database.offlinePrintLogs,
    )..where((row) => row.tenantId.equals(tenantId))).get();
    final payload = utf8.encode(
      jsonEncode({
        'cached_parts': [
          for (final row in parts)
            {
              'id': row.id,
              'payload': jsonDecode(row.payloadJson),
              'version': row.serverVersion,
              'deleted': row.deleted,
              'updated_at': row.updatedAt.toUtc().toIso8601String(),
            },
        ],
        'pending_mutations': [
          for (final row in outbox)
            {
              'id': row.id,
              'entity_type': row.entityType,
              'entity_id': row.entityId,
              'operation': row.operation,
              'payload': jsonDecode(row.payloadJson),
              'base_version': row.baseVersion,
              'idempotency_key': row.idempotencyKey,
            },
        ],
        'local_previews': [
          for (final row in previews)
            {
              'id': row.id,
              'definition': jsonDecode(row.definitionJson),
              'updated_at': row.updatedAt.toUtc().toIso8601String(),
            },
        ],
        'request_drafts': [
          for (final row in drafts)
            {
              'id': row.id,
              'request_type': row.requestType,
              'payload': jsonDecode(row.payloadJson),
              'updated_at': row.updatedAt.toUtc().toIso8601String(),
            },
        ],
        'offline_print_logs': [
          for (final row in printLogs)
            {
              'id': row.id,
              'print_job_id': row.printJobId,
              'payload': jsonDecode(row.payloadJson),
              'created_at': row.createdAt.toUtc().toIso8601String(),
            },
        ],
      }),
    );
    final checksum = base64Encode((await Sha256().hash(payload)).bytes);
    final manifest = jsonEncode({
      'format': 'codevault-web-cache',
      'format_version': 1,
      'schema_version': database.schemaVersion,
      'tenant_id': tenantId,
      'owner_user_id': ownerUserId,
      'generation': generation,
      'payload_sha256': checksum,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    return Uint8List.fromList(
      ZipEncoder().encode(
        Archive()
          ..addFile(ArchiveFile.string('manifest.json', manifest))
          ..addFile(ArchiveFile.bytes('data/browser-cache.json', payload)),
      ),
    );
  }

  Future<WebImportReport> import(
    Uint8List bytes, {
    required String tenantId,
    required String currentUserId,
    required int serverGeneration,
    bool replace = false,
  }) async {
    final archive = ZipDecoder().decodeBytes(bytes, verify: true);
    final manifestFile = archive.findFile('manifest.json');
    final payloadFile = archive.findFile('data/browser-cache.json');
    if (manifestFile == null || payloadFile == null) {
      throw const FormatException('Invalid browser export.');
    }
    final manifest =
        jsonDecode(utf8.decode(manifestFile.content as List<int>))
            as Map<String, dynamic>;
    if (manifest['format'] != 'codevault-web-cache' ||
        manifest['tenant_id'] != tenantId) {
      throw const FormatException(
        'Export belongs to another tenant or format.',
      );
    }
    final ownerUserId = manifest['owner_user_id'] as String?;
    if (ownerUserId != null && ownerUserId != currentUserId) {
      throw StateError(
        'This backup belongs to another signed-in user account.',
      );
    }
    if ((manifest['generation'] as int) < serverGeneration) {
      throw StateError(
        'Browser export is stale; align with Laravel before import.',
      );
    }
    final payload = payloadFile.content as List<int>;
    if (base64Encode((await Sha256().hash(payload)).bytes) !=
        manifest['payload_sha256']) {
      throw const FormatException('Browser export checksum mismatch.');
    }
    final decoded = jsonDecode(utf8.decode(payload)) as Map<String, dynamic>;
    final parts = decoded['cached_parts'] as List;
    final drafts = decoded['pending_mutations'] as List;
    await database.transaction(() async {
      if (replace) {
        await (database.delete(database.cachedParts)
              ..where((row) => row.tenantId.equals(tenantId)))
            .go();
        await (database.delete(database.syncOutbox)
              ..where((row) => row.tenantId.equals(tenantId)))
            .go();
        await (database.delete(database.syncConflicts)
              ..where((row) => row.tenantId.equals(tenantId)))
            .go();
      }
      for (final raw in parts.cast<Map<String, dynamic>>()) {
        final existing =
            await (database.select(database.cachedParts)..where(
                  (row) =>
                      row.tenantId.equals(tenantId) &
                      row.id.equals(raw['id'] as String),
                ))
                .getSingleOrNull();
        if (existing == null) {
          await database
              .into(database.cachedParts)
              .insert(
                CachedPartsCompanion.insert(
                  id: raw['id'] as String,
                  tenantId: tenantId,
                  payloadJson: jsonEncode(raw['payload']),
                  serverVersion: (raw['version'] as num).toInt(),
                  deleted: Value(raw['deleted'] as bool),
                  updatedAt: DateTime.parse(raw['updated_at'] as String),
                ),
              );
        }
      }
      for (final raw in drafts.cast<Map<String, dynamic>>()) {
        await database
            .into(database.syncConflicts)
            .insertOnConflictUpdate(
              SyncConflictsCompanion.insert(
                id: raw['id'] as String,
                tenantId: tenantId,
                entityType: raw['entity_type'] as String,
                entityId: raw['entity_id'] as String,
                localPayloadJson: jsonEncode(raw['payload']),
                serverPayloadJson: '{}',
                reason: 'imported_browser_draft_requires_review',
              ),
            );
      }
    });
    return WebImportReport(
      cachedParts: parts.length,
      pendingDrafts: drafts.length,
    );
  }
}
