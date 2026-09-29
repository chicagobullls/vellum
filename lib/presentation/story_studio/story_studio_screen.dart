import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/vellum_theme.dart';
import '../../data/models/poem.dart';
import '../widgets/parchment_background.dart';
import '../widgets/wax_seal_widget.dart';

/// Story Card Studio (SCR-04): Offscreen high-res PNG export (9:16 and 1:1)
/// with Parchment / Dark Academia Charcoal theme switch and native iOS Share Sheet.
class StoryStudioScreen extends StatefulWidget {
  final Poem poem;
  const StoryStudioScreen({super.key, required this.poem});

  @override
  State<StoryStudioScreen> createState() => _StoryStudioScreenState();
}

class _StoryStudioScreenState extends State<StoryStudioScreen> {
  final GlobalKey _cardRepaintKey = GlobalKey();

  bool _isStoryFormat = true; // true = 9:16 Story, false = 1:1 Square
  bool _isCharcoalTheme = false; // false = Parchment Light, true = Dark Charcoal
  bool _isExporting = false;

  /// High-resolution image capture via RenderRepaintBoundary
  Future<void> _exportAndShareCard() async {
    setState(() => _isExporting = true);

    try {
      final boundary = _cardRepaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary != null) {
        // High-DPI 3.0 pixel ratio rendering
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

        if (byteData != null) {
          final pngBytes = byteData.buffer.asUint8List();
          final poem = widget.poem;
          final shareText = '📜 "${poem.title}" — ${poem.author}\nЗапечатано в памяти Vellum.';

          await Share.shareXFiles(
            [
              XFile.fromData(
                pngBytes,
                mimeType: 'image/png',
                name: 'vellum_${poem.id}_card.png',
              ),
            ],
            text: shareText,
          );
        }
      }
    } catch (e) {
      // Fallback text share if image capture is constrained in headless tests
      Share.share('📜 "${widget.poem.title}" — ${widget.poem.author}\nЗапечатано в Vellum.');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = _isCharcoalTheme ? VellumTheme.darkWood : VellumTheme.parchmentSurface;
    final textColor = _isCharcoalTheme ? VellumTheme.darkInkPrimary : VellumTheme.inkPrimary;
    final subColor = _isCharcoalTheme ? VellumTheme.darkInkSecondary : VellumTheme.inkSecondary;

    return Scaffold(
      appBar: AppBar(
        title: Text('ОТКРЫТКА ДЛЯ СТОРИС', style: VellumTheme.headerDateStyle),
        centerTitle: true,
      ),
      body: ParchmentBackground(
        child: Column(
          children: [
            // Controls: Aspect Ratio and Theme Toggles
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 9:16 vs 1:1
                  ChoiceChip(
                    label: const Text('9:16 Story'),
                    selected: _isStoryFormat,
                    selectedColor: VellumTheme.inkPrimary,
                    labelStyle: TextStyle(
                      color: _isStoryFormat ? VellumTheme.parchmentLight : VellumTheme.inkPrimary,
                    ),
                    onSelected: (val) => setState(() => _isStoryFormat = true),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('1:1 Square'),
                    selected: !_isStoryFormat,
                    selectedColor: VellumTheme.inkPrimary,
                    labelStyle: TextStyle(
                      color: !_isStoryFormat ? VellumTheme.parchmentLight : VellumTheme.inkPrimary,
                    ),
                    onSelected: (val) => setState(() => _isStoryFormat = false),
                  ),
                  const SizedBox(width: 16),
                  // Texture Toggle
                  IconButton(
                    icon: Icon(_isCharcoalTheme ? Icons.dark_mode : Icons.light_mode, color: VellumTheme.antiqueGold),
                    tooltip: 'Сменить фактуру: Пергамент / Уголь',
                    onPressed: () => setState(() => _isCharcoalTheme = !_isCharcoalTheme),
                  ),
                ],
              ),
            ),

            // Card Canvas Container wrapped in RepaintBoundary
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: RepaintBoundary(
                    key: _cardRepaintKey,
                    child: AspectRatio(
                      aspectRatio: _isStoryFormat ? (9 / 16) : 1.0,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: VellumTheme.antiqueGold, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                const Text(
                                  'VELLUM · SANCTUARY',
                                  style: TextStyle(
                                    fontFamily: 'Cinzel',
                                    fontSize: 10,
                                    letterSpacing: 3,
                                    color: VellumTheme.antiqueGold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  widget.poem.title,
                                  textAlign: TextAlign.center,
                                  style: VellumTheme.poemTitleStyle.copyWith(
                                    fontSize: 22,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.poem.author}, ${widget.poem.year}',
                                  style: VellumTheme.poemAuthorStyle.copyWith(
                                    fontSize: 13,
                                    color: subColor,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                widget.poem.stanzas.isNotEmpty
                                    ? widget.poem.stanzas.first.join('\n')
                                    : widget.poem.originalText,
                                textAlign: TextAlign.center,
                                style: VellumTheme.verseStyle.copyWith(
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                const WaxSealWidget(size: 54, monogram: 'V'),
                                const SizedBox(height: 8),
                                const Text(
                                  'Запечатано в памяти',
                                  style: TextStyle(
                                    fontFamily: 'Cinzel',
                                    fontSize: 10,
                                    letterSpacing: 2,
                                    color: VellumTheme.waxCrimson,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Share Action Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: VellumTheme.inkPrimary,
                  foregroundColor: VellumTheme.parchmentLight,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: _isExporting
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.ios_share),
                label: Text(
                  _isExporting ? 'РЕНДЕРИНГ В HD...' : 'ПОДЕЛИТЬСЯ ОТКРЫТКОЙ',
                  style: const TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.bold),
                ),
                onPressed: _isExporting ? null : _exportAndShareCard,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
