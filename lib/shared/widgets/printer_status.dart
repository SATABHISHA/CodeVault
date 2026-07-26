import 'package:codevault/shared/widgets/status_badge.dart';
import 'package:flutter/material.dart';

class PrinterStatus extends StatelessWidget {
  const PrinterStatus({required this.connected, this.name, super.key});
  final bool connected;
  final String? name;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        Icons.print_outlined,
        color: connected ? Colors.green : Theme.of(context).colorScheme.error,
      ),
      const SizedBox(width: 8),
      Text(name ?? 'Printer'),
      const SizedBox(width: 8),
      StatusBadge(
        label: connected ? 'Connected' : 'Offline',
        tone: connected ? StatusTone.success : StatusTone.error,
      ),
    ],
  );
}
