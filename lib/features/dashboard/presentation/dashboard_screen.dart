import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../authentication/presentation/session_controller.dart';
import '../../labels/application/production_activity.dart';
import '../../labels/data/local_part_repository.dart';
import '../../labels/data/part_repository.dart';
import '../../labels/data/web_local_part_repository.dart';
import '../../labels/data/custom_label_profile_store.dart';
import '../../sync/data/android_cache_database.dart';
import '../../windows_desktop/application/windows_session.dart';
import '../../windows_desktop/data/local_database.dart' show LocalDatabase;
import '../../../core/platform/platform_capabilities.dart';
import '../../backup/application/backup_import_revision.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final activityAsync = ref.watch(productionActivityProvider);
    final activity = activityAsync.value ?? const ProductionActivity();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF684BFF), Color(0xFFAA3DCE), Color(0xFFFF6685)],
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF684BFF).withValues(alpha: .24),
                blurRadius: 32,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 24,
            runSpacing: 20,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Production command center',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Your part master, labels, printers and sync health in one place.',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF5B42DC),
                ),
                onPressed: () => context.go('/studio'),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Create label'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1100
                ? 4
                : constraints.maxWidth >= 600
                ? 2
                : 1;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.05,
              children: [
                _PartsMetric(tenantId: session.tenantId),
                _Metric(
                  icon: Icons.print_rounded,
                  color: const Color(0xFFFF7A59),
                  label: 'Labels printed',
                  value: '${activity.printed}',
                  detail: activity.lastJob == null
                      ? 'No labels printed yet'
                      : 'Latest job completed',
                ),
                _LocalCountMetric(
                  tenantId: session.tenantId,
                  icon: Icons.dashboard_customize_rounded,
                  color: Color(0xFF00B894),
                  label: 'Label templates',
                  source: _LocalMetricSource.templates,
                  detail: 'No tenant templates yet',
                ),
                _LocalCountMetric(
                  tenantId: session.tenantId,
                  icon: Icons.print_outlined,
                  color: Color(0xFF008CCF),
                  label: 'Active printers',
                  source: _LocalMetricSource.printers,
                  detail: 'No tenant printers configured',
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth >= 850
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _ProductionChart(total: activity.printed),
                    ),
                    SizedBox(width: 16),
                    Expanded(flex: 2, child: _RecentJobs(activity: activity)),
                  ],
                )
              : Column(
                  children: [
                    _ProductionChart(total: activity.printed),
                    SizedBox(height: 16),
                    _RecentJobs(activity: activity),
                  ],
                ),
        ),
        const SizedBox(height: 22),
        Text(
          'Quick actions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _Action(
              icon: Icons.qr_code_2,
              color: const Color(0xFF7048E8),
              title: 'QR & Data Matrix',
              subtitle: 'Design and print',
              onTap: () => context.go('/studio'),
            ),
            _Action(
              icon: Icons.print_outlined,
              color: const Color(0xFF008FA8),
              title: 'Printer setup',
              subtitle: 'Connect and test',
              onTap: () => context.go('/printers'),
            ),

            _Action(
              icon: Icons.support_agent,
              color: const Color(0xFFFF5C8A),
              title: 'Get support',
              subtitle: 'Create managed request',
              onTap: () => context.go('/support'),
            ),
          ],
        ),
      ],
    );
  }
}

class _PartsMetric extends StatelessWidget {
  const _PartsMetric({required this.tenantId});
  final String? tenantId;

  PartRepository _getRepo(String activeTenant) {
    if (PlatformCapabilities.current().isWindows) {
      return LocalPartRepository(LocalDatabase(activeTenant));
    }
    return WebLocalPartRepository();
  }

  @override
  Widget build(BuildContext context) {
    final activeTenant = tenantId ?? WindowsSession.companyId;
    return ValueListenableBuilder<int>(
      valueListenable: backupImportRevision,
      builder: (context, revision, child) => FutureBuilder<int>(
        key: ValueKey((activeTenant, revision)),
        future: activeTenant == null
            ? Future.value(0)
            : _getRepo(
                activeTenant,
              ).list(activeTenant).then((value) => value.length),
        builder: (context, snapshot) => _Metric(
          icon: Icons.inventory_2_rounded,
          color: const Color(0xFF6D5DFB),
          label: 'Active parts',
          value: snapshot.hasError
              ? '0'
              : snapshot.hasData
              ? '${snapshot.data}'
              : '…',
          detail: snapshot.hasError
              ? 'Tenant data could not be loaded'
              : 'Available for production',
        ),
      ),
    );
  }
}

enum _LocalMetricSource { templates, printers }

class _LocalCountMetric extends StatelessWidget {
  const _LocalCountMetric({
    required this.tenantId,
    required this.icon,
    required this.color,
    required this.label,
    required this.source,
    required this.detail,
  });
  final String? tenantId;
  final IconData icon;
  final Color color;
  final String label;
  final _LocalMetricSource source;
  final String detail;

  Future<int> _count() async {
    final effectiveTenant = tenantId ?? 'platform-owner';
    final database = kIsWeb
        ? AndroidCacheDatabase.forWeb(effectiveTenant)
        : AndroidCacheDatabase(effectiveTenant);
    try {
      return switch (source) {
        _LocalMetricSource.templates =>
          (await (database.select(
                database.localLabelPreviews,
              )..where((row) => row.tenantId.equals(effectiveTenant))).get())
              .where(
                (row) =>
                    !row.id.startsWith(CustomLabelProfileStore.recordPrefix),
              )
              .length,
        _LocalMetricSource.printers => (await (database.select(
          database.androidPrinterProfiles,
        )..where((row) => row.tenantId.equals(effectiveTenant))).get()).length,
      };
    } finally {
      await database.close();
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<int>(
    future: _count(),
    builder: (context, snapshot) => _Metric(
      icon: icon,
      color: color,
      label: label,
      value: '${snapshot.data ?? 0}',
      detail: snapshot.hasError ? 'Tenant data could not be loaded' : detail,
    ),
  );
}

class _ProductionChart extends StatelessWidget {
  const _ProductionChart({required this.total});
  final int total;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '7-day label output',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                '$total total',
                style: TextStyle(
                  color: Color(0xFF00B894),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final date = DateTime.now().subtract(Duration(days: 6 - index));
                final weekdays = [
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun',
                ];
                final label = weekdays[date.weekday - 1];
                final isToday = index == 6;
                final height = (isToday && total > 0) ? 1.0 : 0.04;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: height,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Color(0xFF6047F5),
                                      Color(0xFF00BCD4),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          label,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    ),
  );
}

class _RecentJobs extends StatelessWidget {
  const _RecentJobs({required this.activity});
  final ProductionActivity activity;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent production',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          if (activity.lastJob == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text('No production activity for this company yet.'),
              ),
            )
          else
            for (final job in [
              (
                'Latest label job',
                '${activity.printed} labels this session',
                const Color(0xFF00B894),
              ),
            ])
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: CircleAvatar(
                  radius: 17,
                  backgroundColor: job.$3.withValues(alpha: .15),
                  child: Icon(Icons.check, size: 17, color: job.$3),
                ),
                title: Text(
                  job.$1,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(job.$2),
                trailing: const Text(
                  'Completed',
                  style: TextStyle(fontSize: 11),
                ),
              ),
        ],
      ),
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.detail,
  });
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String detail;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .13),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  detail,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 245,
    child: Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: .14),
                foregroundColor: color,
                child: Icon(icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),
        ),
      ),
    ),
  );
}
