import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:learn_english/model/recording_item.dart';
import 'package:learn_english/ndl/components/loadable_state.dart';
import 'package:learn_english/network/network.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer';
import 'package:learn_english/services/audio/native_audio_channels.dart';
import 'package:learn_english/services/audio/recorder.dart';
import 'package:learn_english/services/audio/file_uploader.dart';

abstract class AudioRecordingService {
  abstract BehaviorSubject<LoadableState<List<RecordingItemDTO>>> recordingsState;
  abstract BehaviorSubject<Recorder?> recorder;
  Future<void> loadRecordings();
  Future<void> deleteRecording(String uuid);
}

class AudioRecordingServiceImpl implements AudioRecordingService {
  final AbstractNetwork _network;
  final NativeAudioChannels _nativeChannels;

  late final FileUploader _fileUploader;
  Timer? _refreshTimer;

  final Duration _refreshInterval = const Duration(seconds: 5);

  @override
  BehaviorSubject<LoadableState<List<RecordingItemDTO>>> recordingsState =
      BehaviorSubject<LoadableState<List<RecordingItemDTO>>>.seeded(LoadableState.data([]));

  @override
  BehaviorSubject<Recorder?> recorder = BehaviorSubject<Recorder?>.seeded(null);

  AudioRecordingServiceImpl()
      : _network = GetIt.I.get<AbstractNetwork>(),
        _nativeChannels = GetIt.I.get<NativeAudioChannels>() {
    _fileUploader = FileUploader(_onUploadSuccess);
    _nativeChannels.getRecorder().thenNonNull((recorder) {
      recorder.onData = (Uint8List data) {
        _handleNativeChunkComplete(data);
      };

      this.recorder.value = recorder;
    });
  }

  Future<void> _handleNativeChunkComplete(Uint8List m4aData) async {
    if (m4aData.isEmpty) {
      return;
    }
    final uuid = const Uuid().v4();

    try {
      _addNewRecordingToState(uuid);
      await _fileUploader.uploadFile(m4aData, uuid);
    } catch (e, stackTrace) {
      log('[Flutter] ERROR handling native chunk: $e');
      log('[Flutter] Stack trace: $stackTrace');
    }
  }

  void _onUploadSuccess(String uuid) {
    _updateRecordingStatus(uuid, 'recognizing');
    _scheduleRefresh();
  }

  void _scheduleRefresh() {
    _refreshTimer?.cancel();
    log('Scheduling refresh in ${_refreshInterval.inSeconds} seconds');
    _refreshTimer = Timer(_refreshInterval, () {
      _refreshTimer = null;
      loadRecordings();
    });
  }

  void _addNewRecordingToState(String uuid) {
    final currentState = recordingsState.value;
    final currentRecords = List<RecordingItemDTO>.from(currentState.data!);
    final newRecord = RecordingItemDTO(
      title: 'Новая запись',
      time: DateTime.now(),
      uuid: uuid,
      status: 'uploading',
    );
    currentRecords.insert(0, newRecord);
    recordingsState.value = LoadableState.data(currentRecords);
  }

  void _updateRecordingStatus(String uuid, String status) {
    final currentState = recordingsState.value;
    final currentRecords = List<RecordingItemDTO>.from(currentState.data!);
    final index = currentRecords.indexWhere((r) => r.uuid == uuid);
    if (index != -1) {
      currentRecords[index].status = status;
      recordingsState.value = LoadableState.data(currentRecords);
    }
  }

  @override
  Future<void> loadRecordings() async {
    try {
      final currentState = recordingsState.value;
      final currentRecords = List<RecordingItemDTO>.from(currentState.data!);

      final response = await _network.getRecordings();

      final Map<String, RecordingItemDTO> serverRecordsMap = {};
      for (var item in response.recordings) {
        serverRecordsMap[item.uuid] = item;
      }

      for (int i = 0; i < currentRecords.length; i++) {
        final uuid = currentRecords[i].uuid;
        if (serverRecordsMap.containsKey(uuid)) {
          currentRecords[i] = serverRecordsMap[uuid]!;
          serverRecordsMap.remove(uuid);
        }
      }

      currentRecords.addAll(serverRecordsMap.values);

      recordingsState.value = LoadableState.data(currentRecords);

      // Проверяем наличие незавершенных результатов анализа
      final hasIncompleteResults = currentRecords.any((record) {
        final status = record.status;
        return status == 'uploading' || status == 'recognizing';
      });

      if (hasIncompleteResults) {
        log('Found incomplete analysis results, scheduling refresh');
        _scheduleRefresh();
      }
    } catch (e) {
      log('Error loading recordings: $e');
      recordingsState.value = LoadableState.error(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> deleteRecording(String uuid) async {
    final currentState = recordingsState.value;
    if (currentState.data == null) {
      return;
    }

    final updatedRecords = List<RecordingItemDTO>.from(currentState.data!);
    updatedRecords.removeWhere((r) => r.uuid == uuid);
    recordingsState.value = LoadableState.data(updatedRecords);

    await _network.deleteRecording(uuid);
  }

  Future<void> dispose() async {
    final recorderInstance = recorder.value;
    if (recorderInstance != null && recorderInstance.isRecording) {
      await recorderInstance.stopRecording();
    }
    _fileUploader.cancelRetryTimer();
    _refreshTimer?.cancel();
    _network.cancelConnectivitySubscription();
    await recorderInstance?.close();
    await recordingsState.close();
    await recorder.close();
  }
}

extension ThenNonNull<T> on Future<T?> {
  Future<void> thenNonNull(FutureOr<void> Function(T value) action) {
    return then((value) {
      if (value != null) {
        return action(value);
      }
    });
  }
}
