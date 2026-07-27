import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/brand_config.dart';
import '../../../platform/windows/data/bootstrap_store.dart';
import '../../../shared/widgets/animated_login_background.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../application/local_account_service.dart';
import '../application/windows_session.dart';
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

class _FirstRunSetupScreenState extends State<FirstRunSetupScreen> with SingleTickerProviderStateMixin {
  final company = TextEditingController();
  final address = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final username = TextEditingController();
  final name = TextEditingController();
  final password = TextEditingController();
  bool busy = false;
  String? error;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    company.dispose();
    address.dispose();
    email.dispose();
    phone.dispose();
    username.dispose();
    name.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        Positioned.fill(child: AnimatedLoginBackground(busy: busy)),
        Center(
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Colors.blueAccent, Colors.purpleAccent, Colors.pinkAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purpleAccent.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            padding: const EdgeInsets.all(2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: .85),
                  padding: const EdgeInsets.all(42),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CodeVault',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.0,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            'by ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    colors: const [
                                      Colors.blueAccent,
                                      Colors.purpleAccent,
                                      Colors.pinkAccent,
                                      Colors.deepOrangeAccent,
                                      Colors.blueAccent,
                                    ],
                                    stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                                    transform: GradientRotation(_pulseController.value * 2 * 3.1415926535),
                                  ).createShader(bounds);
                                },
                                child: const Text(
                                  'Ahanova AI Technologies Pvt Ltd',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            'wecare@ahanova.in',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Setup your authoritative local company database. No internet or Laravel login is used.',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 32),
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
                  ],
                ),
              ), // Container
              ), // BackdropFilter
            ), // ClipRRect
          ), // Container (outer gradient)
        ), // ConstrainedBox
      ), // SingleChildScrollView
    ), // Center
  ],
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
    body: Stack(
      children: [
        Positioned.fill(child: AnimatedLoginBackground(busy: busy)),
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1060),
              child: Card(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: .94),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final welcome = Container(
                        padding: const EdgeInsets.all(42),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF7357FF), Color(0xFF00AFC8)],
                          ),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.qr_code_2_rounded,
                              color: Colors.white,
                              size: 58,
                            ),
                            SizedBox(height: 30),
                            Text(
                              'Industrial labels, beautifully controlled.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                height: 1.15,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Manage part masters, generate production codes, preview exact label sizes and print across Windows, web and Android.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 28),
                            Wrap(
                              spacing: 18,
                              runSpacing: 12,
                              children: [
                                FeatureWidget(
                                  icon: Icons.offline_bolt,
                                  label: 'Offline ready',
                                ),
                                FeatureWidget(
                                  icon: Icons.sync,
                                  label: 'Secure sync',
                                ),
                                FeatureWidget(
                                  icon: Icons.print,
                                  label: 'Multi-printer',
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                      final form = Padding(
                        padding: const EdgeInsets.all(38),
                        child: AutofillGroup(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                BrandConfig.productName,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Welcome back. Sign in to your workspace.',
                              ),
                              const SizedBox(height: 28),
                              AppTextField(
                                label: 'Username or email',
                                icon: Icons.person_outline,
                                controller: username,
                                autofillHints: const [AutofillHints.username],
                              ),
                              const SizedBox(height: 15),
                              AppTextField(
                                label: 'Password',
                                icon: Icons.lock_outline,
                                controller: password,
                                obscureText: true,
                                autofillHints: const [AutofillHints.password],
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
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => context.push(
                                    '/windows/recovery',
                                    extra: widget.companyId,
                                  ),
                                  child: const Text('Forgot password?'),
                                ),
                              ),
                              const SizedBox(height: 15),
                              FilledButton.icon(
                                key: const Key('local-login'),
                                onPressed: busy ? null : _login,
                                icon: busy
                                    ? const SizedBox.square(
                                        dimension: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.arrow_forward),
                                label: Text(
                                  busy ? 'Signing in…' : 'Sign in securely',
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                BrandConfig.poweredBy,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      );
                      if (constraints.maxWidth < 780) return form;
                      return SizedBox(
                        height: 640,
                        child: Row(
                          children: [
                            Expanded(child: welcome),
                            Expanded(child: form),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
  Future<void> _login() async {
    setState(() {
      busy = true;
      error = null;
    });
    final database = LocalDatabase(widget.companyId);
    try {
      final result = await LocalAccountService(
        database,
      ).login(username.text, password.text);
      WindowsSession.companyId = widget.companyId;
      WindowsSession.userId = result.user.id;
      WindowsSession.role = result.user.role;
      WindowsSession.permissions = result.permissions;
      final company = await (database.select(
        database.companies,
      )..where((row) => row.id.equals(widget.companyId))).getSingle();
      WindowsSession.companyName = company.name;
      WindowsSession.companyAddress = company.address ?? '';
      if (mounted) context.go('/windows/dashboard');
    } catch (exception) {
      if (mounted) setState(() => error = exception.toString());
    } finally {
      await database.close();
      if (mounted) setState(() => busy = false);
    }
  }
}
