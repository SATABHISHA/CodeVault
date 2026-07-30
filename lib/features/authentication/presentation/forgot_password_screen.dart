import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/remote_auth_service.dart';

/// Web / Android only. On Windows, password recovery goes through
/// OfflineRecoveryScreen which uses the local SQLite database.
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
                    Text(
                      requested ? 'Set a new password' : 'Recover your account',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      requested
                          ? 'Paste the reset token from your email and choose a secure password.'
                          : 'Enter the email linked to your CodeVault account. We will send reset instructions if it exists.',
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                    ),
                    if (requested) ...[
                      const SizedBox(height: 14),
                      TextField(
                        controller: token,
                        decoration: const InputDecoration(
                          labelText: 'Reset token',
                          prefixIcon: Icon(Icons.key),
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
                            : 'Send reset instructions',
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
      await (widget.authService ?? RemoteAuthService()).forgotPassword(
        email.text,
      );
      if (mounted) {
        setState(() {
          requested = true;
          message = 'If the account exists, reset instructions were sent.';
        });
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
