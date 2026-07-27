import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../sync/application/web_local_export_service.dart';
import '../../sync/data/android_cache_database.dart';

class WebCacheTransferCard extends StatefulWidget {
  const WebCacheTransferCard({required this.tenantId, super.key});
  final String tenantId;
  @override
  State<WebCacheTransferCard> createState() => _WebCacheTransferCardState();
}

class _WebCacheTransferCardState extends State<WebCacheTransferCard> {
  bool busy = false;
  String? status;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Company-local data transfer',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'Download this company’s local data, merge missing records without overwriting, or replace this company’s local cache. Files from another company are rejected.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              OutlinedButton.icon(
                key: const Key('export-web-cache'),
                onPressed: busy ? null : _export,
                icon: const Icon(Icons.download),
                label: const Text('Download .cvbackup'),
              ),
              OutlinedButton.icon(
                key: const Key('import-web-cache'),
                onPressed: busy ? null : () => _import(replace: false),
                icon: const Icon(Icons.upload_file),
                label: const Text('Merge import'),
              ),
              OutlinedButton.icon(
                key: const Key('replace-local-cache'),
                onPressed: busy ? null : () => _confirmReplace(context),
                icon: const Icon(Icons.find_replace),
                label: const Text('Replace local data'),
              ),
            ],
          ),
          if (status != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(status!),
            ),
        ],
      ),
    ),
  );

  Future<int> _generation(AndroidCacheDatabase database) async =>
      (await (database.select(database.syncMetadata)
                ..where((row) => row.tenantId.equals(widget.tenantId)))
              .getSingleOrNull())
          ?.generation ??
      0;

  Future<void> _export() async {
    setState(() => busy = true);
    final database = kIsWeb
        ? AndroidCacheDatabase.forWeb(widget.tenantId)
        : AndroidCacheDatabase(widget.tenantId);
    try {
      final bytes = await WebLocalExportService(
        database,
      ).export(widget.tenantId, await _generation(database));
      final file = XFile.fromData(
        bytes,
        name: 'codevault-${widget.tenantId}.cvbackup',
        mimeType: 'application/zip',
      );
      final filename = 'codevault-${widget.tenantId}.cvbackup';
      if (kIsWeb) {
        await file.saveTo(filename);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        await file.saveTo(p.join(directory.path, filename));
      }
      if (mounted) setState(() => status = 'Company-local backup saved.');
    } catch (error) {
      if (mounted) setState(() => status = 'Export failed: $error');
    } finally {
      await database.close();
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _confirmReplace(BuildContext context) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Replace local company data?'),
        content: const Text('Only the signed-in company’s local cache will be replaced. Laravel data and other companies are unaffected.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Replace')),
        ],
      ),
    );
    if (approved == true) await _import(replace: true);
  }

  Future<void> _import({required bool replace}) async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'CodeVault backup', extensions: ['cvbackup']),
      ],
    );
    if (file == null) return;
    setState(() => busy = true);
    final database = kIsWeb
        ? AndroidCacheDatabase.forWeb(widget.tenantId)
        : AndroidCacheDatabase(widget.tenantId);
    try {
      final report = await WebLocalExportService(database).import(
        await file.readAsBytes(),
        tenantId: widget.tenantId,
        serverGeneration: await _generation(database),
        replace: replace,
      );
      if (mounted) {
        setState(
          () => status =
              '${replace ? 'Replaced with' : 'Merged'} ${report.cachedParts} cached records; ${report.pendingDrafts} drafts require review.',
        );
      }
    } catch (error) {
      if (mounted) setState(() => status = 'Import rejected: $error');
    } finally {
      await database.close();
      if (mounted) setState(() => busy = false);
    }
  }
}
