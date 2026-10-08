import 'quiz_type.dart';

class TrainedPair {
  final String word;
  final int meaningId;

  final int trainedPhase;

  int englishToRussianSuccessAttemptsCount;
  int russianToEnglishSuccessAttemptsCount;
  int meaningToEnglishSuccessAttemptsCount;

  final String meaning;
  final String translations;

  final List<String> examples;

  final int maxNumberOfSuccessAttempts = 2;

  TrainedPair(this.word,
              this.meaningId,
              this.trainedPhase,
              this.englishToRussianSuccessAttemptsCount,
              this.russianToEnglishSuccessAttemptsCount,
              this.meaningToEnglishSuccessAttemptsCount,
              this.meaning,
              this.translations,
              this.examples);

  int numberOfSuccessAttempts(QuizType quizType)  {
    switch (quizType) {
      case QuizType.englishToRussian:
        return englishToRussianSuccessAttemptsCount;
      case QuizType.russianToEnglish:
        return russianToEnglishSuccessAttemptsCount;
      case QuizType.meaningToEnglish:
        return meaningToEnglishSuccessAttemptsCount;
    }
  }

  factory TrainedPair.fromJson(Map<String, dynamic> json) {
    return TrainedPair(
        json['word'] as String,
        json['meaningId'] as int,
        json['trainedPhase'] as int,
        json['englishToRussianSuccessAttemptsCount'] as int,
        json['russianToEnglishSuccessAttemptsCount'] as int,
        json['meaningToEnglishSuccessAttemptsCount'] as int,
        json['meaning'] as String,
        json['translations'] as String,
        (json['examples'] as List<dynamic>).map((e) => e as String).toList()
    );
  }
}

extension TrainedPairExtension on TrainedPair {
  void resetNumberOfSuccessAttempts(QuizType quizType) {
    switch (quizType) {
      case QuizType.meaningToEnglish:
        meaningToEnglishSuccessAttemptsCount = 0;
        break;
      case QuizType.englishToRussian:
        englishToRussianSuccessAttemptsCount = 0;
        break;
      case QuizType.russianToEnglish:
        russianToEnglishSuccessAttemptsCount = 0;
        break;
    }
  }

  void increaseNumberOfSuccessAttemptsForTrainedPair(QuizType quizType) {
    switch (quizType) {
      case QuizType.meaningToEnglish:
        meaningToEnglishSuccessAttemptsCount += 1;
        break;
      case QuizType.englishToRussian:
        englishToRussianSuccessAttemptsCount += 1;
        break;
      case QuizType.russianToEnglish:
        russianToEnglishSuccessAttemptsCount += 1;
        break;
    }
  }
}

extension LessonFilters on TrainedPair {
  bool fitMeaningToEnglish() {
    return meaningToEnglishSuccessAttemptsCount < maxNumberOfSuccessAttempts &&
        englishToRussianSuccessAttemptsCount >= maxNumberOfSuccessAttempts &&
        russianToEnglishSuccessAttemptsCount >= maxNumberOfSuccessAttempts;
  }

  bool fitRussianToEnglish() {
    return russianToEnglishSuccessAttemptsCount < maxNumberOfSuccessAttempts &&
        englishToRussianSuccessAttemptsCount >= maxNumberOfSuccessAttempts;
  }

  bool fitEnglishToRussian() {
    return englishToRussianSuccessAttemptsCount < maxNumberOfSuccessAttempts;
  }

  bool fitQuizType(QuizType quizType) {
    switch (quizType) {
      case QuizType.meaningToEnglish:
        return fitMeaningToEnglish();
      case QuizType.russianToEnglish:
        return fitRussianToEnglish();
      case QuizType.englishToRussian:
        return fitEnglishToRussian();
    }
  }
}