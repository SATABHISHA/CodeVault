import 'package:codevault/core/router/app_router.dart';
import 'package:codevault/core/theme/app_theme.dart';
import 'package:codevault/core/security/token_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppSkin {
  violet('Violet Pulse', Color(0xFF6047F5)),
  ocean('Ocean Blue', Color(0xFF0077B6)),
  emerald('Emerald', Color(0xFF00875A)),
  sunset('Sunset Coral', Color(0xFFE85D75)),
  amber('Amber Gold', Color(0xFFB86E00));

  const AppSkin(this.label, this.color);
  final String label;
  final Color color;
}

class AppearanceState {
  const AppearanceState({
    this.mode = ThemeMode.system,
    this.skin = AppSkin.violet,
  });
  final ThemeMode mode;
  final AppSkin skin;
}

class AppearanceController extends Notifier<AppearanceState> {
  static const _store = SecureTokenStore();
  @override
  AppearanceState build() {
    Future.microtask(_restore);
    return const AppearanceState();
  }

  Future<void> _restore() async {
    final skin = await _store.readKey('appearance.skin');
    final mode = await _store.readKey('appearance.mode');
    state = AppearanceState(
      skin:
          AppSkin.values.where((value) => value.name == skin).firstOrNull ??
          state.skin,
      mode:
          ThemeMode.values.where((value) => value.name == mode).firstOrNull ??
          state.mode,
    );
  }

  Future<void> setSkin(AppSkin skin) async {
    state = AppearanceState(mode: state.mode, skin: skin);
    await _store.writeKey('appearance.skin', skin.name);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = AppearanceState(mode: mode, skin: state.skin);
    await _store.writeKey('appearance.mode', mode.name);
  }
}

final appearanceProvider =
    NotifierProvider<AppearanceController, AppearanceState>(
      AppearanceController.new,
    );

class CodeVaultApp extends ConsumerWidget {
  const CodeVaultApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(appearanceProvider);
    return MaterialApp.router(
      title: 'CodeVault',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themed(Brightness.light, appearance.skin.color),
      darkTheme: AppTheme.themed(Brightness.dark, appearance.skin.color),
      themeMode: appearance.mode,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
