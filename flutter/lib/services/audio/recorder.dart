import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

class Recorder {
  final StreamSubscription<dynamic> subscription;
  final MethodChannel methodChannel;
  final BehaviorSubject<bool> _isRecording = BehaviorSubject<bool>.seeded(false);

  Recorder(this.subscription, this.methodChannel);

  void Function(Uint8List data)? onData;
  void Function(Object error)? onError;
  void Function()? onStopRecording;

  bool get isRecording => _isRecording.value;
  Stream<bool> get isRecordingStream => _isRecording.stream;

  Future<void> startRecording(int chunkDurationSeconds) async {
    if (isRecording) {
      return;
    }

    if (Platform.isAndroid) {
      final status = await Permission.microphone.status;

      if (!status.isGranted) {
        final result = await Permission.microphone.request();

        if (!result.isGranted) {
          throw Exception('RECORD_AUDIO permission is required for audio recording');
        }
      }
    }

    try {
      await methodChannel.invokeMethod('startRecording', {
        'chunkDuration': chunkDurationSeconds,
      });
      _isRecording.value = true;
    } catch (e) {
      _isRecording.value = false;
      rethrow;
    }
  }

  Future<void> stopRecording() async {
    if (!isRecording) {
      return;
    }

    try {
      await methodChannel.invokeMethod('stopRecording');
      _isRecording.value = false;
    } catch (e) {
      _isRecording.value = false;
      rethrow;
    }
  }

  Future<void> close() async {
    await subscription.cancel();
    await _isRecording.close();
  }
}
