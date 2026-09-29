import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// StoreKit 2 and In-App Purchase product definition.
enum VellumProduct {
  monthly(id: 'pro.monthly', priceString: '\$2.99 / мес', title: 'Vellum Pro Monthly'),
  annual(id: 'pro.annual', priceString: '\$19.99 / год (3 дня триал)', title: 'Vellum Pro Annual'),
  lifetime(id: 'patron.lifetime', priceString: '\$49.99 единоразово', title: 'Vellum Patron Lifetime');

  final String id;
  final String priceString;
  final String title;

  const VellumProduct({
    required this.id,
    required this.priceString,
    required this.title,
  });
}

/// Service managing Feature Gating (GATE-01..GATE-06) and StoreKit 2 entitlements.
class VellumBillingService {
  static final VellumBillingService _instance = VellumBillingService._internal();
  factory VellumBillingService() => _instance;
  VellumBillingService._internal();

  static const String _kProStatusKey = 'vellum_entitlement_pro_active';
  static const int kFreeFolioMaxLimit = 15;

  bool _isPro = false;
  bool get isPro => _isPro;

  final ValueNotifier<bool> proStatusNotifier = ValueNotifier<bool>(false);

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPro = prefs.getBool(_kProStatusKey) ?? false;
      proStatusNotifier.value = _isPro;
    } catch (e) {
      debugPrint('Billing initialization error: $e');
    }
  }

  /// Feature Gating GATE-04: Free users are limited to 15 saved poems in Folio
  bool canSaveToFolio(int currentCount) {
    if (_isPro) return true;
    return currentCount < kFreeFolioMaxLimit;
  }

  /// Feature Gating GATE-03: Levels 3 & 4 (Cloze 50% and The Void) require Pro
  bool isClozeLevelUnlocked(int level) {
    if (_isPro) return true;
    return level <= 2;
  }

  /// Simulates StoreKit 2 purchase
  Future<bool> purchaseProduct(VellumProduct product) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPro = true;
      await prefs.setBool(_kProStatusKey, true);
      proStatusNotifier.value = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Restores previous App Store purchases
  Future<bool> restorePurchases() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPro = prefs.getBool(_kProStatusKey) ?? false;
      proStatusNotifier.value = _isPro;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// For testing and resets
  Future<void> setProStatusForTesting(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    _isPro = status;
    await prefs.setBool(_kProStatusKey, status);
    proStatusNotifier.value = status;
  }
}
