import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/brand_config.dart';

/// Animated, reusable company signature for authentication and app chrome.
class AhanovaSignature extends StatefulWidget {
  const AhanovaSignature({this.compact = false, super.key});

  final bool compact;

  @override
  State<AhanovaSignature> createState() => _AhanovaSignatureState();
}

class _AhanovaSignatureState extends State<AhanovaSignature>
    with SingleTickerProviderStateMixin {
  late final AnimationController animation = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  Future<void> _open(String value) async {
    final uri = Uri.parse(value);
    if (!await launchUrl(uri, mode: LaunchMode.platformDefault) && mounted) {
      ScaffoldMessenger.maybeOf(
        context,
      )?.showSnackBar(SnackBar(content: Text('Could not open $value')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final companyStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      fontSize: widget.compact ? 11 : 13,
      fontWeight: FontWeight.w900,
      letterSpacing: .25,
    );
    return Semantics(
      label:
          '${BrandConfig.poweredBy}. Website ${BrandConfig.website}. Email ${BrandConfig.supportEmail}',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.compact ? 8 : 14,
          vertical: widget.compact ? 8 : 11,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: .34),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.primary.withValues(alpha: .20)),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: .10),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Powered by',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) => ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment(-1.8 + animation.value * 3.6, -1),
                  end: Alignment(-.8 + animation.value * 3.6, 1),
                  colors: const [
                    Color(0xFF7C3AED),
                    Color(0xFF22D3EE),
                    Color(0xFFF472B6),
                    Color(0xFF7C3AED),
                  ],
                ).createShader(bounds),
                child: child,
              ),
              child: Text(
                BrandConfig.companyName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: companyStyle,
              ),
            ),
            SizedBox(height: widget.compact ? 5 : 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: widget.compact ? 2 : 6,
              runSpacing: 2,
              children: [
                _contact(
                  icon: Icons.language_rounded,
                  label: 'ahanova.in',
                  tooltip: BrandConfig.website,
                  onTap: () => _open(BrandConfig.website),
                ),
                _contact(
                  icon: Icons.mail_outline_rounded,
                  label: BrandConfig.supportEmail,
                  tooltip: 'Email ${BrandConfig.supportEmail}',
                  onTap: () => _open('mailto:${BrandConfig.supportEmail}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _contact({
    required IconData icon,
    required String label,
    required String tooltip,
    required VoidCallback onTap,
  }) => Tooltip(
    message: tooltip,
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: widget.compact ? 11 : 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: widget.compact ? 8.5 : 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
