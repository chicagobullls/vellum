import 'package:flutter/material.dart';
import '../../core/audio/audio_theme.dart';
import '../../core/audio/vellum_sound_engine.dart';
import '../../core/billing/vellum_billing_service.dart';
import '../../core/haptics/vellum_haptic_engine.dart';
import '../../core/theme/vellum_theme.dart';
import '../widgets/vellum_app_bar.dart';
import '../widgets/soft_surface.dart';
import '../widgets/typewriter_paper_background.dart';
import '../paywall/vellum_pro_dialog.dart';

/// Settings & Sound Sanctuary Screen (SCR-06).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final VellumSoundEngine _sound = VellumSoundEngine();
  final VellumBillingService _billing = VellumBillingService();

  bool _hapticsEnabled = VellumHapticEngine.enabled;
  bool _soundEnabled = !VellumSoundEngine().isMuted;
  double _volume = VellumSoundEngine().volume;
  String _reminderTime = '09:00';

  @override
  void initState() {
    super.initState();
    _billing.init();
  }

  void _onThemeSelected(AudioTheme theme) {
    if (theme.isPro && !_billing.isPro) {
      showSoftDialog(
        context: context,
        builder: (_) => VellumProDialog(
          triggerReason: 'Тема звука «${theme.title}» доступна в Vellum Pro',
        ),
      ).then((_) => setState(() {}));
      return;
    }

    setState(() {
      _sound.setTheme(theme);
    });
    _sound.previewTheme(theme);
    VellumHapticEngine.keyClick();
  }

  @override
  Widget build(BuildContext context) {
    final isPro = _billing.isPro;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const VellumAppBar(title: 'НАСТРОЙКИ · SANCTUARY'),
      body: TypewriterPaperBackground(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Pro Membership Banner
            SoftSurface(
              tone: SurfaceTone.ink,
              radius: 24,
              padding: const EdgeInsets.all(18),
              onTap: () => showSoftDialog(
                context: context,
                builder: (_) => const VellumProDialog(),
              ).then((_) => setState(() {})),
              child: Row(
                children: [
                  Icon(
                    isPro ? Icons.verified_outlined : Icons.workspace_premium_outlined,
                    color: VellumTheme.paperHighlight,
                    size: 26,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPro ? 'VELLUM PATRON · PRO' : 'VELLUM PRO',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                            color: VellumTheme.paperHighlight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isPro
                              ? 'Все сокровищницы, звуки и безлимитный фолиант открыты.'
                              : 'Разблокируйте безлимитный фолиант, звуки и глубокий Cloze.',
                          style: const TextStyle(fontSize: 11, height: 1.4, color: VellumTheme.carbonInkSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 20, color: VellumTheme.paperHighlight),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Section 1: Acoustic Typewriter Themes
            _buildSectionHeader('АКУСТИЧЕСКИЕ ТЕМЫ ПЕЧАТНЫХ МАШИНОК'),
            const SizedBox(height: 12),
            ...AudioTheme.values.map((theme) {
              final isSelected = _sound.currentTheme == theme;
              final isLocked = theme.isPro && !isPro;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SoftSurface(
                  elevated: isSelected,
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    contentPadding: const EdgeInsets.only(left: 4, right: 14),
                    leading: IconButton(
                      icon: const Icon(Icons.volume_up_outlined, size: 20),
                      tooltip: 'Прослушать звук',
                      onPressed: () => _sound.previewTheme(theme),
                    ),
                    title: Row(
                      children: [
                        Flexible(child: Text(theme.title)),
                        if (isLocked) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.lock_outline, size: 13, color: VellumTheme.inkSecondary),
                        ],
                      ],
                    ),
                    subtitle: Text(theme.description),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: VellumTheme.ink, size: 20)
                        : null,
                    onTap: () => _onThemeSelected(theme),
                  ),
                ),
              );
            }),

            const SizedBox(height: 28),

            // Section 2: Tactile & Sound Settings
            _buildSectionHeader('ТАКТИЛЬНЫЙ И ЗВУКОВОЙ ОТКЛИК'),
            const SizedBox(height: 4),
            SwitchListTile.adaptive(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              applyCupertinoTheme: true,
              title: const Text('Звуковые щелчки литер'),
              subtitle: const Text('Воспроизведение механики при наборе'),
              value: _soundEnabled,
              onChanged: (val) {
                setState(() {
                  _soundEnabled = val;
                  _sound.isMuted = !val;
                });
              },
            ),
            SwitchListTile.adaptive(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              applyCupertinoTheme: true,
              title: const Text('Тактильная отдача (Taptic Engine)'),
              subtitle: const Text('Физический импульс удара молоточка'),
              value: _hapticsEnabled,
              onChanged: (val) {
                setState(() {
                  _hapticsEnabled = val;
                  VellumHapticEngine.enabled = val;
                });
              },
            ),

            const SizedBox(height: 28),

            // Section 3: Daily Ritual & Reminders
            _buildSectionHeader('ЕЖЕДНЕВНЫЙ РИТУАЛ'),
            const SizedBox(height: 4),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: const Text('Время утреннего вдохновения'),
              subtitle: Text('Напоминание о новом стихе дня: $_reminderTime'),
              trailing: const Icon(Icons.access_time, color: VellumTheme.inkSecondary),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 9, minute: 0),
                );
                if (picked != null) {
                  setState(() {
                    _reminderTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                  });
                }
              },
            ),

            const SizedBox(height: 40),

            // Zero-PII Privacy & Legal
            Center(
              child: Column(
                children: [
                  const Text('VELLUM v1.0.0 (Impeller 120fps)', style: VellumTheme.captionStyle),
                  const SizedBox(height: 8),
                  const Text(
                    '100% Offline-first · Zero-PII Architecture\nВаши стихи и нажатия клавиш никогда не покидают ваше устройство.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: VellumTheme.inkSecondary, height: 1.6),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text('Политика конфиденциальности'),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Условия использования'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(title, style: VellumTheme.captionStyle),
    );
  }
}
