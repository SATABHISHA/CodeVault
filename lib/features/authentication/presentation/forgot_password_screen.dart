import 'package:codevault/core/platform/platform_capabilities.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../data/remote_auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.authService});
  final RemoteAuthService? authService;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final email = TextEditingController();
  final token = TextEditingController();
  final password = TextEditingController();

  bool requested = false;
  bool busy = false;
  String? message;
  String? _revealedToken; // only set on Windows after server returns the token

  bool get _isWindows => PlatformCapabilities.current().isWindows;

  @override
  void dispose() {
    email.dispose();
    token.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF120C2B), Color(0xFF062A3B), Color(0xFF101827)],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon header
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C4DFF), Color(0xFF00BCD4)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      requested ? 'Set a new password' : 'Recover your account',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      requested
                          ? (_isWindows
                              ? 'Copy the one-time token shown below, enter it and choose a new password.'
                              : 'Paste the reset token from your email and choose a secure password.')
                          : (_isWindows
                              ? 'Enter the email linked to your account. Your reset token will appear here — no email needed.'
                              : 'Enter the email linked to your CodeVault account. We will send reset instructions if it exists.'),
                    ),
                    const SizedBox(height: 24),

                    // Email field (always visible)
                    TextField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      readOnly: requested,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                    ),

                    // ── Windows: on-screen token reveal box ──
                    if (requested && _isWindows && _revealedToken != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2340),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF7C4DFF),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.key,
                                  size: 16,
                                  color: Color(0xFF7C4DFF),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Your one-time reset token',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(color: const Color(0xFF7C4DFF)),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 18),
                                  tooltip: 'Copy token',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: _revealedToken!),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Token copied to clipboard'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              _revealedToken!,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13,
                                letterSpacing: 0.5,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Single-use · expires in 60 minutes',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.white38),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Token + new password fields (shown after request)
                    if (requested) ...[
                      const SizedBox(height: 14),
                      TextField(
                        controller: token,
                        decoration: InputDecoration(
                          labelText: 'Reset token',
                          prefixIcon: const Icon(Icons.key),
                          hintText: _isWindows ? 'Paste the token shown above' : null,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: password,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'New password',
                          helperText: 'At least 12 characters',
                          prefixIcon: Icon(Icons.password),
                        ),
                      ),
                    ],

                    // Info / error message
                    if (message != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Text(
                          message!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    const SizedBox(height: 22),

                    // Primary action button
                    FilledButton.icon(
                      onPressed: busy ? null : (requested ? _reset : _request),
                      icon: Icon(
                        requested
                            ? Icons.check_circle_outline
                            : Icons.send_outlined,
                      ),
                      label: Text(
                        busy
                            ? 'Please wait…'
                            : requested
                            ? 'Reset password'
                            : (_isWindows
                                ? 'Generate reset token'
                                : 'Send reset instructions'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: () => context.go('/login'),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to sign in'),
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

  Future<void> _request() async {
    if (!email.text.contains('@')) {
      setState(() => message = 'Enter a valid email address.');
      return;
    }
    setState(() {
      busy = true;
      message = null;
    });
    try {
      final service = widget.authService ?? RemoteAuthService();
      if (_isWindows) {
        // Windows: fetch the token directly from the server and show it on-screen.
        final revealedToken = await service.revealPasswordToken(email.text);
        if (mounted) {
          setState(() {
            requested = true;
            _revealedToken = revealedToken;
            // Pre-fill the token field so the user just has to set the password.
            if (revealedToken != null) token.text = revealedToken;
            message = revealedToken != null
                ? 'Token generated. Copy it above or it is already filled in the field below.'
                : 'If the account exists, a token was generated.';
          });
        }
      } else {
        // Non-Windows: classic email flow.
        await service.forgotPassword(email.text);
        if (mounted) {
          setState(() {
            requested = true;
            message = 'If the account exists, reset instructions were sent.';
          });
        }
      }
    } catch (error) {
      if (mounted) setState(() => message = _error(error));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _reset() async {
    if (token.text.trim().isEmpty || password.text.length < 12) {
      setState(
        () => message =
            'Enter the reset token and a password of at least 12 characters.',
      );
      return;
    }
    setState(() {
      busy = true;
      message = null;
    });
    try {
      await (widget.authService ?? RemoteAuthService()).resetPassword(
        email: email.text,
        token: token.text,
        password: password.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset. You can now sign in.')),
        );
        context.go('/login');
      }
    } catch (error) {
      if (mounted) setState(() => message = _error(error));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String _error(Object error) => error is DioException
      ? (error.response?.data?.toString() ?? error.message ?? 'Request failed')
      : error.toString();
}

