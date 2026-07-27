import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/remote_auth_service.dart';
import 'session_controller.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key, this.authService});
  final RemoteAuthService? authService;

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final current = TextEditingController();
  final password = TextEditingController();
  final confirmation = TextEditingController();
  bool busy = false;
  String? error;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Change temporary password',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Development seed accounts must choose a private password before accessing tenant or platform data.',
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: current,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Current password',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New password',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmation,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm new password',
                    ),
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
                      key: const Key('change-seed-password'),
                      onPressed: busy ? null : _submit,
                      child: Text(busy ? 'Changing…' : 'Change password'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _submit() async {
    if (password.text != confirmation.text || password.text.length < 12) {
      setState(
        () =>
            error = 'Passwords must match and contain at least 12 characters.',
      );
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await (widget.authService ?? RemoteAuthService()).changePassword(
        currentPassword: current.text,
        newPassword: password.text,
      );
      ref.read(sessionProvider.notifier).passwordChanged();
      if (mounted) context.go('/dashboard');
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'Password change failed. Verify the current password and password length.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
