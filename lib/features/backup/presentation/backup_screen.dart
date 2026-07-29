import 'package:codevault/core/platform/platform_capabilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/presentation/session_controller.dart';
import 'web_cache_transfer_card.dart';
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
        if (platform.supportsLocalBackup)
          const LocalBackupPanel()
        else
          WebCacheTransferCard(tenantId: _tenantId(context)),
      ],
    );
  }

  String _tenantId(BuildContext context) =>
      ProviderScope.containerOf(
        context,
        listen: false,
      ).read(sessionProvider).tenantId ??
      'platform-owner';
}

