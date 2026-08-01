import 'package:codevault/core/platform/platform_capabilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_backup_panel.dart';
import '../../authentication/presentation/session_controller.dart';
import '../../windows_desktop/application/windows_session.dart';
import 'web_cache_transfer_card.dart';

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
        if (platform.isWindows)
          LocalBackupPanel(userId: _userId(context))
        else
          WebCacheTransferCard(
            tenantId: _tenantId(context),
            userId: _userId(context),
          ),
      ],
    );
  }

  String _tenantId(BuildContext context) {
    String? tenant;
    try {
      tenant = ProviderScope.containerOf(
        context,
        listen: false,
      ).read(sessionProvider).tenantId;
    } catch (_) {
      tenant = null;
    }
    return tenant ?? WindowsSession.companyId ?? 'platform-owner';
  }

  String _userId(BuildContext context) {
    String? user;
    try {
      user = ProviderScope.containerOf(
        context,
        listen: false,
      ).read(sessionProvider).userId;
    } catch (_) {
      user = null;
    }
    return user ?? WindowsSession.userId ?? 'unknown-user';
  }
}

