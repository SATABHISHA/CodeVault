import 'package:drift/drift.dart';

import '../../../platform/windows/data/database_connection.dart';

part 'local_database.g.dart';

class Companies extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 2, max: 160)();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalUsers extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id)();
  TextColumn get username => text().withLength(min: 3, max: 80)();
  TextColumn get displayName => text().withLength(min: 2, max: 120)();
  TextColumn get passwordHash => text()();
  TextColumn get passwordSalt => text()();
  TextColumn get role => text().withDefault(const Constant('operator'))();
  TextColumn get permissionsJson => text().withDefault(const Constant('[]'))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  BoolColumn get mustChangePassword =>
      boolean().withDefault(const Constant(true))();
  IntColumn get failedAttempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get lockedUntil => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {companyId, username},
  ];
}

class Roles extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id)();
  TextColumn get name => text()();
  TextColumn get permissionsJson => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalSettings extends Table {
  TextColumn get companyId => text().references(Companies, #id)();
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column<Object>> get primaryKey => {companyId, key};
}

class Parts extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id)();
  TextColumn get item => text()();
  TextColumn get model => text().nullable()();
  TextColumn get description => text().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Ports extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id)();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get configurationJson => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Printers extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id)();
  TextColumn get name => text()();
  TextColumn get transport => text()();
  TextColumn get language => text()();
  TextColumn get configurationJson => text()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LabelTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id)();
  TextColumn get name => text()();
  TextColumn get language => text()();
  TextColumn get definitionJson => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SerialRules extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id)();
  TextColumn get name => text()();
  TextColumn get symbology => text()();
  TextColumn get ruleJson => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PrintJobs extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id)();
  TextColumn get userId => text().references(LocalUsers, #id)();
  TextColumn get printerId => text().nullable()();
  TextColumn get payload => text()();
  IntColumn get copies => integer()();
  TextColumn get status => text()();
  TextColumn get error => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AuditLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get companyId => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get event => text()();
  TextColumn get detailsJson => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class RecoveryCodes extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get userId => text()();
  TextColumn get codeHash => text()();
  TextColumn get codeSalt => text()();
  DateTimeColumn get expiresAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get usedAt => dateTime().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class BackupReports extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get operation => text()();
  TextColumn get path => text()();
  TextColumn get checksum => text()();
  TextColumn get resultJson => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Companies,
    LocalUsers,
    Roles,
    LocalSettings,
    Parts,
    Ports,
    Printers,
    LabelTemplates,
    SerialRules,
    PrintJobs,
    AuditLogs,
    RecoveryCodes,
    BackupReports,
  ],
)
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase(String companyId) : super(openWindowsDatabase(companyId));
  LocalDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await customStatement('PRAGMA foreign_keys = ON');
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      if (details.wasCreated) {
        await customStatement('PRAGMA user_version = $schemaVersion');
      }
    },
  );

  Future<bool> isInitialized() async =>
      (await select(companies).get()).isNotEmpty;
}
