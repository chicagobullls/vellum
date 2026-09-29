import 'dart:async';
import '../../data/models/poem.dart';

/// Deterministic hash-based selector ensuring every user worldwide
/// receives the exact same Poem of the Day for any calendar day and language.
class PoemDateSelector {
  /// Deterministically picks a poem for a date and language
  static Poem getPoemForDate(
    DateTime date,
    List<Poem> poems, {
    String language = 'ru',
  }) {
    if (poems.isEmpty) {
      throw ArgumentError('Poem list cannot be empty');
    }

    // Filter by language group (RU/EN)
    final filtered = poems.where((p) => p.language.toLowerCase() == language.toLowerCase()).toList();
    final candidateList = filtered.isNotEmpty ? filtered : poems;

    // Calculate a stable deterministic day number based on UTC epoch day
    final utcDate = DateTime.utc(date.year, date.month, date.day);
    final dayIndex = utcDate.millisecondsSinceEpoch ~/ (1000 * 60 * 60 * 24);

    // Knuth multiplicative hash for uniform dispersion
    final hash = (dayIndex * 2654435761) & 0x7FFFFFFF;
    final poemIndex = hash % candidateList.length;
    return candidateList[poemIndex];
  }

  /// Calculates duration until next 00:00 midnight local time
  static Duration durationUntilMidnight(DateTime now) {
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return tomorrow.difference(now);
  }

  /// Creates a stream that triggers at every local 00:00 midnight
  static Stream<DateTime> midnightStream() async* {
    while (true) {
      final now = DateTime.now();
      final waitDuration = durationUntilMidnight(now);
      await Future.delayed(waitDuration);
      yield DateTime.now();
    }
  }
}
