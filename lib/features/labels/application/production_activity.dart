import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/platform/platform_capabilities.dart';
import '../../authentication/presentation/session_controller.dart';
import '../../sync/data/android_cache_database.dart';
import '../../windows_desktop/application/windows_session.dart';
import '../../windows_desktop/data/local_database.dart' as win_db;
import 'package:drift/drift.dart' as drift;

class ProductionActivity {
  const ProductionActivity({this.printed = 0, this.lastJob, this.lastStatus});
  final int printed;
  final DateTime? lastJob;
  final String? lastStatus;
}

class ProductionActivityController extends AsyncNotifier<ProductionActivity> {
  String get _tenantId =>
      ref.read(sessionProvider).tenantId ??
      (PlatformCapabilities.current().isWindows ? (WindowsSession.companyId ?? 'platform-owner') : 'platform-owner');

  @override
  Future<ProductionActivity> build() async {
    final tenantId = _tenantId;
    if (PlatformCapabilities.current().isWindows) {
      final db = win_db.LocalDatabase(tenantId);
      try {
        final total = await db.customSelect(
          'SELECT SUM(copies) as sum FROM print_jobs WHERE company_id = ?',
          variables: [drift.Variable.withString(tenantId)],
        ).getSingle();
        final latest = await db.customSelect(
          'SELECT created_at FROM print_jobs WHERE company_id = ? ORDER BY created_at DESC LIMIT 1',
          variables: [drift.Variable.withString(tenantId)],
        ).getSingleOrNull();
        final sum = total.read<int?>('sum') ?? 0;
        return ProductionActivity(
          printed: sum,
          lastJob: latest != null ? DateTime.fromMillisecondsSinceEpoch(latest.read<int>('created_at') * 1000) : null,
          lastStatus: sum > 0 ? 'Printed successfully' : null,
        );
      } finally {
        await db.close();
      }
    } else {
      final db = kIsWeb
          ? AndroidCacheDatabase.forWeb(tenantId)
          : AndroidCacheDatabase(tenantId);
      try {
        final jobs = await (db.select(db.androidPrintJobs)
              ..where((row) => row.tenantId.equals(tenantId))
              ..orderBy([(row) => drift.OrderingTerm.desc(row.createdAt)]))
            .get();
        final sum = jobs.fold(0, (total, job) => total + job.quantity);
        return ProductionActivity(
          printed: sum,
          lastJob: jobs.isNotEmpty ? jobs.first.createdAt : null,
          lastStatus: sum > 0 ? 'Printed successfully' : null,
        );
      } finally {
        await db.close();
      }
    }
  }

  Future<void> recordPrint(int copies) async {
    final tenantId = _tenantId;
    final now = DateTime.now().toUtc();
    if (PlatformCapabilities.current().isWindows) {
      final db = win_db.LocalDatabase(tenantId);
      try {
        await db.into(db.printJobs).insert(
          win_db.PrintJobsCompanion.insert(
            id: const Uuid().v4(),
            companyId: tenantId,
            userId: ref.read(sessionProvider).userId ?? 'unknown',
            payload: 'Manual Print',
            copies: copies,
            status: 'completed',
          ),
        );
      } finally {
        await db.close();
      }
    } else {
      final db = kIsWeb
          ? AndroidCacheDatabase.forWeb(tenantId)
          : AndroidCacheDatabase(tenantId);
      try {
        await db.into(db.androidPrintJobs).insert(
          AndroidPrintJobsCompanion.insert(
            id: const Uuid().v4(),
            tenantId: tenantId,
            printerId: 'manual',
            payload: 'Manual Print',
            quantity: copies,
            state: 'completed',
            createdAt: drift.Value(now),
          ),
        );
      } finally {
        await db.close();
      }
    }

    // Optimistic update
    final current = state.value ?? const ProductionActivity();
    state = AsyncData(ProductionActivity(
      printed: current.printed + copies,
      lastJob: now,
      lastStatus: 'Printed successfully',
    ));
  }
}

final productionActivityProvider =
    AsyncNotifierProvider<ProductionActivityController, ProductionActivity>(
      ProductionActivityController.new,
    );
