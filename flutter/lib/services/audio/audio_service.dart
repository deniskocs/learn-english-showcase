import 'package:audioplayers/audioplayers.dart';

abstract class AudioService {
  void playWord(String word);
}

class AudioServiceImpl implements AudioService {
  final player = AudioPlayer();

  @override
  void playWord(String word) {
    player.play(AssetSource('sounds/$word.mp3'));
  }
}
