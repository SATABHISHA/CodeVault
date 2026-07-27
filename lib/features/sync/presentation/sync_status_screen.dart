import 'package:flutter/material.dart';

class SyncStatusScreen extends StatelessWidget {
  const SyncStatusScreen({
    super.key,
    this.pending = 0,
    this.conflicts = 0,
    this.connected = true,
    this.failed = 0,
    this.alignmentRequired = false,
    this.progress,
    this.onRetry,
    this.onResolve,
    this.onStartAlignment,
  });
  final int pending;
  final int conflicts;
  final bool connected;
  final int failed;
  final bool alignmentRequired;
  final double? progress;
  final VoidCallback? onRetry;
  final VoidCallback? onResolve;
  final VoidCallback? onStartAlignment;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text(
        'Offline synchronization',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const Text(
        'Laravel/MySQL remains authoritative. Device data is a tenant-isolated cache and pending queue.',
      ),
      const SizedBox(height: 18),
      Card(
        child: ListTile(
          leading: Icon(connected ? Icons.cloud_done : Icons.cloud_off),
          title: Text(connected ? 'Connected' : 'Offline'),
          subtitle: const Text(
            'Retries use bounded exponential backoff and idempotency keys.',
          ),
        ),
      ),
      Card(
        child: ListTile(
          key: const Key('failed-sync'),
          leading: const Icon(Icons.error_outline),
          title: const Text('Failed records'),
          subtitle: const Text(
            'Validation and permission failures need review; network failures retry with bounded backoff.',
          ),
          trailing: Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('$failed'),
              OutlinedButton(
                key: const Key('retry-sync'),
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      Card(
        child: ListTile(
          key: const Key('pending-sync'),
          leading: const Icon(Icons.outbox),
          title: const Text('Pending changes'),
          trailing: Text('$pending'),
        ),
      ),
      Card(
        child: ListTile(
          key: const Key('sync-conflicts'),
          leading: const Icon(Icons.merge_type),
          title: const Text('Conflicts requiring review'),
          trailing: Text('$conflicts'),
          subtitle: const Text(
            'Compare local and server values. Keep server, discard local, or reapply as a new versioned mutation.',
          ),
          onTap: onResolve,
        ),
      ),
      Card(
        child: ListTile(
          key: const Key('alignment-wizard'),
          leading: Icon(Icons.restore_page),
          title: Text(
            alignmentRequired
                ? 'Alignment required'
                : 'Generation-aware alignment',
          ),
          subtitle: const Text(
            'After a server restore, stale cached rows are discarded and pending edits are preserved as conflicts instead of overriding cloud data.',
          ),
          trailing: alignmentRequired
              ? FilledButton(
                  onPressed: onStartAlignment,
                  child: const Text('Start safely'),
                )
              : const Icon(Icons.check_circle_outline),
        ),
      ),
      if (progress != null)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: LinearProgressIndicator(
            value: progress,
            semanticsLabel: 'Alignment progress',
          ),
        ),
    ],
  );
}
