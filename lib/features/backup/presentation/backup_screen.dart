import 'package:codevault/core/platform/platform_capabilities.dart';
import 'package:codevault/shared/widgets/animated_request_dialog.dart';
import 'package:codevault/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key, this.capabilities});
  final PlatformCapabilities? capabilities;
  @override
  Widget build(BuildContext context) {
    final platform = capabilities ?? PlatformCapabilities.current();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Data protection',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        if (platform.supportsLocalBackup) ...[
          const EmptyState(
            icon: Icons.folder_copy_outlined,
            title: 'Local Windows backups',
            message:
                'Windows uses offline local backup and restore. Cloud requests are intentionally unavailable.',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.save_alt),
            label: const Text('Create local backup'),
          ),
        ] else if (platform.supportsManagedCloudRequests) ...[
          const EmptyState(
            icon: Icons.cloud_queue,
            title: 'Managed Laravel backup',
            message:
                'Submit a request. Only Ahanova platform administration can create or restore the protected server package.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                key: const Key('request-backup'),
                onPressed: () => showAnimatedRequestDialog(
                  context,
                  type: RequestType.backup,
                ),
                icon: const Icon(Icons.backup_outlined),
                label: const Text('Request backup'),
              ),
              OutlinedButton.icon(
                key: const Key('request-restore'),
                onPressed: () => showAnimatedRequestDialog(
                  context,
                  type: RequestType.restore,
                ),
                icon: const Icon(Icons.restore),
                label: const Text('Request restore'),
              ),
            ],
          ),
        ] else
          const EmptyState(
            icon: Icons.block,
            title: 'Unavailable',
            message: 'Data protection is not available on this platform.',
          ),
      ],
    );
  }
}
