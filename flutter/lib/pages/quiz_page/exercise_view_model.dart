import 'dart:collection';
import 'dart:math';

import 'package:get_it/get_it.dart';
import 'package:learn_english/utils/utils.dart';
import 'package:learn_english/model/trained_pair.dart';
import 'package:learn_english/pages/quiz_page/exercise_config.dart';
import 'package:learn_english/pages/quiz_page/exercise_task.dart';
import 'package:learn_english/services/audio/audio_service.dart';
import 'package:learn_english/services/dictionary_service/dictionary_service.dart';
import 'package:collection/collection.dart';

abstract class ExerciseViewModelAbstract {
  ExerciseTask getTask();
  int getNumberOfTrainedPairs();
  ExerciseConfig getConfig();

  abstract int taskIndex;

  abstract Function onModelChanged;
  abstract Function onClose;

  void onAnswerSelected(bool isCorrect);
}

class ExerciseViewModel implements ExerciseViewModelAbstract {
  static var testsChunkSize = 10;

  @override
  int taskIndex = 0;
  final AudioService _audioService = GetIt.I.get();
  final AbstractDictionaryService _dictionaryService = GetIt.I.get();
  var tasks = <ExerciseTask>[];
  final ExerciseConfig _config;

  bool _wrongAnswerWasSelectedInCurrentTask = false;

  @override
  late Function onModelChanged;
  @override
  late Function onClose;

  ExerciseViewModel(ExerciseConfig config) : _config = config {
    buildTasks();
  }

  @override
  ExerciseTask getTask() {
    return tasks[taskIndex];
  }

  @override
  int getNumberOfTrainedPairs() {
    return getWordsToTrain();
  }

  @override
  ExerciseConfig getConfig() {
    return _config;
  }

  @override
  void onAnswerSelected(bool isCorrect) async {
    var task = getTask();
    if (isCorrect) {
      _audioService.playWord(task.word);

      if (!_wrongAnswerWasSelectedInCurrentTask && !task.completed) {
        task.completed = await _dictionaryService.increaseNumberOfSuccessAttempts(task.word, task.meaningId, _config.type);
      }

      var delay = _wrongAnswerWasSelectedInCurrentTask ? 3 : 1;
      _wrongAnswerWasSelectedInCurrentTask = false;
      processIncreaseSuccess(delay);
    } else {
      _wrongAnswerWasSelectedInCurrentTask = true;
      if (task.completed) {
        return;
      }

      try {
        await _dictionaryService.resetProgress(task.word, task.meaningId, _config.type);
      } catch (error) {
        // print("Unable to update $error");
      }
    }
  }

  void processIncreaseSuccess(int delay) {
    taskIndex += 1;

    if (taskIndex == tasks.length) {
      if (getWordsToTrain() == 0) {
        onClose();
        return;
      }

      var allWordsWereTrainedSuccessfully = tasks.firstWhereOrNull((element) => element.completed == false) == null;

      if (allWordsWereTrainedSuccessfully) {
        buildTasks();
      } else {
        tasks = Utils.mix(tasks.toList());
      }

      taskIndex = 0;
    }

    showNextQuestionAfterDelay(delay);
  }

  void showNextQuestionAfterDelay(int delay) {
    Future.delayed(Duration(seconds: delay), () => {getTask().mix(), onModelChanged()});
  }

  int getWordsToTrain() {
    return getTrainedPairs().length;
  }

  List<TrainedPair> getTrainedPairs() {
    return _dictionaryService.getTrainedWords(_config.type);
  }

  List<TrainedPair> getAdditionalTrainedPairs() {
    return _dictionaryService.additionalWords;
  }

  void buildTasks() {
    // Build set of words for training
    // there shouldn't be two training pairs with the same word
    // to prevent user mistakes during training phase
    var trainedPairs = getTrainedPairs();
    var reducedTrainedWords = reducePairsList(trainedPairs);
    // Try to get limit of trained words

    var numberOfWords = min(testsChunkSize, reducedTrainedWords.length);
    var trainingSet = reducedTrainedWords.getRange(0, numberOfWords).toList();
    var additionalTrainedPairs = List<TrainedPair>.from(getAdditionalTrainedPairs());

    var additionalTrainedPairsMixed = Utils.mix(additionalTrainedPairs);

    while (trainingSet.length < testsChunkSize) {
      var additionalPair = additionalTrainedPairsMixed.removeAt(0);
      // Add only pairs with word which isn't exist in training set

      var searchResult = trainingSet.where((element) => element.word == additionalPair.word);

      if (searchResult.isEmpty) {
        trainingSet.add(additionalPair);
      }
    }

    tasks.clear();
    var allPairs = trainedPairs + additionalTrainedPairs;

    for (var pair in trainingSet) {
      var wrongAnswers = HashSet<String>();
      for (var secondPair in allPairs) {
        if (pair.word != secondPair.word && !wrongAnswers.contains(_config.answer(secondPair))) {
          wrongAnswers.add(_config.answer(secondPair));
        }
      }
      var mixedWrongAnswers = Utils.mix(wrongAnswers.toList());
      tasks.add(ExerciseTask(pair.word, pair.meaningId, _config.question(pair), _config.answer(pair), mixedWrongAnswers));
    }
    tasks = Utils.mix(tasks.toList());
  }
}

List<TrainedPair> reducePairsList(List<TrainedPair> src) {
  Map<String, TrainedPair> map = <String, TrainedPair>{};
  for (var element in src) {
    map[element.word] = element;
  }

  var list = map.values.toList();
  list.sort((a, b) => a.word.compareTo(b.word));
  return list;
}
