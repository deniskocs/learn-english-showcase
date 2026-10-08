

import 'package:learn_english/model/quiz_type.dart';
import 'package:learn_english/network/application_request.dart';

class IncreaseNumberOfSuccessAttemptsRequest implements ApplicationRequest {
  @override
  String endpoint = "training/increaseNumberOfSuccessAttempts";

  @override
  Method method = Method.get;

  @override
  Map<String, dynamic> parameters = {};

  IncreaseNumberOfSuccessAttemptsRequest(String word, int meaningId, QuizType quizType) {
    parameters = {
      "word": word,
      "meaningId": "$meaningId",
      "quizType": quizType.lessonName
    };
  }

  @override
  String? body;
}
