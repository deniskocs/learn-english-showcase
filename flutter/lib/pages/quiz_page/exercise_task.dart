import 'package:learn_english/pages/quiz_page/answer_descriptor.dart';
import 'package:learn_english/utils/utils.dart';

class ExerciseTask {
  String word;
  int meaningId;

  String question;
  List<AnswerDescriptor> answers = <AnswerDescriptor>[];

  bool completed = false;

  ExerciseTask(this.word, this.meaningId, this.question, String correctAnswer,
      List<String> wrongAnswers) {
    answers.add(AnswerDescriptor(correctAnswer, true));

    for (int i = 0; i < 7; i++) {
      answers.add(AnswerDescriptor(wrongAnswers[i], false));
    }

    answers = Utils.mix(answers);
  }

  void mix() {
    answers = Utils.mix(answers);
  }
}
