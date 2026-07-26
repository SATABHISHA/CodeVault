import 'package:codevault/app.dart';
import 'package:codevault/core/config/brand_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text(
        'About',
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 16),
      const Card(
        child: ListTile(
          leading: Icon(Icons.qr_code_2, size: 42),
          title: Text(BrandConfig.productName),
          subtitle: Text(
            '${BrandConfig.companyName}\n${BrandConfig.website}\n${BrandConfig.supportEmail}',
          ),
          isThreeLine: true,
        ),
      ),
      const SizedBox(height: 16),
      SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(
            value: ThemeMode.system,
            label: Text('System'),
            icon: Icon(Icons.brightness_auto),
          ),
          ButtonSegment(
            value: ThemeMode.light,
            label: Text('Light'),
            icon: Icon(Icons.light_mode),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            label: Text('Dark'),
            icon: Icon(Icons.dark_mode),
          ),
        ],
        selected: {ref.watch(themeModeProvider)},
        onSelectionChanged: (value) =>
            ref.read(themeModeProvider.notifier).setThemeMode(value.first),
      ),
    ],
  );
}
