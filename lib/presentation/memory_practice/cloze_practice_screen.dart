import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/audio/vellum_sound_engine.dart';
import '../../core/billing/vellum_billing_service.dart';
import '../../core/haptics/vellum_haptic_engine.dart';
import '../../core/theme/vellum_theme.dart';
import '../../core/utils/roman_numerals.dart';
import '../../data/models/poem.dart';
import '../../data/models/user_folio_entry.dart';
import '../../data/repositories/poem_repository.dart';
import '../../domain/algorithms/cloze_mask_generator.dart';
import '../widgets/vellum_app_bar.dart';
import '../widgets/seal_widget.dart';
import '../widgets/soft_surface.dart';
import '../widgets/typewriter_paper_background.dart';
import '../paywall/vellum_pro_dialog.dart';

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
  final VellumBillingService _billing = VellumBillingService();
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
    _billing.init();
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

  void _onLevelSelected(int lvl) {
    if (!_billing.isClozeLevelUnlocked(lvl)) {
      showSoftDialog(
        context: context,
        builder: (_) => const VellumProDialog(
          triggerReason: 'Уровни заучивания Cloze III и IV доступны в Vellum Pro',
        ),
      ).then((_) {
        if (_billing.isPro) {
          setState(() {
            _selectedLevel = lvl;
            _regenerateMask();
          });
        }
      });
      return;
    }

    setState(() {
      _selectedLevel = lvl;
      _regenerateMask();
    });
  }

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
    showSoftDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SoftDialog(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SealWidget(
                size: 88,
                monogram: RomanNumerals.toRoman(_selectedLevel),
                finish: _sealFinish,
              ),
              const SizedBox(height: 18),
              const Text('MASTERED · СТИХ ПОКОРЕН', style: VellumTheme.captionStyle),
              const SizedBox(height: 10),
              Text(
                widget.poem.title.toUpperCase(),
                textAlign: TextAlign.center,
                style: VellumTheme.poemTitleStyle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatPill('Уровень', RomanNumerals.toRoman(_selectedLevel)),
                  _buildStatPill('Точность', '${accuracy.toStringAsFixed(1)}%'),
                  _buildStatPill('Скорость', '$wpm WPM'),
                ],
              ),
              const SizedBox(height: 24),
              SoftButton(
                label: 'ВЕРНУТЬСЯ В СВЯТИЛИЩЕ',
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  SealFinish get _sealFinish => _selectedLevel >= 3 ? SealFinish.ink : SealFinish.paper;

  Widget _buildStatPill(String title, String val) {
    return Column(
      children: [
        Text(title.toUpperCase(), style: VellumTheme.captionStyle.copyWith(fontSize: 9)),
        const SizedBox(height: 4),
        Text(
          val,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: VellumTheme.ink,
            shadows: VellumTheme.inkBleed,
          ),
        ),
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
      extendBodyBehindAppBar: true,
      appBar: VellumAppBar(
        title: 'ТРЕНИРОВКА ПАМЯТИ',
        actions: [
          SoftToolbar(
            children: [
              IconButton(
                icon: Icon(
                  Icons.edit_note,
                  size: 22,
                  color: _isHintActive ? VellumTheme.inkSecondary : VellumTheme.ink,
                ),
                tooltip: 'Перо: приоткрыть строку на 2 сек',
                onPressed: _triggerFeatherHint,
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                tooltip: 'Начать заново',
                onPressed: _regenerateMask,
              ),
            ],
          ),
        ],
      ),
      body: TypewriterPaperBackground(
        child: Column(
          children: [
            // Roman Numeral Level Selector (I..IV) with lock on Pro levels III & IV
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SoftSegmentedControl(
                count: 4,
                height: 46,
                selectedIndex: _selectedLevel - 1,
                onSelected: (i) => _onLevelSelected(i + 1),
                itemBuilder: (context, i, isSelected) {
                  final lvl = i + 1;
                  final isLocked = !_billing.isClozeLevelUnlocked(lvl);
                  final foreground = isSelected ? VellumTheme.ink : VellumTheme.inkSecondary;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            RomanNumerals.toRoman(lvl),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: foreground),
                          ),
                          if (isLocked) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.lock_outline, size: 11, color: foreground),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getLevelTitle(lvl).toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 8, letterSpacing: 0.8, color: foreground),
                      ),
                    ],
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: InkProgressBar(value: progress),
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              child: _isHintActive
                  ? const Padding(
                      padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
                      child: SoftSurface(
                        radius: null,
                        padding: EdgeInsets.symmetric(vertical: 7, horizontal: 14),
                        child: Center(
                          child: Text(
                            'ПЕРО: СТРОКА ОТКРЫТА НА 2 СЕКУНДЫ',
                            style: VellumTheme.captionStyle,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),

            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => FocusScope.of(context).requestFocus(_focusNode),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                  child: Column(
                    children: [
                      Text(
                        widget.poem.title.toUpperCase(),
                        style: VellumTheme.poemTitleStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(widget.poem.author, style: VellumTheme.poemAuthorStyle),
                      const SizedBox(height: 28),

                      _buildMaskedDisplay(),

                      const SizedBox(height: 36),

                      if (_isCompleted) ...[
                        SealWidget(
                          size: 88,
                          monogram: RomanNumerals.toRoman(_selectedLevel),
                          finish: _sealFinish,
                        ),
                        const SizedBox(height: 14),
                        const Text('MASTERED', style: VellumTheme.headerDateStyle),
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

  static const TextStyle _typedStyle = TextStyle(
    color: VellumTheme.ink,
    shadows: VellumTheme.inkBleed,
  );
  static const TextStyle _currentStyle = TextStyle(
    color: VellumTheme.ink,
    decoration: TextDecoration.underline,
    decorationColor: VellumTheme.ink,
    decorationThickness: 2,
  );
  static const TextStyle _ghostStyle = TextStyle(color: VellumTheme.inkGhost);

  Widget _buildMaskedDisplay() {
    final spans = <TextSpan>[];
    final original = widget.poem.originalText;
    final buffer = StringBuffer();
    TextStyle? runStyle;

    // Merge consecutive glyphs of the same state into one run.
    void flush() {
      if (buffer.isEmpty) return;
      spans.add(TextSpan(text: buffer.toString(), style: runStyle));
      buffer.clear();
    }

    for (int i = 0; i < original.length; i++) {
      final isTyped = i < _charIndex;
      final isCurrent = i == _charIndex;
      final maskedChar = i < _maskedChars.length ? _maskedChars[i] : null;

      String displayChar;
      if (isTyped) {
        displayChar = original[i];
      } else if (_isHintActive) {
        displayChar = original[i];
      } else if (maskedChar != null) {
        displayChar = maskedChar.displayGlyph;
      } else {
        displayChar = original[i];
      }

      final style = isTyped
          ? _typedStyle
          : isCurrent
              ? _currentStyle
              : _ghostStyle;
      if (!identical(style, runStyle)) {
        flush();
        runStyle = style;
      }
      buffer.write(displayChar);
    }
    flush();

    return SelectableText.rich(
      TextSpan(children: spans, style: VellumTheme.verseStyle),
      textAlign: TextAlign.center,
    );
  }
}
