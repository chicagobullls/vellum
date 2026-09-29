import 'package:flutter_test/flutter_test.dart';
import 'package:vellum/core/billing/vellum_billing_service.dart';

void main() {
  group('Milestone M2: Feature Gating & Billing Acceptance Tests', () {
    late VellumBillingService billing;

    setUp(() {
      billing = VellumBillingService();
    });

    test('TASK-111: Free tier allows up to 15 poems in Folio, gates 16th', () async {
      await billing.setProStatusForTesting(false);
      expect(billing.isPro, isFalse);

      expect(billing.canSaveToFolio(0), isTrue);
      expect(billing.canSaveToFolio(14), isTrue);
      expect(billing.canSaveToFolio(15), isFalse, reason: '16th poem (index 15) must trigger paywall on Free tier');
    });

    test('TASK-111: Pro tier allows unlimited poems in Folio', () async {
      await billing.setProStatusForTesting(true);
      expect(billing.isPro, isTrue);

      expect(billing.canSaveToFolio(15), isTrue);
      expect(billing.canSaveToFolio(100), isTrue);
      expect(billing.canSaveToFolio(500), isTrue);
    });

    test('TASK-111: Cloze levels 1 & 2 are free, levels 3 & 4 require Pro', () async {
      await billing.setProStatusForTesting(false);
      expect(billing.isClozeLevelUnlocked(1), isTrue);
      expect(billing.isClozeLevelUnlocked(2), isTrue);
      expect(billing.isClozeLevelUnlocked(3), isFalse, reason: 'Level 3 must be gated for Free users');
      expect(billing.isClozeLevelUnlocked(4), isFalse, reason: 'Level 4 must be gated for Free users');

      await billing.setProStatusForTesting(true);
      expect(billing.isClozeLevelUnlocked(3), isTrue);
      expect(billing.isClozeLevelUnlocked(4), isTrue);
    });

    test('TASK-111: StoreKit products definitions integrity', () {
      expect(VellumProduct.monthly.id, 'pro.monthly');
      expect(VellumProduct.annual.id, 'pro.annual');
      expect(VellumProduct.lifetime.id, 'patron.lifetime');
    });
  });
}
