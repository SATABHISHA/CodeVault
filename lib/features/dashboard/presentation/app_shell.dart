import 'package:codevault/core/config/brand_config.dart';
import 'package:codevault/core/layout/breakpoints.dart';
import 'package:codevault/core/platform/platform_capabilities.dart';
import 'package:codevault/features/authentication/data/remote_auth_service.dart';
import 'package:codevault/features/authentication/presentation/session_controller.dart';
import 'package:codevault/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../windows_desktop/application/windows_session.dart';

class AppShell extends ConsumerWidget {
  const AppShell({required this.child, this.locationOverride, super.key});
  final Widget child;
  final String? locationOverride;
  static const cloudDestinations = [
    (Icons.dashboard_outlined, 'Dashboard', '/dashboard'),
    (Icons.admin_panel_settings_outlined, 'Administration', '/administration'),
    (Icons.payments_outlined, 'Billing', '/billing'),
    (Icons.auto_awesome_mosaic_outlined, 'Label studio', '/studio'),
    (Icons.backup_outlined, 'Backup', '/backup'),
    (Icons.support_agent_outlined, 'Support', '/support'),
    (Icons.person_outline, 'Profile', '/profile'),
    (Icons.info_outline, 'About', '/about'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final baseDestinations = PlatformCapabilities.current().isWindows
        ? const [
            (Icons.dashboard_outlined, 'Dashboard', '/windows/dashboard'),
            (
              Icons.auto_awesome_mosaic_outlined,
              'Label studio',
              '/windows/operations',
            ),
            (Icons.backup_outlined, 'Local backup', '/backup'),
            (Icons.group_outlined, 'Local users', '/windows/users'),
            (Icons.person_outline, 'Profile', '/profile'),
            (Icons.info_outline, 'About', '/about'),
          ]
        : cloudDestinations;
    final destinations = baseDestinations
        .where(
          (item) =>
              (item.$3 != '/administration' ||
                  [
                    'super-superadmin',
                    'superadmin',
                    'tenant-admin',
                  ].contains(session.role)) &&
              (item.$3 != '/billing' ||
                  ['super-superadmin', 'superadmin'].contains(session.role)),
        )
        .toList();
    final size = layoutSizeFor(MediaQuery.sizeOf(context).width);
    final location = locationOverride ?? GoRouterState.of(context).uri.path;
    final selected = destinations
        .indexWhere((item) => item.$3 == location)
        .clamp(0, destinations.length - 1);
    final content = FocusTraversalGroup(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: KeyedSubtree(key: ValueKey(location), child: child),
      ),
    );
    if (size == LayoutSize.compact) {
      final compactDestinations = destinations.take(4).toList();
      final compactSelected = compactDestinations
          .indexWhere((item) => item.$3 == location)
          .clamp(0, compactDestinations.length - 1);
      return Scaffold(
        appBar: AppBar(
          title: const Text(BrandConfig.productName),
          actions: [_skinMenu(context, ref), _logoutButton(context, ref)],
        ),
        body: content,
        bottomNavigationBar: NavigationBar(
          selectedIndex: compactSelected,
          onDestinationSelected: (index) =>
              context.go(compactDestinations[index].$3),
          destinations: [
            for (final item in compactDestinations)
              NavigationDestination(icon: Icon(item.$1), label: item.$2),
          ],
        ),
      );
    }
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: size == LayoutSize.expanded,
            selectedIndex: selected,
            onDestinationSelected: (index) =>
                context.go(destinations[index].$3),
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Icon(Icons.qr_code_2_rounded, size: 36),
            ),
            destinations: [
              for (final item in destinations)
                NavigationRailDestination(
                  icon: Icon(item.$1),
                  label: Text(item.$2),
                ),
            ],
            trailing: size == LayoutSize.expanded
                ? const Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          BrandConfig.poweredBy,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  )
                : null,
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  title: Text(destinations[selected].$2),
                  automaticallyImplyLeading: false,
                  actions: [
                    _skinMenu(context, ref),
                    _logoutButton(context, ref),
                    const SizedBox(width: 10),
                  ],
                ),
                Expanded(child: content),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _skinMenu(BuildContext context, WidgetRef ref) =>
      PopupMenuButton<AppSkin>(
        tooltip: 'Change skin color',
        icon: const Icon(Icons.palette_outlined),
        onSelected: (skin) =>
            ref.read(appearanceProvider.notifier).setSkin(skin),
        itemBuilder: (context) => [
          for (final skin in AppSkin.values)
            PopupMenuItem(
              value: skin,
              child: IgnorePointer(
                child: ListTile(
                  leading: Icon(Icons.circle, color: skin.color),
                  title: Text(skin.label),
                ),
              ),
            ),
        ],
      );

  Widget _logoutButton(BuildContext context, WidgetRef ref) => IconButton(
        tooltip: 'Logout',
        icon: const CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Icon(Icons.logout),
        ),
        onPressed: () => _showLogoutDialog(context, ref),
      );

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Row(
                children: [
                  Icon(Icons.logout, color: Colors.redAccent),
                  SizedBox(width: 12),
                  Text('Logout'),
                ],
              ),
              content: const Text('Are you sure you want to securely log out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    try {
                      if (PlatformCapabilities.current().isWindows) {
                        WindowsSession.clear();
                        if (context.mounted) context.go('/windows');
                        return;
                      }
                      await RemoteAuthService().logout();
                    } catch (_) {}
                    ref.read(sessionProvider.notifier).signOut();
                    if (context.mounted) context.go('/login');
                  },
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
