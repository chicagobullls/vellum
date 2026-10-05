import 'package:flutter/material.dart';
import '../../core/theme/vellum_theme.dart';
import '../../core/utils/poem_date_selector.dart';
import '../../core/utils/roman_numerals.dart';
import '../../data/models/poem.dart';
import '../../data/models/user_folio_entry.dart';
import '../../data/repositories/poem_repository.dart';
import '../widgets/seal_widget.dart';
import '../widgets/soft_surface.dart';
import '../widgets/typewriter_paper_background.dart';
import 'ghost_typing_widget.dart';
import '../memory_practice/cloze_practice_screen.dart';
import '../folio_book/folio_screen.dart';
import '../story_studio/story_studio_screen.dart';
import '../settings/settings_screen.dart';

class DailySanctuaryScreen extends StatefulWidget {
  final PoemRepository repository;
  const DailySanctuaryScreen({super.key, required this.repository});

  @override
  State<DailySanctuaryScreen> createState() => _DailySanctuaryScreenState();
}

class _DailySanctuaryScreenState extends State<DailySanctuaryScreen> {
  Poem? _todayPoem;
  String _selectedLanguage = 'ru';
  int _charIndex = 0;
  int _mistakes = 0;
  bool _isCompleted = false;
  DateTime _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadPoem();
  }

  Future<void> _loadPoem() async {
    final poems = await widget.repository.getAllPoems();
    if (poems.isNotEmpty && mounted) {
      setState(() {
        _todayPoem = PoemDateSelector.getPoemForDate(
          DateTime.now(),
          poems,
          language: _selectedLanguage,
        );
        _charIndex = 0;
        _mistakes = 0;
        _isCompleted = false;
        _startTime = DateTime.now();
      });
    }
  }

  void _toggleLanguage() {
    setState(() {
      _selectedLanguage = _selectedLanguage == 'ru' ? 'en' : 'ru';
      _loadPoem();
    });
  }

  void _onProgress(int charIndex, int mistakes, bool isCompleted) {
    setState(() {
      _charIndex = charIndex;
      _mistakes = mistakes;
      _isCompleted = isCompleted;
    });
  }

  void _onCompleted() {
    if (_todayPoem == null) return;
    final durationSec = DateTime.now().difference(_startTime).inSeconds;
    final wpm = durationSec > 0 ? ((_charIndex / 5) / (durationSec / 60)).round() : 45;
    final total = _charIndex + _mistakes;
    final accuracy = total > 0 ? (_charIndex / total) * 100.0 : 100.0;

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
  Widget build(BuildContext context) {
    if (_todayPoem == null) {
      return const Scaffold(
        body: TypewriterPaperBackground(
          child: Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
        ),
      );
    }

    final poem = _todayPoem!;
    final totalLen = poem.originalText.isEmpty ? 1 : poem.originalText.length;
    final progress = (_charIndex / totalLen).clamp(0.0, 1.0);
    final totalTyped = _charIndex + _mistakes;
    final accuracy = totalTyped > 0 ? ((_charIndex / totalTyped) * 100).round() : 100;
    final elapsedSec = DateTime.now().difference(_startTime).inSeconds;
    final wpm = elapsedSec > 2 ? ((_charIndex / 5) / (elapsedSec / 60)).round() : 0;

    return Scaffold(
      body: TypewriterPaperBackground(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(poem),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: InkProgressBar(value: progress),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 4),
                  child: Column(
                    children: [
                      Text(
                        poem.title.toUpperCase(),
                        style: VellumTheme.poemTitleStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text('${poem.author}, ${poem.year}', style: VellumTheme.poemAuthorStyle),
                      const SizedBox(height: 12),
                      SoftSurface(
                        radius: null,
                        elevated: false,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        child: Text(poem.meter.toUpperCase(), style: VellumTheme.captionStyle.copyWith(fontSize: 9)),
                      ),
                    ],
                  ),
                ),

                // The verse scrolls up past the floating stats capsule.
                Expanded(
                  child: GhostTypingWidget(
                    key: ValueKey('${poem.id}_$_selectedLanguage'),
                    poem: poem,
                    bottomInset: _isCompleted ? 0 : 72,
                    onProgress: _onProgress,
                    onCompleted: _onCompleted,
                  ),
                ),

                if (_isCompleted)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: SoftSurface(
                      radius: 24,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const SealWidget(size: 72, monogram: 'V'),
                          const SizedBox(height: 12),
                          const Text('ЗАПЕЧАТАНО В ПАМЯТИ', style: VellumTheme.captionStyle),
                          const SizedBox(height: 16),
                          SoftButton(
                            icon: Icons.psychology_outlined,
                            label: 'ЗАКРЕПИТЬ В ТРЕНАЖЁРЕ',
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
                      ),
                    ),
                  ),
              ],
            ),

            if (!_isCompleted)
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: Center(
                  child: SoftSurface(
                    radius: null,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Text(
                      'ТОЧНОСТЬ $accuracy%   ·   $wpm WPM   ·   СТРОК ${poem.totalLines}',
                      textAlign: TextAlign.center,
                      style: VellumTheme.labelStyle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Top bar: soft toolbars for navigation and actions around the Roman date.
  Widget _buildTopBar(Poem poem) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      child: Row(
        children: [
          SoftToolbar(
            children: [
              IconButton(
                icon: const Icon(Icons.menu_book_outlined, size: 20),
                tooltip: 'Мой Фолиант (Folio)',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FolioScreen(repository: widget.repository),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.tune, size: 20),
                tooltip: 'Настройки звука и ритуала',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    RomanNumerals.formatDateRoman(DateTime.now()),
                    style: VellumTheme.headerDateStyle,
                  ),
                ),
                const SizedBox(height: 4),
                const Text('СТИХ ДНЯ', style: VellumTheme.captionStyle),
              ],
            ),
          ),
          SoftToolbar(
            children: [
              IconButton(
                icon: Text(
                  _selectedLanguage.toUpperCase(),
                  style: VellumTheme.labelStyle.copyWith(color: VellumTheme.ink),
                ),
                tooltip: 'Язык стиха',
                onPressed: _toggleLanguage,
              ),
              IconButton(
                icon: const Icon(Icons.ios_share, size: 20),
                tooltip: 'Экспорт открытки (Story)',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StoryStudioScreen(poem: poem),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
