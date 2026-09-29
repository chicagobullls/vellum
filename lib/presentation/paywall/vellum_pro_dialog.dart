import 'package:flutter/material.dart';
import '../../core/billing/vellum_billing_service.dart';
import '../../core/theme/vellum_theme.dart';
import '../widgets/wax_seal_widget.dart';

/// Dignified Victorian Dark Academia Paywall Modal (SCR-05).
class VellumProDialog extends StatefulWidget {
  final String? triggerReason;
  const VellumProDialog({super.key, this.triggerReason});

  @override
  State<VellumProDialog> createState() => _VellumProDialogState();
}

class _VellumProDialogState extends State<VellumProDialog> {
  final VellumBillingService _billing = VellumBillingService();
  VellumProduct _selectedProduct = VellumProduct.annual;
  bool _isProcessing = false;

  Future<void> _handlePurchase() async {
    setState(() => _isProcessing = true);
    final success = await _billing.purchaseProduct(_selectedProduct);
    setState(() => _isProcessing = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: VellumTheme.antiqueGold,
            content: Text(
              '⚜️ Добро пожаловать в Vellum Pro! Все сокровищницы открыты.',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isProcessing = true);
    final restored = await _billing.restorePurchases();
    setState(() => _isProcessing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            restored && _billing.isPro
                ? '✅ Подписка Vellum Pro успешно восстановлена.'
                : 'Покупок для восстановления не найдено.',
          ),
        ),
      );
      if (_billing.isPro) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: VellumTheme.parchmentLight,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: VellumTheme.antiqueGold, width: 1.5),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const WaxSealWidget(
              size: 72,
              monogram: '★',
              color: VellumTheme.antiqueGold,
            ),
            const SizedBox(height: 14),
            Text(
              'VELLUM PRO',
              style: VellumTheme.poemTitleStyle.copyWith(
                letterSpacing: 2.5,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.triggerReason ?? 'Неограниченная сокровищница поэзии',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: VellumTheme.inkSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),

            // Feature Checklist
            _buildFeatureRow(Icons.all_inclusive, 'Безлимитный Фолиант (более 15 стихов)'),
            _buildFeatureRow(Icons.psychology_outlined, 'Сложные уровни памяти (Cloze III и IV)'),
            _buildFeatureRow(Icons.palette_outlined, 'Эксклюзивные золотые и изумрудные сургучи'),
            _buildFeatureRow(Icons.music_note_outlined, '4 темы старинных печатных машинок'),
            _buildFeatureRow(Icons.hd_outlined, 'Экспорт карточек в Ultra-HD 4K без знака'),

            const SizedBox(height: 20),

            // Product selection cards
            ...VellumProduct.values.map((prod) {
              final isSelected = _selectedProduct == prod;
              final isAnnual = prod == VellumProduct.annual;

              return GestureDetector(
                onTap: () => setState(() => _selectedProduct = prod),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? VellumTheme.parchmentSurface : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? VellumTheme.antiqueGold : VellumTheme.parchmentSurface,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? VellumTheme.antiqueGold : VellumTheme.inkSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  prod.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: VellumTheme.inkPrimary,
                                  ),
                                ),
                                if (isAnnual) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: VellumTheme.antiqueGold,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'ВЫГОДНО -44%',
                                      style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              prod.priceString,
                              style: const TextStyle(fontSize: 11, color: VellumTheme.inkSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Primary Action Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: VellumTheme.antiqueGold,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _isProcessing ? null : _handlePurchase,
              child: _isProcessing
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      'АКТИВИРОВАТЬ (${_selectedProduct.priceString.split(' ')[0]})',
                      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: _handleRestore,
                  child: const Text(
                    'Восстановить покупки',
                    style: TextStyle(fontSize: 11, color: VellumTheme.inkSecondary),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Позже',
                    style: TextStyle(fontSize: 11, color: VellumTheme.inkSecondary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: VellumTheme.antiqueGold),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12, color: VellumTheme.inkPrimary)),
          ),
        ],
      ),
    );
  }
}
