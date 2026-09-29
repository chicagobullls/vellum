/// Local user preferences stored via SharedPreferences.
class UserSettings {
  final bool soundEnabled;
  final double soundVolume;
  final bool hapticsEnabled;
  final bool isDarkMode;
  final bool isPro;
  final String dailyReminderTime; // "09:00"

  const UserSettings({
    this.soundEnabled = true,
    this.soundVolume = 0.85,
    this.hapticsEnabled = true,
    this.isDarkMode = false,
    this.isPro = false,
    this.dailyReminderTime = '09:00',
  });

  UserSettings copyWith({
    bool? soundEnabled,
    double? soundVolume,
    bool? hapticsEnabled,
    bool? isDarkMode,
    bool? isPro,
    String? dailyReminderTime,
  }) =>
      UserSettings(
        soundEnabled: soundEnabled ?? this.soundEnabled,
        soundVolume: soundVolume ?? this.soundVolume,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        isDarkMode: isDarkMode ?? this.isDarkMode,
        isPro: isPro ?? this.isPro,
        dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      );
}
