import 'package:codevault/core/platform/platform_capabilities.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../backup/application/backup_import_revision.dart';
import '../application/windows_session.dart';
import '../data/local_database.dart';

class WindowsDashboardScreen extends StatefulWidget {
  const WindowsDashboardScreen({super.key});
  @override
  State<WindowsDashboardScreen> createState() => _WindowsDashboardScreenState();
}

class _WindowsDashboardScreenState extends State<WindowsDashboardScreen> {
  late Future<_LocalMetrics> metrics = _load();

  @override
  void initState() {
    super.initState();
    backupImportRevision.addListener(_backupImported);
  }

  @override
  void dispose() {
    backupImportRevision.removeListener(_backupImported);
    super.dispose();
  }

  void _backupImported() {
    if (mounted) setState(() => metrics = _load());
  }

  Future<_LocalMetrics> _load() async {
    final companyId = WindowsSession.companyId;
    if (companyId == null) return const _LocalMetrics();
    final db = LocalDatabase(companyId);
    try {
      final parts = await (db.select(
        db.parts,
      )..where((row) => row.active.equals(true))).get();
      final templates = await (db.select(
        db.labelTemplates,
      )..where((row) => row.companyId.equals(companyId))).get();
      final printers = await (db.select(
        db.printers,
      )..where((row) => row.active.equals(true))).get();
      final users = await (db.select(
        db.localUsers,
      )..where((row) => row.active.equals(true))).get();
      final jobs = await (db.select(
        db.printJobs,
      )..where((row) => row.companyId.equals(companyId))).get();
      return _LocalMetrics(
        parts: parts.length,
        templates: templates.length,
        printers: printers.length,
        users: users.length,
        labels: jobs.fold(0, (sum, job) => sum + job.copies),
        recent: jobs.reversed.take(4).toList(),
      );
    } finally {
      await db.close();
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_LocalMetrics>(
    future: metrics,
    builder: (context, snapshot) {
      final data = snapshot.data ?? const _LocalMetrics();
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 700),
            tween: Tween(begin: 0, end: 1),
            builder: (_, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 22 * (1 - value)),
                child: child,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6A35FF),
                    Color(0xFFEA4C89),
                    Color(0xFF00A7C4),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6A35FF).withValues(alpha: .25),
                    blurRadius: 32,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 20,
                runSpacing: 16,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        WindowsSession.companyName.isEmpty
                            ? 'Offline production command center'
                            : WindowsSession.companyName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Offline command center • Signed in as ${WindowsSession.role ?? 'local user'}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6038E8),
                    ),
                    onPressed: () => context.go(
                      PlatformCapabilities.current().isWindows
                          ? '/windows/operations'
                          : '/studio',
                    ),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Create label'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) => GridView.count(
              crossAxisCount: constraints.maxWidth >= 900
                  ? 4
                  : constraints.maxWidth >= 520
                  ? 2
                  : 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.05,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              children: [
                _metric(
                  'Active parts',
                  data.parts,
                  Icons.inventory_2,
                  const Color(0xFF6747F5),
                ),
                _metric(
                  'Labels printed',
                  data.labels,
                  Icons.print,
                  const Color(0xFFFF6B57),
                ),
                _metric(
                  'Templates',
                  data.templates,
                  Icons.dashboard_customize,
                  const Color(0xFF00A884),
                ),
                _metric(
                  'Local users',
                  data.users,
                  Icons.groups_2,
                  const Color(0xFF008CCF),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final graph = _graph(context, data.labels);
              final recent = _recent(context, data.recent);
              return constraints.maxWidth >= 850
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: graph),
                        const SizedBox(width: 14),
                        Expanded(flex: 2, child: recent),
                      ],
                    )
                  : Column(
                      children: [graph, const SizedBox(height: 14), recent],
                    );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Quick links',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _action(
                context,
                'Create industrial label',
                'Barcode, QR and Data Matrix',
                Icons.qr_code_2,
                PlatformCapabilities.current().isWindows
                    ? '/windows/operations'
                    : '/studio',
                const Color(0xFF6747F5),
              ),
              _action(
                context,
                'Manage local users',
                'Accounts and password resets',
                Icons.groups_2_outlined,
                '/windows/users',
                const Color(0xFF008F79),
              ),
              _action(
                context,
                'Protect local data',
                'Export, merge or safely replace',
                Icons.shield_outlined,
                '/backup',
                const Color(0xFFE05B55),
              ),
            ],
          ),
        ],
      );
    },
  );

  Widget _graph(BuildContext context, int total) => Card(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '7-day local output',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              Text(
                '$total total',
                style: const TextStyle(
                  color: Color(0xFF00B894),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final day in [
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun',
                ])
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 700),
                                tween: Tween(
                                  begin: 0,
                                  end: day == 'Sun' && total > 0 ? 1 : .04,
                                ),
                                builder: (_, value, child) =>
                                    FractionallySizedBox(
                                      heightFactor: value,
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
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            day,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _recent(BuildContext context, List<PrintJob> jobs) => Card(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent local production',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          if (jobs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 34),
              child: Center(child: Text('No labels printed yet.')),
            ),
          for (final job in jobs)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.check, size: 18)),
              title: Text('${job.copies} label${job.copies == 1 ? '' : 's'}'),
              subtitle: Text(job.createdAt.toLocal().toString()),
              trailing: Text(job.status),
            ),
        ],
      ),
    ),
  );

  static Widget _metric(String title, int value, IconData icon, Color color) =>
      Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: color.withValues(alpha: .14),
                foregroundColor: color,
                child: Icon(icon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title),
                    Text(
                      '$value',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'Stored on this computer',
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  static Widget _action(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    String route,
    Color color,
  ) => SizedBox(
    width: 310,
    child: Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.go(route),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withValues(alpha: .15),
                foregroundColor: color,
                child: Icon(icon),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(subtitle),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ),
    ),
  );
}

class _LocalMetrics {
  const _LocalMetrics({
    this.parts = 0,
    this.labels = 0,
    this.templates = 0,
    this.printers = 0,
    this.users = 0,
    this.recent = const [],
  });
  final int parts;
  final int labels;
  final int templates;
  final int printers;
  final int users;
  final List<PrintJob> recent;
}
