import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final owner = ref.watch(sessionProvider).role == 'super-superadmin';
    return ListView(
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
            'Billing & payment center',
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
            child: ListTile(
              title: Text(error!),
              trailing: TextButton(
                onPressed: _load,
                child: const Text('Retry'),
              ),
            ),
          ),
        DropdownButtonFormField<String>(
          initialValue: tenant,
          decoration: const InputDecoration(labelText: 'Company / tenant'),
          items: [
            for (final raw in tenants)
              DropdownMenuItem(
                value: (raw as Map<String, dynamic>)['id'] as String,
                child: Text(raw['name'] as String),
              ),
          ],
          onChanged: (value) async {
            tenant = value;
            await _load();
          },
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: tenant == null ? null : _record,
            icon: const Icon(Icons.payments_outlined),
            label: const Text('Record payment'),
          ),
        ),
        const SizedBox(height: 16),
        for (final raw in payments)
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long),
              title: Text(
                '₹${((raw as Map<String, dynamic>)['amount_minor'] as num? ?? 0) / 100}',
              ),
              subtitle: Text(
                '${raw['payment_date']} • ${raw['method']} • ${raw['status']}',
              ),
              trailing: Text(raw['receipt_number'] as String? ?? ''),
            ),
          ),
        if (owner) ...[const SizedBox(height: 24), _smtpCard()],
      ],
    );
  }

  Future<void> _record() async {
    final fields = [for (var i = 0; i < 4; i++) TextEditingController()];
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Record payment'),
            content: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: fields[0],
                    decoration: const InputDecoration(labelText: 'Amount'),
                  ),
                  TextField(
                    controller: fields[1],
                    decoration: const InputDecoration(labelText: 'Reference'),
                  ),
                  TextField(
                    controller: fields[2],
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                  TextField(
                    controller: fields[3],
                    decoration: const InputDecoration(
                      labelText:
                          'Method: cash, upi, bank_transfer, card, cheque, other',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Record'),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    await service.recordPayment(tenant!, {
      'payment_date': DateTime.now().toIso8601String().substring(0, 10),
      'method': fields[3].text.trim().isEmpty
          ? 'bank_transfer'
          : fields[3].text.trim(),
      'reference': fields[1].text.trim(),
      'amount': fields[0].text.trim(),
      'status': 'completed',
      'notes': fields[2].text.trim(),
    });
    await _load();
  }

  Widget _smtpCard() => Card(
    child: ListTile(
      leading: const Icon(Icons.outgoing_mail),
      title: const Text('Platform SMTP server'),
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
            'From name' =>
              current['from_name']?.toString() ??
                  'Ahanova AI Technologies Pvt. Ltd.',
            'From address' => current['from_address']?.toString(),
            'Reply-to' => current['reply_to']?.toString(),
            'Test recipient' => current['test_recipient']?.toString(),
            _ => '',
          },
        ),
    ];
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('SMTP server settings'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (var i = 0; i < labels.length; i++)
                      TextField(
                        controller: c[i],
                        obscureText: i == 3,
                        decoration: InputDecoration(labelText: labels[i]),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Save'),
              ),
            ],
          ),
        ) ??
        false;
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
