import '../../../network/application_request.dart';

class GetRecordingsRequest implements ApplicationRequest {
  @override
  String endpoint = "/recordings";

  @override
  Method method = Method.get;

  @override
  Map<String, dynamic> parameters = {};

  @override
  String? body;
}
