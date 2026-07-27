import 'package:flutter/material.dart';

import '../../../shared/widgets/animated_login_background.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../application/offline_recovery_service.dart';
import '../data/local_database.dart';

class OfflineRecoveryScreen extends StatefulWidget {
  const OfflineRecoveryScreen({required this.companyId, super.key});
  final String companyId;
  @override
  State<OfflineRecoveryScreen> createState() => _OfflineRecoveryScreenState();
}

class _OfflineRecoveryScreenState extends State<OfflineRecoveryScreen> {
  final username = TextEditingController();
  final code = TextEditingController();
  final password = TextEditingController();
  RecoveryChallenge? challenge;
  String? error;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Local Offline Recovery')),
    body: Stack(
      children: [
        const Positioned.fill(child: AnimatedLoginBackground(busy: false)),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: .94),
              child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Recovery codes are shown only on this computer, expire after five minutes, are single-use, and have an attempt limit.',
                ),
                const SizedBox(height: 18),
                AppTextField(
                  label: 'Local admin username',
                  controller: username,
                ),
                const SizedBox(height: 18),
                FilledButton(
                  key: const Key('confirm-offline-recovery'),
                  onPressed: _create,
                  child: const Text('I confirm local account recovery'),
                ),
                if (challenge != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    challenge!.code,
                    key: const Key('recovery-code'),
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  Text('Expires ${challenge!.expiresAt.toLocal()}'),
                  const Text(
                    'Enter this one-time code below to choose the new administrator password.',
                  ),
                  const SizedBox(height: 16),
                  AppTextField(label: 'One-time code', controller: code),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'New password (12+ characters)',
                    controller: password,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.lock_reset),
                    label: const Text('Change administrator password'),
                  ),
                ],
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
              ],
            ),
          ),
        ),
      ),
    ),
  ],
  ),
  );
  Future<void> _create() async {
    final database = LocalDatabase(widget.companyId);
    try {
      final value = await OfflineRecoveryService(
        database,
      ).create(username.text, confirmed: true);
      if (mounted) {
        setState(() {
          challenge = value;
          error = null;
        });
      }
    } catch (exception) {
      if (mounted) setState(() => error = exception.toString());
    } finally {
      await database.close();
    }
  }

  Future<void> _reset() async {
    final currentChallenge = challenge;
    if (currentChallenge == null) return;
    final database = LocalDatabase(widget.companyId);
    try {
      final changed = await OfflineRecoveryService(database).resetPassword(
        challengeId: currentChallenge.id,
        code: code.text,
        newPassword: password.text,
      );
      if (!changed) throw StateError('The code is invalid or has expired.');
      if (mounted) Navigator.pop(context);
    } catch (exception) {
      if (mounted) setState(() => error = exception.toString());
    } finally {
      await database.close();
    }
  }
}
