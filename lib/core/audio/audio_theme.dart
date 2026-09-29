/// Typewriter audio themes for Vellum
enum AudioTheme {
  underwood(
    id: 'underwood',
    title: 'Underwood No. 5 (1920)',
    description: 'Глубокий механический удар и чугунный резонанс',
    isPro: false,
    assetKey: 'audio/typewriter_key.wav',
  ),
  hermes(
    id: 'hermes',
    title: 'Hermes 3000 (1958)',
    description: 'Швейцарская точность, приглушенный мягкий щелчок',
    isPro: true,
    assetKey: 'audio/typewriter_key.wav',
  ),
  olympia(
    id: 'olympia',
    title: 'Olympia Splendid (1960)',
    description: 'Звонкий металлический щелчок портативной машинки',
    isPro: true,
    assetKey: 'audio/typewriter_key.wav',
  ),
  calligraphy(
    id: 'calligraphy',
    title: 'Калиграфическое перо',
    description: 'Мягкий шелест гусиного пера по пергаменту',
    isPro: true,
    assetKey: 'audio/typewriter_space.wav',
  );

  final String id;
  final String title;
  final String description;
  final bool isPro;
  final String assetKey;

  const AudioTheme({
    required this.id,
    required this.title,
    required this.description,
    required this.isPro,
    required this.assetKey,
  });
}
