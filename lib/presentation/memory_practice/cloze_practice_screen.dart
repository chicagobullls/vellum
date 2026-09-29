import 'package:flutter/material.dart';
import '../../core/audio/vellum_sound_engine.dart';
import '../../core/haptics/vellum_haptic_engine.dart';
import '../../core/theme/vellum_theme.dart';
import '../../core/utils/roman_numerals.dart';
import '../../data/models/poem.dart';
import '../../data/models/user_folio_entry.dart';
import '../../data/repositories/poem_repository.dart';
import '../../domain/algorithms/cloze_mask_generator.dart';
import '../widgets/parchment_background.dart';
import '../widgets/wax_seal_widget.dart';

class ClozePracticeScreen extends StatefulWidget {
  final Poem poem;
  final PoemRepository repository;

  const ClozePracticeScreen({
    super.key,
    required this.poem,
    required this.repository,
  });

  @override
  State<ClozePracticeScreen> createState() => _ClozePracticeScreenState();
}

class _ClozePracticeScreenState extends State<ClozePracticeScreen> {
  final VellumSoundEngine _soundEngine = VellumSoundEngine();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textController = TextEditingController();

  int _selectedLevel = 2; // Default to Level II (Vowels masked)
  int _charIndex = 0;
  bool _isCompleted = false;
  int _mistakes = 0;
  DateTime _startTime = DateTime.now();
  late List<MaskedChar> _maskedChars;

  @override
  void initState() {
    super.initState();
    _soundEngine.init();
    _regenerateMask();
  }

  void _regenerateMask() {
    setState(() {
      _charIndex = 0;
      _mistakes = 0;
      _isCompleted = false;
      _startTime = DateTime.now();
      _maskedChars = ClozeMaskGenerator.generateLineMask(widget.poem.originalText, _selectedLevel);
    });
  }

  void _onKeyInput(String input) {
    if (_isCompleted || input.isEmpty) return;
    final original = widget.poem.originalText;
    if (_charIndex >= original.length) return;

    final expectedChar = original[_charIndex];
    final typed = input[input.length - 1];
    _textController.clear();

    if (typed.toLowerCase() == expectedChar.toLowerCase()) {
      _soundEngine.playKeystroke();
      VellumHapticEngine.keyClick();

      setState(() {
        _charIndex++;
        // Auto skip spaces/newlines
        while (_charIndex < original.length && (original[_charIndex] == '\n' || original[_charIndex] == ' ')) {
          if (original[_charIndex] == ' ') _soundEngine.playSpace();
          _charIndex++;
        }

        if (_charIndex >= original.length) {
          _handleCompletion();
        }
      });
    } else {
      _mistakes++;
      VellumHapticEngine.mistake();
    }
  }

  void _handleCompletion() {
    _isCompleted = true;
    _soundEngine.playBellDing();
    _soundEngine.playWaxSealStamp();
    VellumHapticEngine.waxSealStamp();

    final durationSec = DateTime.now().difference(_startTime).inSeconds;
    final wpm = durationSec > 0 ? ((_charIndex / 5) / (durationSec / 60)).round() : 40;
    final accuracy = (_charIndex / (_charIndex + _mistakes)) * 100.0;

    widget.repository.saveMasteredVerse(UserFolioEntry(
      id: 'entry_${DateTime.now().millisecondsSinceEpoch}',
      poemId: widget.poem.id,
      masteredAt: DateTime.now(),
      maxClozeLevelAchieved: _selectedLevel,
      bestAccuracy: accuracy,
      typingSpeedWpm: wpm,
      waxSealColor: _selectedLevel >= 3 ? 'antique_gold' : 'crimson',
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
    final progress = _charIndex / (widget.poem.originalText.isEmpty ? 1 : widget.poem.originalText.length);

    return Scaffold(
      appBar: AppBar(
        title: Text('ТРЕНИРОВКА ПАМЯТИ', style: VellumTheme.headerDateStyle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: VellumTheme.inkPrimary),
            tooltip: 'Начать заново',
            onPressed: _regenerateMask,
          ),
        ],
      ),
      body: ParchmentBackground(
        child: Column(
          children: [
            // Cloze Level Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [1, 2, 3, 4].map((lvl) {
                  final isSelected = _selectedLevel == lvl;
                  return ChoiceChip(
                    label: Text(
                      '${RomanNumerals.toRoman(lvl)}: ${_getLevelName(lvl)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? VellumTheme.parchmentLight : VellumTheme.inkPrimary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: VellumTheme.inkPrimary,
                    backgroundColor: VellumTheme.parchmentSurface,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedLevel = lvl;
                          _regenerateMask();
                        });
                      }
                    },
                  );
                }).toList(),
              ),
            ),

            // Progress bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: VellumTheme.antiqueGoldMuted,
              valueColor: const AlwaysStoppedAnimation<Color>(VellumTheme.antiqueGold),
              minHeight: 2.0,
            ),

            // Poem interactive masked area
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).requestFocus(_focusNode),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
                  child: Column(
                    children: [
                      Text(widget.poem.title, style: VellumTheme.poemTitleStyle, textAlign: TextAlign.center),
                      const SizedBox(height: 4),
                      Text(widget.poem.author, style: VellumTheme.poemAuthorStyle),
                      const SizedBox(height: 32),

                      // Masked Text Display
                      _buildMaskedDisplay(),

                      const SizedBox(height: 40),

                      if (_isCompleted) ...[
                        WaxSealWidget(
                          size: 92,
                          monogram: RomanNumerals.toRoman(_selectedLevel),
                          color: _selectedLevel >= 3 ? VellumTheme.antiqueGold : VellumTheme.waxCrimson,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'УРОВЕНЬ ${RomanNumerals.toRoman(_selectedLevel)} ПОКОРЕН',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.5,
                            color: _selectedLevel >= 3 ? VellumTheme.antiqueGold : VellumTheme.waxCrimson,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Точность: ${((_charIndex / (_charIndex + _mistakes)) * 100).toStringAsFixed(1)}% · Скорость: ${((_charIndex / 5) / (DateTime.now().difference(_startTime).inSeconds / 60)).round()} WPM',
                          style: VellumTheme.labelStyle,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

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

  String _getLevelName(int lvl) {
    switch (lvl) {
      case 1:
        return 'Призрак';
      case 2:
        return 'Гласные';
      case 3:
        return 'Cloze 50%';
      case 4:
      default:
        return 'Пустота';
    }
  }

  Widget _buildMaskedDisplay() {
    final spans = <TextSpan>[];
    final original = widget.poem.originalText;

    for (int i = 0; i < original.length; i++) {
      final isTyped = i < _charIndex;
      final isCurrent = i == _charIndex;
      final maskedChar = i < _maskedChars.length ? _maskedChars[i] : null;

      String displayChar;
      if (isTyped) {
        displayChar = original[i];
      } else if (maskedChar != null) {
        displayChar = maskedChar.displayGlyph;
      } else {
        displayChar = original[i];
      }

      spans.add(
        TextSpan(
          text: displayChar,
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
