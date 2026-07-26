import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;

QueryExecutor openWindowsDatabase(String companyId) {
  final safeId = RegExp(r'^[0-9a-fA-F-]{36}$');
  if (!safeId.hasMatch(companyId)) {
    throw ArgumentError.value(companyId, 'companyId', 'Invalid UUID');
  }
  final localAppData = Platform.environment['LOCALAPPDATA'];
  if (localAppData == null || localAppData.isEmpty) {
    throw StateError('LOCALAPPDATA is unavailable.');
  }
  final companyDirectory = Directory(
    path.join(localAppData, 'Ahanova', 'CodeVault', 'companies', companyId),
  )..createSync(recursive: true);
  return NativeDatabase.createInBackground(
    File(path.join(companyDirectory.path, 'codevault.sqlite')),
    setup: (database) {
      database.execute('PRAGMA foreign_keys = ON');
      database.execute('PRAGMA journal_mode = WAL');
      database.execute('PRAGMA synchronous = FULL');
    },
  );
}
