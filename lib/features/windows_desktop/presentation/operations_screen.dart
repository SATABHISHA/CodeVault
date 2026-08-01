import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/label_preview.dart';
import '../../labels/domain/label_typography.dart';
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
  final company = TextEditingController();
  final date = TextEditingController();
  final time = TextEditingController();
  final pack = TextEditingController(text: '1');
  final quantity = TextEditingController(text: '1');
  bool includeName = true;
  bool dualSideCodes = true;
  bool autoDateTime = true;
  String format = 'Barcode';
  String status = 'Ready';

  @override
  void initState() {
    super.initState();
    _stampNow();
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  void _stampNow() {
    final now = DateTime.now();
    date.text = '${_twoDigits(now.day)}-${_twoDigits(now.month)}-${now.year}';
    time.text =
        '${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}';
  }

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
              width: 280,
              child: AppTextField(label: 'Company', controller: company),
            ),
            SizedBox(
              width: 220,
              child: AppTextField(label: 'Date (DD-MM-YYYY)', controller: date),
            ),
            SizedBox(
              width: 220,
              child: AppTextField(label: 'Time (HH:MM:SS)', controller: time),
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
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          FilterChip(
            label: const Text('Dual left-right code format'),
            selected: dualSideCodes,
            onSelected: (value) => setState(() => dualSideCodes = value),
          ),
          FilterChip(
            label: const Text('Auto date/time'),
            selected: autoDateTime,
            onSelected: (value) {
              setState(() => autoDateTime = value);
              if (value) {
                _stampNow();
              }
            },
          ),
          OutlinedButton.icon(
            onPressed: () => setState(_stampNow),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh timestamp'),
          ),
        ],
      ),
      const SizedBox(height: 12),
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
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (dualSideCodes)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.qr_code_2, size: 56),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    company.text.trim().isEmpty
                                        ? 'COMPANY NAME'
                                        : company.text.trim().toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: LabelTypography.fontFamily,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing:
                                          LabelTypography.companyTracking,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'MODEL: ${model.text.isEmpty ? '-' : model.text.toUpperCase()}',
                                        style: const TextStyle(
                                          fontFamily:
                                              LabelTypography.fontFamily,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (port.text.trim().isNotEmpty)
                                        Text(
                                          port.text.trim().toUpperCase(),
                                          style: const TextStyle(
                                            fontFamily:
                                                LabelTypography.fontFamily,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                  Text(
                                    'DATE: ${date.text.isEmpty ? '-' : date.text}    TIME: ${time.text.isEmpty ? '-' : time.text}',
                                    style: const TextStyle(
                                      fontFamily: LabelTypography.fontFamily,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'PART NO: ${part.text.isEmpty ? '-' : part.text}',
                                    style: const TextStyle(
                                      fontFamily: LabelTypography.fontFamily,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    content.isEmpty
                                        ? 'Enter part and serial data'
                                        : content,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: LabelTypography.fontFamily,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.qr_code_2, size: 56),
                          ],
                        )
                      else ...[
                        Text(
                          company.text.trim().isEmpty
                              ? 'COMPANY NAME'
                              : company.text.trim().toUpperCase(),
                          style: const TextStyle(
                            fontFamily: LabelTypography.fontFamily,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          port.text.trim().isEmpty
                              ? 'MODEL: ${model.text.isEmpty ? '-' : model.text.toUpperCase()}'
                              : 'MODEL: ${model.text.isEmpty ? '-' : model.text.toUpperCase()}    ${port.text.trim().toUpperCase()}',
                          style: const TextStyle(
                            fontFamily: LabelTypography.fontFamily,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'DATE: ${date.text.isEmpty ? '-' : date.text}    TIME: ${time.text.isEmpty ? '-' : time.text}',
                          style: const TextStyle(
                            fontFamily: LabelTypography.fontFamily,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'PART NO: ${part.text.isEmpty ? '-' : part.text}',
                          style: const TextStyle(
                            fontFamily: LabelTypography.fontFamily,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      if (!dualSideCodes)
                        Text(
                          content.isEmpty
                              ? 'Enter part and serial data'
                              : content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: LabelTypography.fontFamily,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
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
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        OutlinedButton(
                          onPressed: _testPrint,
                          child: const Text('Test print'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () => _print(withName: false),
                          icon: const Icon(Icons.print_disabled),
                          label: const Text('Print without name'),
                        ),
                        FilledButton.icon(
                          key: const Key('offline-print'),
                          onPressed: () => _print(withName: true),
                          icon: const Icon(Icons.print),
                          label: const Text('Print with name'),
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

  Future<void> _print({bool? withName}) async {
    final copies = int.tryParse(quantity.text) ?? 0;
    final include = withName ?? includeName;
    final modelLine = port.text.trim().isEmpty
        ? 'MODEL:${model.text}'
        : 'MODEL:${model.text} ${port.text.trim()}';
    if (autoDateTime) {
      _stampNow();
    }
    final receipt = await printer.print(
      PrintRequest(
        jobId: const Uuid().v4(),
        content: include
            ? '${company.text}\n$modelLine\nDATE:${date.text} TIME:${time.text}\nPART:${part.text}\n$content'
            : content,
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
