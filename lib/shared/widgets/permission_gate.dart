import 'package:flutter/widgets.dart';

class PermissionGate extends StatelessWidget {
  const PermissionGate({
    required this.permission,
    required this.permissions,
    required this.child,
    this.fallback = const SizedBox.shrink(),
    super.key,
  });
  final String permission;
  final Set<String> permissions;
  final Widget child;
  final Widget fallback;
  @override
  Widget build(BuildContext context) =>
      permissions.contains(permission) ? child : fallback;
}
