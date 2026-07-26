import 'dart:io';

import 'package:codevault/features/backup/presentation/backup_screen.dart';
import 'package:codevault/core/platform/platform_capabilities.dart';
import 'package:codevault/features/windows_desktop/application/local_account_service.dart';
import 'package:codevault/features/windows_desktop/application/local_backup_service.dart';
import 'package:codevault/features/windows_desktop/application/offline_recovery_service.dart';
import 'package:codevault/features/windows_desktop/data/local_database.dart';
import 'package:codevault/features/windows_desktop/domain/printer.dart';
import 'package:codevault/features/windows_desktop/presentation/operations_screen.dart';
import 'package:codevault/features/windows_desktop/presentation/windows_entry_screen.dart';
import 'package:codevault/platform/windows/data/bootstrap_store.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late LocalDatabase database;
  late LocalAccountService accounts;
  setUp(() {
    database = LocalDatabase.forTesting(NativeDatabase.memory());
    accounts = LocalAccountService(database);
  });
  tearDown(() => database.close());

  test('first run creates company and mandatory-change local admin', () async {
    final companyId = await _initialize(accounts);
    final company = await database.select(database.companies).getSingle();
    final admin = await database.select(database.localUsers).getSingle();
    expect(company.id, companyId);
    expect(admin.role, 'admin');
    expect(admin.mustChangePassword, isTrue);
    expect(admin.passwordHash, isNot('CorrectHorseBattery!1'));
  });

  test('local login returns admin permissions and audits success', () async {
    await _initialize(accounts);
    final result = await accounts.login('owner', 'CorrectHorseBattery!1');
    expect(
      result.permissions,
      containsAll(['users.manage', 'backup.manage', 'print.execute']),
    );
    expect(
      (await database.select(database.auditLogs).get()).map((row) => row.event),
      contains('auth.login'),
    );
  });

  test('five invalid local logins lock the account', () async {
    await _initialize(accounts);
    for (var attempt = 0; attempt < 5; attempt++) {
      await expectLater(
        accounts.login('owner', 'IncorrectPassword!1'),
        throwsStateError,
      );
    }
    final admin = await database.select(database.localUsers).getSingle();
    expect(admin.failedAttempts, 5);
    expect(admin.lockedUntil, isA<DateTime>());
  });

  test(
    'offline recovery is confirmed, six-digit, one-use, and forces change',
    () async {
      await _initialize(accounts);
      final recovery = OfflineRecoveryService(database);
      await expectLater(recovery.create('owner'), throwsStateError);
      final challenge = await recovery.create('owner', confirmed: true);
      expect(challenge.code, matches(RegExp(r'^\d{6}$')));
      expect(await recovery.consume(challenge.id, challenge.code), isTrue);
      expect(await recovery.consume(challenge.id, challenge.code), isFalse);
      expect(
        (await database.select(database.localUsers).getSingle())
            .mustChangePassword,
        isTrue,
      );
    },
  );

  test('part and template records remain company-local', () async {
    final companyId = await _initialize(accounts);
    await database
        .into(database.parts)
        .insert(
          PartsCompanion.insert(
            id: const Uuid().v4(),
            companyId: companyId,
            item: 'Bearing',
            model: const Value('6204'),
          ),
        );
    await database
        .into(database.labelTemplates)
        .insert(
          LabelTemplatesCompanion.insert(
            id: const Uuid().v4(),
            companyId: companyId,
            name: 'Bearing label',
            language: 'zpl',
            definitionJson: '{}',
          ),
        );
    expect(await database.select(database.parts).get(), hasLength(1));
    expect(await database.select(database.labelTemplates).get(), hasLength(1));
  });

  test(
    'admin manages user permissions, activation, and temporary password reset',
    () async {
      final companyId = await _initialize(accounts);
      final admin = await database.select(database.localUsers).getSingle();
      final temporary = await accounts.createUser(
        companyId: companyId,
        actorId: admin.id,
        username: 'operator',
        displayName: 'Operator',
        permissions: {'print.execute'},
      );
      expect(temporary.length, 16);
      var operator = await (database.select(
        database.localUsers,
      )..where((row) => row.username.equals('operator'))).getSingle();
      await accounts.editUser(
        userId: operator.id,
        actorId: admin.id,
        displayName: 'Senior Operator',
        permissions: {'print.execute', 'parts.manage'},
      );
      await accounts.setActive(operator.id, false, admin.id);
      operator = await (database.select(
        database.localUsers,
      )..where((row) => row.id.equals(operator.id))).getSingle();
      expect(operator.displayName, 'Senior Operator');
      expect(operator.active, isFalse);
      final reset = await accounts.resetPassword(operator.id, admin.id);
      expect(reset.length, 16);
      expect(
        (await database.select(database.auditLogs).get()).map(
          (row) => row.event,
        ),
        containsAll([
          'user.created',
          'user.updated',
          'user.activation_changed',
          'user.password_reset',
        ]),
      );
    },
  );

  test('backup verifies integrity and replace creates safety copy', () async {
    final directory = await Directory.systemTemp.createTemp(
      'codevault-backup-test-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final databaseFile = File(
      '${directory.path}${Platform.pathSeparator}codevault.sqlite',
    )..writeAsStringSync('sqlite-snapshot');
    final destination = File(
      '${directory.path}${Platform.pathSeparator}company.cvbackup',
    );
    const service = LocalBackupService();
    final manifest = await service.create(
      companyId: const Uuid().v4(),
      database: databaseFile,
      destination: destination,
    );
    expect(
      (await service.verify(destination)).databaseSha256,
      manifest.databaseSha256,
    );
    databaseFile.writeAsStringSync('damaged-current');
    final safety = await service.replace(
      source: destination,
      currentDatabase: databaseFile,
    );
    expect(databaseFile.readAsStringSync(), 'sqlite-snapshot');
    expect(safety.readAsStringSync(), 'damaged-current');
  });

  test(
    'merge imports missing operational records and reports counts',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'codevault-merge-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final companyId = const Uuid().v4();
      final sourceFile = File(
        '${directory.path}${Platform.pathSeparator}source.sqlite',
      );
      final sourceDatabase = LocalDatabase.forTesting(
        NativeDatabase(sourceFile),
      );
      await LocalAccountService(sourceDatabase).initializeCompany(
        companyId: companyId,
        name: 'Merge Source',
        username: 'source-admin',
        displayName: 'Source Admin',
        password: 'CorrectHorseBattery!1',
      );
      await sourceDatabase
          .into(sourceDatabase.parts)
          .insert(
            PartsCompanion.insert(
              id: const Uuid().v4(),
              companyId: companyId,
              item: 'Imported Part',
            ),
          );
      await sourceDatabase.close();
      final backup = File(
        '${directory.path}${Platform.pathSeparator}merge.cvbackup',
      );
      const service = LocalBackupService();
      await service.create(
        companyId: companyId,
        database: sourceFile,
        destination: backup,
      );
      await LocalAccountService(database).initializeCompany(
        companyId: companyId,
        name: 'Merge Target',
        username: 'target-admin',
        displayName: 'Target Admin',
        password: 'CorrectHorseBattery!1',
      );
      final report = await service.merge(source: backup, target: database);
      expect(report['parts'], 1);
      expect(
        (await database.select(database.parts).getSingle()).item,
        'Imported Part',
      );
    },
  );

  test('mock printer supports test and deterministic job receipt', () async {
    final printer = MockPrinterAdapter();
    await printer.testConnection();
    final receipt = await printer.print(
      const PrintRequest(jobId: 'job-1', content: 'ABC', copies: 2),
    );
    expect(receipt.jobId, 'job-1');
    expect(printer.jobs, hasLength(1));
  });

  testWidgets('first-run screen is exposed when no company is registered', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: WindowsEntryScreen(store: _MemoryBootstrapStore())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Set up CodeVault'), findsOneWidget);
    expect(find.byKey(const Key('initialize-local-company')), findsOneWidget);
  });

  testWidgets('operations expose all offline print workflow controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: WindowsOperationsScreen())),
    );
    expect(find.text('Select part / item'), findsOneWidget);
    expect(find.text('Serial'), findsOneWidget);
    expect(find.text('Pack quantity'), findsOneWidget);
    expect(find.byKey(const Key('offline-print')), findsOneWidget);
  });

  testWidgets('Windows backup contains no cloud request UI', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BackupScreen(
          capabilities: PlatformCapabilities(AppPlatform.windows),
        ),
      ),
    );
    expect(
      find.textContaining('Cloud requests are intentionally unavailable'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('request-backup')), findsNothing);
    expect(find.byKey(const Key('request-restore')), findsNothing);
  });
}

Future<String> _initialize(LocalAccountService accounts) =>
    accounts.initializeCompany(
      name: 'Ahanova Factory',
      username: 'owner',
      displayName: 'Local Owner',
      password: 'CorrectHorseBattery!1',
    );

class _MemoryBootstrapStore implements BootstrapStore {
  String? value;
  @override
  Future<String?> readCompanyId() async => value;
  @override
  Future<void> writeCompanyId(String companyId) async => value = companyId;
}
