import 'package:codevault/core/config/brand_config.dart';
import 'package:codevault/shared/widgets/diagnostics_panel.dart';
import 'package:codevault/shared/widgets/support_card.dart';
import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: const [
      SupportCard(),
      SizedBox(height: 16),
      DiagnosticsPanel(
        items: {
          'Product': BrandConfig.productName,
          'Support': BrandConfig.supportEmail,
          'Website': BrandConfig.website,
        },
      ),
    ],
  );
}
