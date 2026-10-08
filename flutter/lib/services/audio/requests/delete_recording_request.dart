import '../../../network/application_request.dart';

class DeleteRecordingRequest implements ApplicationRequest {
  @override
  String endpoint = "/deleteRecording";

  @override
  Method method = Method.post;

  @override
  Map<String, dynamic> parameters = {};

  @override
  String? body;

  DeleteRecordingRequest(String uuid) {
    parameters = {"uuid": uuid};
  }
}

