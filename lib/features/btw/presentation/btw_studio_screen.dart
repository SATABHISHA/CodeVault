import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../core/platform/platform_capabilities.dart';
import '../../authentication/presentation/session_controller.dart';
import '../../labels/domain/dynamic_label_field.dart';
import '../../labels/domain/label_field_config.dart';
import '../../labels/presentation/label_studio_screen.dart';
import '../../windows_desktop/application/windows_session.dart';
import '../data/btw_template_repository.dart';
import '../domain/btw_importer.dart';

class BtwStudioScreen extends ConsumerStatefulWidget {
  const BtwStudioScreen({super.key});

  @override
  ConsumerState<BtwStudioScreen> createState() => _BtwStudioScreenState();
}

class _BtwStudioScreenState extends ConsumerState<BtwStudioScreen> {
  final repository = BtwTemplateRepository();
  int editorRevision = 0;
  bool busy = false;
  String status = 'Import a BarTender .btw file to begin.';

  (String, String)? get _identity {
    final session = ref.read(sessionProvider);
    final tenantId = session.tenantId ?? WindowsSession.companyId;
    final userId = session.userId ?? WindowsSession.userId;
    return tenantId == null || userId == null ? null : (tenantId, userId);
  }

  @override
  Widget build(BuildContext context) => LabelStudioScreen(
    key: ValueKey(editorRevision),
    repository: repository,
    workspaceTitle: 'BTW Label Designer',
    workspaceSubtitle:
        'Edit imported BarTender fields, arrange the preview, and print on any supported platform',
    recordCollectionName: 'BTW Template',
    leadingContent: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
          child: _hero(context),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          child: _actions(context),
        ),
      ],
    ),
  );

  Widget _hero(BuildContext context) => Container(
    padding: const EdgeInsets.all(26),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF4C1D95), Color(0xFF7C3AED), Color(0xFFEC4899)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF7C3AED).withValues(alpha: .30),
          blurRadius: 34,
          offset: const Offset(0, 16),
        ),
      ],
    ),
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 24,
      runSpacing: 18,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 660),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_fix_high_rounded, color: Colors.white),
                  SizedBox(width: 9),
                  Text(
                    'BTW COMPATIBILITY WORKSPACE',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.3,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'Bring BarTender labels into your CodeVault workflow',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                  height: 1.12,
                ),
              ),
              SizedBox(height: 9),
              Text(
                'Import recognizable fields, fine-tune every value, drag and rotate the live layout, then save and print locally.',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          key: const Key('import-btw'),
          onPressed: busy ? null : _importBtw,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF6D28D9),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          ),
          icon: const Icon(Icons.file_open_outlined),
          label: const Text('Import .btw'),
        ),
      ],
    ),
  );

  Widget _actions(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: const Icon(Icons.storage_rounded),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Local BTW library',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(status),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                key: const Key('export-btw-backup'),
                onPressed: busy ? null : _exportBackup,
                icon: const Icon(Icons.download_outlined),
                label: const Text('Export BTW backup'),
              ),
              OutlinedButton.icon(
                key: const Key('merge-btw-backup'),
                onPressed: busy ? null : _mergeBackup,
                icon: const Icon(Icons.merge_rounded),
                label: const Text('Import & merge'),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Future<void> _importBtw() async {
    final identity = _identity;
    if (identity == null) {
      return _setStatus('Sign in before importing BTW files.');
    }
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'BarTender label', extensions: ['btw']),
      ],
    );
    if (file == null) return;
    await _run(() async {
      final result = const BtwImporter().parse(
        await file.readAsBytes(),
        filename: file.name,
      );
      final fields = <DynamicLabelField>[
        if (result.serialNumber.isNotEmpty)
          DynamicLabelField(
            id: 'btw-serial',
            label: 'Serial No',
            value: result.serialNumber,
            x: .28,
            y: .64,
          ),
        ...result.fields,
      ];
      await repository.create(identity.$1, {
        'part_number': result.partNumber,
        'item_name': result.itemName,
        'item_model': result.model,
        'default_pack_quantity': 1,
        'barcode_type': 'data_matrix',
        'label_field_config': LabelFieldConfig.toJsonObject(
          LabelFieldConfig.defaults(),
        ),
        'dynamic_label_fields': DynamicLabelField.listToJson(fields),
      });
      return [
        '${file.name} imported with ${fields.length} editable custom field${fields.length == 1 ? '' : 's'}.',
        ...result.warnings,
      ].join(' ');
    });
  }

  Future<void> _exportBackup() async {
    final identity = _identity;
    if (identity == null) {
      return _setStatus('Sign in before exporting backups.');
    }
    await _run(() async {
      final bytes = Uint8List.fromList(
        utf8.encode(
          jsonEncode({
            'format': 'codevault-btw-backup',
            'version': 1,
            'tenant_id': identity.$1,
            'owner_user_id': identity.$2,
            'exported_at': DateTime.now().toUtc().toIso8601String(),
            'templates': await repository.exportRecords(identity.$1),
          }),
        ),
      );
      final filename =
          'codevault-btw-${DateTime.now().millisecondsSinceEpoch}.cvbtw';
      final file = XFile.fromData(
        bytes,
        name: filename,
        mimeType: 'application/json',
      );
      if (kIsWeb) {
        await file.saveTo(filename);
      } else if (PlatformCapabilities.current().isWindows) {
        final location = await getSaveLocation(
          suggestedName: filename,
          acceptedTypeGroups: const [
            XTypeGroup(label: 'CodeVault BTW backup', extensions: ['cvbtw']),
          ],
        );
        if (location == null) return 'Backup export cancelled.';
        await file.saveTo(location.path);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        await file.saveTo(path.join(directory.path, filename));
        return 'BTW backup saved to ${directory.path}.';
      }
      return 'BTW backup exported successfully.';
    });
  }

  Future<void> _mergeBackup() async {
    final identity = _identity;
    if (identity == null) {
      return _setStatus('Sign in before importing backups.');
    }
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'CodeVault BTW backup', extensions: ['cvbtw']),
      ],
    );
    if (file == null) return;
    await _run(() async {
      final decoded = jsonDecode(utf8.decode(await file.readAsBytes()));
      if (decoded is! Map<String, dynamic> ||
          decoded['format'] != 'codevault-btw-backup' ||
          decoded['version'] != 1) {
        throw const FormatException('This is not a supported BTW backup.');
      }
      if (decoded['tenant_id'] != identity.$1 ||
          decoded['owner_user_id'] != identity.$2) {
        throw const FormatException(
          'This BTW backup belongs to another company or user.',
        );
      }
      final templates = decoded['templates'];
      if (templates is! List) {
        throw const FormatException('Backup data is missing.');
      }
      final merged = await repository.mergeRecords(
        identity.$1,
        templates.cast<Map<String, dynamic>>(),
      );
      return '$merged BTW template${merged == 1 ? '' : 's'} merged; existing records were kept.';
    });
  }

  Future<void> _run(Future<String> Function() action) async {
    setState(() => busy = true);
    try {
      final result = await action();
      if (!mounted) return;
      setState(() {
        status = result;
        editorRevision++;
      });
    } catch (error) {
      _setStatus('Action could not be completed: $error');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void _setStatus(String value) {
    if (!mounted) return;
    setState(() => status = value);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}
