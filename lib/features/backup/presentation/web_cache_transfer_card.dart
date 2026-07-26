import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

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
            'Browser-local cache transfer',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'Exports cached data and pending drafts only. Laravel remains authoritative. Imports from another tenant or server generation are rejected; imported drafts require review.',
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
                onPressed: busy ? null : _import,
                icon: const Icon(Icons.upload_file),
                label: const Text('Import .cvbackup'),
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
    final database = AndroidCacheDatabase.forWeb(widget.tenantId);
    try {
      final bytes = await WebLocalExportService(
        database,
      ).export(widget.tenantId, await _generation(database));
      await XFile.fromData(
        bytes,
        name: 'codevault-${widget.tenantId}.cvbackup',
        mimeType: 'application/zip',
      ).saveTo('codevault-${widget.tenantId}.cvbackup');
      if (mounted) setState(() => status = 'Browser cache export downloaded.');
    } catch (error) {
      if (mounted) setState(() => status = 'Export failed: $error');
    } finally {
      await database.close();
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _import() async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'CodeVault backup', extensions: ['cvbackup']),
      ],
    );
    if (file == null) return;
    setState(() => busy = true);
    final database = AndroidCacheDatabase.forWeb(widget.tenantId);
    try {
      final report = await WebLocalExportService(database).import(
        await file.readAsBytes(),
        tenantId: widget.tenantId,
        serverGeneration: await _generation(database),
      );
      if (mounted)
        setState(
          () => status =
              'Imported ${report.cachedParts} cached records; ${report.pendingDrafts} drafts require review.',
        );
    } catch (error) {
      if (mounted) setState(() => status = 'Import rejected: $error');
    } finally {
      await database.close();
      if (mounted) setState(() => busy = false);
    }
  }
}
