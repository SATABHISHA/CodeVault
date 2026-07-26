import 'package:codevault/core/config/brand_config.dart';
import 'package:codevault/core/platform/platform_capabilities.dart';
import 'package:codevault/features/authentication/data/remote_auth_service.dart';
import 'package:codevault/features/authentication/presentation/session_controller.dart';
import 'package:codevault/shared/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.authService});
  final RemoteAuthService? authService;
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final login = TextEditingController();
  final password = TextEditingController();
  bool busy = false;
  String? error;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: AutofillGroup(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 56,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      BrandConfig.productName,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const Text('Secure Laravel account login'),
                    const SizedBox(height: 28),
                    AppTextField(
                      label: 'Username or email',
                      icon: Icons.person_outline,
                      controller: login,
                      autofillHints: const [AutofillHints.username],
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const Key('remote-login'),
                        onPressed: busy ? null : _submit,
                        icon: const Icon(Icons.login),
                        label: Text(busy ? 'Signing in…' : 'Sign in'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      BrandConfig.poweredBy,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
    try {
      final capabilities = PlatformCapabilities.current();
      final session = await (widget.authService ?? RemoteAuthService()).login(
        login: login.text,
        password: password.text,
        deviceName: 'CodeVault ${capabilities.isAndroid ? 'Android' : 'Web'}',
        platform: capabilities.isAndroid ? 'android' : 'web',
      );
      ref
          .read(sessionProvider.notifier)
          .signInRemote(
            userId: session.userId,
            tenantId: session.tenantId,
            mustChangePassword: session.mustChangePassword,
            permissions: session.permissions,
          );
      if (mounted) context.go('/dashboard');
    } catch (exception) {
      if (mounted) {
        setState(
          () => error =
              'Sign in failed. Check credentials and server connection.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
