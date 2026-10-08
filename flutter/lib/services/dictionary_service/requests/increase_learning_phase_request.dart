import 'package:learn_english/network/application_request.dart';

class IncreaseLearningPhaseRequest implements ApplicationRequest {
  @override
  String endpoint = "training/increasePhase";

  @override
  Method method = Method.get;

  @override
  Map<String, dynamic> parameters = {};

  IncreaseLearningPhaseRequest(String word, int meaningId) {
    parameters = {
      "word": word,
      "meaningId": meaningId
    };
  }

  @override
  String? body;
}
