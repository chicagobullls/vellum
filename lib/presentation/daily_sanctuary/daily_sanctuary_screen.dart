import 'package:flutter/material.dart';
import '../../core/audio/vellum_sound_engine.dart';
import '../../core/haptics/vellum_haptic_engine.dart';
import '../../core/theme/vellum_theme.dart';
import '../../core/utils/poem_date_selector.dart';
import '../../core/utils/roman_numerals.dart';
import '../../data/models/poem.dart';
import '../../data/models/user_folio_entry.dart';
import '../../data/repositories/poem_repository.dart';
import '../widgets/parchment_background.dart';
import '../widgets/wax_seal_widget.dart';
import '../memory_practice/cloze_practice_screen.dart';
import '../folio_book/folio_screen.dart';
import '../story_studio/story_studio_screen.dart';

class DailySanctuaryScreen extends StatefulWidget {
  final PoemRepository repository;
  const DailySanctuaryScreen({super.key, required this.repository});

  @override
  State<DailySanctuaryScreen> createState() => _DailySanctuaryScreenState();
}

class _DailySanctuaryScreenState extends State<DailySanctuaryScreen> {
  final VellumSoundEngine _soundEngine = VellumSoundEngine();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textController = TextEditingController();

  Poem? _todayPoem;
  int _charIndex = 0;
  bool _isCompleted = false;
  int _mistakes = 0;
  DateTime _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _soundEngine.init();
    _loadPoem();
  }

  Future<void> _loadPoem() async {
    final poems = await widget.repository.getAllPoems();
    if (poems.isNotEmpty && mounted) {
      setState(() {
        _todayPoem = PoemDateSelector.getPoemForDate(DateTime.now(), poems);
        _startTime = DateTime.now();
      });
    }
  }

  void _onKeyInput(String input) {
    if (_todayPoem == null || _isCompleted) return;
    final original = _todayPoem!.originalText;
    if (_charIndex >= original.length) return;

    final expectedChar = original[_charIndex];

    // Handle newline skips or whitespace automatically if user hits space/enter
    if (input.isNotEmpty) {
      final typed = input[input.length - 1];
      _textController.clear();

      if (typed.toLowerCase() == expectedChar.toLowerCase()) {
        _soundEngine.playKeystroke();
        VellumHapticEngine.keyClick();

        setState(() {
          _charIndex++;
          // Auto advance over punctuation or newlines if applicable
          while (_charIndex < original.length && (original[_charIndex] == '\n' || original[_charIndex] == ' ')) {
            if (original[_charIndex] == ' ') {
              _soundEngine.playSpace();
            }
            _charIndex++;
          }

          if (_charIndex >= original.length) {
            _handlePoemCompletion();
          }
        });
      } else {
        _mistakes++;
        VellumHapticEngine.mistake();
      }
    }
  }

  void _handlePoemCompletion() {
    _isCompleted = true;
    _soundEngine.playBellDing();
    _soundEngine.playWaxSealStamp();
    VellumHapticEngine.waxSealStamp();

    final durationSec = DateTime.now().difference(_startTime).inSeconds;
    final wpm = durationSec > 0 ? ((_charIndex / 5) / (durationSec / 60)).round() : 45;
    final accuracy = (_charIndex / (_charIndex + _mistakes)) * 100.0;

    widget.repository.saveMasteredVerse(UserFolioEntry(
      id: 'entry_${DateTime.now().millisecondsSinceEpoch}',
      poemId: _todayPoem!.id,
      masteredAt: DateTime.now(),
      maxClozeLevelAchieved: 1,
      bestAccuracy: accuracy,
      typingSpeedWpm: wpm,
      waxSealColor: 'crimson',
    ));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_todayPoem == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: VellumTheme.antiqueGold)),
      );
    }

    final poem = _todayPoem!;
    final progress = _charIndex / (poem.originalText.isEmpty ? 1 : poem.originalText.length);

    return Scaffold(
      body: ParchmentBackground(
        child: Column(
          children: [
            // Top App Bar: Roman Date & Nav
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu_book_outlined, color: VellumTheme.inkPrimary),
                    tooltip: 'Мой Фолиант (Folio)',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => FolioScreen(repository: widget.repository)),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        RomanNumerals.formatDateRoman(DateTime.now()),
                        style: VellumTheme.headerDateStyle,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'СТИХ ДНЯ · SANCTUARY',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 2,
                          color: VellumTheme.inkSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, color: VellumTheme.inkPrimary),
                    tooltip: 'Экспорт открытки (Story)',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StoryStudioScreen(poem: poem)),
                    ),
                  ),
                ],
              ),
            ),

            // Antique Gold Progress Indicator
            LinearProgressIndicator(
              value: progress,
              backgroundColor: VellumTheme.antiqueGoldMuted,
              valueColor: const AlwaysStoppedAnimation<Color>(VellumTheme.antiqueGold),
              minHeight: 2.5,
            ),

            // Scrollable Poem Sheet
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).requestFocus(_focusNode),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Poem Header
                      Text(
                        poem.title,
                        textAlign: TextAlign.center,
                        style: VellumTheme.poemTitleStyle,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${poem.author}, ${poem.year}',
                        textAlign: TextAlign.center,
                        style: VellumTheme.poemAuthorStyle,
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          border: Border.all(color: VellumTheme.antiqueGold.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          poem.meter.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            letterSpacing: 1.5,
                            color: VellumTheme.antiqueGold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Kinetic Ghost Typing Verse Display
                      _buildKineticVerse(poem.originalText),

                      const SizedBox(height: 40),

                      // Completion Wax Seal Stamp
                      if (_isCompleted) ...[
                        const WaxSealWidget(
                          size: 84,
                          monogram: 'V',
                          color: VellumTheme.waxCrimson,
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'ЗАПЕЧАТАНО В ПАМЯТИ',
                          style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w700,
                            color: VellumTheme.waxCrimson,
                          ),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: VellumTheme.inkPrimary,
                            foregroundColor: VellumTheme.parchmentLight,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.psychology_outlined),
                          label: const Text('ПЕРЕЙТИ К ТРЕНИРОВКЕ ПАМЯТИ (CLOZE)'),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ClozePracticeScreen(
                                poem: poem,
                                repository: widget.repository,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Hidden text field for soft keyboard typing capture
            Offstage(
              offstage: true,
              child: TextField(
                focusNode: _focusNode,
                controller: _textController,
                autofocus: true,
                onChanged: _onKeyInput,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKineticVerse(String text) {
    final spans = <TextSpan>[];

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final isTyped = i < _charIndex;
      final isCurrent = i == _charIndex;

      spans.add(
        TextSpan(
          text: char,
          style: TextStyle(
            color: isTyped
                ? VellumTheme.inkCorrect
                : isCurrent
                    ? VellumTheme.antiqueGold
                    : VellumTheme.inkGhost,
            fontWeight: isTyped || isCurrent ? FontWeight.w600 : FontWeight.normal,
            backgroundColor: isCurrent ? VellumTheme.antiqueGoldMuted : null,
          ),
        ),
      );
    }

    return SelectableText.rich(
      TextSpan(
        children: spans,
        style: VellumTheme.verseStyle,
      ),
      textAlign: TextAlign.center,
    );
  }
}
