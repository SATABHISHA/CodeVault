import 'package:codevault/shared/widgets/loading_skeleton.dart';
import 'package:codevault/shared/widgets/status_badge.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text(
        'Operations overview',
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      Text(
        'Monitor labels, printers and synchronization across your company.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(height: 24),
      LayoutBuilder(
        builder: (_, constraints) {
          final columns = constraints.maxWidth >= 900
              ? 3
              : constraints.maxWidth >= 560
              ? 2
              : 1;
          return GridView.count(
            crossAxisCount: columns,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.1,
            children: const [
              _MetricCard(
                icon: Icons.inventory_2_outlined,
                title: 'Parts',
                value: '—',
                badge: StatusBadge(label: 'Ready', tone: StatusTone.success),
              ),
              _MetricCard(
                icon: Icons.print_outlined,
                title: 'Print jobs',
                value: '—',
                badge: StatusBadge(label: 'Idle', tone: StatusTone.neutral),
              ),
              _MetricCard(
                icon: Icons.sync_outlined,
                title: 'Synchronization',
                value: '—',
                badge: StatusBadge(label: 'Checking', tone: StatusTone.info),
              ),
            ],
          );
        },
      ),
      const SizedBox(height: 24),
      const LoadingSkeleton(lines: 4),
    ],
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.badge,
  });
  final IconData icon;
  final String title;
  final String value;
  final Widget badge;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(icon, size: 34, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          badge,
        ],
      ),
    ),
  );
}
