/// Telemetry and transient state during a kinetic typing session.
class TypingSession {
  final String poemId;
  final int clozeLevel;
  final DateTime startTime;
  DateTime? endTime;
  int correctKeystrokes = 0;
  int mistakeKeystrokes = 0;

  TypingSession({
    required this.poemId,
    required this.clozeLevel,
    required this.startTime,
  });

  void recordKeystroke({required bool isCorrect}) {
    if (isCorrect) {
      correctKeystrokes++;
    } else {
      mistakeKeystrokes++;
    }
  }

  void complete() {
    endTime = DateTime.now();
  }

  double get accuracy {
    final total = correctKeystrokes + mistakeKeystrokes;
    if (total == 0) return 100.0;
    return (correctKeystrokes / total) * 100.0;
  }

  int get wpm {
    final end = endTime ?? DateTime.now();
    final elapsedMinutes = end.difference(startTime).inSeconds / 60.0;
    if (elapsedMinutes <= 0.05) return 0;
    final words = correctKeystrokes / 5.0; // Standard definition: 5 characters per word
    return (words / elapsedMinutes).round();
  }
}
