import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learn_english/services/audio/recorder.dart';
import 'package:learn_english/ndl/app_colors.dart';
import 'package:learn_english/ndl/app_text_styles.dart';

class ActiveRecordingWidget extends StatefulWidget {
  final Recorder recorder;

  const ActiveRecordingWidget({
    super.key,
    required this.recorder,
  });

  @override
  State<ActiveRecordingWidget> createState() => _ActiveRecordingWidgetState();
}

class _ActiveRecordingWidgetState extends State<ActiveRecordingWidget> {
  Future<void> _handleStartRecording() async {
    try {
      await widget.recorder.startRecording(600); // 10 minutes
      _showSnackBar('Фоновая запись активирована');
    } catch (e) {
      _showSnackBar('Ошибка: ${e.toString()}', isError: true);
    }
  }

  Future<void> _handleStopRecording() async {
    try {
      await widget.recorder.stopRecording();
      _showSnackBar('Фоновая запись выключена');
    } catch (e) {
      _showSnackBar('Ошибка: ${e.toString()}', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: isError ? 2 : 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: widget.recorder.isRecordingStream,
      initialData: widget.recorder.isRecording,
      builder: (context, snapshot) {
        final isRecording = snapshot.data ?? false;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: Spacings.normal, vertical: Spacings.small),
          padding: const EdgeInsets.symmetric(
              horizontal: Spacings.normal + Spacings.extraSmall, vertical: Spacings.medium + Spacings.extraSmall),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(Radiuses.card),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Активная запись',
                style: AppTextStyles.wordTitle,
              ),
              isRecording
                  ? IconButton(
                      onPressed: _handleStopRecording,
                      icon: Icon(
                        CupertinoIcons.stop_fill,
                        color: AppColors.primary,
                      ),
                      tooltip: 'Остановить запись',
                    )
                  : IconButton(
                      onPressed: _handleStartRecording,
                      icon: Icon(
                        CupertinoIcons.circle_fill,
                        color: AppColors.danger,
                      ),
                      tooltip: 'Начать запись',
                    ),
            ],
          ),
        );
      },
    );
  }
}
