import 'package:codevault/core/config/brand_config.dart';
import 'package:codevault/core/platform/platform_capabilities.dart';
import 'package:codevault/core/security/token_store.dart';
import 'package:codevault/features/authentication/data/remote_auth_service.dart';
import 'package:codevault/features/authentication/presentation/session_controller.dart';
import 'package:codevault/features/windows_desktop/application/windows_session.dart';
import 'package:codevault/platform/windows/data/bootstrap_store.dart';
import 'package:codevault/shared/widgets/animated_login_background.dart';
import 'package:codevault/shared/widgets/app_text_field.dart';
import 'package:dio/dio.dart';
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
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedUsername();
  }

  Future<void> _loadRememberedUsername() async {
    try {
      final saved = await const SecureTokenStore().readKey(
        'cloud_login_username',
      );
      if (saved != null && saved.isNotEmpty) {
        if (mounted) {
          setState(() {
            login.text = saved;
            rememberMe = true;
          });
        }
      }
    } catch (_) {
      // Username memory is optional and must not block login UX.
    }
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
                                controller: login,
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
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: rememberMe,
                                        onChanged: (val) => setState(
                                            () => rememberMe = val ?? false),
                                      ),
                                      const Text('Remember me'),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        context.go('/forgot-password'),
                                    child: const Text('Forgot password?'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              FilledButton.icon(
                                key: const Key('remote-login'),
                                onPressed: busy ? null : _submit,
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

  Future<void> _submit() async {
    if (login.text.trim().isEmpty || password.text.isEmpty) {
      await _showLoginFailure('Enter your username and password to continue.');
      return;
    }
    setState(() {
      busy = true;
    });
    try {
      final capabilities = PlatformCapabilities.current();
      final session = await (widget.authService ?? RemoteAuthService()).login(
        login: login.text,
        password: password.text,
        deviceName:
            'CodeVault ${capabilities.isAndroid
                ? 'Android'
                : capabilities.isWindows
                ? 'Windows'
                : 'Web'}',
        platform: capabilities.isAndroid ? 'android' : 'web',
      );
      ref
          .read(sessionProvider.notifier)
          .signInRemote(
            userId: session.userId,
            tenantId: session.tenantId,
            mustChangePassword: session.mustChangePassword,
            permissions: session.permissions,
            deviceId: session.deviceId,
            role: session.role,
            companyName: session.companyName,
            companyAddress: session.companyAddress,
          );

      // Prime in-memory session immediately (safe — no I/O).
      if (session.tenantId != null) {
        WindowsSession.companyId = session.tenantId;
        WindowsSession.companyName = session.companyName;
        WindowsSession.companyAddress = session.companyAddress;
        WindowsSession.userId = session.userId;
        WindowsSession.role = session.role;
        WindowsSession.permissions = session.permissions;
        // Persist companyId in bootstrap storage; web/android data lives in
        // their own local cache DBs after login.
        _persistCompanyId(session.tenantId!);
      }

      try {
        if (rememberMe) {
          await const SecureTokenStore().writeKey(
            'cloud_login_username',
            login.text.trim(),
          );
        } else {
          await const SecureTokenStore().writeKey('cloud_login_username', '');
        }
      } catch (_) {
        // Optional preference storage must not fail sign-in.
      }

      if (mounted) {
        context.go('/dashboard');
      }
    } catch (exception) {
      if (mounted) {
        String message;
        if (exception is DioException) {
          if (exception.response == null) {
            message = 'We could not reach CodeVault. Check your connection and try again.';
          } else if (exception.response?.statusCode == 429) {
            message = 'Too many attempts. Please wait a moment before trying again.';
          } else if (exception.response?.statusCode == 422) {
            message = 'The username or password is incorrect. Please check your details.';
          } else if (exception.response?.statusCode == 403) {
            message = 'Your account or tenant is currently unavailable.';
          } else {
            message = 'An unexpected server error occurred (${exception.response?.statusCode}). Please try again later.';
          }
        } else {
          message = 'An unexpected error occurred. Please try again.';
        }
        await _showLoginFailure(message);
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  /// Persists [companyId] to [BootstrapStore].
  /// Runs fire-and-forget; failures must not block login.
  Future<void> _persistCompanyId(String companyId) async {
    try {
      await createBootstrapStore().writeCompanyId(companyId);
    } catch (_) { /* bootstrap store failure is non-fatal */ }
  }

  Future<void> _showLoginFailure(String message) => showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (context, animation, secondaryAnimation) => Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 410,
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 40,
                offset: Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 550),
                tween: Tween(begin: 0, end: 1),
                curve: Curves.elasticOut,
                builder: (context, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF5C8A), Color(0xFFFF875C)],
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_person_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Sign in unsuccessful',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    transitionBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: child,
          ),
        ),
  );
}
