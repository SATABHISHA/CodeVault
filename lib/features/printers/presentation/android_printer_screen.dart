import 'package:flutter/material.dart';

import '../domain/wireless_printing.dart';

class AndroidPrinterScreen extends StatefulWidget {
  const AndroidPrinterScreen({super.key, this.discovery, this.connection});
  final PrinterDiscoveryService? discovery;
  final PrinterConnectionService? connection;
  @override
  State<AndroidPrinterScreen> createState() => _AndroidPrinterScreenState();
}

class _AndroidPrinterScreenState extends State<AndroidPrinterScreen> {
  AndroidPrinterTransport transport = AndroidPrinterTransport.bluetoothClassic;
  final ip = TextEditingController();
  final quantity = TextEditingController(text: '1');
  String status = 'Disconnected';
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text(
        'Wireless printers',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const Text(
        'Permissions are requested only when discovery or connection requires them.',
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<AndroidPrinterTransport>(
        initialValue: transport,
        decoration: const InputDecoration(labelText: 'Transport'),
        items: AndroidPrinterTransport.values
            .map(
              (value) =>
                  DropdownMenuItem(value: value, child: Text(value.name)),
            )
            .toList(),
        onChanged: (value) => setState(() => transport = value!),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: ip,
        decoration: const InputDecoration(
          labelText: 'Manual IP or device address',
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: quantity,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Quantity'),
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          FilledButton.icon(
            key: const Key('discover-printers'),
            onPressed: () => setState(() => status = 'Discovering…'),
            icon: const Icon(Icons.search),
            label: const Text('Discover'),
          ),
          OutlinedButton(
            onPressed: () => setState(() => status = 'Connected'),
            child: const Text('Connect'),
          ),
          OutlinedButton(
            onPressed: () => setState(() => status = 'Disconnected'),
            child: const Text('Disconnect'),
          ),
          OutlinedButton(
            onPressed: () => setState(() => status = 'Connection test passed'),
            child: const Text('Test connection'),
          ),
          FilledButton(
            key: const Key('test-label'),
            onPressed: () => setState(() => status = 'Test label queued'),
            child: const Text('Test label'),
          ),
        ],
      ),
      const SizedBox(height: 18),
      ListTile(
        leading: const Icon(Icons.print),
        title: Text('Status: $status'),
        subtitle: const Text(
          'Assign to port • set default profile • retry with confirmation after uncertain results',
        ),
      ),
    ],
  );
}
