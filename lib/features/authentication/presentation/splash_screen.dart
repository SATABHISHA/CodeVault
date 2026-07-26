import 'package:codevault/core/config/brand_config.dart';
import 'package:codevault/core/platform/platform_capabilities.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 450), () {
      if (mounted) {
        context.go(
          PlatformCapabilities.current().isWindows ? '/windows' : '/login',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 400),
        tween: Tween(begin: .92, end: 1),
        builder: (_, value, child) =>
            Transform.scale(scale: value, child: child),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_2_rounded, size: 72),
            SizedBox(height: 16),
            Text(
              BrandConfig.productName,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text(BrandConfig.poweredBy),
          ],
        ),
      ),
    ),
  );
}
