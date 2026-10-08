import 'dart:async';
import 'dart:io';
import 'dart:developer';
import 'dart:typed_data';
import 'package:learn_english/network/network.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class FileUploader {
  final AbstractNetwork _network;
  final void Function(String uuid) _onUploadSuccess;
  bool _isUploading = false;
  Timer? _uploadRetryTimer;
  final List<Map<String, dynamic>> _pendingRecords = [];
  final Duration _uploadRetryInterval = const Duration(seconds: 30);

  FileUploader(this._onUploadSuccess) : _network = GetIt.I.get<AbstractNetwork>() {
    _startConnectivityMonitoring();
  }

  bool get isUploading => _isUploading;

  void _startConnectivityMonitoring() {
    // Слушаем изменения подключения
    _network.listenConnectivityChanges((List<ConnectivityResult> results) {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        log('Internet connection restored, starting upload queue');
        processUploadQueue();
      }
    });
  }

  void setUploading(bool value) {
    _isUploading = value;
  }

  void cancelRetryTimer() {
    _uploadRetryTimer?.cancel();
    _uploadRetryTimer = null;
  }

  void scheduleRetryTimer(void Function() callback) {
    if (_uploadRetryTimer != null) {
      return;
    }

    _uploadRetryTimer = Timer(_uploadRetryInterval, () {
      _uploadRetryTimer = null;
      callback();
    });
  }

  Duration get uploadRetryInterval => _uploadRetryInterval;

  bool get hasRetryTimer => _uploadRetryTimer != null;

  bool get hasPendingRecords => _pendingRecords.isNotEmpty;

  int get pendingRecordsCount => _pendingRecords.length;

  List<Map<String, dynamic>> getPendingRecordsCopy() {
    return List<Map<String, dynamic>>.from(_pendingRecords);
  }

  void removePendingRecord(Map<String, dynamic> record) {
    final uuid = record['uuid'] as String?;
    if (uuid != null) {
      _pendingRecords.removeWhere((r) => r['uuid'] == uuid);
    }
  }

  Future<String> saveRecordingFile(Uint8List m4aData) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = _generateRecordingFileName();
    final filePath = '${directory.path}/$fileName';

    final outputFile = File(filePath);
    await outputFile.writeAsBytes(m4aData);

    return filePath;
  }

  Future<void> uploadFile(Uint8List m4aData, String uuid) async {
    final filePath = await saveRecordingFile(m4aData);
    _pendingRecords.add({
      'uuid': uuid,
      'filePath': filePath,
    });
    await processUploadQueue();
  }

  String _generateRecordingFileName() {
    final dateTime = DateTime.now();
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return 'recording-$day.$month.$year-$hour:$minute.m4a';
  }

  Future<void> processUploadQueue() async {
    if (_isUploading) {
      log('Upload already in progress, skipping');
      return;
    }

    if (!hasPendingRecords) {
      log('Upload queue is empty, nothing to process');
      return;
    }

    log('Starting upload queue processing, $pendingRecordsCount records pending');

    final hasInternet = await _network.checkInternetConnection();
    if (!hasInternet) {
      log('No internet connection, pausing uploads');
      scheduleRetryTimer(() {
        processUploadQueue();
      });
      return;
    }

    _isUploading = true;
    cancelRetryTimer();

    log('Processing upload queue, $pendingRecordsCount records pending');

    final recordsToProcess = getPendingRecordsCopy();
    for (final record in recordsToProcess) {
      final filePath = record['filePath'] as String;
      final uuid = record['uuid'] as String;

      if (!File(filePath).existsSync()) {
        log('File no longer exists, removing from queue: $filePath');
        removePendingRecord(record);
        continue;
      }

      final success = await _network.uploadRecording(filePath, uuid);
      if (success) {
        removePendingRecord(record);
        log('File uploaded and removed from queue: $filePath');
        _onUploadSuccess(uuid);
      } else {
        log('Upload failed, keeping file in queue: $filePath');
        _isUploading = false;
        scheduleRetryTimer(() {
          processUploadQueue();
        });
        return;
      }
    }

    _isUploading = false;
    log('Upload queue processed. Remaining records: $pendingRecordsCount');
  }
}
