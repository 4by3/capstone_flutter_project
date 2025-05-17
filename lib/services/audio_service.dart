import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _effectPlayer = AudioPlayer();
  static final AudioPlayer _bgPlayer = AudioPlayer();

  /// Plays a sound when the user selects the correct answer.
  static Future<void> playCorrect() async {
    try {
      await _effectPlayer.play(AssetSource('audio/correct_answer.mp3'));
    } catch (e) {
      print('Error playing correct answer sound: $e');
    }
  }

  /// Plays a sound when the user selects the wrong answer.
  static Future<void> playWrong() async {
    try {
      await _effectPlayer.play(AssetSource('audio/wrong_answer.mp3'));
    } catch (e) {
      print('Error playing wrong answer sound: $e');
    }
  }

  /// Plays background music in a loop.
  static Future<void> startBackgroundMusic() async {
    try {
      // Do NOT set the source first. Instead, use `play()` directly.
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.setVolume(0.2);
      await _bgPlayer.play(AssetSource('audio/background_music.mp3'));
    } catch (e) {
      print('Error playing background music: $e');
    }
  }

  /// Stops background music.
  static Future<void> stopBackgroundMusic() async {
    try {
      await _bgPlayer.stop();
    } catch (e) {
      print('Error stopping background music: $e');
    }
  }
}
