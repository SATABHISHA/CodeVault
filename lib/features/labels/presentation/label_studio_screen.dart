import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../core/platform/platform_capabilities.dart'
    show PlatformCapabilities;
import '../../windows_desktop/application/windows_session.dart';
import '../../windows_desktop/data/local_database.dart' show LocalDatabase;
import '../../../features/printers/data/printing_browser_gateway.dart';
import '../../../features/printers/domain/browser_printing.dart';
import '../../../shared/widgets/barcode_view.dart';
import '../../backup/application/backup_import_revision.dart';
import '../../authentication/presentation/session_controller.dart';
import '../application/production_activity.dart';
import '../data/local_part_repository.dart';
import '../data/part_repository.dart';
import '../data/custom_label_profile_store.dart';
import '../data/web_local_part_repository.dart';
import '../domain/label_typography.dart';

class LabelStudioScreen extends ConsumerStatefulWidget {
  const LabelStudioScreen({super.key, this.repository, this.printGateway});
  final PartRepository? repository;
  final BrowserPrintGateway? printGateway;

  @override
  ConsumerState<LabelStudioScreen> createState() => _LabelStudioScreenState();
}

class _LabelStudioScreenState extends ConsumerState<LabelStudioScreen> {
  late PartRepository repository = _initRepository();
  late final BrowserPrintGateway gateway =
      widget.printGateway ?? const PrintingBrowserGateway();

  /// Returns the platform-local repository.
  /// Windows: full local company SQLite.
  /// Web/Android: local cache database (Drift WASM / SQLite).
  PartRepository _initRepository() {
    if (widget.repository != null) return widget.repository!;
    final companyId = WindowsSession.companyId;
    if (PlatformCapabilities.current().isWindows && companyId != null) {
      return LocalPartRepository(LocalDatabase(companyId));
    }
    return WebLocalPartRepository();
  }

  final search = TextEditingController();
  final partNumber = TextEditingController();
  final itemName = TextEditingController();
  final model = TextEditingController();
  final serial = TextEditingController(text: '001');
  final dr = TextEditingController(text: 'NR');
  final pack = TextEditingController(text: '1');
  final quantity = TextEditingController(text: '1');
  final portLabel = TextEditingController(text: 'PORT 1');
  final labelDate = TextEditingController();
  final labelTime = TextEditingController();
  final companyName = TextEditingController();
  final companyAddress = TextEditingController();
  List<PartRecord> parts = const [];
  PartRecord? selected;
  bool loading = true;
  bool busy = false;
  bool includeName = true;
  bool includeBorder = true;
  bool dualSideCodes = true;
  bool autoDateTime = true;
  String symbology = 'data_matrix';
  String labelSize = '100 × 30 mm';
  int stickersPerRow = 1; // will be set to maxStickersPerRow in initState
  static const double maxPageWidthMm = 210.0;
  int get maxStickersPerRow => (maxPageWidthMm / sizes[labelSize]!.$1).floor();

  String port = '';
  String message = 'Ready for production';
  Timer? debounce;
  List<Printer> _availablePrinters = [];
  Printer? _selectedPrinter;
  bool _printersLoaded = false;

