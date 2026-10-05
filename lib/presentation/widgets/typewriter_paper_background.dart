import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/vellum_theme.dart';

/// Procedural sheet of worn typewriter paper: light beige tone, uneven ageing, grimy corners,
/// wrinkles, tide-line stains, scuffs, foxing, fibres and tooth grain.
/// [isDark] switches to carbon copy paper. With [safeArea] it acts as a full-screen background
/// sized to the screen (so the sheet stays put when the keyboard opens); without it, as a card surface.
class TypewriterPaperBackground extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final bool safeArea;

  const TypewriterPaperBackground({
    super.key,
    required this.child,
    this.isDark = false,
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final sheet = Positioned.fill(
      child: safeArea
          ? _PaperSheet(isDark: isDark, sheetSize: MediaQuery.sizeOf(context))
          : LayoutBuilder(
              builder: (context, constraints) => _PaperSheet(isDark: isDark, sheetSize: constraints.biggest),
            ),
    );

    final surface = Stack(
      fit: StackFit.passthrough,
      children: [
        sheet,
        safeArea ? SafeArea(child: child) : child,
      ],
    );

    if (!safeArea) return surface;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: surface,
    );
  }
}

/// Draws the pre-rendered sheet anchored at the top-left corner.
class _PaperSheet extends StatelessWidget {
  final bool isDark;
  final Size sheetSize;

  const _PaperSheet({required this.isDark, required this.sheetSize});

  @override
  Widget build(BuildContext context) {
    if (sheetSize.isEmpty || !sheetSize.isFinite) return const SizedBox.expand();
    // The texture is soft: 2x is indistinguishable from 3x and saves half the memory.
    final scale = min(MediaQuery.devicePixelRatioOf(context), 2.0);
    return RepaintBoundary(
      child: CustomPaint(
        painter: _SheetImagePainter(
          image: _obtainSheet(sheetSize, scale, isDark),
          sheetSize: sheetSize,
        ),
      ),
    );
  }
}

class _SheetImagePainter extends CustomPainter {
  final ui.Image image;
  final Size sheetSize;

  const _SheetImagePainter({required this.image, required this.sheetSize});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Offset.zero & sheetSize,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(covariant _SheetImagePainter oldDelegate) =>
      !identical(oldDelegate.image, image) || oldDelegate.sheetSize != sheetSize;
}

/// Rendered sheets keyed by size and finish. Impeller replays vector pictures every frame, so the
/// thousands of strokes are rasterised once and every later frame draws a single texture.
/// Evicted images are left to the GC: a painter may still be holding one.
final LinkedHashMap<String, ui.Image> _sheetCache = LinkedHashMap<String, ui.Image>();
const int _sheetCacheCapacity = 6;

ui.Image _obtainSheet(Size size, double scale, bool isDark) {
  final key = '${size.width.round()}x${size.height.round()}@${scale.toStringAsFixed(2)}${isDark ? 'd' : 'l'}';
  final cached = _sheetCache.remove(key);
  if (cached != null) return _sheetCache[key] = cached;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(scale);
  _paintSheet(canvas, size, isDark);
  final picture = recorder.endRecording();
  final image = picture.toImageSync((size.width * scale).ceil(), (size.height * scale).ceil());
  picture.dispose();

  _sheetCache[key] = image;
  if (_sheetCache.length > _sheetCacheCapacity) _sheetCache.remove(_sheetCache.keys.first);
  return image;
}

const Color _agedBrown = Color(0xFF8A6A3E);
const Color _rust = Color(0xFF8B5A2B);

void _paintSheet(Canvas canvas, Size size, bool isDark) {
  // Fixed seed keeps the sheet identical between launches.
  final rnd = Random(1873);
  final grime = isDark ? Colors.black : _agedBrown;

  _paintTone(canvas, size, isDark);
  _paintUnevenAgeing(canvas, size, rnd, isDark, grime);
  _paintGrimyCorners(canvas, size, rnd, isDark, grime);
  _paintWrinkles(canvas, size, rnd, isDark, grime);
  if (!isDark) _paintStains(canvas, size, rnd);
  _paintFibres(canvas, size, rnd, isDark);
  _paintScuffs(canvas, size, rnd, isDark);
  if (!isDark) _paintFoxing(canvas, size, rnd);
  _paintGrain(canvas, size, rnd, isDark);
  _paintAgedEdges(canvas, size, isDark);
}

