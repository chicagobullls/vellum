import 'package:flutter/material.dart';
import '../../core/billing/vellum_billing_service.dart';
import '../../core/theme/vellum_theme.dart';
import '../widgets/seal_widget.dart';
import '../widgets/soft_surface.dart';

/// Soft Paper Paywall Modal (SCR-05).
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
            content: Text('Добро пожаловать в Vellum Pro! Все сокровищницы открыты.'),
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
                ? 'Подписка Vellum Pro успешно восстановлена.'
                : 'Покупок для восстановления не найдено.',
          ),
        ),
      );
      if (_billing.isPro) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SoftDialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SealWidget(
              size: 72,
              monogram: 'V',
              finish: SealFinish.ink,
            ),
            const SizedBox(height: 16),
            Text(
              'VELLUM PRO',
              style: VellumTheme.poemTitleStyle.copyWith(letterSpacing: 4, fontSize: 22),
            ),
            const SizedBox(height: 6),
            Text(
              widget.triggerReason ?? 'Неограниченная сокровищница поэзии',
              textAlign: TextAlign.center,
              style: const TextStyle(color: VellumTheme.inkSecondary, fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 20),

            // Feature Checklist
            _buildFeatureRow(Icons.all_inclusive, 'Безлимитный Фолиант (более 15 стихов)'),
            _buildFeatureRow(Icons.psychology_outlined, 'Сложные уровни памяти (Cloze III и IV)'),
            _buildFeatureRow(Icons.palette_outlined, 'Эксклюзивные чернильные печати'),
            _buildFeatureRow(Icons.music_note_outlined, '4 темы старинных печатных машинок'),
            _buildFeatureRow(Icons.hd_outlined, 'Экспорт карточек в Ultra-HD 4K без знака'),

            const SizedBox(height: 20),

            // Product selection cards
            ...VellumProduct.values.map((prod) {
              final isSelected = _selectedProduct == prod;
              final isAnnual = prod == VellumProduct.annual;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SoftSurface(
                  elevated: isSelected,
                  radius: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  onTap: () => setState(() => _selectedProduct = prod),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? VellumTheme.ink : VellumTheme.inkSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    prod.title,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                      color: VellumTheme.ink,
                                    ),
                                  ),
                                ),
                                if (isAnnual) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: VellumTheme.ink,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      'ВЫГОДНО -44%',
                                      style: TextStyle(
                                        fontSize: 8,
                                        letterSpacing: 0.8,
                                        color: VellumTheme.paperHighlight,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(prod.priceString, style: VellumTheme.labelStyle.copyWith(letterSpacing: 0.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 14),

            // Primary Action Button
            SoftButton(
              label: 'АКТИВИРОВАТЬ (${_selectedProduct.priceString.split(' ')[0]})',
              isLoading: _isProcessing,
              onPressed: _isProcessing ? null : _handlePurchase,
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: _handleRestore,
                  child: const Text('Восстановить покупки'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Позже'),
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
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 16, color: VellumTheme.ink),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12, height: 1.4, color: VellumTheme.ink)),
          ),
        ],
      ),
    );
  }
}
