import 'package:flutter/material.dart';
import 'package:learn_english/pages/quiz_page/answer_line.dart';
import 'package:learn_english/pages/quiz_page/exercise_task.dart';
import 'package:learn_english/pages/quiz_page/question_card.dart';
import 'package:learn_english/pages/quiz_page/exercise_view_model.dart';
import 'package:learn_english/pages/quiz_page/exercise_config.dart';
import 'package:learn_english/ndl/components/lesson_start_dialog.dart';

class ExercisePage extends StatefulWidget {
  final ExerciseViewModelAbstract viewModel;

  const ExercisePage({super.key, required this.viewModel});

  @override
  State<StatefulWidget> createState() => _ExercisePageState();

  static var englishToRussian = ExercisePage(viewModel: ExerciseViewModel(ExerciseConfigExtension.englishToRussian));

  static var russianToEnglish = ExercisePage(viewModel: ExerciseViewModel(ExerciseConfigExtension.russianToEnglish));

  static var meaningToEnglish = ExercisePage(viewModel: ExerciseViewModel(ExerciseConfigExtension.meaningToEnglish));
}

class _ExercisePageState extends State<ExercisePage> {
  late ExerciseTask _task;
  late int _activeTaskIndex;
  late int _total;

  void sync() {
    _task = widget.viewModel.getTask();
    _activeTaskIndex = widget.viewModel.taskIndex + 1;
    _total = widget.viewModel.getNumberOfTrainedPairs();
  }

  @override
  void initState() {
    super.initState();
    sync();

    widget.viewModel.onModelChanged = () {
      setState(sync);
    };

    widget.viewModel.onClose = () {
      Navigator.of(context).pop();
    };

    // Show lesson start dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final config = widget.viewModel.getConfig();
      LessonStartDialog.show(
        context,
        lessonType: config.title,
        description: config.description,
      );
    });
  }

  void onAnswerSelected(bool isCorrect) {
    widget.viewModel.onAnswerSelected(isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFcFcFd),
        elevation: 2,
        centerTitle: true,
        title: const Text(
          "Урок",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF212529),
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            QuestionCard(_task.question),
            const SizedBox(height: 6),
            Text(
              "Слово ${((_activeTaskIndex - 1) % 10) + 1} из 10 • Осталось $_total",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF6C757D),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  children: [
                    AnswerLine(
                      answers: _task.answers.sublist(0, 2),
                      onAnswerSelected: onAnswerSelected,
                    ),
                    const SizedBox(height: 12),
                    AnswerLine(
                      answers: _task.answers.sublist(2, 4),
                      onAnswerSelected: onAnswerSelected,
                    ),
                    const SizedBox(height: 12),
                    AnswerLine(
                      answers: _task.answers.sublist(4, 6),
                      onAnswerSelected: onAnswerSelected,
                    ),
                    const SizedBox(height: 12),
                    AnswerLine(
                      answers: _task.answers.sublist(6, 8),
                      onAnswerSelected: onAnswerSelected,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