/// Base tone, a touch brighter toward the upper-left as if lit across the sheet.
void _paintTone(Canvas canvas, Size size, bool isDark) {
  final rect = Offset.zero & size;
  canvas.drawRect(
    rect,
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.45),
        radius: 1.35,
        colors: isDark
            ? const [VellumTheme.carbonHighlight, VellumTheme.carbonBase, VellumTheme.carbonDeep]
            : const [VellumTheme.paperHighlight, VellumTheme.paperBase, VellumTheme.paperShade],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect),
  );
}

void _paintSoftSpot(Canvas canvas, Offset center, double radius, Color color) {
  canvas.drawCircle(
    center,
    radius,
    Paint()
      ..shader = RadialGradient(colors: [color, color.withAlpha(0)])
          .createShader(Rect.fromCircle(center: center, radius: radius)),
  );
}

/// Clouds of lighter and darker tone: paper never ages evenly.
void _paintUnevenAgeing(Canvas canvas, Size size, Random rnd, bool isDark, Color grime) {
  for (var i = 0; i < 28; i++) {
    final center = Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height);
    final radius = size.shortestSide * (0.12 + rnd.nextDouble() * 0.45);
    final isLighter = rnd.nextDouble() < 0.45;
    final color = isLighter
        ? Colors.white.withAlpha(isDark ? 4 + rnd.nextInt(5) : 14 + rnd.nextInt(16))
        : grime.withAlpha(isDark ? 10 + rnd.nextInt(10) : 6 + rnd.nextInt(10));
    _paintSoftSpot(canvas, center, radius, color);
  }
}

/// Corners darkened by the hands that held the sheet.
void _paintGrimyCorners(Canvas canvas, Size size, Random rnd, bool isDark, Color grime) {
  final corners = [Offset.zero, Offset(size.width, 0), Offset(0, size.height), Offset(size.width, size.height)];
  for (final corner in corners) {
    final jitter = Offset((rnd.nextDouble() - 0.5), (rnd.nextDouble() - 0.5)) * size.shortestSide * 0.16;
    final radius = size.shortestSide * (0.45 + rnd.nextDouble() * 0.25);
    _paintSoftSpot(canvas, corner + jitter, radius, grime.withAlpha(isDark ? 40 : 22 + rnd.nextInt(12)));
  }
}

/// Thin creases wandering across parts of the sheet, each a dark valley with a light edge.
void _paintWrinkles(Canvas canvas, Size size, Random rnd, bool isDark, Color grime) {
  final valley = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final ridge = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  for (var i = 0; i < 9; i++) {
    var point = Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height);
    var angle = rnd.nextDouble() * pi * 2;
    final crease = Path()..moveTo(point.dx, point.dy);
    final segments = 5 + rnd.nextInt(5);
    for (var s = 0; s < segments; s++) {
      angle += (rnd.nextDouble() - 0.5) * 0.5;
      point += Offset(cos(angle), sin(angle)) * (12 + rnd.nextDouble() * 28);
      crease.lineTo(point.dx, point.dy);
    }

    valley
      ..strokeWidth = 0.6
      ..color = grime.withAlpha(isDark ? 40 : 20);
    ridge
      ..strokeWidth = 0.8
      ..color = Colors.white.withAlpha(isDark ? 10 : 55);
    canvas.drawPath(crease.shift(const Offset(0.6, 0.6)), ridge);
    canvas.drawPath(crease, valley);
  }
}

/// Paper fibres: short, gently curved strands.
void _paintFibres(Canvas canvas, Size size, Random rnd, bool isDark) {
  final fibre = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final fibres = (size.width * size.height / 900).round();
  for (var i = 0; i < fibres; i++) {
    final start = Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height);
    final angle = rnd.nextDouble() * pi;
    final length = 4 + rnd.nextDouble() * 16;
    final direction = Offset(cos(angle), sin(angle));
    final normal = Offset(-direction.dy, direction.dx);
    final end = start + direction * length;
    final control = start + direction * (length / 2) + normal * ((rnd.nextDouble() - 0.5) * length * 0.6);
    final isPale = rnd.nextDouble() < 0.35;
    fibre
      ..strokeWidth = 0.35 + rnd.nextDouble() * 0.5
      ..color = isDark
          ? (isPale ? Colors.white.withAlpha(6 + rnd.nextInt(9)) : Colors.black.withAlpha(20 + rnd.nextInt(20)))
          : (isPale ? Colors.white.withAlpha(30 + rnd.nextInt(30)) : _agedBrown.withAlpha(10 + rnd.nextInt(14)));
    canvas.drawPath(
      Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy),
      fibre,
    );
  }
}

