import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../data/printing_browser_gateway.dart';
import '../domain/browser_printing.dart';

class WebPrintScreen extends StatefulWidget {
  const WebPrintScreen({
    super.key,
    this.generator = const BrowserPdfGenerator(),
    this.gateway = const PrintingBrowserGateway(),
  });
  final BrowserPdfGenerator generator;
  final BrowserPrintGateway gateway;

  @override
  State<WebPrintScreen> createState() => _WebPrintScreenState();
}

class _WebPrintScreenState extends State<WebPrintScreen> {
  final title = TextEditingController(text: 'CodeVault label');
  final content = TextEditingController(text: 'PART-0001');
  final width = TextEditingController(text: '100');
  final height = TextEditingController(text: '50');
  Uint8List? pdf;
  bool busy = false;

  BrowserLabelDocument get label => BrowserLabelDocument(
    title: title.text.trim(),
    content: content.text.trim(),
    widthMm: double.tryParse(width.text) ?? 100,
    heightMm: double.tryParse(height.text) ?? 50,
  );

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text(
        'Browser PDF printing',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 8),
      const Text(
        'The browser print dialog controls the final printer. Select 100% / Actual size and disable browser margins for physical-size labels.',
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(
            width: 280,
            child: TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
          ),
          SizedBox(
            width: 280,
            child: TextField(
              controller: content,
              decoration: const InputDecoration(labelText: 'Label content'),
            ),
          ),
          SizedBox(
            width: 140,
            child: TextField(
              controller: width,
              decoration: const InputDecoration(labelText: 'Width (mm)'),
            ),
          ),
          SizedBox(
            width: 140,
            child: TextField(
              controller: height,
              decoration: const InputDecoration(labelText: 'Height (mm)'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          FilledButton.icon(
            key: const Key('generate-web-pdf'),
            onPressed: busy ? null : _generate,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Generate preview'),
          ),
          OutlinedButton.icon(
            key: const Key('print-web-pdf'),
            onPressed: pdf == null
                ? null
                : () => widget.gateway.showPrintDialog(
                    pdf!,
                    'codevault-label.pdf',
                  ),
            icon: const Icon(Icons.print),
            label: const Text('Print'),
          ),
          OutlinedButton.icon(
            key: const Key('download-web-pdf'),
            onPressed: pdf == null
                ? null
                : () => widget.gateway.download(pdf!, 'codevault-label.pdf'),
            icon: const Icon(Icons.download),
            label: const Text('Download PDF'),
          ),
        ],
      ),
      const SizedBox(height: 24),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            pdf == null
                ? 'Generate a PDF to validate the ${width.text} × ${height.text} mm page.'
                : 'PDF ready (${pdf!.length} bytes). Use the print dialog preview to verify orientation and scaling.',
          ),
        ),
      ),
      const SizedBox(height: 16),
      const Card(
        child: ListTile(
          leading: Icon(Icons.info_outline),
          title: Text(
            'Raw ZPL, TSPL and ESC/POS are not sent from an ordinary browser',
          ),
          subtitle: Text(
            'A future localhost print agent may use explicit tenant pairing, expiring signed jobs, revocation and status polling. It is intentionally not enabled in this release.',
          ),
        ),
      ),
    ],
  );

  Future<void> _generate() async {
    setState(() => busy = true);
    try {
      pdf = await widget.generator.generate(label);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
