import 'dart:async';
import 'package:flutter/services.dart';
import 'package:learn_english/services/audio/recorder.dart';

class NativeAudioChannels {
  final MethodChannel methodChannel;
  final EventChannel eventChannel;
  StreamSubscription<dynamic>? _nativeEventSubscription;

  NativeAudioChannels({
    required this.methodChannel,
    required this.eventChannel,
  });

  factory NativeAudioChannels.create() {
    return NativeAudioChannels(
      methodChannel: const MethodChannel('com.chilik.learn_english/continuous_audio_recorder'),
      eventChannel: const EventChannel('com.chilik.learn_english/continuous_audio_recorder_events'),
    );
  }

  Future<void> startService() async {
    await methodChannel.invokeMethod('startService');
  }

  Future<Recorder?> getRecorder() async {
    try {
      await startService();
    } catch (e) {
      return null;
    }

    Recorder? connection;
    final subscription = eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        // Если приходят данные напрямую (Uint8List) - это chunkComplete
        if (event is Uint8List) {
          connection?.onData?.call(event);
          return;
        }

        // Если приходит Map - это другие события (recordingStopped, error)
        if (event is Map) {
          final eventType = event['event'] as String?;

          switch (eventType) {
            case 'recordingStopped':
              connection?.onStopRecording?.call();
              break;
            case 'error':
              final errorMessage = event['error'] as String? ?? 'Recording error';
              connection?.onError?.call(Exception(errorMessage));
              break;
          }
        }
      },
      onError: (error) {
        connection?.onError?.call(error);
      },
      cancelOnError: false,
    );

    connection = Recorder(subscription, methodChannel);
    _nativeEventSubscription = subscription;
    return connection;
  }

  void cancelSubscription() {
    _nativeEventSubscription?.cancel();
    _nativeEventSubscription = null;
  }

  Stream<dynamic> get eventsStream => eventChannel.receiveBroadcastStream();
}
