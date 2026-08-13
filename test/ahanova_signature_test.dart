import 'package:codevault/core/config/brand_config.dart';
import 'package:codevault/shared/widgets/ahanova_signature.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('company signature shows company website and support email', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AhanovaSignature())),
    );

    expect(find.text('Powered by'), findsOneWidget);
    expect(find.text(BrandConfig.companyName), findsOneWidget);
    expect(find.text('ahanova.in'), findsOneWidget);
    expect(find.text(BrandConfig.supportEmail), findsOneWidget);
  });
}
