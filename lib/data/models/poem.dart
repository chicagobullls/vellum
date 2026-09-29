/// Represents a curated poetry masterpiece in public domain.
class Poem {
  final String id;
  final String title;
  final String author;
  final int year;
  final String language;
  final String meter;
  final int difficulty; // 1 (Introductory), 2 (Medium), 3 (Mastery)
  final List<String> tags;
  final bool isPublicDomain;
  final String originalText;
  final List<List<String>> stanzas;

  const Poem({
    required this.id,
    required this.title,
    required this.author,
    required this.year,
    required this.language,
    required this.meter,
    required this.difficulty,
    required this.tags,
    required this.isPublicDomain,
    required this.originalText,
    required this.stanzas,
  });

  factory Poem.fromJson(Map<String, dynamic> json) {
    final rawStanzas = json['stanzas'] as List<dynamic>? ?? [];
    final stanzasList = rawStanzas
        .map((s) => (s as List<dynamic>).map((line) => line.toString()).toList())
        .toList();

    return Poem(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      year: json['year'] as int? ?? 1800,
      language: json['language'] as String? ?? 'ru',
      meter: json['meter'] as String? ?? 'Ямб',
      difficulty: json['difficulty'] as int? ?? 1,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isPublicDomain: json['is_public_domain'] as bool? ?? true,
      originalText: json['original_text'] as String? ?? '',
      stanzas: stanzasList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'year': year,
        'language': language,
        'meter': meter,
        'difficulty': difficulty,
        'tags': tags,
        'is_public_domain': isPublicDomain,
        'original_text': originalText,
        'stanzas': stanzas,
      };

  int get totalLines => stanzas.fold(0, (acc, s) => acc + s.length);
  int get totalCharacters => originalText.replaceAll(RegExp(r'\s+'), '').length;
}
