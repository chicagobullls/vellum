import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Ultra-low latency acoustic sound engine for tactile typing & wax stamps.
class VellumSoundEngine {
  static final VellumSoundEngine _instance = VellumSoundEngine._internal();
  factory VellumSoundEngine() => _instance;
  VellumSoundEngine._internal();

  final AudioPlayer _keyPlayer = AudioPlayer();
  final AudioPlayer _spacePlayer = AudioPlayer();
  final AudioPlayer _bellPlayer = AudioPlayer();
  final AudioPlayer _stampPlayer = AudioPlayer();
  final Random _rng = Random();

  bool isMuted = false;
  double volume = 0.85;

  Future<void> init() async {
    try {
      await _keyPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _spacePlayer.setPlayerMode(PlayerMode.lowLatency);
      await _bellPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _stampPlayer.setPlayerMode(PlayerMode.lowLatency);

      await _keyPlayer.setVolume(volume);
      await _spacePlayer.setVolume(volume);
      await _bellPlayer.setVolume(volume * 0.9);
      await _stampPlayer.setVolume(volume);
    } catch (e) {
      debugPrint('Audio initialization note: $e');
    }
  }

  /// Plays crisp mechanical typewriter keystroke with slight pitch variance
  void playKeystroke() {
    if (isMuted) return;
    try {
      // Subtle pitch variation to avoid machine-gun effect
      final pitchVar = 0.95 + (_rng.nextDouble() * 0.1);
      _keyPlayer.setPlaybackRate(pitchVar);
      _keyPlayer.play(AssetSource('audio/typewriter_key.wav'), volume: volume);
    } catch (_) {}
  }

  /// Plays wooden spacebar return thud
  void playSpace() {
    if (isMuted) return;
    try {
      _spacePlayer.play(AssetSource('audio/typewriter_space.wav'), volume: volume);
    } catch (_) {}
  }

  /// Plays vintage brass bell ding upon stanza or line completion
  void playBellDing() {
    if (isMuted) return;
    try {
      _bellPlayer.play(AssetSource('audio/typewriter_bell.wav'), volume: volume * 0.95);
    } catch (_) {}
  }

  /// Plays physical wax seal stamp squish and solid thud
  void playWaxSealStamp() {
    if (isMuted) return;
    try {
      _stampPlayer.play(AssetSource('audio/wax_seal_stamp.wav'), volume: volume);
    } catch (_) {}
  }

  void dispose() {
    _keyPlayer.dispose();
    _spacePlayer.dispose();
    _bellPlayer.dispose();
    _stampPlayer.dispose();
  }
}
