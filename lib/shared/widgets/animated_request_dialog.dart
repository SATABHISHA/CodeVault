import 'package:codevault/shared/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

enum RequestType { backup, restore }

Future<void> showAnimatedRequestDialog(
  BuildContext context, {
  required RequestType type,
}) => showGeneralDialog<void>(
  context: context,
  barrierDismissible: true,
  barrierLabel: 'Close request dialog',
  transitionDuration: const Duration(milliseconds: 220),
  pageBuilder: (context, animation, secondaryAnimation) =>
      _RequestDialog(type: type),
  transitionBuilder: (context, animation, secondaryAnimation, child) =>
      FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: .96, end: 1.0).animate(animation),
          child: child,
        ),
      ),
);

class _RequestDialog extends StatelessWidget {
  const _RequestDialog({required this.type});
  final RequestType type;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      type == RequestType.backup
          ? 'Request managed backup'
          : 'Request managed restore',
    ),
    content: const SizedBox(
      width: 480,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(label: 'Reason', icon: Icons.notes),
          SizedBox(height: 12),
          AppTextField(label: 'Preferred contact time', icon: Icons.schedule),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Submit request'),
      ),
    ],
  );
}
