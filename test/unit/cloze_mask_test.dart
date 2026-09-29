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

    test('Level 2: 30% words masked preserves prepositions and particles', () {
      const line = 'В душе моей угасла';
      final masked = ClozeMaskGenerator.generateLineMask(line, 2);
      expect(masked.length, line.length);

      // 'В' is a structural preposition, so it must remain visible
      expect(masked[0].char, 'В');
      expect(masked[0].isVisibleHint, isTrue);
    });

    test('Level 3: 50% Cloze Deletion masks alternating words', () {
      final masked = ClozeMaskGenerator.generateLineMask(testLineRu, 3);
      expect(masked.length, testLineRu.length);
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
