import 'package:flutter/material.dart';
import '../../core/theme/vellum_theme.dart';

/// Renders authentic deckle-edged parchment paper texture with subtle vintage vignette.
class ParchmentBackground extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const ParchmentBackground({
    super.key,
    required this.child,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isDark ? VellumTheme.darkWood : VellumTheme.parchmentLight;
    final surfaceColor = isDark ? VellumTheme.darkSurface : VellumTheme.parchmentSurface;

    return Container(
      decoration: BoxDecoration(
        color: baseColor,
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.25,
          colors: [
            baseColor,
            surfaceColor.withOpacity(0.9),
            isDark ? const Color(0xFF0D0C0B) : const Color(0xFFEFE7D8),
          ],
          stops: const [0.3, 0.75, 1.0],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}
