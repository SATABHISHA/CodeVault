import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import '../../../platform/windows/data/bootstrap_store.dart';
import '../../windows_desktop/application/local_backup_service.dart';
import '../../windows_desktop/data/local_database.dart';

class LocalBackupPanel extends StatefulWidget {
  const LocalBackupPanel({required this.userId, super.key});
  final String userId;
  @override
  State<LocalBackupPanel> createState() => _LocalBackupPanelState();
}

class _LocalBackupPanelState extends State<LocalBackupPanel> {
  bool busy = false;
  String status = 'Choose an action to protect or restore local company data.';
  final service = const LocalBackupService();

  Future<(String, File)> _database() async {
    final companyId = await createBootstrapStore().readCompanyId();
    if (companyId == null) {
      throw StateError('Local company is not initialized.');
    }
    final base = Platform.environment['LOCALAPPDATA'];
    if (base == null) throw StateError('LOCALAPPDATA is unavailable.');
    return (
      companyId,
      File(
        path.join(
          base,
          'Ahanova',
          'CodeVault',
          'companies',
          companyId,
          'codevault.sqlite',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Local Windows backup',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Text(
            'Cloud requests are intentionally unavailable on Windows; all files remain under local administrator control.',
          ),
          const SizedBox(height: 6),
          Text(status),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: busy ? null : _export,
                icon: const Icon(Icons.download),
                label: const Text('Create local backup'),
              ),
              OutlinedButton.icon(
                onPressed: busy ? null : () => _import(RestoreMode.merge),
                icon: const Icon(Icons.merge),
                label: const Text('Import & merge'),
              ),
              OutlinedButton.icon(
                onPressed: busy ? null : () => _confirmReplace(),
                icon: const Icon(Icons.find_replace),
                label: const Text('Replace database'),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Future<void> _export() async {
    final target = await getSaveLocation(
      suggestedName:
          'codevault-${DateTime.now().millisecondsSinceEpoch}.cvbackup',
      acceptedTypeGroups: const [
        XTypeGroup(label: 'CodeVault backup', extensions: ['cvbackup']),
      ],
    );
    if (target == null) return;
    await _run(() async {
      final value = await _database();
      await service.create(
        companyId: value.$1,
        ownerUserId: widget.userId,
        database: value.$2,
        destination: File(target.path),
      );
      return 'Backup saved to ${target.path}.';
    });
  }

  Future<void> _import(RestoreMode mode) async {
    final source = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'CodeVault backup', extensions: ['cvbackup']),
      ],
    );
    if (source == null) return;
    await _run(() async {
      final value = await _database();
      final manifest = await service.verify(File(source.path));
      if (manifest.companyId != value.$1) {
        throw StateError('This backup belongs to another company.');
      }
      if (manifest.ownerUserId != null && manifest.ownerUserId != widget.userId) {
        throw StateError('This backup belongs to another signed-in user account.');
      }
      if (mode == RestoreMode.merge) {
        final database = LocalDatabase(value.$1);
        try {
          final report = await service.merge(
            source: File(source.path),
            target: database,
          );
          return 'Merge complete: ${report.values.fold<int>(0, (a, b) => a + b)} new records; existing records kept.';
        } finally {
          await database.close();
        }
      }
      final safety = await service.replace(
        source: File(source.path),
        currentDatabase: value.$2,
      );
      return 'Database replaced. Safety copy: ${safety.path}';
    });
  }

  Future<void> _confirmReplace() async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Replace local database?'),
            content: const Text(
              'The current database will be preserved as a safety copy before replacement. Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Replace safely'),
              ),
            ],
          ),
        ) ??
        false;
    if (confirmed) {
      await _import(RestoreMode.replace);
    }
  }

  Future<void> _run(Future<String> Function() action) async {
    setState(() => busy = true);
    try {
      final message = await action();
      if (mounted) {
        setState(() => status = message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => status = 'Action failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }
}
