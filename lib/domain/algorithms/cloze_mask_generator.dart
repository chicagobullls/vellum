/// Character state in a masked verse line.
class MaskedChar {
  final String char;
  final bool isVisibleHint;
  final bool isPunctuationOrSpace;

  const MaskedChar({
    required this.char,
    required this.isVisibleHint,
    required this.isPunctuationOrSpace,
  });

  /// Displays either the actual character hint or a ghost underline dot
  String get displayGlyph {
    if (isPunctuationOrSpace || isVisibleHint) {
      return char;
    }
    return '·';
  }
}

/// Algorithm that generates 4 progressive cloze-deletion memorization levels.
class ClozeMaskGenerator {
  static const String russianVowels = 'аеёиоуыэюяАЕЁИОУЫЭЮЯ';
  static const String englishVowels = 'aeiouyAEIOUY';

  static bool isVowel(String char) {
    return russianVowels.contains(char) || englishVowels.contains(char);
  }

  static bool isPunctuationOrSpace(String char) {
    return RegExp(r'[ \t\n\r.,!?;:—\-–"«»’‘()…—]').hasMatch(char);
  }

  /// Generates masked characters for a single line at a given Cloze Level (1..4)
  static List<MaskedChar> generateLineMask(String line, int level) {
    final result = <MaskedChar>[];
    final words = line.split(' ');

    switch (level) {
      case 1:
        // Level 1: Full Ghost Typing (All letters are visible in ghost ink)
        for (int i = 0; i < line.length; i++) {
          final c = line[i];
          result.add(MaskedChar(
            char: c,
            isVisibleHint: true,
            isPunctuationOrSpace: isPunctuationOrSpace(c),
          ));
        }
        break;

      case 2:
        // Level 2: Vowels Masked (Consonants & punctuation remain visible)
        for (int i = 0; i < line.length; i++) {
          final c = line[i];
          final isPunct = isPunctuationOrSpace(c);
          final isV = isVowel(c);
          result.add(MaskedChar(
            char: c,
            isVisibleHint: !isV,
            isPunctuationOrSpace: isPunct,
          ));
        }
        break;

      case 3:
        // Level 3: 50% Cloze Deletion (Every second word has only first letter visible)
        int charCursor = 0;
        for (int wIdx = 0; wIdx < words.length; wIdx++) {
          final word = words[wIdx];
          final shouldMaskWord = (wIdx % 2 == 1);

          for (int cIdx = 0; cIdx < word.length; cIdx++) {
            final c = word[cIdx];
            final isPunct = isPunctuationOrSpace(c);
            final isFirstLetter = (cIdx == 0);

            final visible = !shouldMaskWord || isFirstLetter || isPunct;
            result.add(MaskedChar(
              char: c,
              isVisibleHint: visible,
              isPunctuationOrSpace: isPunct,
            ));
            charCursor++;
          }

          // Add space between words
          if (wIdx < words.length - 1) {
            result.add(const MaskedChar(
              char: ' ',
              isVisibleHint: true,
              isPunctuationOrSpace: true,
            ));
            charCursor++;
          }
        }
        break;

      case 4:
      default:
        // Level 4: Pure Memory / The Void (Only punctuation and spaces visible)
        for (int i = 0; i < line.length; i++) {
          final c = line[i];
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
