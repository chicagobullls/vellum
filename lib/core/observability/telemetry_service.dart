import 'package:flutter/foundation.dart';

/// Zero-PII Anonymous Telemetry and Sentry Event Logger.
/// Enforces complete privacy: user keystrokes and poem texts are NEVER collected.
class TelemetryService {
  static final TelemetryService _instance = TelemetryService._internal();
  factory TelemetryService() => _instance;
  TelemetryService._internal();

  bool _initialized = false;

  Future<void> init() async {
    _initialized = true;
    logEvent('app_opened', parameters: {
      'engine': 'impeller_metal',
      'offline_ready': true,
    });
  }

  /// Logs anonymous event (compatible with TelemetryDeck Zero-PII API)
  void logEvent(String eventName, {Map<String, dynamic>? parameters}) {
    if (!_initialized) return;

    // Strict Zero-PII Guard: reject any disallowed fields
    final sanitizedParams = <String, dynamic>{};
    if (parameters != null) {
      for (final entry in parameters.entries) {
        final key = entry.key.toLowerCase();
        // Never allow keystrokes or text payloads in analytics
        if (key.contains('text') || key.contains('key') || key.contains('user') || key.contains('input')) {
          continue;
        }
        sanitizedParams[entry.key] = entry.value;
      }
    }

    debugPrint('📊 [Telemetry Zero-PII] $eventName -> $sanitizedParams');
  }

  void logVerseCompleted({
    required String poemId,
    required int wpm,
    required double accuracy,
    required int clozeLevel,
  }) {
    logEvent('verse_completed', parameters: {
      'poem_id': poemId,
      'wpm': wpm,
      'accuracy_tier': accuracy >= 95.0 ? 'high' : 'medium',
      'cloze_level': clozeLevel,
    });
  }

  void logPaywallViewed({required String triggerReason}) {
    logEvent('paywall_viewed', parameters: {
      'trigger': triggerReason,
    });
  }

  void logProPurchased({required String productId}) {
    logEvent('pro_purchased', parameters: {
      'product_id': productId,
    });
  }

  void logCardExported({required String format, required String theme}) {
    logEvent('card_exported', parameters: {
      'format': format,
      'theme': theme,
    });
  }
}
