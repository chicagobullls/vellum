import '../../data/models/poem.dart';

/// Deterministic hash-based selector ensuring every user on Earth
/// receives the exact same Poem of the Day for any calendar day.
class PoemDateSelector {
  static Poem getPoemForDate(DateTime date, List<Poem> poems) {
    if (poems.isEmpty) {
      throw ArgumentError('Poem list cannot be empty');
    }
    // Calculate a stable deterministic day number based on UTC epoch day
    final utcDate = DateTime.utc(date.year, date.month, date.day);
    final dayIndex = utcDate.millisecondsSinceEpoch ~/ (1000 * 60 * 60 * 24);
    
    // Simple LCG hash to distribute sequential days across varied poems
    final hash = (dayIndex * 2654435761) & 0x7FFFFFFF;
    final poemIndex = hash % poems.length;
    return poems[poemIndex];
  }
}
