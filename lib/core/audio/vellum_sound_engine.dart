import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'audio_theme.dart';

/// Ultra-low latency acoustic sound engine with theme support (< 8ms latency).
class VellumSoundEngine {
  static final VellumSoundEngine _instance = VellumSoundEngine._internal();
  factory VellumSoundEngine() => _instance;
  VellumSoundEngine._internal();

  final AudioPlayer _keyPlayer = AudioPlayer();
  final AudioPlayer _spacePlayer = AudioPlayer();
  final AudioPlayer _bellPlayer = AudioPlayer();
  final AudioPlayer _stampPlayer = AudioPlayer();
  final AudioPlayer _errorPlayer = AudioPlayer();
  final Random _rng = Random();

  bool isMuted = false;
  double volume = 0.85;
  AudioTheme currentTheme = AudioTheme.underwood;

  Future<void> init() async {
    try {
      await _keyPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _spacePlayer.setPlayerMode(PlayerMode.lowLatency);
      await _bellPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _stampPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _errorPlayer.setPlayerMode(PlayerMode.lowLatency);

      await _keyPlayer.setVolume(volume);
      await _spacePlayer.setVolume(volume);
      await _bellPlayer.setVolume(volume * 0.95);
      await _stampPlayer.setVolume(volume);
      await _errorPlayer.setVolume(volume * 0.7);
    } catch (e) {
      debugPrint('Audio initialization note: $e');
    }
  }

  void setTheme(AudioTheme theme) {
    currentTheme = theme;
  }

  /// Plays keystroke corresponding to current theme
  void playKeystroke() {
    if (isMuted) return;
    try {
      final pitchVar = 0.95 + (_rng.nextDouble() * 0.1);
      _keyPlayer.setPlaybackRate(pitchVar);
      _keyPlayer.play(AssetSource(currentTheme.assetKey), volume: volume);
    } catch (_) {}
  }

  /// Plays wooden spacebar return thud
  void playSpace() {
    if (isMuted) return;
    try {
      _spacePlayer.play(AssetSource('audio/typewriter_space.wav'), volume: volume);
    } catch (_) {}
  }

  /// Plays brass bell ding on carriage return
  void playBellDing() {
    if (isMuted) return;
    try {
      _bellPlayer.play(AssetSource('audio/typewriter_bell.wav'), volume: volume * 0.95);
    } catch (_) {}
  }

  /// Plays muted jammed key sound on mistype
  void playJammedKey() {
    if (isMuted) return;
    try {
      _errorPlayer.play(AssetSource('audio/typewriter_error.wav'), volume: volume * 0.75);
    } catch (_) {}
  }

  /// Plays wax seal stamp
  void playWaxSealStamp() {
    if (isMuted) return;
    try {
      _stampPlayer.play(AssetSource('audio/wax_seal_stamp.wav'), volume: volume);
    } catch (_) {}
  }

  /// Preview a specific theme sound in settings
  void previewTheme(AudioTheme theme) {
    if (isMuted) return;
    try {
      _keyPlayer.play(AssetSource(theme.assetKey), volume: volume);
    } catch (_) {}
  }

  void dispose() {
    _keyPlayer.dispose();
    _spacePlayer.dispose();
    _bellPlayer.dispose();
    _stampPlayer.dispose();
    _errorPlayer.dispose();
  }
}
