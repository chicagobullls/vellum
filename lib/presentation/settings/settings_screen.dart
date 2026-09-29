import 'package:flutter/material.dart';
import '../../core/audio/audio_theme.dart';
import '../../core/audio/vellum_sound_engine.dart';
import '../../core/billing/vellum_billing_service.dart';
import '../../core/haptics/vellum_haptic_engine.dart';
import '../../core/theme/vellum_theme.dart';
import '../widgets/parchment_background.dart';
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
      showDialog(
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
      appBar: AppBar(
        title: Text('НАСТРОЙКИ · SANCTUARY', style: VellumTheme.headerDateStyle),
        centerTitle: true,
      ),
      body: ParchmentBackground(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Pro Membership Banner
            GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (_) => const VellumProDialog(),
              ).then((_) => setState(() {})),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isPro ? VellumTheme.antiqueGoldMuted : VellumTheme.parchmentSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: VellumTheme.antiqueGold, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPro ? Icons.verified : Icons.stars,
                      color: VellumTheme.antiqueGold,
                      size: 28,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPro ? 'VELLUM PATRON · PRO' : 'VELLUM PRO',
                            style: const TextStyle(
                              fontFamily: 'Cinzel',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: VellumTheme.antiqueGold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isPro
                                ? 'Все сокровищницы, звуки и безлимитный фолиант открыты.'
                                : 'Разблокируйте безлимитный фолиант, звуки и глубокий Cloze.',
                            style: const TextStyle(fontSize: 12, color: VellumTheme.inkSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: VellumTheme.antiqueGold),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Section 1: Acoustic Typewriter Themes
            _buildSectionHeader('АКУСТИЧЕСКИЕ ТЕМЫ ПЕЧАТНЫХ МАШИНОК'),
            const SizedBox(height: 12),
            ...AudioTheme.values.map((theme) {
              final isSelected = _sound.currentTheme == theme;
              final isLocked = theme.isPro && !isPro;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: VellumTheme.parchmentSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? VellumTheme.antiqueGold : const Color(0x22C29B38),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  leading: IconButton(
                    icon: const Icon(Icons.volume_up_outlined, color: VellumTheme.antiqueGold),
                    tooltip: 'Прослушать звук',
                    onPressed: () => _sound.previewTheme(theme),
                  ),
                  title: Row(
                    children: [
                      Text(
                        theme.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: VellumTheme.inkPrimary,
                        ),
                      ),
                      if (isLocked) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.lock, size: 12, color: VellumTheme.antiqueGold),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    theme.description,
                    style: const TextStyle(fontSize: 11, color: VellumTheme.inkSecondary),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: VellumTheme.antiqueGold, size: 20)
                      : null,
                  onTap: () => _onThemeSelected(theme),
                ),
              );
            }),

            const SizedBox(height: 24),

            // Section 2: Tactile & Sound Settings
            _buildSectionHeader('ТАКТИЛЬНЫЙ И ЗВУКОВОЙ ОТКЛИК'),
            SwitchListTile.adaptive(
              title: const Text('Звуковые щелчки литер'),
              subtitle: const Text('Воспроизведение механики при наборе', style: TextStyle(fontSize: 12)),
              activeColor: VellumTheme.antiqueGold,
              value: _soundEnabled,
              onChanged: (val) {
                setState(() {
                  _soundEnabled = val;
                  _sound.isMuted = !val;
                });
              },
            ),
            SwitchListTile.adaptive(
              title: const Text('Тактильная отдача (Taptic Engine)'),
              subtitle: const Text('Физический импульс удара молоточка', style: TextStyle(fontSize: 12)),
              activeColor: VellumTheme.antiqueGold,
              value: _hapticsEnabled,
              onChanged: (val) {
                setState(() {
                  _hapticsEnabled = val;
                  VellumHapticEngine.enabled = val;
                });
              },
            ),

            const SizedBox(height: 24),

            // Section 3: Daily Ritual & Reminders
            _buildSectionHeader('ЕЖЕДНЕВНЫЙ РИТУАЛ'),
            ListTile(
              title: const Text('Время утреннего вдохновения'),
              subtitle: Text('Напоминание о новом стихе дня: $_reminderTime', style: const TextStyle(fontSize: 12)),
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

            const SizedBox(height: 36),

            // Zero-PII Privacy & Legal
            Center(
              child: Column(
                children: [
                  const Text(
                    'VELLUM v1.0.0 (Impeller 120fps)',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      letterSpacing: 1.5,
                      color: VellumTheme.inkSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '100% Offline-first · Zero-PII Architecture\nВаши стихи и нажатия клавиш никогда не покидают ваше устройство.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: VellumTheme.inkSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text('Политика конфиденциальности', style: TextStyle(fontSize: 11, color: VellumTheme.inkSecondary)),
                      ),
                      const Text('·', style: TextStyle(color: VellumTheme.inkSecondary)),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Условия использования', style: TextStyle(fontSize: 11, color: VellumTheme.inkSecondary)),
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
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Cinzel',
        fontSize: 11,
        letterSpacing: 2.0,
        fontWeight: FontWeight.bold,
        color: VellumTheme.antiqueGold,
      ),
    );
  }
}
