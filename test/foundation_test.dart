import 'package:codevault/core/config/api_environment.dart';
import 'package:codevault/core/config/brand_config.dart';
import 'package:codevault/core/layout/breakpoints.dart';
import 'package:codevault/core/platform/platform_capabilities.dart';
import 'package:codevault/core/theme/app_theme.dart';
import 'package:codevault/features/backup/presentation/backup_screen.dart';
import 'package:codevault/features/dashboard/presentation/app_shell.dart';
import 'package:codevault/shared/widgets/permission_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('central branding values are authoritative', () {
    expect(BrandConfig.productName, 'CodeVault');
    expect(BrandConfig.companyName, 'Ahanova AI Technologies Pvt. Ltd.');
    expect(BrandConfig.supportEmail, 'wecare@ahanova.in');
    expect(BrandConfig.website, 'https://ahanova.in');
  });
  test('environment defaults and release safeguards are platform aware', () {
    expect(
      ApiEnvironment.resolve(
        isWebOverride: true,
        platformOverride: TargetPlatform.windows,
        releaseOverride: false,
      ),
      'http://127.0.0.1:8000/api/v1',
    );
    expect(
      ApiEnvironment.resolve(
        isWebOverride: false,
        platformOverride: TargetPlatform.android,
        releaseOverride: false,
      ),
      'http://10.0.2.2:8000/api/v1',
    );
    expect(
      ApiEnvironment.resolve(
        isWebOverride: false,
        platformOverride: TargetPlatform.windows,
        releaseOverride: true,
      ),
      '',
    );
    expect(
      () => ApiEnvironment.resolve(
        isWebOverride: true,
        platformOverride: TargetPlatform.windows,
        releaseOverride: true,
      ),
      throwsStateError,
    );
  });
  test('responsive breakpoints classify layouts', () {
    expect(layoutSizeFor(400), LayoutSize.compact);
    expect(layoutSizeFor(800), LayoutSize.medium);
    expect(layoutSizeFor(1200), LayoutSize.expanded);
  });
  test('themes expose accessible light and dark color schemes', () {
    expect(AppTheme.light.brightness, Brightness.light);
    expect(AppTheme.dark.brightness, Brightness.dark);
    expect(AppTheme.light.useMaterial3, isTrue);
  });
  testWidgets('permission gate controls visibility', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PermissionGate(
          permission: 'parts.write',
          permissions: {'parts.read'},
          child: Text('Edit'),
        ),
      ),
    );
    expect(find.text('Edit'), findsNothing);
    await tester.pumpWidget(
      const MaterialApp(
        home: PermissionGate(
          permission: 'parts.write',
          permissions: {'parts.write'},
          child: Text('Edit'),
        ),
      ),
    );
    expect(find.text('Edit'), findsOneWidget);
  });
  testWidgets('Windows hides managed request controls', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BackupScreen(
          capabilities: PlatformCapabilities(AppPlatform.windows),
        ),
      ),
    );
    expect(find.byKey(const Key('request-backup')), findsNothing);
    expect(find.text('Create local backup'), findsOneWidget);
  });
  testWidgets('Android and Web show managed request controls', (tester) async {
    for (final platform in [AppPlatform.android, AppPlatform.web]) {
      await tester.pumpWidget(
        MaterialApp(
          home: BackupScreen(capabilities: PlatformCapabilities(platform)),
        ),
      );
      expect(find.byKey(const Key('request-backup')), findsOneWidget);
      expect(find.byKey(const Key('request-restore')), findsOneWidget);
    }
  });
  testWidgets('navigation adapts between compact and desktop layouts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      const MaterialApp(
        home: AppShell(locationOverride: '/dashboard', child: Text('Body')),
      ),
    );
    expect(find.byType(NavigationBar), findsOneWidget);
    tester.view.physicalSize = const Size(1200, 800);
    await tester.pumpWidget(
      const MaterialApp(
        home: AppShell(locationOverride: '/dashboard', child: Text('Body')),
      ),
    );
    expect(find.byType(NavigationRail), findsOneWidget);
    addTearDown(tester.view.resetPhysicalSize);
  });
}
