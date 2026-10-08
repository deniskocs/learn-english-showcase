import 'package:learn_english/model/trained_pair.dart';

class GetTrainedWordsResponse {
  final List<TrainedPair> trainedWords;
  final List<TrainedPair> additionalWords;

  GetTrainedWordsResponse({required this.trainedWords, required this.additionalWords});

  factory GetTrainedWordsResponse.fromJson(dynamic json1) {
    final json = json1 as Map<String, dynamic>;
    final trainedWords = json['trainedWords'] as List<dynamic>;
    final additionalWords = json['additionalWords'] as List<dynamic>;
    return GetTrainedWordsResponse(
      trainedWords: trainedWords.map((e) => TrainedPair.fromJson(e)).toList(),
      additionalWords: additionalWords.map((e) => TrainedPair.fromJson(e)).toList(),
    );
  }
}
