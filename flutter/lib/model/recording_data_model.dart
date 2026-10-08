class RecordingDataModel {
  final String uuid;
  final String? status;
  final String? title;
  final String? description;
  final int? time; // timestamp in milliseconds
  final String? englishText;

  RecordingDataModel({
    required this.uuid,
    this.status,
    this.title,
    this.description,
    this.time,
    this.englishText,
  });

  factory RecordingDataModel.fromJson(Map<String, dynamic> json) {
    return RecordingDataModel(
      uuid: json['uuid'] as String,
      status: json['status'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      time: json['time'] as int?,
      englishText: json['englishText'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'status': status,
      'title': title,
      'description': description,
      'time': time,
      'englishText': englishText,
    };
  }
}

