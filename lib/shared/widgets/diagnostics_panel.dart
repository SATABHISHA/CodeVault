import 'package:flutter/material.dart';

class DiagnosticsPanel extends StatelessWidget {
  const DiagnosticsPanel({required this.items, super.key});
  final Map<String, String> items;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Diagnostics', style: Theme.of(context).textTheme.titleMedium),
          const Divider(),
          for (final entry in items.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Expanded(child: Text(entry.key)),
                  Flexible(child: SelectableText(entry.value)),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}
