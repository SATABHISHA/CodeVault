import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/brand_config.dart';
import '../../../platform/windows/data/bootstrap_store.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../application/local_account_service.dart';
import '../data/local_database.dart';

class WindowsEntryScreen extends StatefulWidget {
  const WindowsEntryScreen({super.key, this.store});
  final BootstrapStore? store;
  @override
  State<WindowsEntryScreen> createState() => _WindowsEntryScreenState();
}

class _WindowsEntryScreenState extends State<WindowsEntryScreen> {
  late final BootstrapStore store = widget.store ?? createBootstrapStore();
  String? companyId;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    store.readCompanyId().then((value) {
      if (mounted) {
        setState(() {
          companyId = value;
          loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (companyId == null) {
      return FirstRunSetupScreen(
        onComplete: (id) async {
          await store.writeCompanyId(id);
          if (mounted) setState(() => companyId = id);
        },
      );
    }
    return LocalLoginScreen(companyId: companyId!);
  }
}

class FirstRunSetupScreen extends StatefulWidget {
  const FirstRunSetupScreen({required this.onComplete, super.key});
  final Future<void> Function(String companyId) onComplete;
  @override
  State<FirstRunSetupScreen> createState() => _FirstRunSetupScreenState();
}

class _FirstRunSetupScreenState extends State<FirstRunSetupScreen> {
  final company = TextEditingController();
  final address = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final username = TextEditingController();
  final name = TextEditingController();
  final password = TextEditingController();
  bool busy = false;
  String? error;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set up CodeVault',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Text(
                    'Creates an authoritative local company database. No internet or Laravel login is used.',
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: 330,
                        child: AppTextField(
                          label: 'Company name',
                          controller: company,
                        ),
                      ),
                      SizedBox(
                        width: 330,
                        child: AppTextField(
                          label: 'Address',
                          controller: address,
                        ),
                      ),
                      SizedBox(
                        width: 330,
                        child: AppTextField(
                          label: 'Company email',
                          controller: email,
                        ),
                      ),
                      SizedBox(
                        width: 330,
                        child: AppTextField(label: 'Phone', controller: phone),
                      ),
                      SizedBox(
                        width: 330,
                        child: AppTextField(
                          label: 'Admin username',
                          controller: username,
                        ),
                      ),
                      SizedBox(
                        width: 330,
                        child: AppTextField(
                          label: 'Admin display name',
                          controller: name,
                        ),
                      ),
                      SizedBox(
                        width: 330,
                        child: AppTextField(
                          label: 'Admin password (12+ characters)',
                          controller: password,
                          obscureText: true,
                        ),
                      ),
                    ],
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    key: const Key('initialize-local-company'),
                    onPressed: busy ? null : _submit,
                    icon: const Icon(Icons.business),
                    label: Text(
                      busy ? 'Initializing…' : 'Create local company',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(BrandConfig.poweredBy),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  Future<void> _submit() async {
    setState(() {
      busy = true;
      error = null;
    });
    final provisionalId = const Uuid().v4();
    final database = LocalDatabase(provisionalId);
    try {
      final id = await LocalAccountService(database).initializeCompany(
        companyId: provisionalId,
        name: company.text,
        username: username.text,
        displayName: name.text,
        password: password.text,
        address: address.text,
        phone: phone.text,
        email: email.text,
      );
      if (id != provisionalId) {
        throw StateError('Company database identity mismatch.');
      }
      await widget.onComplete(id);
    } catch (exception) {
      if (mounted) setState(() => error = exception.toString());
    } finally {
      await database.close();
      if (mounted) setState(() => busy = false);
    }
  }
}

class LocalLoginScreen extends StatefulWidget {
  const LocalLoginScreen({required this.companyId, super.key});
  final String companyId;
  @override
  State<LocalLoginScreen> createState() => _LocalLoginScreenState();
}

class _LocalLoginScreenState extends State<LocalLoginScreen> {
  final username = TextEditingController();
  final password = TextEditingController();
  String? error;
  bool busy = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.offline_bolt, size: 52),
                Text(
                  'Local offline login',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Text(
                  'This Windows account is stored only on this computer.',
                ),
                const SizedBox(height: 24),
                AppTextField(label: 'Username', controller: username),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Password',
                  controller: password,
                  obscureText: true,
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const Key('local-login'),
                    onPressed: busy ? null : _login,
                    child: const Text('Open local dashboard'),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push(
                    '/windows/recovery',
                    extra: widget.companyId,
                  ),
                  child: const Text('Local Offline Recovery'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  Future<void> _login() async {
    setState(() {
      busy = true;
      error = null;
    });
    final database = LocalDatabase(widget.companyId);
    try {
      await LocalAccountService(database).login(username.text, password.text);
      if (mounted) context.go('/windows/operations');
    } catch (exception) {
      if (mounted) setState(() => error = exception.toString());
    } finally {
      await database.close();
      if (mounted) setState(() => busy = false);
    }
  }
}
