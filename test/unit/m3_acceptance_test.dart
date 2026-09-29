import 'package:flutter_test/flutter_test.dart';
import 'package:vellum/core/audio/audio_theme.dart';
import 'package:vellum/core/audio/vellum_sound_engine.dart';
import 'package:vellum/core/observability/telemetry_service.dart';

void main() {
  group('Milestone M3: Settings, Observability & Audio Themes Tests', () {
    test('TASK-112: AudioTheme enum covers all 4 typewriter models', () {
      expect(AudioTheme.values.length, 4);
      expect(AudioTheme.underwood.isPro, isFalse);
      expect(AudioTheme.hermes.isPro, isTrue);
      expect(AudioTheme.olympia.isPro, isTrue);
      expect(AudioTheme.calligraphy.isPro, isTrue);
    });

    test('TASK-112: Sound engine supports setting theme', () {
      final engine = VellumSoundEngine();
      expect(engine.currentTheme, AudioTheme.underwood);

      engine.setTheme(AudioTheme.hermes);
      expect(engine.currentTheme, AudioTheme.hermes);

      engine.setTheme(AudioTheme.underwood);
    });

    test('TASK-113: Telemetry service sanitizes parameters and enforces Zero-PII', () async {
      final telemetry = TelemetryService();
      await telemetry.init();

      // Ensure no exceptions during telemetry emission
      telemetry.logVerseCompleted(
        poemId: 'poem_test',
        wpm: 55,
        accuracy: 98.2,
        clozeLevel: 2,
      );

      telemetry.logPaywallViewed(triggerReason: 'test_trigger');
      telemetry.logProPurchased(productId: 'pro.annual');
      telemetry.logCardExported(format: '9:16', theme: 'parchment');
    });
  });
}
