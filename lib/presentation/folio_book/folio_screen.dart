import 'package:flutter/material.dart';
import '../../core/billing/vellum_billing_service.dart';
import '../../core/theme/vellum_theme.dart';
import '../../core/utils/roman_numerals.dart';
import '../../data/models/poem.dart';
import '../../data/models/user_folio_entry.dart';
import '../../data/repositories/poem_repository.dart';
import '../widgets/parchment_background.dart';
import '../widgets/wax_seal_widget.dart';
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
      appBar: AppBar(
        title: Text('МОЙ ФОЛИАНТ', style: VellumTheme.headerDateStyle),
        centerTitle: true,
        actions: [
          // Pro Status / Upgrade Badge
          TextButton.icon(
            icon: Icon(
              Icons.stars,
              size: 16,
              color: isPro ? VellumTheme.antiqueGold : VellumTheme.inkSecondary,
            ),
            label: Text(
              isPro ? 'PRO' : '$count / 15',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isPro ? VellumTheme.antiqueGold : VellumTheme.inkSecondary,
              ),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const VellumProDialog(),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ),
      body: ParchmentBackground(
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Поиск по автору или названию...',
                  prefixIcon: const Icon(Icons.search, size: 18, color: VellumTheme.inkSecondary),
                  filled: true,
                  fillColor: VellumTheme.parchmentSurface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: VellumTheme.antiqueGold.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: VellumTheme.antiqueGold.withOpacity(0.3)),
                  ),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),

            // Folio Card List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: VellumTheme.antiqueGold))
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

  /// Pressed bookplate card design with antique gold spine (TASK-109)
  Widget _buildPressedBookplateCard(Poem poem, UserFolioEntry entry) {
    final sealColor = entry.waxSealColor == 'antique_gold'
        ? VellumTheme.antiqueGold
        : VellumTheme.waxCrimson;

    final dateStr = '${entry.masteredAt.day}.${entry.masteredAt.month}.${entry.masteredAt.year}';

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
          // Antique Gold Book Spine on the left edge
          border: const Border(
            left: BorderSide(color: VellumTheme.antiqueGold, width: 4.5),
            top: BorderSide(color: Color(0x22C29B38)),
            right: BorderSide(color: Color(0x22C29B38)),
            bottom: BorderSide(color: Color(0x22C29B38)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
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
                  Text(
                    '${poem.author}, ${poem.year}',
                    style: VellumTheme.poemAuthorStyle.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Заучено: $dateStr',
                        style: const TextStyle(fontSize: 11, color: VellumTheme.inkSecondary),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Точность: ${entry.bestAccuracy.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 11, color: VellumTheme.inkSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: VellumTheme.inkSecondary),
          ],
        ),
      ),
    );
  }
}
