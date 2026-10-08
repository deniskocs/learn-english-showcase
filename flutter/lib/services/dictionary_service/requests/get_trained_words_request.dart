import '../../../network/application_request.dart';

class GetTrainedWordsRequest implements ApplicationRequest {
  @override
  String endpoint = "training/list";

  @override
  Method method = Method.get;

  @override
  Map<String, dynamic> parameters = {};

  @override
  String? body;
}
