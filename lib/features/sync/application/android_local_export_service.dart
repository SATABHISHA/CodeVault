import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:cryptography/cryptography.dart';

class AndroidExportManifest {
  const AndroidExportManifest({
    required this.tenantId,
    required this.generation,
    required this.checksum,
  });
  final String tenantId;
  final int generation;
  final String checksum;
}

class AndroidLocalExportService {
  const AndroidLocalExportService();
  Future<void> export({
    required String tenantId,
    required int generation,
    required File cacheDatabase,
    required File destination,
  }) async {
    if (!destination.path.toLowerCase().endsWith('.cvbackup')) {
      throw ArgumentError('Export path must end in .cvbackup.');
    }
    final bytes = await cacheDatabase.readAsBytes();
    final checksum = base64Encode((await Sha256().hash(bytes)).bytes);
    final manifest = jsonEncode({
      'format': 'codevault-android-cache',
      'format_version': 1,
      'tenant_id': tenantId,
      'generation': generation,
      'database_sha256': checksum,
    });
    final archive = Archive()
      ..addFile(ArchiveFile.string('manifest.json', manifest))
      ..addFile(
        ArchiveFile.bytes('cache/codevault_android_cache.sqlite', bytes),
      );
    await destination.writeAsBytes(ZipEncoder().encode(archive), flush: true);
  }

  Future<AndroidExportManifest> verify({
    required File source,
    required String tenantId,
    required int serverGeneration,
  }) async {
    final archive = ZipDecoder().decodeBytes(
      await source.readAsBytes(),
      verify: true,
    );
    final manifestFile = archive.findFile('manifest.json');
    final databaseFile = archive.findFile(
      'cache/codevault_android_cache.sqlite',
    );
    if (manifestFile == null || databaseFile == null) {
      throw const FormatException('Invalid Android cache export.');
    }
    final manifest =
        jsonDecode(utf8.decode(manifestFile.content as List<int>))
            as Map<String, dynamic>;
    if (manifest['format'] != 'codevault-android-cache' ||
        manifest['tenant_id'] != tenantId) {
      throw const FormatException(
        'Export belongs to another tenant or format.',
      );
    }
    final generation = manifest['generation'] as int;
    if (generation != serverGeneration) {
      throw StateError(
        'Export generation is stale; server alignment is required.',
      );
    }
    final checksum = base64Encode(
      (await Sha256().hash(databaseFile.content as List<int>)).bytes,
    );
    if (checksum != manifest['database_sha256']) {
      throw const FormatException('Export integrity verification failed.');
    }
    return AndroidExportManifest(
      tenantId: tenantId,
      generation: generation,
      checksum: checksum,
    );
  }
}
