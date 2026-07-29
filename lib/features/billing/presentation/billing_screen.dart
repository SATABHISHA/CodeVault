import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../authentication/presentation/session_controller.dart';
import '../data/billing_service.dart';

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});
  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  final service = BillingService();
  List<dynamic> tenants = const [], payments = const [];
  String? tenant, error;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final values = await service.tenants();
      final selected =
          tenant ??
          (values.isEmpty
              ? null
              : (values.first as Map<String, dynamic>)['id'] as String);
      final records = selected == null
          ? <dynamic>[]
          : await service.payments(selected);
      if (mounted) {
        setState(() {
          tenants = values;
          tenant = selected;
          payments = records;
          error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => error = 'Billing data could not be loaded: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePayment(String paymentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment'),
        content: const Text('Are you sure you want to delete this payment record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || tenant == null) return;

    setState(() => _isLoading = true);
    try {
      await service.deletePayment(tenant!, paymentId);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final owner = ref.watch(sessionProvider).role == 'super-superadmin';
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5130B7), Color(0xFFE04F92)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'Billing & Payment Center',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (error != null)
              Card(
                color: Colors.red.shade50,
                child: ListTile(
                  title: Text(error!, style: TextStyle(color: Colors.red.shade900)),
                  trailing: TextButton(
                    onPressed: _load,
                    child: const Text('Retry'),
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withAlpha(51)), // 0.2 opacity
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: tenant,
                  isExpanded: true,
                  hint: const Text('Select Company / Tenant'),
                  items: [
                    for (final raw in tenants)
                      DropdownMenuItem(
                        value: (raw as Map<String, dynamic>)['id'] as String,
                        child: Text(raw['name'] as String, style: const TextStyle(fontWeight: FontWeight.w500)),
                      ),
                  ],
                  onChanged: (value) async {
                    if (value != tenant) {
                      tenant = value;
                      await _load();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Payments', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                FilledButton.icon(
                  onPressed: tenant == null ? null : () => showDialog(context: context, builder: (context) => _ReceiptDialog(tenant: tenant!, service: service, onComplete: _load, printCallback: _printReceipt)),
                  icon: const Icon(Icons.add_card),
                  label: const Text('New Payment'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF5130B7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (payments.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(child: Text('No payments recorded yet.', style: TextStyle(color: Colors.grey.shade600))),
              ),
            for (final raw in payments)
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFE04F92).withAlpha(26), // 0.1 opacity
                    child: const Icon(Icons.receipt_long, color: Color(0xFFE04F92)),
                  ),
                  title: Text(
                    '₹${((raw as Map<String, dynamic>)['amount_minor'] as num? ?? 0) / 100}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(
                    '${raw['payment_date']} • Method: ${raw['method']?.toString().toUpperCase()} • ${raw['status']}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          raw['receipt_number'] as String? ?? 'N/A',
                          style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.print, color: Color(0xFF5130B7)),
                        tooltip: 'Print Receipt',
                        onPressed: () => _printReceipt(raw),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        tooltip: 'Delete',
                        onPressed: () => _deletePayment(raw['id'] as String),
                      ),
                    ],
                  ),
                ),
              ),
            if (owner) ...[const SizedBox(height: 24), _smtpCard()],
          ],
        ),
        if (_isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black12,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  Future<void> _printReceipt(Map<String, dynamic> raw) async {
    final pdf = pw.Document();
    
    final baseAmt = raw['base_amount'] ?? (((raw['amount_minor'] as num? ?? 0) / 100).toDouble());
    final isGst = raw['is_gst'] == true || (raw['notes']?.toString().contains('SGST') ?? false);
    final receiptNum = raw['receipt_number'] ?? raw['reference'] ?? 'N/A';
    final tenantName = tenants.firstWhere((t) => (t as Map<String, dynamic>)['id'] == tenant, orElse: () => {'name': tenant})['name'];

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('TAX RECEIPT', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF5130B7))),
              pw.SizedBox(height: 24),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Receipt No: $receiptNum', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Date: ${raw['payment_date'] ?? DateTime.now().toIso8601String().substring(0, 10)}'),
                      pw.Text('Client: $tenantName'),
                    ]
                  ),
                  if (raw['is_gst'] == true || raw['company_gst'] != null)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Our GSTIN: ${raw['company_gst'] ?? 'N/A'}'),
                        pw.Text('Client GSTIN: ${raw['client_gst'] ?? 'N/A'}'),
                      ]
                    ),
                ]
              ),
              pw.SizedBox(height: 30),
              pw.TableHelper.fromTextArray(
                context: context,
                border: pw.TableBorder.all(color: const PdfColor.fromInt(0xFFE0E0E0)),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF5130B7)),
                cellPadding: const pw.EdgeInsets.all(10),
                data: <List<String>>[
                  ['Description', 'Amount (INR)'],
                  if (isGst) ...[
                    ['Base Amount', (raw['base_amount'] ?? 0.0).toStringAsFixed(2)],
                    if ((raw['sgst'] ?? 0) > 0) ['SGST (9%)', (raw['sgst'] as num).toStringAsFixed(2)],
                    if ((raw['cgst'] ?? 0) > 0) ['CGST (9%)', (raw['cgst'] as num).toStringAsFixed(2)],
                    if ((raw['igst'] ?? 0) > 0) ['IGST (18%)', (raw['igst'] as num).toStringAsFixed(2)],
                  ],
                  ['Total Amount', (raw['total_amount'] ?? baseAmt).toStringAsFixed(2)],
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Text('Thank you for your business!', style: const pw.TextStyle(fontSize: 16)),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.layoutPdf(onLayout: (format) async => bytes);
  }

  Widget _smtpCard() => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: ListTile(
      contentPadding: const EdgeInsets.all(20),
      leading: CircleAvatar(
        backgroundColor: Colors.blue.withAlpha(26), // 0.1 opacity
        child: const Icon(Icons.outgoing_mail, color: Colors.blue),
      ),
      title: const Text('Platform SMTP Server', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: const Text(
        'Configure the server used for invoices, receipts, requests and account email.',
      ),
      trailing: FilledButton(onPressed: _smtp, child: const Text('Configure')),
    ),
  );

  Future<void> _smtp() async {
    final current = await service.smtp() ?? const <String, dynamic>{};
    if (!mounted) return;
    final labels = [
      'Host',
      'Port',
      'Username',
      'Password (leave blank to keep)',
      'From name',
      'From address',
      'Reply-to',
      'Test recipient',
    ];
    final c = [
      for (final label in labels)
        TextEditingController(
          text: switch (label) {
            'Host' => current['host']?.toString(),
            'Port' => current['port']?.toString() ?? '587',
            'Username' => current['username']?.toString(),
            'From name' => current['from_name']?.toString() ?? 'Ahanova AI Technologies Pvt. Ltd.',
            'From address' => current['from_address']?.toString(),
            'Reply-to' => current['reply_to']?.toString(),
            'Test recipient' => current['test_recipient']?.toString(),
            _ => '',
          },
        ),
    ];
    final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('SMTP Settings'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (var i = 0; i < labels.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextField(
                          controller: c[i],
                          obscureText: i == 3,
                          decoration: InputDecoration(
                            labelText: labels[i],
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
            ],
          ),
        ) ?? false;
    if (!ok) return;
    await service.saveSmtp({
      'host': c[0].text,
      'port': int.tryParse(c[1].text) ?? 587,
      'encryption': 'tls',
      'username': c[2].text,
      'password': c[3].text,
      'from_name': c[4].text,
      'from_address': c[5].text,
      'reply_to': c[6].text.isEmpty ? null : c[6].text,
      'timeout': 30,
      'test_recipient': c[7].text,
      'enabled': true,
    });
    if (c[7].text.isNotEmpty) await service.testSmtp(c[7].text);
  }
}

