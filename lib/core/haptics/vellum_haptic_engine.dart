import 'package:flutter/services.dart';

/// Haptic feedback controller designed for subtle typewriter impulses.
/// Integrates with native iOS CoreHaptics via MethodChannel with system fallbacks.
class VellumHapticEngine {
  static const MethodChannel _channel = MethodChannel('com.vellum.haptics/core');
  static bool enabled = true;

  /// Lightweight transient tap for normal character press
  static Future<void> keyClick({double intensity = 0.6, double sharpness = 0.5}) async {
    if (!enabled) return;
    try {
      await _channel.invokeMethod('triggerKeyTap', {
        'intensity': intensity,
        'sharpness': sharpness,
      });
    } catch (_) {
      HapticFeedback.selectionClick();
    }
  }

  /// Medium impact on line or stanza completion
  static Future<void> stanzaCompleted() async {
    if (!enabled) return;
    try {
      await _channel.invokeMethod('triggerKeyTap', {
        'intensity': 0.85,
        'sharpness': 0.6,
      });
    } catch (_) {
      HapticFeedback.mediumImpact();
    }
  }

  /// Heavy physical feedback when pressing the wax seal stamp
  static Future<void> waxSealStamp() async {
    if (!enabled) return;
    try {
      await _channel.invokeMethod('triggerWaxStamp');
    } catch (_) {
      HapticFeedback.heavyImpact();
    }
  }

  /// Double micro-vibration on typo/mistake
  static Future<void> doubleMistakePulse() async {
    if (!enabled) return;
    try {
      await _channel.invokeMethod('triggerErrorShake');
    } catch (_) {
      HapticFeedback.selectionClick();
      await Future.delayed(const Duration(milliseconds: 40));
      HapticFeedback.selectionClick();
    }
  }
}
