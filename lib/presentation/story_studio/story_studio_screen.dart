import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/vellum_theme.dart';
import '../../data/models/poem.dart';
import '../widgets/parchment_background.dart';
import '../widgets/wax_seal_widget.dart';

class StoryStudioScreen extends StatefulWidget {
  final Poem poem;
  const StoryStudioScreen({super.key, required this.poem});

  @override
  State<StoryStudioScreen> createState() => _StoryStudioScreenState();
}

class _StoryStudioScreenState extends State<StoryStudioScreen> {
  bool _isStoryFormat = true; // true = 9:16 Story, false = 1:1 Square

  void _sharePoem() {
    final text = '📜 "${widget.poem.title}" — ${widget.poem.author}\n\n'
        '${widget.poem.stanzas.isNotEmpty ? widget.poem.stanzas.first.join("\n") : widget.poem.originalText}\n\n'
        'Заучено и запечатано в Vellum.';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ОТКРЫТКА ДЛЯ СТОРИС', style: VellumTheme.headerDateStyle),
        centerTitle: true,
      ),
      body: ParchmentBackground(
        child: Column(
          children: [
            // Format Selector: 9:16 vs 1:1
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('9:16 Story'),
                    selected: _isStoryFormat,
                    selectedColor: VellumTheme.inkPrimary,
                    labelStyle: TextStyle(
                      color: _isStoryFormat ? VellumTheme.parchmentLight : VellumTheme.inkPrimary,
                    ),
                    onSelected: (val) => setState(() => _isStoryFormat = true),
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('1:1 Square'),
                    selected: !_isStoryFormat,
                    selectedColor: VellumTheme.inkPrimary,
                    labelStyle: TextStyle(
                      color: !_isStoryFormat ? VellumTheme.parchmentLight : VellumTheme.inkPrimary,
                    ),
                    onSelected: (val) => setState(() => _isStoryFormat = false),
                  ),
                ],
              ),
            ),

            // Card Preview Container
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: AspectRatio(
                    aspectRatio: _isStoryFormat ? (9 / 16) : 1.0,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: VellumTheme.parchmentSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: VellumTheme.antiqueGold, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
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
                                style: VellumTheme.poemTitleStyle.copyWith(fontSize: 22),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.poem.author}, ${widget.poem.year}',
                                style: VellumTheme.poemAuthorStyle.copyWith(fontSize: 14),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              widget.poem.stanzas.isNotEmpty
                                  ? widget.poem.stanzas.first.join('\n')
                                  : widget.poem.originalText,
                              textAlign: TextAlign.center,
                              style: VellumTheme.verseStyle.copyWith(fontSize: 16),
                            ),
                          ),
                          Column(
                            children: [
                              const WaxSealWidget(size: 56, monogram: 'V'),
                              const SizedBox(height: 8),
                              const Text(
                                'Запечатано в памяти',
                                style: TextStyle(fontSize: 10, letterSpacing: 2, color: VellumTheme.waxCrimson),
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

            // Share Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: VellumTheme.inkPrimary,
                  foregroundColor: VellumTheme.parchmentLight,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.ios_share),
                label: const Text('ПОДЕЛИТЬСЯ ОТКРЫТКОЙ', style: TextStyle(letterSpacing: 1.2)),
                onPressed: _sharePoem,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
