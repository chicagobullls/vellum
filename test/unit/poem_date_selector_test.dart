import 'package:flutter_test/flutter_test.dart';
import 'package:vellum/core/utils/poem_date_selector.dart';
import 'package:vellum/data/models/poem.dart';

void main() {
  group('PoemDateSelector Determinism Tests', () {
    final samplePoems = [
      const Poem(
        id: 'p1',
        title: 'Poem 1',
        author: 'Author A',
        year: 1800,
        language: 'ru',
        meter: 'Ямб',
        difficulty: 1,
        tags: [],
        isPublicDomain: true,
        originalText: 'Sample text 1',
        stanzas: [],
      ),
      const Poem(
        id: 'p2',
        title: 'Poem 2',
        author: 'Author B',
        year: 1820,
        language: 'ru',
        meter: 'Хорей',
        difficulty: 2,
        tags: [],
        isPublicDomain: true,
        originalText: 'Sample text 2',
        stanzas: [],
      ),
    ];

    test('Returns exact same poem for identical calendar date across different runs', () {
      final dateA = DateTime(2026, 9, 29, 10, 0, 0);
      final dateB = DateTime(2026, 9, 29, 23, 59, 59);

      final poemA = PoemDateSelector.getPoemForDate(dateA, samplePoems);
      final poemB = PoemDateSelector.getPoemForDate(dateB, samplePoems);

      expect(poemA.id, poemB.id);
    });
  });
}
