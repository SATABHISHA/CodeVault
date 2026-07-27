import 'package:codevault/core/config/brand_config.dart';
import 'package:codevault/core/network/api_client.dart';
import 'package:codevault/core/platform/platform_capabilities.dart';
import 'package:codevault/features/authentication/presentation/session_controller.dart';
import 'package:codevault/features/backup/data/managed_request_service.dart';
import 'package:codevault/shared/widgets/animated_request_dialog.dart';
import 'package:codevault/shared/widgets/diagnostics_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});
  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  String supportEmail = BrandConfig.supportEmail;
  @override
  void initState() { super.initState(); Future.microtask(_loadSupportAddress); }

  Future<void> _loadSupportAddress() async {
    final tenantId = ref.read(sessionProvider).tenantId;
    if (tenantId == null) return;
    try {
      final response = await ApiClient().dio.get<Map<String, dynamic>>('/tenants/$tenantId/support-center');
      final data = response.data?['data'] as Map<String, dynamic>?;
      if (mounted && data?['support_email'] is String) setState(() => supportEmail = data!['support_email'] as String);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(24), children: [
    Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Ahanova support', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      const Text('Create a tracked support request. If platform SMTP is not configured, contact us directly at:'),
      const SizedBox(height: 8),
      SelectableText(supportEmail, style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 18),
      FilledButton.icon(onPressed: _openTicket, icon: const Icon(Icons.support_agent), label: const Text('Open support ticket')),
    ]))),
    const SizedBox(height: 16),
    DiagnosticsPanel(items: {'Product': BrandConfig.productName, 'Support': supportEmail, 'Website': BrandConfig.website}),
  ]);

  Future<void> _openTicket() => showAnimatedRequestDialog(context,
    type: RequestType.support,
    platform: PlatformCapabilities.current().isWeb ? 'web' : 'android',
    deviceName: PlatformCapabilities.current().isWeb ? 'CodeVault Web Browser' : 'CodeVault Android',
    onSubmit: (input) async {
      final tenantId = ref.read(sessionProvider).tenantId;
      if (tenantId == null) throw StateError('Tenant session required');
      await ManagedRequestService(ApiClient()).submit(tenantId, input);
    });
}
