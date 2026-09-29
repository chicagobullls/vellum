import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/audio/vellum_sound_engine.dart';
import '../../core/haptics/vellum_haptic_engine.dart';
import '../../core/theme/vellum_theme.dart';
import '../../data/models/poem.dart';

/// Interactive Ghost Typing kinetic verse widget with 22% ghost opacity,
/// ink bleed animation, horizontal micro-shake on mistakes, and vertical auto-centering.
class GhostTypingWidget extends StatefulWidget {
  final Poem poem;
  final Function(int charIndex, int mistakes, bool isCompleted) onProgress;
  final VoidCallback onCompleted;

  const GhostTypingWidget({
    super.key,
    required this.poem,
    required this.onProgress,
    required this.onCompleted,
  });

  @override
  State<GhostTypingWidget> createState() => _GhostTypingWidgetState();
}

class _GhostTypingWidgetState extends State<GhostTypingWidget>
    with SingleTickerProviderStateMixin {
  final VellumSoundEngine _sound = VellumSoundEngine();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  int _charIndex = 0;
  int _mistakes = 0;
  bool _isCompleted = false;

  // Exact 22% opacity token from PRD FR-02 & TASK-105
  static const Color ghostInkColor = Color(0x381A1816);
  static const Color activeInkColor = Color(0xFF1A1816);

  @override
  void initState() {
    super.initState();
    _sound.init();

    // 110ms micro-shake animation controller with 3px amplitude
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 3.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reverse();
      }
    });
  }

  void _processInput(String input) {
    if (_isCompleted || input.isEmpty) return;
    final original = widget.poem.originalText;
    if (_charIndex >= original.length) return;

    final expectedChar = original[_charIndex];
    final typedChar = input[input.length - 1];
    _controller.clear();

    if (typedChar.toLowerCase() == expectedChar.toLowerCase()) {
      // Correct keystroke
      _sound.playKeystroke();
      VellumHapticEngine.keyClick();

      setState(() {
        _charIndex++;

        // Auto advance over whitespace or newlines
        while (_charIndex < original.length &&
            (original[_charIndex] == ' ' || original[_charIndex] == '\n')) {
          if (original[_charIndex] == '\n') {
            // End of line / stanza: brass bell ding & medium haptic
            _sound.playBellDing();
            VellumHapticEngine.stanzaCompleted();
          } else if (original[_charIndex] == ' ') {
            _sound.playSpace();
          }
          _charIndex++;
        }

        // Auto-center scrolling to keep typing cursor centered
        _autoCenterScroll();

        if (_charIndex >= original.length) {
          _isCompleted = true;
          _sound.playBellDing();
          _sound.playWaxSealStamp();
          VellumHapticEngine.waxSealStamp();
          widget.onCompleted();
        }
      });

      widget.onProgress(_charIndex, _mistakes, _isCompleted);
    } else {
      // Mistake: trigger 3px horizontal micro-shake, jammed sound, double vibration
      _mistakes++;
      _shakeController.forward(from: 0.0);
      _sound.playJammedKey();
      VellumHapticEngine.doubleMistakePulse();

      widget.onProgress(_charIndex, _mistakes, _isCompleted);
    }
  }

  void _autoCenterScroll() {
    if (!_scrollController.hasClients) return;
    final totalLen = widget.poem.originalText.length;
    if (totalLen == 0) return;
    final ratio = _charIndex / totalLen;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final targetOffset = maxScroll * ratio;

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _focusNode.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).requestFocus(_focusNode),
      child: Stack(
        children: [
          // Auto-centering scrollable verse
          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              // Horizontal sinusoidal micro-shake offset
              final shakeOffset = sin(_shakeController.value * pi * 4) * 3.0;
              return Transform.translate(
                offset: Offset(shakeOffset, 0),
                child: child,
              );
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: _buildRichKineticVerse(),
            ),
          ),

          // Hidden input field with Apple QuickType autocorrection disabled
          Offstage(
            offstage: true,
            child: TextField(
              focusNode: _focusNode,
              controller: _controller,
              autofocus: true,
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.none,
              spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
              onChanged: _processInput,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRichKineticVerse() {
    final original = widget.poem.originalText;
    final spans = <TextSpan>[];

    for (int i = 0; i < original.length; i++) {
      final char = original[i];
      final isTyped = i < _charIndex;
      final isCurrent = i == _charIndex;

      spans.add(
        TextSpan(
          text: char,
          style: TextStyle(
            color: isTyped
                ? activeInkColor
                : isCurrent
                    ? VellumTheme.antiqueGold
                    : ghostInkColor,
            fontWeight: isTyped || isCurrent ? FontWeight.w600 : FontWeight.normal,
            backgroundColor: isCurrent ? VellumTheme.antiqueGoldMuted : null,
          ),
        ),
      );
    }

    return Center(
      child: SelectableText.rich(
        TextSpan(children: spans, style: VellumTheme.verseStyle),
        textAlign: TextAlign.center,
      ),
    );
  }
}
