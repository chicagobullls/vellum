import 'package:flutter/material.dart';
import '../../core/billing/vellum_billing_service.dart';
import '../../core/theme/vellum_theme.dart';
import '../../core/utils/roman_numerals.dart';
import '../../data/models/poem.dart';
import '../../data/models/user_folio_entry.dart';
import '../../data/repositories/poem_repository.dart';
import '../widgets/vellum_app_bar.dart';
import '../widgets/seal_widget.dart';
import '../widgets/soft_surface.dart';
import '../widgets/typewriter_paper_background.dart';
import '../memory_practice/cloze_practice_screen.dart';
import '../paywall/vellum_pro_dialog.dart';

class FolioScreen extends StatefulWidget {
  final PoemRepository repository;
  const FolioScreen({super.key, required this.repository});

  @override
  State<FolioScreen> createState() => _FolioScreenState();
}

class _FolioScreenState extends State<FolioScreen> {
  final VellumBillingService _billing = VellumBillingService();
  List<Poem> _allPoems = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _billing.init();
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
    final isPro = _billing.isPro;
    final count = entries.length;

    final filteredEntries = entries.where((entry) {
      if (_searchQuery.isEmpty) return true;
      final poem = _allPoems.firstWhere(
        (p) => p.id == entry.poemId,
        orElse: () => _allPoems.first,
      );
      final q = _searchQuery.toLowerCase();
      return poem.title.toLowerCase().contains(q) ||
          poem.author.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: VellumAppBar(
        title: 'МОЙ ФОЛИАНТ',
        actions: [
          // Pro Status / Upgrade Badge
          Center(
            child: SoftSurface(
              tone: isPro ? SurfaceTone.ink : SurfaceTone.paper,
              radius: null,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              onTap: () {
                showSoftDialog(
                  context: context,
                  builder: (_) => const VellumProDialog(),
                ).then((_) => setState(() {}));
              },
              child: Text(
                isPro ? 'PRO' : '$count / 15',
                style: VellumTheme.labelStyle.copyWith(
                  color: isPro ? VellumTheme.paperHighlight : VellumTheme.ink,
                ),
              ),
            ),
          ),
        ],
      ),
      body: TypewriterPaperBackground(
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: SoftSurface(
                radius: null,
                elevated: false,
                padding: EdgeInsets.zero,
                child: TextField(
                  style: const TextStyle(fontSize: 13, color: VellumTheme.ink),
                  decoration: const InputDecoration(
                    hintText: 'Поиск по автору или названию...',
                    hintStyle: TextStyle(fontSize: 13, color: VellumTheme.inkSecondary),
                    prefixIcon: Icon(Icons.search, size: 18, color: VellumTheme.inkSecondary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
            ),

            // Folio Card List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 1.5))
                  : filteredEntries.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          itemCount: filteredEntries.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final entry = filteredEntries[index];
                            final poem = _allPoems.firstWhere(
                              (p) => p.id == entry.poemId,
                              orElse: () => _allPoems.first,
                            );
                            return _buildPressedBookplateCard(poem, entry);
                          },
                        ),
            ),
          ],
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
            const Icon(Icons.auto_stories_outlined, size: 48, color: VellumTheme.inkSecondary),
            const SizedBox(height: 18),
            Text(
              'ФОЛИАНТ ПОКА ЧИСТ',
              style: VellumTheme.poemTitleStyle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text(
              'Завершите свой первый стих дня, чтобы скрепить его печатью в этой книге.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: VellumTheme.inkSecondary, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  /// Pressed bookplate card: a soft paper card with a ribbon-ink spine (TASK-109)
  Widget _buildPressedBookplateCard(Poem poem, UserFolioEntry entry) {
    final dateStr = '${entry.masteredAt.day}.${entry.masteredAt.month}.${entry.masteredAt.year}';

    return SoftSurface(
      padding: EdgeInsets.zero,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ClozePracticeScreen(poem: poem, repository: widget.repository),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ribbon-ink book spine along the left edge, set inside the card
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 14, 0, 14),
                child: Container(
                  width: 4.5,
                  decoration: BoxDecoration(
                    gradient: VellumTheme.inkSpine,
                    borderRadius: BorderRadius.circular(2.25),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 16, 16),
                  child: Row(
                    children: [
                      SealWidget(
                        size: 52,
                        monogram: RomanNumerals.toRoman(entry.maxClozeLevelAchieved),
                        finish: SealFinish.fromStored(entry.waxSealColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              poem.title.toUpperCase(),
                              style: VellumTheme.poemTitleStyle.copyWith(fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${poem.author}, ${poem.year}',
                              style: VellumTheme.poemAuthorStyle.copyWith(fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ЗАУЧЕНО $dateStr  ·  ${entry.bestAccuracy.toStringAsFixed(1)}%',
                              style: VellumTheme.labelStyle.copyWith(fontSize: 10, letterSpacing: 1),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 20, color: VellumTheme.inkSecondary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
