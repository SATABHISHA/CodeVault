import 'package:drift/drift.dart';

import '../../../platform/android/data/android_database_connection.dart';
import '../../../platform/web/data/web_database_connection.dart';

part 'android_cache_database.g.dart';

class CachedParts extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get payloadJson => text()();
  IntColumn get serverVersion => integer()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {tenantId, id};
}

class SyncOutbox extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get payloadJson => text()();
  IntColumn get baseVersion => integer().nullable()();
  TextColumn get idempotencyKey => text().unique()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SyncConflicts extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get localPayloadJson => text()();
  TextColumn get serverPayloadJson => text()();
  TextColumn get reason => text()();
  DateTimeColumn get detectedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SyncMetadata extends Table {
  TextColumn get tenantId => text()();
  TextColumn get pullCursor => text().nullable()();
  IntColumn get generation => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPulledAt => dateTime().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {tenantId};
}

class AndroidPrintJobs extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get printerId => text()();
  TextColumn get payload => text()();
  IntColumn get quantity => integer()();
  TextColumn get state => text()();
  BoolColumn get resultUncertain =>
      boolean().withDefault(const Constant(false))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AndroidPrinterProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get name => text()();
  TextColumn get transport => text()();
  TextColumn get language => text()();
  TextColumn get address => text()();
  TextColumn get portId => text().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  @override
  Set<Column<Object>> get primaryKey => {tenantId, id};
}

@DriftDatabase(
  tables: [
    CachedParts,
    SyncOutbox,
    SyncConflicts,
    SyncMetadata,
    AndroidPrintJobs,
    AndroidPrinterProfiles,
  ],
)
class AndroidCacheDatabase extends _$AndroidCacheDatabase {
  AndroidCacheDatabase(String tenantId) : super(openAndroidDatabase(tenantId));
  AndroidCacheDatabase.forWeb(String tenantId)
    : super(openWebDatabase(tenantId));
  AndroidCacheDatabase.forTesting(super.executor);
  @override
  int get schemaVersion => 1;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
  );
}
