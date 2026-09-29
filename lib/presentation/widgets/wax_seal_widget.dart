import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/vellum_theme.dart';

/// Physical 3D-embossed Wax Seal Stamp with monogram and wax edge irregularity.
class WaxSealWidget extends StatelessWidget {
  final double size;
  final String monogram;
  final Color color;
  final VoidCallback? onTap;
  final bool isStamped;

  const WaxSealWidget({
    super.key,
    this.size = 72,
    this.monogram = 'V',
    this.color = VellumTheme.waxCrimson,
    this.onTap,
    this.isStamped = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isStamped ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(2, 5),
              ),
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 14,
                spreadRadius: 2,
              ),
            ],
            gradient: RadialGradient(
              center: const Alignment(-0.25, -0.25),
              radius: 0.9,
              colors: [
                color.withRed(min(255, color.red + 50)),
                color,
                color.withRed(max(0, color.red - 45)),
              ],
            ),
          ),
          child: Center(
            child: Container(
              width: size * 0.76,
              height: size * 0.76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black.withOpacity(0.2),
                  width: 2.0,
                ),
              ),
              child: Center(
                child: Text(
                  monogram,
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: size * 0.42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.92),
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.6),
                        offset: const Offset(1, 2),
                        blurRadius: 2,
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
}
