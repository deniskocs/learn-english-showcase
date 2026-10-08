import '../../../network/application_request.dart';

class SearchDefinitions implements ApplicationRequest {
  @override
  String endpoint = "/search";

  @override
  Method method = Method.get;

  @override
  late Map<String, dynamic> parameters;

  @override
  String? body;

  SearchDefinitions({required String text}) {
    parameters = {
      "text": text,
    };
  }
}
