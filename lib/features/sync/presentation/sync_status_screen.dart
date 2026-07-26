import 'package:flutter/material.dart';

class SyncStatusScreen extends StatelessWidget {
  const SyncStatusScreen({
    super.key,
    this.pending = 0,
    this.conflicts = 0,
    this.connected = true,
  });
  final int pending;
  final int conflicts;
  final bool connected;
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
        ),
      ),
      const Card(
        child: ListTile(
          leading: Icon(Icons.restore_page),
          title: Text('Generation-aware alignment'),
          subtitle: Text(
            'After a server restore, stale cached rows are discarded and pending edits are preserved as conflicts instead of overriding cloud data.',
          ),
        ),
      ),
    ],
  );
}
