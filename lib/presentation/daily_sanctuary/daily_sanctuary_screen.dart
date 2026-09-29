import 'package:flutter/material.dart';
import '../../core/theme/vellum_theme.dart';
import '../../core/utils/poem_date_selector.dart';
import '../../core/utils/roman_numerals.dart';
import '../../data/models/poem.dart';
import '../../data/models/user_folio_entry.dart';
import '../../data/repositories/poem_repository.dart';
import '../widgets/parchment_background.dart';
import '../widgets/wax_seal_widget.dart';
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
        body: Center(child: CircularProgressIndicator(color: VellumTheme.antiqueGold)),
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
      body: ParchmentBackground(
        child: Column(
          children: [
            // Top App Bar: Navigation, Roman Date & Settings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu_book_outlined, color: VellumTheme.inkPrimary),
                        tooltip: 'Мой Фолиант (Folio)',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FolioScreen(repository: widget.repository),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: VellumTheme.inkPrimary, size: 20),
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
                  Row(
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: const Size(36, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                        onPressed: _toggleLanguage,
                        child: Text(
                          _selectedLanguage.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: VellumTheme.antiqueGold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined, color: VellumTheme.inkPrimary),
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
            ),

            LinearProgressIndicator(
              value: progress,
              backgroundColor: VellumTheme.antiqueGoldMuted,
              valueColor: const AlwaysStoppedAnimation<Color>(VellumTheme.antiqueGold),
              minHeight: 2.5,
            ),

            Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 6),
              child: Column(
                children: [
                  Text(poem.title, style: VellumTheme.poemTitleStyle, textAlign: TextAlign.center),
                  const SizedBox(height: 3),
                  Text('${poem.author}, ${poem.year}', style: VellumTheme.poemAuthorStyle),
                  const SizedBox(height: 8),
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
                ],
              ),
            ),

            Expanded(
              child: GhostTypingWidget(
                key: ValueKey('${poem.id}_$_selectedLanguage'),
                poem: poem,
                onProgress: _onProgress,
                onCompleted: _onCompleted,
              ),
            ),

            if (_isCompleted) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  children: [
                    const WaxSealWidget(size: 78, monogram: 'V'),
                    const SizedBox(height: 8),
                    const Text(
                      'ЗАПЕЧАТАНО В ПАМЯТИ',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.bold,
                        color: VellumTheme.waxCrimson,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VellumTheme.inkPrimary,
                        foregroundColor: VellumTheme.parchmentLight,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.psychology_outlined, size: 18),
                      label: const Text('ЗАКРЕПИТЬ ПАМЯТЬ В ТРЕНАЖЕРЕ (CLOZE)'),
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
            ] else ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Точность: $accuracy%', style: VellumTheme.labelStyle),
                    const SizedBox(width: 20),
                    Text('Скорость: $wpm WPM', style: VellumTheme.labelStyle),
                    const SizedBox(width: 20),
                    Text('Строк: ${poem.totalLines}', style: VellumTheme.labelStyle),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
