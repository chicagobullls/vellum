import 'package:flutter/services.dart';

/// Haptic feedback controller designed for subtle typewriter impulses.
class VellumHapticEngine {
  static bool enabled = true;

  /// Lightweight transient tap for normal character press
  static void keyClick() {
    if (!enabled) return;
    HapticFeedback.selectionClick();
  }

  /// Medium impact on line or stanza completion
  static void stanzaCompleted() {
    if (!enabled) return;
    HapticFeedback.mediumImpact();
  }

  /// Heavy physical feedback when pressing the wax seal stamp
  static void waxSealStamp() {
    if (!enabled) return;
    HapticFeedback.heavyImpact();
  }

  /// Error vibration
  static void mistake() {
    if (!enabled) return;
    HapticFeedback.vibrate();
  }
}
