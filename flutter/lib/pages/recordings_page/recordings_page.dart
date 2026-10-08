import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learn_english/model/recording_item.dart';
import 'package:learn_english/ndl/components/loadable_state.dart';
import 'package:learn_english/pages/app_nav_bar.dart';
import 'package:learn_english/pages/recordings_page/recording_item.dart';
import 'package:learn_english/pages/recordings_page/active_recording_widget.dart';
import 'package:learn_english/pages/recordings_page/recording_analysis_page.dart';
import 'package:learn_english/services/audio/audio_recording_service.dart';
import 'package:learn_english/services/audio/recorder.dart';
import 'package:learn_english/ndl/components/loadable_component.dart';
import 'package:get_it/get_it.dart';

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();

  static var barItem = BottomNavigationBarItem(
    icon: Icon(CupertinoIcons.mic),
    label: 'Записи',
  );
}

class _RecordsPageState extends State<RecordsPage> {
  late final AudioRecordingService _recordingService;

  @override
  void initState() {
    super.initState();
    _recordingService = GetIt.I.get<AudioRecordingService>();
    _recordingService.loadRecordings();
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

  Future<void> _refreshRecordings() async {
    try {
      await _recordingService.loadRecordings();
    } catch (e) {
      _showSnackBar('Ошибка загрузки записей: ${e.toString()}', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: const AppNavBar(title: 'Записи'),
      body: Column(
        children: [
          const SizedBox(height: 12),
          StreamBuilder<Recorder?>(
            stream: _recordingService.recorder,
            builder: (context, snapshot) {
              final recorder = snapshot.data;
              if (recorder == null) {
                return const SizedBox.shrink();
              }
              return ActiveRecordingWidget(recorder: recorder);
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshRecordings,
              child: LoadableComponent<List<RecordingItemDTO>, LoadableState<List<RecordingItemDTO>>>(
                stateStream: _recordingService.recordingsState.stream,
                loadFunction: _refreshRecordings,
                dataContentBuilder: (context, records) {
                  return ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      ...records.map((recording) {
                        return RecordingItem(
                          item: recording,
                          onDelete: () => _recordingService.deleteRecording(recording.uuid),
                          onTap: recording.canOpen && recording.englishText != null
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RecordingAnalysisPage(
                                        englishText: recording.englishText!,
                                        recordingTitle: recording.displayTitle,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
