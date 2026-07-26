import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';

import '../data/android_cache_database.dart';

class WebImportReport {
  const WebImportReport({
    required this.cachedParts,
    required this.pendingDrafts,
  });
  final int cachedParts;
  final int pendingDrafts;
}

class WebLocalExportService {
  const WebLocalExportService(this.database);
  final AndroidCacheDatabase database;

  Future<Uint8List> export(String tenantId, int generation) async {
    final parts = await (database.select(
      database.cachedParts,
    )..where((row) => row.tenantId.equals(tenantId))).get();
    final outbox = await (database.select(
      database.syncOutbox,
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
      }),
    );
    final checksum = base64Encode((await Sha256().hash(payload)).bytes);
    final manifest = jsonEncode({
      'format': 'codevault-web-cache',
      'format_version': 1,
      'schema_version': database.schemaVersion,
      'tenant_id': tenantId,
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
    required int serverGeneration,
  }) async {
    final archive = ZipDecoder().decodeBytes(bytes, verify: true);
    final manifestFile = archive.findFile('manifest.json');
    final payloadFile = archive.findFile('data/browser-cache.json');
    if (manifestFile == null || payloadFile == null)
      throw const FormatException('Invalid browser export.');
    final manifest =
        jsonDecode(utf8.decode(manifestFile.content as List<int>))
            as Map<String, dynamic>;
    if (manifest['format'] != 'codevault-web-cache' ||
        manifest['tenant_id'] != tenantId) {
      throw const FormatException(
        'Export belongs to another tenant or format.',
      );
    }
    if (manifest['generation'] != serverGeneration)
      throw StateError(
        'Browser export is stale; align with Laravel before import.',
      );
    final payload = payloadFile.content as List<int>;
    if (base64Encode((await Sha256().hash(payload)).bytes) !=
        manifest['payload_sha256']) {
      throw const FormatException('Browser export checksum mismatch.');
    }
    final decoded = jsonDecode(utf8.decode(payload)) as Map<String, dynamic>;
    final parts = decoded['cached_parts'] as List;
    final drafts = decoded['pending_mutations'] as List;
    await database.transaction(() async {
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
