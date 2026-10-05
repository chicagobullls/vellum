import 'package:flutter/material.dart';
import '../../core/theme/vellum_theme.dart';

/// Fill of a soft surface.
enum SurfaceTone {
  /// Warm near-white card lifted off the sheet.
  paper,

  /// Solid ribbon ink for primary actions and emphasis.
  ink,
}

/// Minimal surface: a flat fill with a soft, warm shadow. With [elevated] off it lies flat on the
/// sheet, outlined by a hairline instead of a shadow. A null [radius] makes a capsule.
class SoftSurface extends StatelessWidget {
  final Widget child;
  final SurfaceTone tone;
  final double? radius;
  final EdgeInsetsGeometry padding;
  final bool elevated;
  final VoidCallback? onTap;

  const SoftSurface({
    super.key,
    required this.child,
    this.tone = SurfaceTone.paper,
    this.radius = 18,
    this.padding = const EdgeInsets.all(14),
    this.elevated = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isInk = tone == SurfaceTone.ink;
    final side = elevated ? BorderSide.none : const BorderSide(color: VellumTheme.hairline);
    final ShapeBorder shape = radius == null
        ? StadiumBorder(side: side)
        : RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius!), side: side);

    final surface = DecoratedBox(
      decoration: ShapeDecoration(
        color: isInk
            ? VellumTheme.ink
            : elevated
                ? VellumTheme.paperSurface
                : const Color(0x8CFCFAF6),
        shape: shape,
        shadows: elevated ? (isInk ? VellumTheme.softShadowInk : VellumTheme.softShadow) : null,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return surface;
    return _SoftPressable(onTap: onTap!, child: surface);
  }
}

/// Quiet press feedback: the surface settles slightly while held.
class _SoftPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _SoftPressable({required this.child, required this.onTap});

  @override
  State<_SoftPressable> createState() => _SoftPressableState();
}

class _SoftPressableState extends State<_SoftPressable> {
  bool _isDown = false;

  void _setDown(bool value) {
    if (_isDown != value) setState(() => _isDown = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setDown(true),
      onTapUp: (_) => _setDown(false),
      onTapCancel: () => _setDown(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isDown ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Typewriter-labelled capsule button.
class SoftButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final SurfaceTone tone;

  const SoftButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.tone = SurfaceTone.ink,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = tone == SurfaceTone.ink ? VellumTheme.paperHighlight : VellumTheme.ink;
    final isEnabled = onPressed != null && !isLoading;

    return Opacity(
      opacity: onPressed == null && !isLoading ? 0.5 : 1.0,
      child: SoftSurface(
        tone: tone,
        radius: null,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        onTap: isEnabled ? onPressed : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(color: foreground, strokeWidth: 2),
              )
            else if (icon != null)
              Icon(icon, size: 18, color: foreground),
            if (isLoading || icon != null) const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: VellumTheme.typewriterFamily,
                  fontSize: 12,
                  letterSpacing: 1.6,
                  color: foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Round button holding a single icon.
class SoftIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final double iconSize;

  const SoftIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final button = SoftSurface(
      radius: null,
      padding: const EdgeInsets.all(10),
      onTap: onPressed,
      child: Icon(icon, size: iconSize, color: VellumTheme.ink),
    );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}

/// Capsule grouping several compact toolbar buttons.
class SoftToolbar extends StatelessWidget {
  final List<Widget> children;

  const SoftToolbar({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return SoftSurface(
      radius: null,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: IconButtonTheme(
        data: IconButtonThemeData(
          style: IconButton.styleFrom(
            visualDensity: VisualDensity.compact,
            foregroundColor: VellumTheme.ink,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

/// Segmented control: a paper thumb with a soft shadow glides along a recessed track.
class SoftSegmentedControl extends StatelessWidget {
  final int count;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget Function(BuildContext context, int index, bool isSelected) itemBuilder;
  final double height;

  const SoftSegmentedControl({
    super.key,
    required this.count,
    required this.selectedIndex,
    required this.onSelected,
    required this.itemBuilder,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: const Color(0x12231F1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(height / 2 + 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: SizedBox(
          height: height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final segmentWidth = constraints.maxWidth / count;
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    left: segmentWidth * selectedIndex,
                    top: 0,
                    bottom: 0,
                    width: segmentWidth,
                    child: const DecoratedBox(
                      decoration: ShapeDecoration(
                        color: VellumTheme.paperSurface,
                        shape: StadiumBorder(),
                        shadows: VellumTheme.softShadow,
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(
                      count,
                      (i) => Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onSelected(i),
                          child: Center(child: itemBuilder(context, i, i == selectedIndex)),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Thin ribbon-ink progress line.
class InkProgressBar extends StatelessWidget {
  final double value;

  const InkProgressBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(1.5),
        child: ColoredBox(
          color: const Color(0x1F231F1A),
          child: AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            heightFactor: 1.0,
            child: const ColoredBox(color: VellumTheme.ink),
          ),
        ),
      ),
    );
  }
}

/// Modal dialog on a paper card with a soft shadow.
class SoftDialog extends StatelessWidget {
  final Widget child;

  const SoftDialog({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SoftSurface(radius: 24, padding: EdgeInsets.zero, child: child),
    );
  }
}

/// Shows a dialog over a light ink veil.
Future<T?> showSoftDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: const Color(0x33231F1A),
    builder: builder,
  );
}
