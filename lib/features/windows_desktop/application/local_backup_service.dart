import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:cryptography/cryptography.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../data/local_database.dart';

enum RestoreMode { merge, replace }

class BackupManifest {
  const BackupManifest({
    required this.companyId,
    required this.schemaVersion,
    required this.createdAt,
    required this.databaseSha256,
  });
  final String companyId;
  final int schemaVersion;
  final DateTime createdAt;
  final String databaseSha256;
  Map<String, Object> toJson() => {
    'format': 'codevault-backup',
    'format_version': 1,
    'company_id': companyId,
    'schema_version': schemaVersion,
    'created_at': createdAt.toUtc().toIso8601String(),
    'database_sha256': databaseSha256,
  };
}

class LocalBackupService {
  const LocalBackupService();

  Future<BackupManifest> create({
    required String companyId,
    required File database,
    required File destination,
    Directory? assetsDirectory,
  }) async {
    if (!destination.path.toLowerCase().endsWith('.cvbackup')) {
      throw ArgumentError('Backup path must end in .cvbackup.');
    }
    final databaseBytes = await database.readAsBytes();
    final checksum = await _sha256(databaseBytes);
    final manifest = BackupManifest(
      companyId: companyId,
      schemaVersion: 1,
      createdAt: DateTime.now(),
      databaseSha256: checksum,
    );
    final archive = Archive()
      ..addFile(ArchiveFile.bytes('database/codevault.sqlite', databaseBytes))
      ..addFile(
        ArchiveFile.string('manifest.json', jsonEncode(manifest.toJson())),
      );
    if (assetsDirectory != null && await assetsDirectory.exists()) {
      await for (final entity in assetsDirectory.list(recursive: true)) {
        if (entity is File) {
          final relative = path
              .relative(entity.path, from: assetsDirectory.path)
              .replaceAll('\\', '/');
          archive.addFile(
            ArchiveFile.bytes('assets/$relative', await entity.readAsBytes()),
          );
        }
      }
    }
    final encoded = ZipEncoder().encode(archive);
    await destination.parent.create(recursive: true);
    await destination.writeAsBytes(encoded, flush: true);
    return manifest;
  }

  Future<BackupManifest> verify(File source) async {
    final archive = ZipDecoder().decodeBytes(
      await source.readAsBytes(),
      verify: true,
    );
    final manifestFile = archive.findFile('manifest.json');
    final databaseFile = archive.findFile('database/codevault.sqlite');
    if (manifestFile == null || databaseFile == null) {
      throw const FormatException('Required backup entries are missing.');
    }
    final json =
        jsonDecode(utf8.decode(manifestFile.content as List<int>))
            as Map<String, dynamic>;
    if (json['format'] != 'codevault-backup' || json['format_version'] != 1) {
      throw const FormatException('Unsupported backup format.');
    }
    final checksum = await _sha256(databaseFile.content as List<int>);
    if (checksum != json['database_sha256']) {
      throw const FormatException('Backup integrity verification failed.');
    }
    return BackupManifest(
      companyId: json['company_id'] as String,
      schemaVersion: json['schema_version'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      databaseSha256: checksum,
    );
  }

  Future<Map<String, int>> merge({
    required File source,
    required LocalDatabase target,
  }) async {
    await verify(source);
    final archive = ZipDecoder().decodeBytes(await source.readAsBytes());
    final bytes =
        archive.findFile('database/codevault.sqlite')!.content as List<int>;
    final temporary = File(
      path.join(
        Directory.systemTemp.path,
        'codevault-merge-${const Uuid().v4()}.sqlite',
      ),
    );
    await temporary.writeAsBytes(bytes, flush: true);
    final escaped = temporary.path.replaceAll("'", "''");
    const tables = [
      'parts',
      'ports',
      'printers',
      'label_templates',
      'serial_rules',
    ];
    final report = <String, int>{};
    try {
      await target.customStatement("ATTACH DATABASE '$escaped' AS imported");
      await target.transaction(() async {
        for (final table in tables) {
          final before = await _count(target, table);
          await target.customStatement(
            'INSERT OR IGNORE INTO $table SELECT * FROM imported.$table',
          );
          report[table] = await _count(target, table) - before;
        }
      });
      await target.customStatement('DETACH DATABASE imported');
      return report;
    } catch (_) {
      try {
        await target.customStatement('DETACH DATABASE imported');
      } catch (_) {}
      rethrow;
    } finally {
      if (await temporary.exists()) await temporary.delete();
    }
  }

  Future<int> _count(LocalDatabase database, String table) async {
    final result = await database
        .customSelect('SELECT COUNT(*) AS total FROM $table')
        .getSingle();
    return result.read<int>('total');
  }

  Future<File> replace({
    required File source,
    required File currentDatabase,
  }) async {
    await verify(source);
    final safety = File(
      '${currentDatabase.path}.pre-replace-${const Uuid().v4()}.bak',
    );
    await currentDatabase.copy(safety.path);
    final archive = ZipDecoder().decodeBytes(await source.readAsBytes());
    final replacement =
        archive.findFile('database/codevault.sqlite')!.content as List<int>;
    final staged = File(
      path.join(currentDatabase.parent.path, 'codevault.restore.tmp'),
    );
    try {
      await staged.writeAsBytes(replacement, flush: true);
      await currentDatabase.writeAsBytes(
        await staged.readAsBytes(),
        flush: true,
      );
      await staged.delete();
      return safety;
    } catch (_) {
      if (await safety.exists()) await safety.copy(currentDatabase.path);
      if (await staged.exists()) await staged.delete();
      rethrow;
    }
  }

  Future<String> _sha256(List<int> bytes) async =>
      base64Encode((await Sha256().hash(bytes)).bytes);
}
