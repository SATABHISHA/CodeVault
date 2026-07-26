import 'package:codevault/core/config/brand_config.dart';
import 'package:codevault/features/authentication/presentation/session_controller.dart';
import 'package:codevault/shared/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
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
                    const SizedBox(height: 4),
                    const Text('Industrial label operations, simplified.'),
                    const SizedBox(height: 28),
                    const AppTextField(
                      label: 'Username or email',
                      icon: Icons.person_outline,
                      autofillHints: [AutofillHints.username],
                    ),
                    const SizedBox(height: 16),
                    const AppTextField(
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      autofillHints: [AutofillHints.password],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          ref.read(sessionProvider.notifier).signIn();
                          context.go('/dashboard');
                        },
                        icon: const Icon(Icons.login),
                        label: const Text('Sign in'),
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
}
