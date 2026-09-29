import 'package:flutter/material.dart';
import '../../core/theme/vellum_theme.dart';
import '../widgets/wax_seal_widget.dart';

class VellumProDialog extends StatelessWidget {
  const VellumProDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: VellumTheme.parchmentLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: VellumTheme.antiqueGold, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const WaxSealWidget(
              size: 68,
              monogram: '★',
              color: VellumTheme.antiqueGold,
            ),
            const SizedBox(height: 16),
            Text(
              'VELLUM PRO',
              style: VellumTheme.poemTitleStyle.copyWith(letterSpacing: 2),
            ),
            const SizedBox(height: 6),
            const Text(
              'Неограниченная сокровищница поэзии',
              textAlign: TextAlign.center,
              style: TextStyle(color: VellumTheme.inkSecondary),
            ),
            const SizedBox(height: 20),
            _buildFeatureRow(Icons.all_inclusive, 'Безлимитный Фолиант (более 15 стихов)'),
            _buildFeatureRow(Icons.psychology, 'Сложные уровни памяти (Cloze III и IV)'),
            _buildFeatureRow(Icons.palette_outlined, 'Эксклюзивные золотые и изумрудные печати'),
            _buildFeatureRow(Icons.music_note, 'Коллекция звуков старинных машинок'),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: VellumTheme.antiqueGold,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('ГОДОВОЙ ДОСТУП — 1 490 ₽ / ГОД', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Восстановить покупки', style: TextStyle(fontSize: 12, color: VellumTheme.inkSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: VellumTheme.antiqueGold),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: VellumTheme.inkPrimary))),
        ],
      ),
    );
  }
}