class _ReceiptDialog extends StatefulWidget {
  final String tenant;
  final BillingService service;
  final VoidCallback onComplete;
  final Function(Map<String, dynamic>) printCallback;

  const _ReceiptDialog({required this.tenant, required this.service, required this.onComplete, required this.printCallback});

  @override
  State<_ReceiptDialog> createState() => _ReceiptDialogState();
}

class _ReceiptDialogState extends State<_ReceiptDialog> with SingleTickerProviderStateMixin {
  final baseAmountController = TextEditingController();
  final companyGstController = TextEditingController();
  final clientGstController = TextEditingController();
  String selectedMethod = 'bank_transfer';
  bool isGst = false;
  bool isProcessing = false;
  String? errorMsg;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 16,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 480,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Theme.of(context).cardColor,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFF5130B7).withAlpha(26), shape: BoxShape.circle),
                    child: const Icon(Icons.receipt_long, color: Color(0xFF5130B7), size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(child: Text('New Payment & Receipt', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 24),
              if (errorMsg != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Text(errorMsg!, style: TextStyle(color: Colors.red.shade900)),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: baseAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Base Amount (₹)',
                  prefixIcon: const Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedMethod,
                    isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'upi', child: Text('UPI')),
                  DropdownMenuItem(value: 'card', child: Text('Card')),
                  DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                    onChanged: (v) => setState(() => selectedMethod = v!),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Generate GST Invoice', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Automatically calculate SGST/CGST/IGST'),
                activeTrackColor: const Color(0xFFE04F92),
                value: isGst,
                onChanged: (val) => setState(() => isGst = val),
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: isGst ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                firstChild: const SizedBox(width: double.infinity, height: 0),
                secondChild: Column(
                  children: [
                    const SizedBox(height: 16),
                    TextField(
                      controller: companyGstController,
                      decoration: InputDecoration(
                        labelText: 'Our Company GSTIN',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: clientGstController,
                      decoration: InputDecoration(
                        labelText: 'Client GSTIN',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isProcessing ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF5130B7),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isProcessing ? null : _submit,
                    icon: isProcessing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check),
                    label: const Text('Record Payment'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() {
      isProcessing = true;
      errorMsg = null;
    });

    try {
      final baseAmount = double.tryParse(baseAmountController.text.trim()) ?? 0.0;
      if (baseAmount <= 0) throw Exception('Please enter a valid amount.');

      double sgst = 0, cgst = 0, igst = 0;
      if (isGst && companyGstController.text.length >= 2 && clientGstController.text.length >= 2) {
        final ourState = companyGstController.text.substring(0, 2);
        final clientState = clientGstController.text.substring(0, 2);
        if (ourState == clientState) {
          sgst = baseAmount * 0.09;
          cgst = baseAmount * 0.09;
        } else {
          igst = baseAmount * 0.18;
        }
      }

      final totalAmount = baseAmount + sgst + cgst + igst;
      final receiptNumber = 'REC-${DateTime.now().millisecondsSinceEpoch}';

      // Record payment with Laravel Backend. Ensure amount is 2 decimal places.
      await widget.service.recordPayment(widget.tenant, {
        'payment_date': DateTime.now().toIso8601String().substring(0, 10),
        'method': selectedMethod,
        'reference': receiptNumber,
        'amount': totalAmount.toStringAsFixed(2), // FIX: 422 Error
        'status': 'completed',
        'notes': isGst ? 'GST Billing - Base: $baseAmount, SGST: $sgst, CGST: $cgst, IGST: $igst' : 'Standard Payment',
      });

      final data = {
        'tenant_id': widget.tenant,
        'receipt_number': receiptNumber,
        'base_amount': baseAmount,
        'is_gst': isGst,
        'company_gst': isGst ? companyGstController.text.trim() : null,
        'client_gst': isGst ? clientGstController.text.trim() : null,
        'sgst': sgst,
        'cgst': cgst,
        'igst': igst,
        'total_amount': totalAmount,
      };

      widget.onComplete();
      
      if (mounted) Navigator.pop(context);
      
      widget.printCallback(data);
    } catch (e) {
      setState(() {
        isProcessing = false;
        errorMsg = e.toString().replaceAll('Exception: ', '');
      });
    }
  }
}

