import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/label_preview.dart';
import '../domain/printer.dart';

class WindowsOperationsScreen extends StatefulWidget {
  const WindowsOperationsScreen({super.key, this.printer});
  final WindowsPrinterAdapter? printer;
  @override
  State<WindowsOperationsScreen> createState() =>
      _WindowsOperationsScreenState();
}

class _WindowsOperationsScreenState extends State<WindowsOperationsScreen> {
  late final WindowsPrinterAdapter printer =
      widget.printer ?? MockPrinterAdapter();
  final part = TextEditingController();
  final model = TextEditingController();
  final serial = TextEditingController();
  final dr = TextEditingController();
  final port = TextEditingController();
  final pack = TextEditingController(text: '1');
  final quantity = TextEditingController(text: '1');
  bool includeName = true;
  String format = 'Barcode';
  String status = 'Ready';
  String get content => [
    part.text,
    model.text,
    serial.text,
    dr.text,
  ].where((value) => value.trim().isNotEmpty).join('|');

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text(
        'Offline label operations',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const Text('All data and print jobs remain on this Windows computer.'),
      const SizedBox(height: 20),
      LayoutBuilder(
        builder: (context, constraints) => Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 280,
              child: AppTextField(
                label: 'Select part / item',
                controller: part,
              ),
            ),
            SizedBox(
              width: 280,
              child: AppTextField(label: 'Model', controller: model),
            ),
            SizedBox(
              width: 280,
              child: AppTextField(label: 'Serial', controller: serial),
            ),
            SizedBox(
              width: 280,
              child: AppTextField(label: 'DR', controller: dr),
            ),
            SizedBox(
              width: 280,
              child: AppTextField(label: 'Port', controller: port),
            ),
            SizedBox(
              width: 180,
              child: AppTextField(label: 'Pack quantity', controller: pack),
            ),
            SizedBox(
              width: 180,
              child: AppTextField(
                label: 'Print quantity',
                controller: quantity,
              ),
            ),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String>(
                initialValue: format,
                decoration: const InputDecoration(
                  labelText: 'Generated content',
                ),
                items: const ['Barcode', 'QR', 'Data Matrix']
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => format = value!),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  '$format preview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                LabelPreview(
                  content: Center(
                    child: Text(
                      content.isEmpty ? 'Enter part and serial data' : content,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Printer: ${printer.name}'),
                    Text('Status: $status'),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Print with name'),
                      value: includeName,
                      onChanged: (value) => setState(() => includeName = value),
                    ),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        OutlinedButton(
                          onPressed: _testPrint,
                          child: const Text('Test print'),
                        ),
                        FilledButton.icon(
                          key: const Key('offline-print'),
                          onPressed: _print,
                          icon: const Icon(Icons.print),
                          label: Text(
                            includeName
                                ? 'Print with name'
                                : 'Print without name',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 10,
        children: [
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Insert part'),
          ),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit),
            label: const Text('Modify part'),
          ),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete part'),
          ),
          TextButton(onPressed: _clear, child: const Text('Clear')),
        ],
      ),
    ],
  );
  Future<void> _testPrint() async {
    await printer.testConnection();
    if (mounted) setState(() => status = 'Test successful');
  }

  Future<void> _print() async {
    final copies = int.tryParse(quantity.text) ?? 0;
    final receipt = await printer.print(
      PrintRequest(
        jobId: const Uuid().v4(),
        content: includeName ? '${part.text}\n$content' : content,
        copies: copies,
      ),
    );
    if (mounted) setState(() => status = receipt.message);
  }

  void _clear() {
    for (final controller in [part, model, serial, dr, port]) {
      controller.clear();
    }
    setState(() => status = 'Ready');
  }
}
