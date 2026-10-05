import 'package:flutter/material.dart';
import '../../core/theme/vellum_theme.dart';

/// Finish of a mastery seal.
enum SealFinish {
  paper,
  ink;

  /// Maps the persisted `waxSealColor` of a folio entry onto a finish:
  /// higher mastery ('antique_gold') is pressed in solid ink.
  static SealFinish fromStored(String waxSealColor) =>
      waxSealColor == 'antique_gold' ? SealFinish.ink : SealFinish.paper;
}

/// Round seal with a soft shadow, a fine inner ring and a typed monogram.
class SealWidget extends StatelessWidget {
  final double size;
  final String monogram;
  final SealFinish finish;
  final VoidCallback? onTap;
  final bool isStamped;

  const SealWidget({
    super.key,
    this.size = 72,
    this.monogram = 'V',
    this.finish = SealFinish.paper,
    this.onTap,
    this.isStamped = true,
  });

  @override
  Widget build(BuildContext context) {
    final isInk = finish == SealFinish.ink;

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
            color: isInk ? VellumTheme.ink : VellumTheme.paperSurface,
            boxShadow: isInk ? VellumTheme.softShadowInk : VellumTheme.softShadow,
          ),
          child: Center(
            child: Container(
              width: size * 0.78,
              height: size * 0.78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isInk ? const Color(0x40F8F3EA) : VellumTheme.hairline,
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: size * 0.56,
                  height: size * 0.56,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      monogram,
                      style: TextStyle(
                        fontFamily: VellumTheme.typewriterFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: size * 0.4,
                        color: isInk ? VellumTheme.paperHighlight : VellumTheme.ink,
                        shadows: isInk ? null : VellumTheme.inkBleed,
                      ),
                    ),
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
