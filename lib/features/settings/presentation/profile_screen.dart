import 'package:codevault/app.dart';
import 'package:codevault/features/authentication/data/remote_auth_service.dart';
import 'package:codevault/features/authentication/presentation/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final current = TextEditingController();
  final password = TextEditingController();
  final confirmation = TextEditingController();
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final appearance = ref.watch(appearanceProvider);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                appearance.skin.color,
                Theme.of(context).colorScheme.tertiary,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My profile & settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      session.tenantId == null
                          ? 'Platform administration account'
                          : 'Tenant production account',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: appearance.skin.color,
                ),
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [_appearanceCard(appearance), _passwordCard()];
            return constraints.maxWidth >= 850
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 16),
                      Expanded(child: cards[1]),
                    ],
                  )
                : Column(
                    children: [cards[0], const SizedBox(height: 16), cards[1]],
                  );
          },
        ),
      ],
    );
  }

  Widget _appearanceCard(AppearanceState appearance) => Card(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application appearance',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          const Text(
            'Your skin and brightness preference is saved on this device.',
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final skin in AppSkin.values)
                Tooltip(
                  message: skin.label,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () =>
                        ref.read(appearanceProvider.notifier).setSkin(skin),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: skin.color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: appearance.skin == skin
                              ? Colors.white
                              : Colors.transparent,
                          width: 4,
                        ),
                        boxShadow: appearance.skin == skin
                            ? [
                                BoxShadow(
                                  color: skin.color.withValues(alpha: .5),
                                  blurRadius: 12,
                                ),
                              ]
                            : null,
                      ),
                      child: appearance.skin == skin
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode),
                label: Text('Light'),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode),
                label: Text('Dark'),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.devices),
                label: Text('System'),
              ),
            ],
            selected: {appearance.mode},
            onSelectionChanged: (value) =>
                ref.read(appearanceProvider.notifier).setThemeMode(value.first),
          ),
        ],
      ),
    ),
  );

  Widget _passwordCard() => Card(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Security',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          const Text('Change your password whenever you choose.'),
          const SizedBox(height: 18),
          TextField(
            controller: current,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Current password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: password,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'New password',
              prefixIcon: Icon(Icons.password),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: confirmation,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirm password',
              prefixIcon: Icon(Icons.verified_user_outlined),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: busy ? null : _changePassword,
            icon: const Icon(Icons.security),
            label: Text(busy ? 'Updating…' : 'Update password'),
          ),
        ],
      ),
    ),
  );

  Future<void> _changePassword() async {
    if (password.text.length < 12 || password.text != confirmation.text) {
      _show('Passwords must match and contain at least 12 characters.');
      return;
    }
    setState(() => busy = true);
    try {
      await RemoteAuthService().changePassword(
        currentPassword: current.text,
        newPassword: password.text,
      );
      current.clear();
      password.clear();
      confirmation.clear();
      _show('Password updated successfully.');
    } catch (_) {
      _show('Password update failed. Check your current password.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _logout() async {
    try {
      await RemoteAuthService().logout();
    } catch (_) {
      /* local token is still cleared */
    }
    ref.read(sessionProvider.notifier).signOut();
    if (mounted) context.go('/login');
  }

  void _show(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
