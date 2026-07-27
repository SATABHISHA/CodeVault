import 'dart:convert';
import 'dart:io';

import 'package:codevault/core/network/api_client.dart';
import 'package:codevault/core/security/token_store.dart';
import 'package:codevault/features/authentication/data/remote_auth_service.dart';
import 'package:codevault/features/backup/data/managed_request_service.dart';
import 'package:codevault/features/printers/domain/wireless_printing.dart';
import 'package:codevault/features/printers/presentation/android_printer_screen.dart';
import 'package:codevault/features/sync/application/sync_engine.dart';
import 'package:codevault/features/sync/application/android_local_export_service.dart';
import 'package:codevault/features/sync/data/android_cache_database.dart';
import 'package:codevault/features/sync/domain/sync_models.dart';
import 'package:codevault/features/sync/presentation/sync_status_screen.dart';
import 'package:codevault/platform/android/permissions/printer_permission_policy.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AndroidCacheDatabase database;
  late _FakeSyncGateway gateway;
  late SyncEngine engine;
  setUp(() {
    database = AndroidCacheDatabase.forTesting(NativeDatabase.memory());
    gateway = _FakeSyncGateway();
    engine = SyncEngine(
      database,
      gateway,
      safetyExporter: _FakeSafetyExporter(),
    );
  });
  tearDown(() => database.close());

  test('Sanctum login stores token and resolves tenant session', () async {
    final tokens = _MemoryTokenStore();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.endsWith('/auth/login')) {
            handler.resolve(
              Response(
                requestOptions: options,
                data: {
                  'data': {
                    'token': 'secret-token',
                    'must_change_password': false,
                    'device_id': 'device-1',
                    'user': {
                      'id': 'user-1',
                      'tenant_id': 'tenant-a',
                      'roles': [],
                    },
                  },
                },
              ),
            );
          } else {
            handler.resolve(
              Response(
                requestOptions: options,
                data: {
                  'data': {'id': 'user-1', 'tenant_id': 'tenant-a'},
                },
              ),
            );
          }
        },
      ),
    );
    final service = RemoteAuthService(
      client: ApiClient(dio: dio, tokenStore: tokens),
      tokenStore: tokens,
    );
    final session = await service.login(
      login: 'operator',
      password: 'Password@12345',
      deviceName: 'Phone',
      platform: 'android',
    );
    expect(tokens.value, 'secret-token');
    expect(session.tenantId, 'tenant-a');
  });

  test('cache uses tenant plus UUID as identity', () async {
    for (final tenant in ['tenant-a', 'tenant-b']) {
      await database
          .into(database.cachedParts)
          .insert(
            CachedPartsCompanion.insert(
              id: 'part-1',
              tenantId: tenant,
              payloadJson: jsonEncode({'name': tenant}),
              serverVersion: 1,
              updatedAt: DateTime.now(),
            ),
          );
    }
    expect(
      await (database.select(
        database.cachedParts,
      )..where((row) => row.tenantId.equals('tenant-a'))).get(),
      hasLength(1),
    );
    expect(await database.select(database.cachedParts).get(), hasLength(2));
  });

  test(
    'offline mutation queues UUID and idempotency key without network',
    () async {
      final id = await engine.queue(
        tenantId: 'tenant-a',
        entityType: 'part',
        entityId: 'part-1',
        operation: 'update',
        payload: {'name': 'Offline'},
        baseVersion: 2,
      );
      await engine.synchronize('tenant-a', connected: false);
      final row = await database.select(database.syncOutbox).getSingle();
      expect(row.id, id);
      expect(row.idempotencyKey, isNotEmpty);
      expect(gateway.pushCalls, 0);
    },
  );

  test(
    'push is idempotent and conflict is removed from outbox for review',
    () async {
      final id = await engine.queue(
        tenantId: 'tenant-a',
        entityType: 'part',
        entityId: 'part-1',
        operation: 'update',
        payload: {'name': 'Local'},
      );
      gateway.conflicts[id] = {'name': 'Server', 'version': 3};
      await engine.synchronize('tenant-a');
      expect(await database.select(database.syncOutbox).get(), isEmpty);
      expect(
        (await database.select(database.syncConflicts).getSingle()).reason,
        'version_conflict',
      );
    },
  );

  test('connectivity failure schedules bounded retry', () async {
    await engine.queue(
      tenantId: 'tenant-a',
      entityType: 'part',
      entityId: 'part-1',
      operation: 'create',
      payload: {'name': 'Part'},
    );
    gateway.failPush = true;
    await engine.synchronize('tenant-a');
    final row = await database.select(database.syncOutbox).getSingle();
    expect(row.attempts, 1);
    expect(row.nextAttemptAt.isAfter(row.createdAt), isTrue);
  });

  test(
    'server restore generation quarantines pending edits and replaces cache',
    () async {
      await database
          .into(database.syncMetadata)
          .insert(
            SyncMetadataCompanion.insert(
              tenantId: 'tenant-a',
              generation: const Value(1),
            ),
          );
      await database
          .into(database.cachedParts)
          .insert(
            CachedPartsCompanion.insert(
              id: 'stale',
              tenantId: 'tenant-a',
              payloadJson: '{}',
              serverVersion: 1,
              updatedAt: DateTime.now(),
            ),
          );
      await engine.queue(
        tenantId: 'tenant-a',
        entityType: 'part',
        entityId: 'pending',
        operation: 'update',
        payload: {'name': 'Pending'},
      );
      gateway.serverGeneration = 2;
      gateway.pullChanges = [
        const PullChange(
          entityType: 'part',
          entityId: 'fresh',
          payload: {'name': 'Fresh'},
          version: 1,
          deleted: false,
        ),
      ];
      await engine.synchronize('tenant-a');
      expect(
        (await database.select(database.cachedParts).getSingle()).id,
        'fresh',
      );
      expect(
        (await database.select(database.syncConflicts).getSingle()).reason,
        'tenant_generation_changed',
      );
      expect(
        (await database.select(database.syncMetadata).getSingle()).generation,
        2,
      );
      expect(
        (await database.select(database.syncMetadata).getSingle())
            .alignmentStatus,
        'aligned',
      );
    },
  );

  test(
    'alignment refuses destructive replacement without a safety exporter',
    () async {
      final unsafeEngine = SyncEngine(database, gateway);
      gateway.serverGeneration = 2;
      await expectLater(unsafeEngine.synchronize('tenant-a'), throwsStateError);
      expect(
        (await database.select(database.syncMetadata).getSingle())
            .alignmentStatus,
        'safety_export_required',
      );
    },
  );

  test(
    'conflict resolution can keep server or reapply local with server version',
    () async {
      await database
          .into(database.syncConflicts)
          .insert(
            SyncConflictsCompanion.insert(
              id: 'conflict-1',
              tenantId: 'tenant-a',
              entityType: 'part',
              entityId: 'part-1',
              localPayloadJson: '{"name":"Local"}',
              serverPayloadJson: '{"version":4}',
              reason: 'version_conflict',
            ),
          );
      await engine.resolveConflict('conflict-1', 'reapply_local');
      expect(
        (await database.select(database.syncConflicts).getSingle()).resolution,
        'reapply_local',
      );
      expect(
        (await database.select(database.syncOutbox).getSingle()).baseVersion,
        4,
      );
    },
  );

  test('managed request posts Android payload and cannot execute', () async {
    Map<String, dynamic>? sent;
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          sent = Map<String, dynamic>.from(options.data as Map);
          handler.resolve(
            Response(
              requestOptions: options,
              data: {
                'data': {'id': 'request-1'},
              },
            ),
          );
        },
      ),
    );
    final id =
        await ManagedRequestService(
          ApiClient(dio: dio, tokenStore: _MemoryTokenStore()),
        ).submit(
          'tenant-a',
          const ManagedRequestInput(
            type: 'backup',
            contactName: 'Owner',
            email: 'owner@example.test',
            phone: '9999999999',
            scope: ['parts'],
            reason: 'Safety copy',
          ),
        );
    expect(id, 'request-1');
    expect(sent!['platform'], 'android');
    expect(sent, isNot(contains('execute')));
  });

  test(
    'device export verifies tenant, integrity, and server generation',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'android-export-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final cache = File(
        '${directory.path}${Platform.pathSeparator}cache.sqlite',
      )..writeAsStringSync('tenant-cache');
      final output = File(
        '${directory.path}${Platform.pathSeparator}cache.cvbackup',
      );
      const service = AndroidLocalExportService();
      await service.export(
        tenantId: 'tenant-a',
        generation: 4,
        cacheDatabase: cache,
        destination: output,
      );
      expect(
        (await service.verify(
          source: output,
          tenantId: 'tenant-a',
          serverGeneration: 4,
        )).generation,
        4,
      );
      await expectLater(
        service.verify(
          source: output,
          tenantId: 'tenant-b',
          serverGeneration: 4,
        ),
        throwsFormatException,
      );
      await expectLater(
        service.verify(
          source: output,
          tenantId: 'tenant-a',
          serverGeneration: 5,
        ),
        throwsStateError,
      );
    },
  );

  test(
    'uncertain printer result requires explicit retry and completed jobs suppress duplicates',
    () async {
      final repository = _MemoryPrintJobs();
      final transport = _FakePrintTransport()..uncertain = true;
      final service = WirelessPrinterService(
        repository: repository,
        transport: transport,
        adapters: {
          AndroidPrinterLanguage.zpl: const TextCommandAdapter(
            AndroidPrinterLanguage.zpl,
          ),
        },
      );
      const request = WirelessPrintRequest(
        jobId: 'job-1',
        tenantId: 'tenant-a',
        printer: PrinterDescriptor(
          id: 'printer-1',
          name: 'Mock',
          transport: AndroidPrinterTransport.rawTcp,
          address: '192.168.1.10',
        ),
        language: AndroidPrinterLanguage.zpl,
        content: 'LABEL',
        quantity: 1,
      );
      expect(
        (await service.print(request)).state,
        PrintDeliveryState.uncertain,
      );
      await expectLater(
        service.print(request),
        throwsA(isA<RetryConfirmationRequired>()),
      );
      transport.uncertain = false;
      expect(
        (await service.print(request, confirmUncertainRetry: true)).state,
        PrintDeliveryState.completed,
      );
      expect(
        (await service.print(request)).message,
        'Duplicate job suppressed',
      );
      expect(transport.calls, 2);
    },
  );

  test('permission policy avoids broad location on modern Android', () {
    const policy = PrinterPermissionPolicy();
    expect(
      policy.requiredFor(AndroidPrinterTransport.ble, sdkInt: 34),
      containsAll([
        AndroidRuntimePermission.bluetoothScan,
        AndroidRuntimePermission.bluetoothConnect,
      ]),
    );
    expect(
      policy.requiredFor(AndroidPrinterTransport.ble, sdkInt: 34),
      isNot(contains(AndroidRuntimePermission.locationWhenInUse)),
    );
    expect(
      policy.requiredFor(AndroidPrinterTransport.rawTcp, sdkInt: 34),
      isEmpty,
    );
  });

  testWidgets('printer and sync views expose operational controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AndroidPrinterScreen())),
    );
    expect(find.byKey(const Key('discover-printers')), findsOneWidget);
    expect(find.byKey(const Key('test-label')), findsOneWidget);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SyncStatusScreen(pending: 2, conflicts: 1)),
      ),
    );
    expect(find.byKey(const Key('pending-sync')), findsOneWidget);
    expect(find.byKey(const Key('sync-conflicts')), findsOneWidget);
  });
}