/// Abraded patches where rubbing lifted the surface fibres into pale streaks.
void _paintScuffs(Canvas canvas, Size size, Random rnd, bool isDark) {
  final streak = Paint()..strokeCap = StrokeCap.round;
  for (var i = 0; i < 7; i++) {
    final center = Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height);
    final radiusX = 18 + rnd.nextDouble() * 50;
    final radiusY = radiusX * (0.3 + rnd.nextDouble() * 0.5);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rnd.nextDouble() * pi);

    final halo = Rect.fromCenter(center: Offset.zero, width: radiusX * 2.4, height: radiusY * 2.4);
    canvas.drawOval(
      halo,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.white.withAlpha(isDark ? 6 : 28), Colors.white.withAlpha(0)],
        ).createShader(halo),
    );

    for (var k = 0; k < 60; k++) {
      final r = sqrt(rnd.nextDouble());
      final theta = rnd.nextDouble() * pi * 2;
      final p = Offset(cos(theta) * radiusX * r, sin(theta) * radiusY * r);
      streak
        ..strokeWidth = 0.4 + rnd.nextDouble() * 0.3
        ..color = Colors.white.withAlpha(isDark ? 8 + rnd.nextInt(10) : 25 + rnd.nextInt(30));
      canvas.drawLine(p, p + Offset(2 + rnd.nextDouble() * 6, 0), streak);
    }
    canvas.restore();
  }
}

/// Faint tide lines left by dried drops: a barely tinted pool with a darker, soft rim.
void _paintStains(Canvas canvas, Size size, Random rnd) {
  for (var i = 0; i < 2; i++) {
    final center = Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height);
    final radius = size.shortestSide * (0.12 + rnd.nextDouble() * 0.12);
    const points = 48;
    final outline = Path();
    for (var k = 0; k < points; k++) {
      final angle = 2 * pi * k / points;
      final wobble = 1 + sin(angle * 3 + i) * 0.06 + (rnd.nextDouble() - 0.5) * 0.04;
      final p = center + Offset(cos(angle), sin(angle)) * radius * wobble;
      k == 0 ? outline.moveTo(p.dx, p.dy) : outline.lineTo(p.dx, p.dy);
    }
    outline.close();
    canvas.drawPath(outline, Paint()..color = _agedBrown.withAlpha(6));
    canvas.drawPath(
      outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = _agedBrown.withAlpha(22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );
  }
}

/// Foxing: rust-brown age spots, soft-edged so they never read as stray punctuation in the verse.
void _paintFoxing(Canvas canvas, Size size, Random rnd) {
  for (var i = 0; i < 12; i++) {
    final center = Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height);
    _paintSoftSpot(canvas, center, 4 + rnd.nextDouble() * 6, _rust.withAlpha(12 + rnd.nextInt(10)));
    final blotches = 2 + rnd.nextInt(3);
    for (var k = 0; k < blotches; k++) {
      final offset = Offset(rnd.nextDouble() - 0.5, rnd.nextDouble() - 0.5) * 5;
      _paintSoftSpot(canvas, center + offset, 1.2 + rnd.nextDouble() * 1.4, _rust.withAlpha(28 + rnd.nextInt(20)));
    }
  }
}

/// Tooth grain.
void _paintGrain(Canvas canvas, Size size, Random rnd, bool isDark) {
  final grains = min(6000, (size.width * size.height / 70).round());
  final palePoints = Float32List(grains * 2);
  final darkPoints = Float32List(grains * 2);
  for (var i = 0; i < grains * 2; i += 2) {
    palePoints[i] = rnd.nextDouble() * size.width;
    palePoints[i + 1] = rnd.nextDouble() * size.height;
    darkPoints[i] = rnd.nextDouble() * size.width;
    darkPoints[i + 1] = rnd.nextDouble() * size.height;
  }
  final grain = Paint()..strokeWidth = 0.9;
  canvas.drawRawPoints(
    ui.PointMode.points,
    palePoints,
    grain..color = Colors.white.withAlpha(isDark ? 12 : 40),
  );
  canvas.drawRawPoints(
    ui.PointMode.points,
    darkPoints,
    grain..color = (isDark ? Colors.black : const Color(0xFF6B5330)).withAlpha(isDark ? 36 : 14),
  );
}

/// Aged edges: a soft warm falloff toward the borders of the sheet.
void _paintAgedEdges(Canvas canvas, Size size, bool isDark) {
  final rect = Offset.zero & size;
  canvas.drawRect(
    rect,
    Paint()
      ..shader = RadialGradient(
        radius: 0.62 * size.longestSide / size.shortestSide,
        colors: [
          Colors.transparent,
          isDark ? const Color(0x40000000) : const Color(0x2E8A6A3E),
        ],
        stops: const [0.55, 1.0],
      ).createShader(rect),
  );
}
