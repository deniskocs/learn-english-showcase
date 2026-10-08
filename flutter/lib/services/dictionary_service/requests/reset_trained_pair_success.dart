import 'package:learn_english/model/quiz_type.dart';
import 'package:learn_english/network/application_request.dart';

class ResetTrainedPairSuccess implements ApplicationRequest {
  @override
  String endpoint = "training/resetTrainedPairSuccess";

  @override
  Method method = Method.get;

  @override
  Map<String, dynamic> parameters = {};

  ResetTrainedPairSuccess(String word, int meaningId, QuizType quizType) {
    parameters = {
      "word": word,
      "meaningId": "$meaningId",
      "lesson": quizType.lessonName
    };
  }

  @override
  String? body;
}
