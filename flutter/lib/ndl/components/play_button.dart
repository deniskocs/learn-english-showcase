import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../app_colors.dart';
import '../../services/audio/audio_service.dart';

/// Кнопка воспроизведения звука
class PlayButton extends StatelessWidget {
  final String word;

  const PlayButton({
    super.key,
    required this.word,
  });

  void _play() {
    final audioService = GetIt.I.get<AudioService>();
    audioService.playWord(word);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        CupertinoIcons.speaker_2_fill,
        color: AppColors.primary,
      ),
      onPressed: _play,
    );
  }
}
