import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

QueryExecutor openAndroidDatabase(String tenantId) => LazyDatabase(() async {
  if (!RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(tenantId)) {
    throw ArgumentError.value(tenantId, 'tenantId', 'Expected a UUID');
  }
  final directory = await getApplicationSupportDirectory();
  final tenantDirectory = Directory(
    path.join(directory.path, 'tenants', tenantId),
  );
  await tenantDirectory.create(recursive: true);
  final file = File(
    path.join(tenantDirectory.path, 'codevault_android_cache.sqlite'),
  );
  return NativeDatabase.createInBackground(
    file,
    setup: (database) {
      database.execute('PRAGMA foreign_keys = ON');
      database.execute('PRAGMA journal_mode = WAL');
    },
  );
});
