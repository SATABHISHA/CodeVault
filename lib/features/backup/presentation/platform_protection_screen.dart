import 'package:flutter/material.dart';

import '../data/platform_protection_service.dart';

class PlatformProtectionScreen extends StatefulWidget {
  const PlatformProtectionScreen({super.key});
  @override
  State<PlatformProtectionScreen> createState() =>
      _PlatformProtectionScreenState();
}

class _PlatformProtectionScreenState extends State<PlatformProtectionScreen> {
  final service = PlatformProtectionService();
  List<dynamic> requests = const [];
  List<dynamic> packages = const [];
  String? error;
  bool busy = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final values = await Future.wait([
        service.requests(),
        service.packages(),
      ]);
      if (mounted) {
        setState(() {
          requests = values[0];
          packages = values[1];
          error = null;
          busy = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          error = 'Platform requests could not be loaded.';
          busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text(
        'Platform data protection',
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
      ),
      const Text(
        'Approve tenant requests, create encrypted packages in Laravel storage, restore once to client devices, then delete retained packages.',
      ),
      const SizedBox(height: 18),
      if (busy) const LinearProgressIndicator(),
      if (error != null)
        Card(
          child: ListTile(
            leading: const Icon(Icons.error_outline),
            title: Text(error!),
            trailing: TextButton(onPressed: _load, child: const Text('Retry')),
          ),
        ),
      Text('Incoming requests', style: Theme.of(context).textTheme.titleLarge),
      for (final raw in requests) _requestCard(raw as Map<String, dynamic>),
      const SizedBox(height: 20),
      Text(
        'Laravel storage packages',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      for (final raw in packages) _packageCard(raw as Map<String, dynamic>),
    ],
  );

  Widget _requestCard(Map<String, dynamic> item) => Card(
    child: ListTile(
      leading: Icon(
        item['type'] == 'restore'
            ? Icons.restore
            : item['type'] == 'backup'
            ? Icons.backup
            : Icons.support_agent,
      ),
      title: Text('${_tenantName(item)} • ${item['type']}'),
      subtitle: Text('${item['reference'] ?? ''} • ${item['status']}'),
      trailing: item['type'] == 'backup'
          ? FilledButton(
              onPressed: () => _act(() => service.createBackup(item)),
              child: const Text('Create backup'),
            )
          : item['type'] == 'restore'
          ? OutlinedButton(
              onPressed: () => _act(() => service.execute(item)),
              child: const Text('Approve restore'),
            )
          : OutlinedButton(
              onPressed: () => _act(() => service.resolveTicket(item)),
              child: const Text('Mark resolved'),
            ),
    ),
  );

  Widget _packageCard(Map<String, dynamic> item) => Card(
    child: ListTile(
      leading: const Icon(Icons.inventory_2_outlined),
      title: Text(item['reference'] as String? ?? 'Protected package'),
      subtitle: Text('${item['status']} • tenant ${item['tenant_id']}'),
      trailing: Wrap(
        spacing: 8,
        children: [
          OutlinedButton(
            onPressed: () => _act(() => service.restoreMerge(item)),
            child: const Text('Restore & sync'),
          ),
          IconButton(
            tooltip: 'Replace and sync',
            onPressed: () => _replace(item),
            icon: const Icon(Icons.find_replace),
          ),
          IconButton(
            tooltip: 'Delete package',
            onPressed: () =>
                _act(() => service.deletePackage(item['id'] as String)),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    ),
  );

  Future<void> _act(Future<void> Function() action) async {
    try {
      await action();
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The action could not be completed. Check its current status and permissions.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _replace(Map<String, dynamic> package) async {
    final company = TextEditingController();
    final password = TextEditingController();
    final reason = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Replace tenant data and sync devices'),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This creates a safety package, replaces the selected tenant dataset, and issues a one-time alignment to its clients.',
              ),
              TextField(
                controller: company,
                decoration: const InputDecoration(
                  labelText: 'Type exact company name',
                ),
              ),
              TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Your platform-owner password',
                ),
              ),
              TextField(
                controller: reason,
                decoration: const InputDecoration(labelText: 'Restore reason'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Replace and sync'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _act(
        () => service.restoreReplace(
          package,
          password: password.text,
          companyName: company.text,
          reason: reason.text,
        ),
      );
    }
  }

  String _tenantName(Map<String, dynamic> item) {
    final tenant = item['tenant'];
    return tenant is Map<String, dynamic>
        ? tenant['name'] as String? ?? 'Company'
        : 'Company';
  }
}
