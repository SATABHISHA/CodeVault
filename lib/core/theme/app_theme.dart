import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _seed = Color(0xFF6D5DFB);

  static ThemeData get light => themed(Brightness.light, _seed);
  static ThemeData get dark => themed(Brightness.dark, _seed);

  static ThemeData themed(Brightness brightness, Color seed) {
    final generated = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    final scheme = generated.copyWith(
      primary: brightness == Brightness.dark
          ? Color.lerp(seed, Colors.white, .35)!
          : seed,
      secondary: brightness == Brightness.dark
          ? const Color(0xFF48D8EC)
          : const Color(0xFF008FA8),
      tertiary: const Color(0xFFFF5C8A),
      surface: brightness == Brightness.dark
          ? const Color(0xFF171A27)
          : Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFF5F5FC)
          : const Color(0xFF0B0D17),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface.withValues(alpha: .96),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .55)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: .55),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: .5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: brightness == Brightness.dark
            ? const Color(0xFF11131E)
            : Colors.white,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.primary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface.withValues(alpha: .92),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      focusColor: scheme.primary.withValues(alpha: .16),
      visualDensity: VisualDensity.standard,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
