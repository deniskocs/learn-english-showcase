import '../../../network/application_request.dart';

/// Запрос для получения списка активных слов пользователя
/// Backend: backend/src/main/java/com/chilik/denis/learnenglish/dictionary/DictionaryController.java
/// Method: activeWords()
/// Endpoint: GET /activeWords
class GetActiveWordsRequest implements ApplicationRequest {
  @override
  String endpoint = "/activeWords";

  @override
  Method method = Method.get;

  @override
  Map<String, dynamic> parameters = {};

  @override
  String? body;

  GetActiveWordsRequest({required int from, required int to}) {
    parameters = {
      "from": from.toString(),
      "to": to.toString(),
    };
  }
}
