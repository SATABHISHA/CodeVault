import 'package:flutter/material.dart';

class FeatureWidget extends StatelessWidget {
  const FeatureWidget({required this.icon, required this.label, super.key});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: Colors.white, size: 18),
      const SizedBox(width: 6),
      Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class AnimatedLoginBackground extends StatefulWidget {
  const AnimatedLoginBackground({required this.busy, super.key});
  final bool busy;

  @override
  State<AnimatedLoginBackground> createState() =>
      _AnimatedLoginBackgroundState();
}

class _AnimatedLoginBackgroundState extends State<AnimatedLoginBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat(reverse: true);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1 + controller.value * .5, -1),
          end: Alignment(1, 1 - controller.value * .35),
          colors: const [
            Color(0xFF0D0824),
            Color(0xFF102849),
            Color(0xFF071D24),
            Color(0xFF231044),
          ],
          stops: const [0, .35, .68, 1],
        ),
      ),
    ),
  );
}
