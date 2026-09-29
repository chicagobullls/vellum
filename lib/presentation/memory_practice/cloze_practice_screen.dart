import 'dart:async';
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
  final VellumSoundEngine _sound = VellumSoundEngine();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textController = TextEditingController();

  int _selectedLevel = 2; // Default to Level II
  int _charIndex = 0;
  int _mistakes = 0;
  bool _isCompleted = false;
  bool _isHintActive = false;
  Timer? _hintTimer;
  DateTime _startTime = DateTime.now();
  late List<MaskedChar> _maskedChars;

  @override
  void initState() {
    super.initState();
    _sound.init();
    _regenerateMask();
  }

  void _regenerateMask() {
    setState(() {
      _charIndex = 0;
      _mistakes = 0;
      _isCompleted = false;
      _isHintActive = false;
      _startTime = DateTime.now();
      _maskedChars = ClozeMaskGenerator.generateLineMask(
        widget.poem.originalText,
        _selectedLevel,
      );
    });
  }

  /// Feather hint button: reveals current line for exactly 2 seconds
  void _triggerFeatherHint() {
    if (_isCompleted || _isHintActive) return;

    _sound.playBellDing();
    VellumHapticEngine.keyClick();

    setState(() {
      _isHintActive = true;
    });

    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _isHintActive = false;
        });
      }
    });
  }

  void _onKeyInput(String input) {
    if (_isCompleted || input.isEmpty) return;
    final original = widget.poem.originalText;
    if (_charIndex >= original.length) return;

    final expectedChar = original[_charIndex];
    final typedChar = input[input.length - 1];
    _textController.clear();

    if (typedChar.toLowerCase() == expectedChar.toLowerCase()) {
      _sound.playKeystroke();
      VellumHapticEngine.keyClick();

      setState(() {
        _charIndex++;
        // Auto skip spaces/newlines
        while (_charIndex < original.length &&
            (original[_charIndex] == '\n' || original[_charIndex] == ' ')) {
          if (original[_charIndex] == '\n') {
            _sound.playBellDing();
            VellumHapticEngine.stanzaCompleted();
          } else if (original[_charIndex] == ' ') {
            _sound.playSpace();
          }
          _charIndex++;
        }

        if (_charIndex >= original.length) {
          _handleCompletion();
        }
      });
    } else {
      _mistakes++;
      _sound.playJammedKey();
      VellumHapticEngine.doubleMistakePulse();
    }
  }

  void _handleCompletion() {
    _isCompleted = true;
    _sound.playBellDing();
    _sound.playWaxSealStamp();
    VellumHapticEngine.waxSealStamp();

    final durationSec = DateTime.now().difference(_startTime).inSeconds;
    final wpm = durationSec > 0 ? ((_charIndex / 5) / (durationSec / 60)).round() : 40;
    final total = _charIndex + _mistakes;
    final accuracy = total > 0 ? (_charIndex / total) * 100.0 : 100.0;

    widget.repository.saveMasteredVerse(UserFolioEntry(
      id: 'entry_${DateTime.now().millisecondsSinceEpoch}',
      poemId: widget.poem.id,
      masteredAt: DateTime.now(),
      maxClozeLevelAchieved: _selectedLevel,
      bestAccuracy: accuracy,
      typingSpeedWpm: wpm,
      waxSealColor: _selectedLevel >= 3 ? 'antique_gold' : 'crimson',
    ));

    _showMasteredDialog(accuracy, wpm);
  }

  void _showMasteredDialog(double accuracy, int wpm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: VellumTheme.parchmentLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: VellumTheme.antiqueGold, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              WaxSealWidget(
                size: 88,
                monogram: '★',
                color: _selectedLevel >= 3 ? VellumTheme.antiqueGold : VellumTheme.waxCrimson,
              ),
              const SizedBox(height: 16),
              const Text(
                'MASTERED · СТИХ ПОКОРЕН',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.5,
                  color: VellumTheme.antiqueGold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.poem.title,
                textAlign: TextAlign.center,
                style: VellumTheme.poemTitleStyle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatPill('Уровень', RomanNumerals.toRoman(_selectedLevel)),
                  _buildStatPill('Точность', '${accuracy.toStringAsFixed(1)}%'),
                  _buildStatPill('Скорость', '$wpm WPM'),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: VellumTheme.inkPrimary,
                  foregroundColor: VellumTheme.parchmentLight,
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('ВЕРНУТЬСЯ В СВЯТИЛИЩЕ (SANCTUARY)'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatPill(String title, String val) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: VellumTheme.inkSecondary)),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VellumTheme.inkPrimary)),
      ],
    );
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final original = widget.poem.originalText;
    final totalLen = original.isEmpty ? 1 : original.length;
    final progress = (_charIndex / totalLen).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Text('ТРЕНИРОВКА ПАМЯТИ', style: VellumTheme.headerDateStyle),
        centerTitle: true,
        actions: [
          // Feather hint button («Перо»)
          IconButton(
            icon: Icon(
              Icons.edit_note,
              color: _isHintActive ? VellumTheme.antiqueGold : VellumTheme.inkPrimary,
            ),
            tooltip: 'Перо: приоткрыть строку на 2 сек',
            onPressed: _triggerFeatherHint,
          ),
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
            // Roman Numeral Level Selector (I..IV)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [1, 2, 3, 4].map((lvl) {
                  final isSelected = _selectedLevel == lvl;
                  return ChoiceChip(
                    label: Text(
                      '${RomanNumerals.toRoman(lvl)}: ${_getLevelTitle(lvl)}',
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

            // Hint banner when feather is active
            if (_isHintActive)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                color: VellumTheme.antiqueGold.withOpacity(0.15),
                child: const Text(
                  '🪶 ПЕРО: СТРОКА ОТКРЫТА НА 2 СЕКУНДЫ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: VellumTheme.antiqueGold,
                  ),
                ),
              ),

            // Interactive Masked Verse Area
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => FocusScope.of(context).requestFocus(_focusNode),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
                  child: Column(
                    children: [
                      Text(widget.poem.title, style: VellumTheme.poemTitleStyle, textAlign: TextAlign.center),
                      const SizedBox(height: 4),
                      Text(widget.poem.author, style: VellumTheme.poemAuthorStyle),
                      const SizedBox(height: 28),

                      // Masked Text with dotted underlines
                      _buildMaskedDisplay(),

                      const SizedBox(height: 36),

                      if (_isCompleted) ...[
                        WaxSealWidget(
                          size: 92,
                          monogram: '★',
                          color: _selectedLevel >= 3 ? VellumTheme.antiqueGold : VellumTheme.waxCrimson,
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'MASTERED',
                          style: TextStyle(
                            fontFamily: 'Cinzel',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                            color: VellumTheme.antiqueGold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Hidden text input field
            Offstage(
              offstage: true,
              child: TextField(
                focusNode: _focusNode,
                controller: _textController,
                autofocus: true,
                autocorrect: false,
                enableSuggestions: false,
                spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
                onChanged: _onKeyInput,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLevelTitle(int lvl) {
    switch (lvl) {
      case 1:
        return 'Призрак';
      case 2:
        return '30% слов';
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
      } else if (_isHintActive) {
        // Feather hint reveals actual character
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
      TextSpan(children: spans, style: VellumTheme.verseStyle),
      textAlign: TextAlign.center,
    );
  }
}
