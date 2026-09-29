import 'package:flutter/material.dart';
import '../../core/theme/vellum_theme.dart';
import '../../core/utils/roman_numerals.dart';
import '../../data/models/poem.dart';
import '../../data/models/user_folio_entry.dart';
import '../../data/repositories/poem_repository.dart';
import '../widgets/parchment_background.dart';
import '../widgets/wax_seal_widget.dart';
import '../memory_practice/cloze_practice_screen.dart';

class FolioScreen extends StatefulWidget {
  final PoemRepository repository;
  const FolioScreen({super.key, required this.repository});

  @override
  State<FolioScreen> createState() => _FolioScreenState();
}

class _FolioScreenState extends State<FolioScreen> {
  List<Poem> _allPoems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final poems = await widget.repository.getAllPoems();
    if (mounted) {
      setState(() {
        _allPoems = poems;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.repository.getFolioEntries();

    return Scaffold(
      appBar: AppBar(
        title: Text('МОЙ ФОЛИАНТ (MY FOLIO)', style: VellumTheme.headerDateStyle),
        centerTitle: true,
      ),
      body: ParchmentBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: VellumTheme.antiqueGold))
            : entries.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const Divider(height: 24),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final poem = _allPoems.firstWhere(
                        (p) => p.id == entry.poemId,
                        orElse: () => _allPoems.first,
                      );
                      return _buildFolioCard(poem, entry);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_stories_outlined, size: 54, color: VellumTheme.inkSecondary),
            const SizedBox(height: 16),
            Text(
              'Фолиант пока чист',
              style: VellumTheme.poemTitleStyle.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 8),
            const Text(
              'Завершите свой первый стих дня, чтобы скрепить его сургучной печатью в этой книге.',
              textAlign: TextAlign.center,
              style: TextStyle(color: VellumTheme.inkSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFolioCard(Poem poem, UserFolioEntry entry) {
    final sealColor = entry.waxSealColor == 'antique_gold'
        ? VellumTheme.antiqueGold
        : VellumTheme.waxCrimson;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ClozePracticeScreen(poem: poem, repository: widget.repository),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: VellumTheme.parchmentSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: VellumTheme.antiqueGold.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            WaxSealWidget(
              size: 52,
              monogram: RomanNumerals.toRoman(entry.maxClozeLevelAchieved),
              color: sealColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(poem.title, style: VellumTheme.poemTitleStyle.copyWith(fontSize: 18)),
                  const SizedBox(height: 3),
                  Text(poem.author, style: VellumTheme.poemAuthorStyle.copyWith(fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Точность: ${entry.bestAccuracy.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 11, color: VellumTheme.inkSecondary),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${entry.typingSpeedWpm} WPM',
                        style: const TextStyle(fontSize: 11, color: VellumTheme.inkSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: VellumTheme.inkSecondary),
          ],
        ),
      ),
    );
  }
}
