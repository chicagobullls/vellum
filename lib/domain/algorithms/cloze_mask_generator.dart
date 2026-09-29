/// Character state in a masked verse line.
class MaskedChar {
  final String char;
  final bool isVisibleHint;
  final bool isPunctuationOrSpace;
  final bool isTemporarilyRevealed;

  const MaskedChar({
    required this.char,
    required this.isVisibleHint,
    required this.isPunctuationOrSpace,
    this.isTemporarilyRevealed = false,
  });

  /// Displays either the actual character hint or a ghost dotted underline
  String get displayGlyph {
    if (isPunctuationOrSpace || isVisibleHint || isTemporarilyRevealed) {
      return char;
    }
    return '·';
  }

  MaskedChar copyWith({bool? isTemporarilyRevealed}) => MaskedChar(
        char: char,
        isVisibleHint: isVisibleHint,
        isPunctuationOrSpace: isPunctuationOrSpace,
        isTemporarilyRevealed: isTemporarilyRevealed ?? this.isTemporarilyRevealed,
      );
}

/// Algorithm that generates 4 progressive Cloze-deletion memorization levels.
class ClozeMaskGenerator {
  static const Set<String> commonShortParticlesRu = {
    'в', 'на', 'с', 'со', 'к', 'ко', 'у', 'о', 'об', 'обо', 'от', 'до', 'из', 'за',
    'по', 'под', 'над', 'и', 'а', 'но', 'да', 'бы', 'ли', 'же', 'не', 'ни', 'то'
  };

  static const Set<String> commonShortParticlesEn = {
    'in', 'on', 'at', 'to', 'for', 'of', 'with', 'by', 'as', 'and', 'but', 'or',
    'nor', 'so', 'yet', 'the', 'a', 'an', 'is', 'it'
  };

  static bool isPunctuationOrSpace(String char) {
    return RegExp(r'[ \t\n\r.,!?;:—\-–"«»’‘()…—]').hasMatch(char);
  }

  static bool isStructuralParticle(String word) {
    final cleanWord = word.toLowerCase().replaceAll(RegExp(r'[.,!?;:—\-–"«»’‘()…]'), '');
    return commonShortParticlesRu.contains(cleanWord) ||
        commonShortParticlesEn.contains(cleanWord);
  }

  /// Generates masked characters for a text at a given Cloze Level (1..4)
  static List<MaskedChar> generateLineMask(String text, int level) {
    final result = <MaskedChar>[];
    final words = text.split(' ');

    switch (level) {
      case 1:
        // Level 1: Full Ghost Typing (100% visible ghost hints)
        for (int i = 0; i < text.length; i++) {
          final c = text[i];
          result.add(MaskedChar(
            char: c,
            isVisibleHint: true,
            isPunctuationOrSpace: isPunctuationOrSpace(c),
          ));
        }
        break;

      case 2:
        // Level 2: 30% of significant words masked (preserves grammatical particles & prepositions)
        for (int wIdx = 0; wIdx < words.length; wIdx++) {
          final word = words[wIdx];
          final isParticle = isStructuralParticle(word);
          // Mask every 3rd word unless it is a short structural particle
          final shouldMask = !isParticle && (wIdx % 3 == 1);

          for (int cIdx = 0; cIdx < word.length; cIdx++) {
            final c = word[cIdx];
            final isPunct = isPunctuationOrSpace(c);
            result.add(MaskedChar(
              char: c,
              isVisibleHint: !shouldMask || isPunct,
              isPunctuationOrSpace: isPunct,
            ));
          }

          if (wIdx < words.length - 1) {
            result.add(const MaskedChar(
              char: ' ',
              isVisibleHint: true,
              isPunctuationOrSpace: true,
            ));
          }
        }
        break;

      case 3:
        // Level 3: 50% Cloze Deletion (alternating words masked, keeping first letter hint)
        for (int wIdx = 0; wIdx < words.length; wIdx++) {
          final word = words[wIdx];
          final shouldMask = (wIdx % 2 == 1);

          for (int cIdx = 0; cIdx < word.length; cIdx++) {
            final c = word[cIdx];
            final isPunct = isPunctuationOrSpace(c);
            final isFirstLetter = (cIdx == 0);

            final visible = !shouldMask || isFirstLetter || isPunct;
            result.add(MaskedChar(
              char: c,
              isVisibleHint: visible,
              isPunctuationOrSpace: isPunct,
            ));
          }

          if (wIdx < words.length - 1) {
            result.add(const MaskedChar(
              char: ' ',
              isVisibleHint: true,
              isPunctuationOrSpace: true,
            ));
          }
        }
        break;

      case 4:
      default:
        // Level 4: Pure Memory / The Void (Only spaces and punctuation visible)
        for (int i = 0; i < text.length; i++) {
          final c = text[i];
          final isPunct = isPunctuationOrSpace(c);
          result.add(MaskedChar(
            char: c,
            isVisibleHint: isPunct,
            isPunctuationOrSpace: isPunct,
          ));
        }
        break;
    }

    return result;
  }
}
