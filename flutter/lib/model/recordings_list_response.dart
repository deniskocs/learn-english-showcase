import 'recording_item.dart';

class RecordingsListResponseDTO {
  final List<RecordingItemDTO> recordings;

  RecordingsListResponseDTO({required this.recordings});

  factory RecordingsListResponseDTO.fromJson(Map<String, dynamic> json) {
    final recordingsList = json['recordings'] as List<dynamic>? ?? [];
    return RecordingsListResponseDTO(
      recordings: recordingsList.map((e) => RecordingItemDTO.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
