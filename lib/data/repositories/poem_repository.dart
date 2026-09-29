import '../models/poem.dart';
import '../models/user_folio_entry.dart';
import '../sources/poem_seed_loader.dart';

/// Repository managing poem catalogue and personal folio entries.
class PoemRepository {
  List<Poem> _cachedPoems = [];
  final List<UserFolioEntry> _folioEntries = [];

  Future<List<Poem>> getAllPoems() async {
    if (_cachedPoems.isEmpty) {
      _cachedPoems = await PoemSeedLoader.loadCuratedPoems();
    }
    return _cachedPoems;
  }

  Future<Poem?> getPoemById(String id) async {
    final poems = await getAllPoems();
    try {
      return poems.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<UserFolioEntry> getFolioEntries() {
    return List.unmodifiable(_folioEntries);
  }

  void saveMasteredVerse(UserFolioEntry entry) {
    _folioEntries.removeWhere((e) => e.poemId == entry.poemId);
    _folioEntries.insert(0, entry);
  }

  bool isMastered(String poemId) {
    return _folioEntries.any((e) => e.poemId == poemId);
  }
}
