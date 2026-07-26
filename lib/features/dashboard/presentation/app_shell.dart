import 'package:codevault/core/config/brand_config.dart';
import 'package:codevault/core/layout/breakpoints.dart';
import 'package:codevault/core/platform/platform_capabilities.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, this.locationOverride, super.key});
  final Widget child;
  final String? locationOverride;
  static const cloudDestinations = [
    (Icons.dashboard_outlined, 'Dashboard', '/dashboard'),
    (Icons.backup_outlined, 'Backup', '/backup'),
    (Icons.support_agent_outlined, 'Support', '/support'),
    (Icons.info_outline, 'About', '/about'),
  ];

  @override
  Widget build(BuildContext context) {
    final destinations = PlatformCapabilities.current().isWindows
        ? const [
            (Icons.print_outlined, 'Operations', '/windows/operations'),
            (Icons.backup_outlined, 'Local backup', '/backup'),
            (Icons.support_agent_outlined, 'Support', '/support'),
            (Icons.info_outline, 'About', '/about'),
          ]
        : cloudDestinations;
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
      return Scaffold(
        appBar: AppBar(title: const Text(BrandConfig.productName)),
        body: content,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selected,
          onDestinationSelected: (index) => context.go(destinations[index].$3),
          destinations: [
            for (final item in destinations)
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
                ),
                Expanded(child: content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