  static const defaultSizes = <String, (double, double)>{
    '38 × 25 mm': (38.0, 25.0),
    '80 × 16 mm': (80.0, 16.0),
    '100 × 30 mm': (100.0, 30.0),
    '60 × 150 mm': (60.0, 150.0),
  };
  late final Map<String, (double, double)> sizes = {...defaultSizes};
  final customLabelProfileStore = const CustomLabelProfileStore();
  @override
  void initState() {
    super.initState();
    companyName.text = WindowsSession.companyName;
    companyAddress.text = WindowsSession.companyAddress;
    _stampNow();
    search.addListener(_searchChanged);
    backupImportRevision.addListener(_backupImported);
    for (final controller in [
      partNumber,
      itemName,
      model,
      serial,
      dr,
      pack,
      portLabel,
      labelDate,
      labelTime,
      companyName,
      companyAddress,
    ]) {
      controller.addListener(_refresh);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadCustomLabelProfiles();
      _load();
      _loadPrinters();
      // Initialise stickersPerRow to the calculated max for the default label/code
      setState(() => stickersPerRow = maxStickersPerRow);
    });
  }

  Future<void> _loadPrinters() async {
    try {
      final printers = await Printing.listPrinters();
      if (mounted) {
        setState(() {
          _availablePrinters = printers.where((p) => p.isAvailable).toList();
          if (_availablePrinters.isNotEmpty) {
            _selectedPrinter = _availablePrinters.cast<Printer?>().firstWhere(
              (p) => p!.isDefault,
              orElse: () => _availablePrinters.first,
            );
            port = _selectedPrinter!.name;
          } else {
            port = 'System Default';
          }
          _printersLoaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _printersLoaded = true;
          port = 'System Default';
        });
      }
    }
  }

  @override
  void dispose() {
    debounce?.cancel();
    backupImportRevision.removeListener(_backupImported);
    search.dispose();
    for (final controller in [
      partNumber,
      itemName,
      model,
      serial,
      dr,
      pack,
      quantity,
      portLabel,
      labelDate,
      labelTime,
      companyName,
      companyAddress,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  (String, String)? get _localProfileIdentity {
    final session = ref.read(sessionProvider);
    final tenantId = session.tenantId ?? WindowsSession.companyId;
    final userId = session.userId ?? WindowsSession.userId;
    if (tenantId == null || userId == null) return null;
    return (tenantId, userId);
  }

  Future<void> _loadCustomLabelProfiles() async {
    final identity = _localProfileIdentity;
    if (identity == null) return;
    try {
      final profiles = await customLabelProfileStore.load(
        tenantId: identity.$1,
        userId: identity.$2,
      );
      if (!mounted) return;
      setState(() {
        sizes
          ..clear()
          ..addAll(defaultSizes);
        for (final profile in profiles) {
          sizes[_labelSizeName(profile.widthMm, profile.heightMm)] = (
            profile.widthMm,
            profile.heightMm,
          );
        }
        if (!sizes.containsKey(labelSize)) labelSize = '100 × 30 mm';
        stickersPerRow = maxStickersPerRow.clamp(1, 999);
      });
    } catch (error) {
      if (mounted) _notice('Custom label sizes could not be loaded: $error');
    }
  }

  Future<void> _addCustomLabelSize() async {
    final identity = _localProfileIdentity;
    if (identity == null) {
      _notice('Please sign in before adding a custom label size');
      return;
    }
    final width = TextEditingController();
    final height = TextEditingController();
    final result = await showDialog<(double, double)>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add custom label size'),
        content: SizedBox(
          width: 360,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: width,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Width (mm)'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: height,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Height (mm)'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final widthMm = double.tryParse(width.text.trim());
              final heightMm = double.tryParse(height.text.trim());
              if (widthMm == null ||
                  heightMm == null ||
                  widthMm <= 0 ||
                  heightMm <= 0 ||
                  widthMm > 210 ||
                  heightMm > 297) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Enter dimensions greater than 0 and within 210 × 297 mm.',
                    ),
                  ),
                );
                return;
              }
              Navigator.pop(dialogContext, (widthMm, heightMm));
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    width.dispose();
    height.dispose();
    if (result == null || !mounted) return;
    final duplicate = sizes.values.any(
      (size) =>
          (size.$1 - result.$1).abs() < .001 &&
          (size.$2 - result.$2).abs() < .001,
    );
    if (duplicate) {
      _notice('That label size is already available');
      return;
    }
    final name = _labelSizeName(result.$1, result.$2);
    setState(() {
      sizes[name] = result;
      labelSize = name;
      stickersPerRow = maxStickersPerRow.clamp(1, 999);
    });
    try {
      await customLabelProfileStore.save(
        tenantId: identity.$1,
        userId: identity.$2,
        profiles: [
          for (final entry in sizes.entries)
            if (!defaultSizes.containsKey(entry.key))
              CustomLabelProfile(
                widthMm: entry.value.$1,
                heightMm: entry.value.$2,
              ),
        ],
      );
      _notice('$name added to label profiles');
    } catch (error) {
      if (mounted) {
        setState(() {
          sizes.remove(name);
          labelSize = '100 × 30 mm';
          stickersPerRow = maxStickersPerRow;
        });
        _notice('Custom label size could not be saved: $error');
      }
    }
  }

  String _labelSizeName(double width, double height) =>
      '${_dimensionText(width)} × ${_dimensionText(height)} mm';

  String _dimensionText(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  void _backupImported() {
    if (!mounted) return;
    // Open a fresh platform connection so browser WASM/IndexedDB and native
    // SQLite readers cannot retain a pre-import snapshot.
    if (widget.repository == null) repository = _initRepository();
    _loadCustomLabelProfiles();
    _load();
  }

  String get codeData {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final year = (now.year % 100).toString().padLeft(2, '0');
    return '00${partNumber.text}${dr.text}E$year$month${serial.text.padLeft(7, '0')}';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  void _stampNow() {
    final now = DateTime.now();
    labelDate.text =
        '${_twoDigits(now.day)}-${_twoDigits(now.month)}-${now.year}';
    labelTime.text =
        '${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}';
  }

  CodeSymbology get codeSymbology => switch (symbology) {
    'qr' => CodeSymbology.qr,
    'data_matrix' => CodeSymbology.dataMatrix,
    _ => CodeSymbology.code128,
  };

  @override
  Widget build(BuildContext context) => CustomScrollView(
    slivers: [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        sliver: SliverToBoxAdapter(child: _header(context)),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        sliver: SliverToBoxAdapter(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 1050;
              final editor = _editor(context);
              final catalog = _catalog(context);
              final preview = _preview(context);
              if (!wide) {
                return Column(
                  children: [
                    editor,
                    const SizedBox(height: 16),
                    catalog,
                    const SizedBox(height: 16),
                    preview,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: editor),
                  const SizedBox(width: 16),
                  Expanded(flex: 4, child: catalog),
                  const SizedBox(width: 16),
                  Expanded(flex: 5, child: preview),
                ],
              );
            },
          ),
        ),
      ),
    ],
  );

  Widget _header(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF6D5DFB), Color(0xFF00B8D9)],
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF6D5DFB).withValues(alpha: .22),
          blurRadius: 30,
          offset: const Offset(0, 12),
        ),
      ],
    ),
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 20,
      runSpacing: 16,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Label Production Studio',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Build, preview and print traceable industrial labels',
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ],
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF7CFFB2),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _editor(BuildContext context) => _panel(
    context,
    title: 'Production data',
    icon: Icons.tune_rounded,
    child: Column(
      children: [
        _field(
          companyName,
          'Company name on this label',
          Icons.business_outlined,
        ),
        const SizedBox(height: 12),
        _field(
          companyAddress,
          'Company address on this label',
          Icons.location_on_outlined,
        ),
        const SizedBox(height: 12),
        _field(partNumber, 'Part number', Icons.confirmation_number_outlined),
        const SizedBox(height: 12),
        _field(itemName, 'Item name', Icons.inventory_2_outlined),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _field(model, 'Item model', Icons.category_outlined),
            ),
            const SizedBox(width: 12),
            Expanded(child: _field(serial, 'Serial no.', Icons.numbers)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _field(dr, 'DR code', Icons.qr_code)),
            const SizedBox(width: 12),
            Expanded(child: _field(pack, 'Pack qty', Icons.inventory)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _printersLoaded
                  ? _availablePrinters.isEmpty
                        ? DropdownButtonFormField<String>(
                            initialValue: 'System Default',
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Printer port',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'System Default',
                                child: Text('SYSTEM DEFAULT'),
                              ),
                            ],
                            onChanged: null,
                          )
                        : DropdownButtonFormField<Printer>(
                            initialValue: _selectedPrinter,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Printer port',
                            ),
                            items: _availablePrinters
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item.name.toUpperCase()),
                                  ),
                                )
                                .toList(),
                            onChanged: (next) {
                              if (next != null) {
                                setState(() {
                                  _selectedPrinter = next;
                                  port = next.name;
                                });
                              }
                            },
                          )
                  : const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(child: CircularProgressIndicator()),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _field(quantity, 'Print qty', Icons.copy, number: true),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _field(
                portLabel,
                'Port label text (e.g. PORT 1)',
                Icons.settings_ethernet,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _field(
                labelDate,
                'Label date (DD-MM-YYYY)',
                Icons.calendar_today,
                enabled: !autoDateTime,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _field(
                labelTime,
                'Label time (HH:MM:SS)',
                Icons.schedule,
                enabled: !autoDateTime,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _dropdown(
                'Label profile',
                labelSize,
                sizes.keys.toList(),
                (value) {
                  setState(() {
                    labelSize = value;
                    // Always reset to the new max when profile changes
                    stickersPerRow = (maxPageWidthMm / sizes[value]!.$1)
                        .floor()
                        .clamp(1, 999);
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filledTonal(
              key: const Key('add-custom-label-size'),
              onPressed: busy ? null : _addCustomLabelSize,
              tooltip: 'Add custom label size',
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _dropdown(
          'Stickers per row',
          stickersPerRow.toString(),
          List.generate(maxStickersPerRow, (i) => (i + 1).toString()),
          (value) => setState(() => stickersPerRow = int.tryParse(value) ?? 1),
        ),
        const SizedBox(height: 12),
        _dropdown('Code type', symbology, const [
          'code128',
          'qr',
          'data_matrix',
        ], (value) => setState(() => symbology = value)),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Dual left-right code layout'),
          subtitle: const Text(
            'Print the same code on left and right like the reference sticker',
          ),
          value: dualSideCodes,
          onChanged: (value) {
            setState(() {
              dualSideCodes = value;
              if (value && symbology == 'code128') {
                symbology = 'qr';
              }
            });
          },
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Auto-fill date and time'),
          subtitle: const Text(
            'Uses current timestamp at PDF generation and printing',
          ),
          value: autoDateTime,
          onChanged: (value) {
            setState(() => autoDateTime = value);
            if (value) {
              _stampNow();
            }
          },
          secondary: IconButton(
            tooltip: 'Refresh timestamp now',
            onPressed: () {
              setState(_stampNow);
            },
            icon: const Icon(Icons.refresh),
          ),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Include item name'),
          subtitle: const Text('Controls the printed label variant'),
          value: includeName,
          onChanged: (value) => setState(() => includeName = value),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Include border'),
          subtitle: const Text('Print a border around each sticker'),
          value: includeBorder,
          onChanged: (value) => setState(() => includeBorder = value),
        ),
      ],
    ),
  );

  Widget _catalog(BuildContext context) => _panel(
    context,
    title: 'Part master',
    icon: Icons.view_list_rounded,
    trailing: IconButton(
      onPressed: _load,
      tooltip: 'Refresh parts',
      icon: const Icon(Icons.refresh),
    ),
    child: Column(
      children: [
        TextField(
          controller: search,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search part, name or model',
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 330,
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : parts.isEmpty
              ? const Center(
                  child: Text(
                    'No matching parts. Add the first part below.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.separated(
                  itemCount: parts.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = parts[index];
                    return ListTile(
                      selected: selected?.id == item.id,
                      selectedTileColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: .55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Text(
                        item.number,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        [
                          item.name,
                          item.model,
                        ].where((value) => value.isNotEmpty).join(' • '),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _select(item),
                    );
                  },
                ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: busy ? null : _saveNew,
              icon: const Icon(Icons.add),
              label: const Text('Insert'),
            ),
            OutlinedButton.icon(
              onPressed: busy || selected == null ? null : _update,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Modify'),
            ),
            OutlinedButton.icon(
              onPressed: busy || selected == null ? null : _delete,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete'),
            ),
            TextButton(onPressed: _clear, child: const Text('Clear')),
          ],
        ),
      ],
    ),
  );

  Widget _preview(BuildContext context) {
    final profile = sizes[labelSize]!;
    final portValue = portLabel.text.trim().toUpperCase();
    return _panel(
      context,
      title: 'Live label preview',
      icon: Icons.center_focus_strong,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final ratio = profile.$1 / profile.$2;
              final previewWidth = math.min(
                constraints.maxWidth,
                520.0 * ratio,
              );
              return Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: previewWidth,
                  child: AspectRatio(
                    aspectRatio: ratio,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: LayoutBuilder(
                        builder: (context, labelConstraints) {
                          final qrSide = math.min(
                            labelConstraints.maxHeight * .52,
                            labelConstraints.maxWidth * .20,
                          );
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (dualSideCodes &&
                                    codeSymbology != CodeSymbology.code128)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: qrSide,
                                            height: qrSide,
                                            child: BarcodeView(
                                              data: codeData,
                                              symbology: codeSymbology,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                // Company — centered
                                                Text(
                                                  companyName.text
                                                          .trim()
                                                          .isEmpty
                                                      ? 'COMPANY NAME'
                                                      : companyName.text
                                                            .trim()
                                                            .toUpperCase(),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontFamily: LabelTypography
                                                        .fontFamily,
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 13,
                                                    letterSpacing:
                                                        LabelTypography
                                                            .companyTracking,
                                                    height: 1.05,
                                                  ),
                                                ),
                                                // MODEL left  ·  PORT right
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'MODEL: ${model.text.trim().isEmpty ? '-' : model.text.trim().toUpperCase()}',
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontFamily:
                                                            LabelTypography
                                                                .fontFamily,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 10,
                                                        letterSpacing:
                                                            LabelTypography
                                                                .textTracking,
                                                        height: 1.15,
                                                      ),
                                                    ),
                                                    if (portLabel.text
                                                        .trim()
                                                        .isNotEmpty)
                                                      Text(
                                                        portLabel.text
                                                            .trim()
                                                            .toUpperCase(),
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontFamily:
                                                              LabelTypography
                                                                  .fontFamily,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 10,
                                                          letterSpacing:
                                                              LabelTypography
                                                                  .textTracking,
                                                          height: 1.15,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                // DATE + TIME — left
                                                Text(
                                                  'DATE: ${labelDate.text.isEmpty ? '-' : labelDate.text}    TIME: ${labelTime.text.isEmpty ? '-' : labelTime.text}',
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontFamily: LabelTypography
                                                        .fontFamily,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                    letterSpacing:
                                                        LabelTypography
                                                            .textTracking,
                                                    height: 1.15,
                                                  ),
                                                ),
                                                // PART NO — left, bold
                                                Text(
                                                  'PART NO: ${partNumber.text.isEmpty ? '—' : partNumber.text}',
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontFamily: LabelTypography
                                                        .fontFamily,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    letterSpacing:
                                                        LabelTypography
                                                            .textTracking,
                                                    height: 1.1,
                                                  ),
                                                ),
                                                if (includeName)
                                                  Text(
                                                    itemName.text.isEmpty
                                                        ? '—'
                                                        : itemName.text,
                                                    textAlign: TextAlign.left,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontFamily:
                                                          LabelTypography
                                                              .fontFamily,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 10,
                                                      letterSpacing:
                                                          LabelTypography
                                                              .textTracking,
                                                      height: 1.15,
                                                    ),
                                                  ),
                                                Text(
                                                  codeData,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontFamily: LabelTypography
                                                        .fontFamily,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                    letterSpacing:
                                                        LabelTypography
                                                            .textTracking,
                                                    height: 1.15,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          SizedBox(
                                            width: qrSide,
                                            height: qrSide,
                                            child: BarcodeView(
                                              data: codeData,
                                              symbology: codeSymbology,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                else ...[
                                  Text(
                                    companyName.text.trim().isEmpty
                                        ? 'COMPANY NAME'
                                        : companyName.text.trim().toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    companyAddress.text.trim().isEmpty
                                        ? 'COMPANY ADDRESS'
                                        : companyAddress.text
                                              .trim()
                                              .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 9,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'PART NO: ${partNumber.text.isEmpty ? '—' : partNumber.text}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  if (includeName)
                                    Text(
                                      'ITEM: ${itemName.text.isEmpty ? '—' : itemName.text}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  Text(
                                    portValue.isEmpty
                                        ? 'MODEL: ${model.text.isEmpty ? '—' : model.text}'
                                        : 'MODEL: ${model.text.isEmpty ? '—' : model.text}   ${portLabel.text.trim()}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    'DATE: ${labelDate.text.isEmpty ? '-' : labelDate.text}   TIME: ${labelTime.text.isEmpty ? '-' : labelTime.text}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 105,
                                    width: double.infinity,
                                    child: BarcodeView(
                                      data: codeData,
                                      symbology: codeSymbology,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    codeData,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'monospace',
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          Text(
            '${profile.$1.toInt()} × ${profile.$2.toInt()} mm • ${symbology.replaceAll('_', ' ').toUpperCase()} • $port',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: busy ? null : () => _generate(),
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Display PDF'),
              ),
              FilledButton.tonalIcon(
                onPressed: busy ? null : () => _print(withName: false),
                icon: const Icon(Icons.print_disabled),
                label: const Text('Print without name'),
              ),
              FilledButton.icon(
                key: const Key('production-print'),
                onPressed: busy ? null : () => _print(withName: true),
                icon: const Icon(Icons.print),
                label: const Text('Print with name'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _panel(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    ),
  );

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool number = false,
    bool enabled = true,
  }) => TextField(
    controller: controller,
    enabled: enabled,
    keyboardType: number ? TextInputType.number : null,
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
  );

  Widget _dropdown(
    String label,
    String value,
    List<String> values,
    ValueChanged<String> changed,
  ) => DropdownButtonFormField<String>(
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    items: values
        .map(
          (item) => DropdownMenuItem(
            value: item,
            child: Text(item.replaceAll('_', ' ').toUpperCase()),
          ),
        )
        .toList(),
    onChanged: (next) {
      if (next != null) changed(next);
    },
  );

  Map<String, dynamic> get _payload => {
    'part_number': partNumber.text.trim(),
    'item_name': itemName.text.trim(),
    'item_model': model.text.trim().isEmpty ? null : model.text.trim(),
    'default_dr_code': dr.text.trim().isEmpty ? null : dr.text.trim(),
    'default_pack_quantity': int.tryParse(pack.text) ?? 1,
    'barcode_type': symbology,
    'is_active': true,
  };

  Future<void> _load() async {
    final tenant = WindowsSession.companyId;
    if (tenant == null) {
      setState(() {
        parts = const [];
        loading = false;
        message = 'Sign in to load parts';
      });
      return;
    }
    setState(() => loading = true);
    try {
      final loaded = await repository.list(tenant, search: search.text.trim());
      if (mounted) {
        setState(() {
          parts = loaded;
          loading = false;
          message = '${loaded.length} parts loaded';
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          parts = const [];
          loading = false;
          message = 'Company parts could not be loaded';
        });
      }
    }
  }

  void _searchChanged() {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 350), _load);
  }

  void _select(PartRecord part) => setState(() {
    selected = part;
    partNumber.text = part.number;
    itemName.text = part.name;
    model.text = part.model;
    dr.text = part.drCode;
    pack.text = part.packQuantity.toString();
    symbology = ['qr', 'data_matrix', 'code128'].contains(part.barcodeType)
        ? part.barcodeType
        : 'code128';
    message = '${part.number} selected';
  });

  Future<void> _saveNew() =>
      _mutate((tenant) => repository.create(tenant, _payload), 'Part inserted');
  Future<void> _update() => _mutate(
    (tenant) => repository.update(tenant, selected!, _payload),
    'Part updated',
  );

  Future<void> _mutate(
    Future<PartRecord> Function(String) action,
    String success,
  ) async {
    if (partNumber.text.trim().isEmpty || itemName.text.trim().isEmpty) {
      _notice('Part number and item name are required');
      return;
    }
    final tenant = WindowsSession.companyId;
    if (tenant == null) {
      _notice('Please sign in before making part master changes');
      return;
    }
    setState(() => busy = true);
    try {
      final changed = await action(tenant);
      await _load();
      final persisted = parts
          .where((part) => part.id == changed.id)
          .firstOrNull;
      if (persisted == null) {
        throw StateError('The updated part could not be reloaded.');
      }
      _select(persisted);
      _notice(success);
    } catch (error) {
      _notice(_error(error));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _delete() async {
    final tenant = WindowsSession.companyId;
    if (tenant == null || selected == null) return;
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete part?'),
            content: Text(
              '${selected!.number} will be removed from the active part master.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    try {
      await repository.delete(tenant, selected!.id);
      _clear();
      await _load();
      _notice('Part deleted');
    } catch (error) {
      _notice(_error(error));
    }
  }

  BrowserLabelDocument _getDocument(bool withName) {
    final size = sizes[labelSize]!;
    return BrowserLabelDocument(
      title: 'PART NO: ${partNumber.text}',
      content: codeData,
      widthMm: size.$1,
      heightMm: size.$2,
      symbology: symbology,
      itemName: withName ? itemName.text : '',
      model: model.text,
      partNumber: partNumber.text.trim(),
      port: portLabel.text.trim(),
      dateText: labelDate.text.trim(),
      timeText: labelTime.text.trim(),
      dualSideCodes: dualSideCodes,
      company: companyName.text.trim(),
      companyAddress: companyAddress.text.trim(),
      packQty: int.tryParse(pack.text) ?? 1,
      stickersPerRow: stickersPerRow,
      includeBorder: includeBorder,
    );
  }

  Future<void> _generate({bool? withName}) async {
    if (partNumber.text.trim().isEmpty) {
      _notice('Select or enter a part first');
      return;
    }
    setState(() => busy = true);
    try {
      if (autoDateTime) {
        _stampNow();
      }
      final bytes = await const BrowserPdfGenerator().generate(
        _getDocument(withName ?? includeName),
      );
      await gateway.download(bytes, 'codevault-${partNumber.text}.pdf');
      _notice('Label PDF generated');
    } catch (error) {
      _notice(_error(error));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _print({bool? withName}) async {
    final copies = int.tryParse(quantity.text) ?? 0;
    if (partNumber.text.trim().isEmpty || copies < 1) {
      _notice('Select a part and enter a valid print quantity');
      return;
    }
    setState(() => busy = true);
    try {
      if (autoDateTime) {
        _stampNow();
      }
      final bytes = await const BrowserPdfGenerator().generate(
        _getDocument(withName ?? includeName),
      );
      if (_selectedPrinter != null) {
        await Printing.directPrintPdf(
          printer: _selectedPrinter!,
          onLayout: (format) async => bytes,
        );
      } else {
        await gateway.showPrintDialog(
          bytes,
          'codevault-${partNumber.text}.pdf',
        );
      }
      ref.read(productionActivityProvider.notifier).recordPrint(copies);
      _notice('$copies label${copies == 1 ? '' : 's'} sent to print');
    } catch (error) {
      _notice(_error(error));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void _clear() => setState(() {
    selected = null;
    for (final controller in [partNumber, itemName, model]) {
      controller.clear();
    }
    serial.text = '001';
    dr.text = 'NR';
    pack.text = '1';
    quantity.text = '1';
    if (autoDateTime) {
      _stampNow();
    }
    message = 'Ready for production';
  });

  void _notice(String value) {
    if (!mounted) return;
    setState(() => message = value);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  String _error(Object error) => error is DioException
      ? switch (error.response?.statusCode) {
          401 => 'Your session expired. Please sign in again.',
          403 => 'This account does not have permission for that action.',
          409 => 'This record was changed elsewhere. Refresh and retry.',
          _ => 'The request could not be completed. Please retry.',
        }
      : error.toString();
}
