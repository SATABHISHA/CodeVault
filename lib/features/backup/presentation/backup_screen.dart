import 'package:codevault/core/platform/platform_capabilities.dart';
import 'package:codevault/shared/widgets/animated_request_dialog.dart';
import 'package:codevault/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../authentication/presentation/session_controller.dart';
import '../data/managed_request_service.dart';
import '../../../core/network/api_client.dart';
import 'web_cache_transfer_card.dart';
import 'platform_protection_screen.dart';
import 'local_backup_panel.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key, this.capabilities, this.permissions});
  final PlatformCapabilities? capabilities;
  final Set<String>? permissions;
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
          const LocalBackupPanel(),
        ] else if (platform.supportsManagedCloudRequests) ...[
          if ((platform.isWeb || platform.isAndroid) && permissions != null)
            WebCacheTransferCard(tenantId: _tenantId(context)),
          if ((platform.isWeb || platform.isAndroid) && permissions != null)
            const SizedBox(height: 16),
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
              if (permissions == null ||
                  permissions!.contains('backup_requests.create'))
                FilledButton.icon(
                  key: const Key('request-backup'),
                  onPressed: () => showAnimatedRequestDialog(
                    context,
                    type: RequestType.backup,
                    onSubmit: (input) => _submitManaged(context, input),
                    platform: platform.isWeb ? 'web' : 'android',
                    deviceName: platform.isWeb
                        ? 'CodeVault Web Browser'
                        : 'CodeVault Android',
                  ),
                  icon: const Icon(Icons.backup_outlined),
                  label: const Text('Request backup'),
                ),
              if (permissions == null ||
                  permissions!.contains('restore_requests.create'))
                OutlinedButton.icon(
                  key: const Key('request-restore'),
                  onPressed: () => showAnimatedRequestDialog(
                    context,
                    type: RequestType.restore,
                    onSubmit: (input) => _submitManaged(context, input),
                    platform: platform.isWeb ? 'web' : 'android',
                    deviceName: platform.isWeb
                        ? 'CodeVault Web Browser'
                        : 'CodeVault Android',
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

  Future<void> _submitManaged(
    BuildContext context,
    ManagedRequestInput input,
  ) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final tenantId = container.read(sessionProvider).tenantId;
    if (tenantId == null) throw StateError('Tenant session is required.');
    await ManagedRequestService(
      ApiClient(
        onSessionExpired: () async {
          container.read(sessionProvider.notifier).signOut();
          if (context.mounted) context.go('/login');
        },
      ),
    ).submit(tenantId, input);
  }

  String _tenantId(BuildContext context) =>
      ProviderScope.containerOf(
        context,
        listen: false,
      ).read(sessionProvider).tenantId ??
      (throw StateError('Tenant session is required.'));
}

class PermissionAwareBackupScreen extends ConsumerWidget {
  const PermissionAwareBackupScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    if (session.role == 'super-superadmin') {
      return const PlatformProtectionScreen();
    }
    return BackupScreen(permissions: session.permissions);
  }
}
