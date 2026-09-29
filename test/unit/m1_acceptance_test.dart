import 'package:flutter_test/flutter_test.dart';
import 'package:vellum/core/utils/poem_date_selector.dart';
import 'package:vellum/domain/algorithms/cloze_mask_generator.dart';
import 'package:vellum/data/models/poem.dart';

void main() {
  group('Milestone M1 Unit & Acceptance Tests', () {
    final samplePoems = [
      const Poem(
        id: 'p_ru_1',
        title: 'Я вас любил',
        author: 'Пушкин',
        year: 1829,
        language: 'ru',
        meter: 'Ямб',
        difficulty: 1,
        tags: [],
        isPublicDomain: true,
        originalText: 'Я вас любил: любовь еще, быть может...',
        stanzas: [['Я вас любил: любовь еще, быть может...']],
      ),
      const Poem(
        id: 'p_en_1',
        title: 'Sonnet 18',
        author: 'Shakespeare',
        year: 1609,
        language: 'en',
        meter: 'Iambic pentameter',
        difficulty: 2,
        tags: [],
        isPublicDomain: true,
        originalText: 'Shall I compare thee to a summer’s day?',
        stanzas: [['Shall I compare thee to a summer’s day?']],
      ),
    ];

    test('TASK-104: Language group filtering returns matching poem', () {
      final ruPoem = PoemDateSelector.getPoemForDate(
        DateTime(2026, 9, 29),
        samplePoems,
        language: 'ru',
      );
      expect(ruPoem.language, 'ru');

      final enPoem = PoemDateSelector.getPoemForDate(
        DateTime(2026, 9, 29),
        samplePoems,
        language: 'en',
      );
      expect(enPoem.language, 'en');
    });

    test('TASK-107: Level 2 masks significant words while preserving prepositions', () {
      const line = 'В тумане моря голубом';
      final masked = ClozeMaskGenerator.generateLineMask(line, 2);

      // 'В' is a structural preposition, must remain visible
      expect(masked[0].char, 'В');
      expect(masked[0].isVisibleHint, isTrue);
    });

    test('TASK-107: Level 3 masks alternating words keeping first letter', () {
      const line = 'Белеет парус одинокой';
      final masked = ClozeMaskGenerator.generateLineMask(line, 3);
      expect(masked.length, line.length);

      // First letter of word 2 ('парус' -> 'п') is visible as hint
      final pIndex = line.indexOf('парус');
      expect(masked[pIndex].char, 'п');
      expect(masked[pIndex].isVisibleHint, isTrue);

      // Second letter of word 2 ('а') is masked
      expect(masked[pIndex + 1].char, 'а');
      expect(masked[pIndex + 1].isVisibleHint, isFalse);
      expect(masked[pIndex + 1].displayGlyph, '·');
    });

    test('TASK-107: Level 4 hides all letters except spaces and punctuation', () {
      const line = 'Молчи, скрывайся!';
      final masked = ClozeMaskGenerator.generateLineMask(line, 4);

      expect(masked[0].displayGlyph, '·'); // 'М'
      expect(masked[5].displayGlyph, ','); // ','
      expect(masked[6].displayGlyph, ' '); // ' '
      expect(masked[16].displayGlyph, '!'); // '!'
    });
  });
}
