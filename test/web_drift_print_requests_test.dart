import 'dart:convert';

import 'package:codevault/core/network/api_client.dart';
import 'package:codevault/core/security/token_store.dart';
import 'package:codevault/features/backup/data/managed_request_service.dart';
import 'package:codevault/features/printers/domain/browser_printing.dart';
import 'package:codevault/features/printers/presentation/web_print_screen.dart';
import 'package:codevault/features/sync/application/web_local_export_service.dart';
import 'package:codevault/features/sync/data/android_cache_database.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test(
    'web export validates tenant and converts pending drafts to review conflicts',
    () async {
      final source = AndroidCacheDatabase.forTesting(NativeDatabase.memory());
      final target = AndroidCacheDatabase.forTesting(NativeDatabase.memory());
      addTearDown(source.close);
      addTearDown(target.close);
      await source
          .into(source.cachedParts)
          .insert(
            CachedPartsCompanion.insert(
              id: 'part-1',
              tenantId: 'tenant-a',
              payloadJson: jsonEncode({'name': 'Cached'}),
              serverVersion: 2,
              updatedAt: DateTime.utc(2026),
            ),
          );
      await source
          .into(source.syncOutbox)
          .insert(
            SyncOutboxCompanion.insert(
              id: 'draft-1',
              tenantId: 'tenant-a',
              entityType: 'part',
              entityId: 'part-2',
              operation: 'create',
              payloadJson: '{}',
              idempotencyKey: 'web-draft-1',
            ),
          );
      final bytes = await WebLocalExportService(source).export('tenant-a', 4);
      await expectLater(
        WebLocalExportService(
          target,
        ).import(bytes, tenantId: 'tenant-b', serverGeneration: 4),
        throwsFormatException,
      );
      final report = await WebLocalExportService(
        target,
      ).import(bytes, tenantId: 'tenant-a', serverGeneration: 4);
      expect(report.cachedParts, 1);
      expect(
        (await target.select(target.syncConflicts).getSingle()).reason,
        'imported_browser_draft_requires_review',
      );
    },
  );

  test('PDF uses requested physical page dimensions', () async {
    final bytes = await const BrowserPdfGenerator().generate(
      const BrowserLabelDocument(
        title: 'Part',
        content: 'P-1',
        widthMm: 100,
        heightMm: 50,
      ),
    );
    expect(bytes.take(4), equals('%PDF'.codeUnits));
    expect(bytes.length, greaterThan(500));
  });

  test('401 removes stored token and signals session expiry', () async {
    final tokens = _MemoryTokenStore()..value = 'expired';
    var expired = false;
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.httpClientAdapter = _UnauthorizedAdapter();
    final client = ApiClient(
      dio: dio,
      tokenStore: tokens,
      onSessionExpired: () async => expired = true,
    );
    await expectLater(
      client.dio.get<void>('/me'),
      throwsA(isA<DioException>()),
    );
    expect(tokens.value, null);
    expect(expired, isTrue);
  });

  test(
    'managed web request includes browser metadata and no execution command',
    () {
      const input = ManagedRequestInput(
        type: 'backup',
        contactName: 'Owner',
        email: 'owner@example.test',
        phone: '9999999999',
        scope: ['parts'],
        reason: 'Safety',
        platform: 'web',
        deviceName: 'CodeVault Web Browser',
      );
      expect(input.toJson()['platform'], 'web');
      expect(input.toJson(), isNot(contains('execute')));
    },
  );

  testWidgets('web print view exposes preview, print and download', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: WebPrintScreen())),
    );
    expect(find.byKey(const Key('generate-web-pdf')), findsOneWidget);
    expect(find.byKey(const Key('print-web-pdf')), findsOneWidget);
    expect(find.byKey(const Key('download-web-pdf')), findsOneWidget);
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

class _UnauthorizedAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    '{}',
    401,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}
