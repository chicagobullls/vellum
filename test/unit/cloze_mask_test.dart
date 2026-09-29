import 'package:flutter_test/flutter_test.dart';
import 'package:vellum/domain/algorithms/cloze_mask_generator.dart';

void main() {
  group('ClozeMaskGenerator Unit Tests', () {
    const testLineRu = 'Я вас любил: любовь еще, быть может,';

    test('Level 1: Full Ghost keeps all characters visible as hints', () {
      final masked = ClozeMaskGenerator.generateLineMask(testLineRu, 1);
      expect(masked.length, testLineRu.length);
      for (final char in masked) {
        expect(char.isVisibleHint, isTrue);
        expect(char.displayGlyph, char.char);
      }
    });

    test('Level 2: Vowels Masked hides vowels in Russian and English', () {
      final masked = ClozeMaskGenerator.generateLineMask(testLineRu, 2);
      expect(masked.length, testLineRu.length);

      // 'Я' is a Russian vowel, so it should be masked
      expect(masked[0].char, 'Я');
      expect(masked[0].isVisibleHint, isFalse);
      expect(masked[0].displayGlyph, '·');

      // 'в' is a consonant, so it should be visible
      expect(masked[2].char, 'в');
      expect(masked[2].isVisibleHint, isTrue);
      expect(masked[2].displayGlyph, 'в');
    });

    test('Level 3: 50% Cloze Deletion masks alternating words', () {
      final masked = ClozeMaskGenerator.generateLineMask(testLineRu, 3);
      expect(masked.length, testLineRu.length);

      // First word ("Я") is not masked
      expect(masked[0].isVisibleHint, isTrue);
    });

    test('Level 4: Pure Void hides all alphabetical characters', () {
      final masked = ClozeMaskGenerator.generateLineMask(testLineRu, 4);
      for (final char in masked) {
        if (char.isPunctuationOrSpace) {
          expect(char.isVisibleHint, isTrue);
        } else {
          expect(char.isVisibleHint, isFalse);
          expect(char.displayGlyph, '·');
        }
      }
    });
  });
}