class _MemoryTokenStore implements TokenStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String token) async => value = token;
  @override
  Future<void> delete() async => value = null;
}

class _FakeSyncGateway implements SyncRemoteGateway {
  int serverGeneration = 0;
  int pushCalls = 0;
  bool failPush = false;
  final conflicts = <String, Map<String, dynamic>>{};
  List<PullChange> pullChanges = [];
  @override
  Future<GenerationState> generation(String tenantId) async =>
      GenerationState(generation: serverGeneration);
  @override
  Future<void> acknowledgeAlignment(
    String tenantId,
    String alignmentId,
    int generation,
  ) async {}
  @override
  Future<PullPage> pull(String tenantId, String? cursor) async => PullPage(
    changes: pullChanges,
    nextCursor: null,
    generation: serverGeneration,
  );
  @override
  Future<PushResult> push(
    String tenantId,
    List<PushMutation> mutations,
    int generation,
  ) async {
    pushCalls++;
    if (failPush) throw StateError('offline');
    return PushResult(
      acceptedIds: {
        for (final item in mutations)
          if (!conflicts.containsKey(item.id)) item.id,
      },
      conflicts: conflicts,
    );
  }
}

class _FakeSafetyExporter implements AlignmentSafetyExporter {
  @override
  Future<String> createSafetyExport(
    String tenantId,
    int localGeneration,
  ) async => 'memory://$tenantId/$localGeneration.cvbackup';
}

class _MemoryPrintJobs implements PrintJobRepository {
  final states = <String, PrintDeliveryState>{};
  @override
  Future<PrintDeliveryState?> state(String tenantId, String jobId) async =>
      states['$tenantId/$jobId'];
  @override
  Future<void> save(
    WirelessPrintRequest request,
    PrintDeliveryState state, {
    String? error,
  }) async => states['${request.tenantId}/${request.jobId}'] = state;
}

class _FakePrintTransport implements PrintTransport {
  bool uncertain = false;
  int calls = 0;
  @override
  Future<WirelessPrintResult> send(
    WirelessPrintRequest request,
    List<int> bytes,
  ) async {
    calls++;
    if (uncertain) {
      throw const AmbiguousPrintResult('Connection closed after send');
    }
    return WirelessPrintResult(
      jobId: request.jobId,
      state: PrintDeliveryState.completed,
    );
  }
}
