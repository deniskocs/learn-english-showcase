class RecordingItemDTO {
  final String uuid;
  String? status;
  final String? title;
  final String? description;
  final DateTime? time;
  final String? englishText;

  RecordingItemDTO({
    required this.uuid,
    this.status,
    this.title,
    this.description,
    this.time,
    this.englishText,
  });

  factory RecordingItemDTO.fromJson(Map<String, dynamic> json) {
    DateTime? time;
    if (json['time'] != null) {
      if (json['time'] is String) {
        try {
          time = DateTime.parse(json['time'] as String);
        } catch (e) {
          print('Failed to parse time: $e');
        }
      } else if (json['time'] is int) {
        time = DateTime.fromMillisecondsSinceEpoch(json['time'] as int);
      } else if (json['time'] is DateTime) {
        time = json['time'] as DateTime;
      }
    }

    return RecordingItemDTO(
      uuid: json['uuid'] as String,
      status: json['status'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      time: time,
      englishText: json['englishText'] as String?,
    );
  }

  DateTime get displayTime {
    if (time != null) {
      return time!;
    }
    return DateTime.now();
  }

  String get displayTitle {
    return title ?? 'Запись';
  }

  bool get canOpen {
    return (status == 'data' || status == 'ready' || status == null) && englishText != null && englishText!.isNotEmpty;
  }
}
