import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/vellum_theme.dart';
import '../../data/models/poem.dart';
import '../widgets/vellum_app_bar.dart';
import '../widgets/seal_widget.dart';
import '../widgets/soft_surface.dart';
import '../widgets/typewriter_paper_background.dart';

/// Story Card Studio (SCR-04): Offscreen high-res PNG export (9:16 and 1:1)
/// with Typewriter Paper / Carbon Copy (charcoal) texture switch and native iOS Share Sheet.
class StoryStudioScreen extends StatefulWidget {
  final Poem poem;
  const StoryStudioScreen({super.key, required this.poem});

  @override
  State<StoryStudioScreen> createState() => _StoryStudioScreenState();
}

class _StoryStudioScreenState extends State<StoryStudioScreen> {
  final GlobalKey _cardRepaintKey = GlobalKey();

  bool _isStoryFormat = true; // true = 9:16 Story, false = 1:1 Square
  bool _isCharcoalTheme = false; // false = Typewriter Paper, true = Carbon Copy (charcoal)
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
    final textColor = _isCharcoalTheme ? VellumTheme.carbonInk : VellumTheme.ink;
    final subColor = _isCharcoalTheme ? VellumTheme.carbonInkSecondary : VellumTheme.inkSecondary;
    final bleed = _isCharcoalTheme ? VellumTheme.inkBleedLight : VellumTheme.inkBleed;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: VellumAppBar(
        title: 'ОТКРЫТКА ДЛЯ СТОРИС',
        actions: [
          SoftIconButton(
            icon: _isCharcoalTheme ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            tooltip: 'Сменить фактуру: Бумага / Копирка',
            onPressed: () => setState(() => _isCharcoalTheme = !_isCharcoalTheme),
          ),
        ],
      ),
      body: TypewriterPaperBackground(
        child: Column(
          children: [
            // Aspect Ratio Toggle
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: SoftSegmentedControl(
                count: 2,
                selectedIndex: _isStoryFormat ? 0 : 1,
                onSelected: (i) => setState(() => _isStoryFormat = i == 0),
                itemBuilder: (context, i, isSelected) => Text(
                  i == 0 ? '9:16 STORY' : '1:1 SQUARE',
                  style: VellumTheme.labelStyle.copyWith(
                    color: isSelected ? VellumTheme.ink : VellumTheme.inkSecondary,
                  ),
                ),
              ),
            ),

            // Card Canvas sized to fit the free space; RepaintBoundary wraps exactly the card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _isStoryFormat ? (9 / 16) : 1.0,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                        boxShadow: [
                          BoxShadow(color: Color(0x335A4630), blurRadius: 18, offset: Offset(0, 8)),
                          BoxShadow(color: Color(0x1A5A4630), blurRadius: 2, offset: Offset(0, 1)),
                        ],
                      ),
                      child: RepaintBoundary(
                        key: _cardRepaintKey,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: TypewriterPaperBackground(
                            isDark: _isCharcoalTheme,
                            safeArea: false,
                            child: Padding(
                              padding: const EdgeInsets.all(26),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        'VELLUM · SANCTUARY',
                                        style: VellumTheme.captionStyle.copyWith(color: subColor),
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        widget.poem.title.toUpperCase(),
                                        textAlign: TextAlign.center,
                                        style: VellumTheme.poemTitleStyle.copyWith(
                                          fontSize: 18,
                                          color: textColor,
                                          shadows: bleed,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${widget.poem.author}, ${widget.poem.year}',
                                        style: VellumTheme.poemAuthorStyle.copyWith(fontSize: 12, color: subColor),
                                      ),
                                    ],
                                  ),
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          widget.poem.stanzas.isNotEmpty
                                              ? widget.poem.stanzas.first.join('\n')
                                              : widget.poem.originalText,
                                          textAlign: TextAlign.center,
                                          style: VellumTheme.verseStyle.copyWith(
                                            fontSize: 14,
                                            color: textColor,
                                            shadows: bleed,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      SealWidget(
                                        size: 54,
                                        monogram: 'V',
                                        finish: _isCharcoalTheme ? SealFinish.ink : SealFinish.paper,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'ЗАПЕЧАТАНО В ПАМЯТИ',
                                        style: VellumTheme.captionStyle.copyWith(fontSize: 9, color: subColor),
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
                ),
              ),
            ),

            // Share Action Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SoftButton(
                icon: Icons.ios_share,
                label: _isExporting ? 'РЕНДЕРИНГ В HD...' : 'ПОДЕЛИТЬСЯ ОТКРЫТКОЙ',
                isLoading: _isExporting,
                onPressed: _isExporting ? null : _exportAndShareCard,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
