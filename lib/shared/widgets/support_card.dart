import 'package:codevault/core/config/brand_config.dart';
import 'package:flutter/material.dart';

class SupportCard extends StatelessWidget {
  const SupportCard({super.key});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Ahanova',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          const SelectableText(BrandConfig.supportEmail),
          const SelectableText(BrandConfig.website),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            children: [
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.support_agent),
                label: const Text('Open support ticket'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.copy),
                label: const Text('Copy email'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
