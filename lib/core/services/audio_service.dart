import 'package:audioplayers/audioplayers.dart';
import '../utils/logger.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  
  late final AudioPlayer _player;
  
  bool _isSoundEnabled = true;

  AudioService._internal() {
    _player = AudioPlayer();
    _player.setReleaseMode(ReleaseMode.stop);
  }

  void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
  }

  bool get isSoundEnabled => _isSoundEnabled;

  Future<void> playSuccess() async {
    if (!_isSoundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/success.mp3'), volume: 0.6);
    } catch (e) {
      AppLogger.error('Error playing success sound', e);
    }
  }

  Future<void> playPop() async {
    if (!_isSoundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/pop.mp3'), volume: 0.4);
    } catch (e) {
      AppLogger.error('Error playing pop sound', e);
    }
  }

  Future<void> stopAll() async {
    await _player.stop();
  }
}
