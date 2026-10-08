import 'package:learn_english/model/quiz_type.dart';
import 'package:learn_english/model/trained_pair.dart';

class ExerciseConfig {
  bool pronounceWhenAppeared;
  bool showPlayButton;
  QuizType type;
  String Function(TrainedPair) question;
  String Function(TrainedPair) answer;
  String title;
  String description;

  ExerciseConfig({
    required this.pronounceWhenAppeared,
    required this.showPlayButton,
    required this.type,
    required this.question,
    required this.answer,
    required this.title,
    required this.description,
  });
}

extension ExerciseConfigExtension on ExerciseConfig {
  static var meaningToEnglish = ExerciseConfig(
      pronounceWhenAppeared: false,
      showPlayButton: false,
      type: QuizType.meaningToEnglish,
      question: (pair) => pair.meaning,
      answer: (pair) => pair.word,
      title: 'Выбор слова по значению',
      description:
          'В этом уроке вам будет показано значение слова, и вы должны выбрать правильное английское слово из предложенных вариантов.\n\nЧтобы слово считалось изученным, нужно дважды подряд выбрать правильный ответ. Это поможет лучше запомнить новые слова и закрепить их в памяти.');
  static var englishToRussian = ExerciseConfig(
      pronounceWhenAppeared: true,
      showPlayButton: true,
      type: QuizType.englishToRussian,
      question: (pair) => pair.word,
      answer: (pair) => pair.translations,
      title: 'Перевод на русский',
      description:
          'В этом уроке вам будет показано английское слово, и вы должны выбрать правильный русский перевод из предложенных вариантов.\n\nЧтобы слово считалось изученным, нужно дважды подряд выбрать правильный ответ. Это поможет лучше запомнить новые слова и закрепить их в памяти.');
  static var russianToEnglish = ExerciseConfig(
      pronounceWhenAppeared: false,
      showPlayButton: false,
      type: QuizType.russianToEnglish,
      question: (pair) => pair.translations,
      answer: (pair) => pair.word,
      title: 'Перевод на английский',
      description:
          'В этом уроке вам будет показан русский перевод, и вы должны выбрать правильное английское слово из предложенных вариантов.\n\nЧтобы слово считалось изученным, нужно дважды подряд выбрать правильный ответ. Это поможет лучше запомнить новые слова и закрепить их в памяти.');
}
