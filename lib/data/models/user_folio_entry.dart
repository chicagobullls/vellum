/// Represents a poem mastered and bound into the user's personal leather Folio.
class UserFolioEntry {
  final String id;
  final String poemId;
  final DateTime masteredAt;
  final int maxClozeLevelAchieved; // 1 to 4
  final double bestAccuracy; // e.g. 98.5
  final int typingSpeedWpm;
  final bool isFavorite;
  final String personalNote;
  final String waxSealColor; // 'crimson', 'antique_gold', 'emerald'

  const UserFolioEntry({
    required this.id,
    required this.poemId,
    required this.masteredAt,
    required this.maxClozeLevelAchieved,
    required this.bestAccuracy,
    required this.typingSpeedWpm,
    this.isFavorite = false,
    this.personalNote = '',
    this.waxSealColor = 'crimson',
  });

  factory UserFolioEntry.fromJson(Map<String, dynamic> json) => UserFolioEntry(
        id: json['id'] as String,
        poemId: json['poem_id'] as String,
        masteredAt: DateTime.parse(json['mastered_at'] as String),
        maxClozeLevelAchieved: json['max_cloze_level'] as int? ?? 1,
        bestAccuracy: (json['best_accuracy'] as num?)?.toDouble() ?? 100.0,
        typingSpeedWpm: json['wpm'] as int? ?? 45,
        isFavorite: json['is_favorite'] as bool? ?? false,
        personalNote: json['personal_note'] as String? ?? '',
        waxSealColor: json['wax_seal_color'] as String? ?? 'crimson',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'poem_id': poemId,
        'mastered_at': masteredAt.toIso8601String(),
        'max_cloze_level': maxClozeLevelAchieved,
        'best_accuracy': bestAccuracy,
        'wpm': typingSpeedWpm,
        'is_favorite': isFavorite,
        'personal_note': personalNote,
        'wax_seal_color': waxSealColor,
      };
}
