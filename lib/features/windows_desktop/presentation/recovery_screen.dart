import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/widgets/animated_login_background.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../application/offline_recovery_service.dart';
import '../data/local_database.dart';

/// Fully local Windows password recovery screen.
///
/// Flow:
///   1. Shown with the pre-filled username from the login screen.
///   2. A recovery code is generated immediately and shown on-screen.
///   3. The user enters that code + a new password to reset.
///   4. On success, Navigator.pop() takes them back to sign in.
class OfflineRecoveryScreen extends StatefulWidget {
  const OfflineRecoveryScreen({
    required this.companyId,
    this.prefillUsername = '',
    super.key,
  });
  final String companyId;
  final String prefillUsername;

  @override
  State<OfflineRecoveryScreen> createState() => _OfflineRecoveryScreenState();
}

class _OfflineRecoveryScreenState extends State<OfflineRecoveryScreen> {
  late final TextEditingController username =
      TextEditingController(text: widget.prefillUsername);
  final code = TextEditingController();
  final password = TextEditingController();
  bool passwordVisible = false;

  RecoveryChallenge? challenge;
  bool generatingCode = false;
  bool resetting = false;
  String? error;

  @override
  void initState() {
    super.initState();
    // Auto-generate a code if a username was passed in.
    if (widget.prefillUsername.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _generateCode());
    }
  }

  @override
  void dispose() {
    username.dispose();
    code.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedLoginBackground(busy: false)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  color: scheme.surface.withValues(alpha: .95),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Header ──────────────────────────────────────────
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF7C4DFF), Color(0xFF00BCD4)],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.lock_reset_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Local Account Recovery',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    'No internet required · Fully offline',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: scheme.primary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ── Username field ───────────────────────────────────
                        AppTextField(
                          label: 'Username',
                          icon: Icons.person_outline,
                          controller: username,
                          readOnly: challenge != null,
                        ),
                        const SizedBox(height: 16),

                        // ── Generate code button (only shown before code generated) ─
                        if (challenge == null)
                          FilledButton.icon(
                            key: const Key('confirm-offline-recovery'),
                            onPressed: generatingCode ? null : _generateCode,
                            icon: generatingCode
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.generating_tokens),
                            label: Text(
                              generatingCode
                                  ? 'Generating…'
                                  : 'Generate one-time recovery code',
                            ),
                          ),

                        // ── On-screen code display ──────────────────────────
                        if (challenge != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D1B2A),
                              borderRadius: BorderRadius.circular(14),
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
                                      'Your one-time recovery code',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: const Color(0xFF7C4DFF),
                                          ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.copy, size: 18),
                                      tooltip: 'Copy code',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        Clipboard.setData(
                                          ClipboardData(text: challenge!.code),
                                        );
                                        // Also auto-fill the code field
                                        code.text = challenge!.code;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Code copied and filled in below',
                                            ),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SelectableText(
                                  challenge!.code,
                                  key: const Key('recovery-code'),
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 6,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.timer_outlined,
                                      size: 14,
                                      color: Colors.white38,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Single-use · expires '
                                      '${challenge!.expiresAt.toLocal().toString().substring(11, 16)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.white38),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── Code entry (pre-filled) ─────────────────────
                          AppTextField(
                            label: 'Enter the code above',
                            icon: Icons.pin,
                            controller: code,
                          ),
                          const SizedBox(height: 14),

                          // ── New password ────────────────────────────────
                          AppTextField(
                            label: 'New password (12+ characters)',
                            icon: Icons.password,
                            controller: password,
                            obscureText: !passwordVisible,
                            suffix: IconButton(
                              icon: Icon(
                                passwordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => passwordVisible = !passwordVisible),
                            ),
                          ),
                          const SizedBox(height: 20),

                          FilledButton.icon(
                            onPressed: resetting ? null : _reset,
                            icon: resetting
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.lock_reset),
                            label: Text(
                              resetting ? 'Resetting…' : 'Change password',
                            ),
                          ),
                        ],

                        // ── Error ────────────────────────────────────────────
                        if (error != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: scheme.errorContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 18,
                                  color: scheme.onErrorContainer,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    error!,
                                    style: TextStyle(
                                      color: scheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: const Text('Back to sign in'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateCode() async {
    setState(() {
      generatingCode = true;
      error = null;
    });
    final database = LocalDatabase(widget.companyId);
    try {
      final value = await OfflineRecoveryService(
        database,
      ).create(username.text.trim(), confirmed: true);
      if (mounted) {
        setState(() {
          challenge = value;
          // Auto-fill the code field so user can skip copy-paste.
          code.text = value.code;
        });
      }
    } catch (exception) {
      if (mounted) setState(() => error = exception.toString());
    } finally {
      await database.close();
      if (mounted) setState(() => generatingCode = false);
    }
  }

  Future<void> _reset() async {
    final currentChallenge = challenge;
    if (currentChallenge == null) return;
    if (code.text.trim().isEmpty || password.text.length < 12) {
      setState(() => error = 'Enter the code and a password of at least 12 characters.');
      return;
    }
    setState(() {
      resetting = true;
      error = null;
    });
    final database = LocalDatabase(widget.companyId);
    try {
      final changed = await OfflineRecoveryService(database).resetPassword(
        challengeId: currentChallenge.id,
        code: code.text.trim(),
        newPassword: password.text,
      );
      if (!changed) throw StateError('The code is invalid or has expired.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed. You can now sign in.'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (exception) {
      if (mounted) setState(() => error = exception.toString());
    } finally {
      await database.close();
      if (mounted) setState(() => resetting = false);
    }
  }
}
