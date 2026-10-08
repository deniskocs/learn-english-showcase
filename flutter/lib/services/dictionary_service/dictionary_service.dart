import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:learn_english/model/word_definition.dart';
import 'package:learn_english/ndl/components/loadable_state.dart';
import 'package:learn_english/services/config/config_service.dart';
import 'package:learn_english/model/quiz_type.dart';
import 'package:learn_english/model/trained_pair.dart';
import 'package:learn_english/model/trained_words_state.dart';

import '../../network/network.dart';
import 'package:rxdart/rxdart.dart';

enum SuccessType { trained, reachTrainedAttempt, success }

class DictionaryServiceException implements Exception {
  String cause;
  DictionaryServiceException(this.cause);
}

abstract class AbstractDictionaryService {
  abstract List<TrainedPair> additionalWords;
  abstract BehaviorSubject<TrainedWordsState> trainedWordsReactive;
  abstract BehaviorSubject<LoadableState<List<WordDefinitionDTO>>> searchResult;
  abstract BehaviorSubject<LoadableState<List<WordDefinitionDTO>>> activeWordsReactive;

  List<TrainedPair> getTrainedWords(QuizType quizType);
  Future loadData();
  Future loadActiveWords();

  Future<bool> increaseNumberOfSuccessAttempts(String word, int meaningId, QuizType quizType);
  Future increaseLearningPhase(String word, int meaningId);
  Future resetProgress(String word, int meaningId, QuizType quizType);
  Future searchDefinitions(String text);
  Future train(WordDefinitionDTO definition);
  Future repeatDefinition(String word, int meaningId);
  Future markDefinitionAsTrained(String word, int meaningId);
}

class DictionaryService extends AbstractDictionaryService {
  final AbstractNetwork network = GetIt.I.get();
  final ConfigService configService = GetIt.I.get();

  static var becameTrainedAfter = 2;

  @override
  List<TrainedPair> additionalWords = [];

  @override
  BehaviorSubject<TrainedWordsState> trainedWordsReactive = BehaviorSubject<TrainedWordsState>.seeded(TrainedWordsState.loading());

  @override
  BehaviorSubject<LoadableState<List<WordDefinitionDTO>>> searchResult =
      BehaviorSubject<LoadableState<List<WordDefinitionDTO>>>.seeded(LoadableState.nodata());

  @override
  BehaviorSubject<LoadableState<List<WordDefinitionDTO>>> activeWordsReactive =
      BehaviorSubject<LoadableState<List<WordDefinitionDTO>>>.seeded(LoadableState.loading());

  bool validate(TrainedPair trainedPair) {
    return configService.selectedStages[trainedPair.trainedPhase] ?? false;
  }

  int trainedWordIndex(String word, int meaningId) {
    final state = trainedWordsReactive.value;
    if (state.type != TrainedWordsStateType.data || state.data == null) {
      return -1;
    }
    return state.data!.indexWhere((element) => element.word == word && element.meaningId == meaningId);
  }

  void moveWordFromTrainedToAdditional(String word, int meaningId) {
    final state = trainedWordsReactive.value;
    if (state.type != TrainedWordsStateType.data || state.data == null) {
      return;
    }
    var index = trainedWordIndex(word, meaningId);
    if (index == -1) return;
    var newList = List<TrainedPair>.from(state.data!);
    var descriptor = newList.removeAt(index);
    trainedWordsReactive.value = TrainedWordsState.data(newList);
    additionalWords.add(descriptor);
  }

  @override
  List<TrainedPair> getTrainedWords(QuizType quizType) {
    final state = trainedWordsReactive.value;
    if (state.type != TrainedWordsStateType.data || state.data == null) {
      return [];
    }
    var list = state.data!.where((element) => element.fitQuizType(quizType));

    return list.where((element) => validate(element)).toList();
  }

  @override
  Future loadData() async {
    try {
      trainedWordsReactive.value = TrainedWordsState.loading();
      var response = await network.getTrainedWords();
      if (response.trainedWords.isEmpty) {
        trainedWordsReactive.value = TrainedWordsState.nodata();
      } else {
        trainedWordsReactive.value = TrainedWordsState.data(response.trainedWords);
      }
      additionalWords = response.additionalWords;
    } catch (error) {
      trainedWordsReactive.value = TrainedWordsState.error(error.toString());
      rethrow;
    }
  }

  @override
  Future<bool> increaseNumberOfSuccessAttempts(String word, int meaningId, QuizType quizType) async {
    final state = trainedWordsReactive.value;
    if (state.type != TrainedWordsStateType.data || state.data == null) {
      return true;
    }
    var index = trainedWordIndex(word, meaningId);
    if (index == -1) {
      return true;
    }
    var newList = List<TrainedPair>.from(state.data!);
    var trainedPair = newList[index];
    trainedPair.increaseNumberOfSuccessAttemptsForTrainedPair(quizType);
    trainedWordsReactive.value = TrainedWordsState.data(newList);

    try {
      var response = await network.increaseNumberOfSuccessAttempts(word, meaningId, quizType);
      if (response.trainingPhaseWasIncreased) {
        moveWordFromTrainedToAdditional(word, meaningId);
        return true;
      }
      return trainedPair.numberOfSuccessAttempts(quizType) >= DictionaryService.becameTrainedAfter;
    } catch (error) {
      throw DictionaryServiceException("Unable to update");
    }
  }

  @override
  Future increaseLearningPhase(String word, int meaningId) async {
    try {
      await network.increaseLearningPhase(word, meaningId);
      moveWordFromTrainedToAdditional(word, meaningId);
    } catch (error) {
      throw DictionaryServiceException("Error received");
    }
  }

  @override
  Future resetProgress(String word, int meaningId, QuizType quizType) async {
    final state = trainedWordsReactive.value;
    if (state.type != TrainedWordsStateType.data || state.data == null) {
      return;
    }
    var index = trainedWordIndex(word, meaningId);
    if (index == -1) return;

    try {
      await network.resetProgress(word, meaningId, quizType);
      var newList = List<TrainedPair>.from(state.data!);
      newList[index].resetNumberOfSuccessAttempts(quizType);
      trainedWordsReactive.value = TrainedWordsState.data(newList);
    } catch (error) {
      throw DictionaryServiceException("Unable to update");
    }
  }

  @override
  Future searchDefinitions(String text) async {
    try {
      log('searchDefinitions: searching for "$text"');
      searchResult.value = LoadableState.loading();
      var response = await network.searchDefinitions(text);
      log('searchDefinitions: parsed ${response.length} items');
      if (response.isEmpty) {
        searchResult.value = LoadableState.nodata();
      } else {
        searchResult.value = LoadableState.data(response);
      }
    } catch (error, stackTrace) {
      log('Error in searchDefinitions: $error');
      log('Stack trace: $stackTrace');
      searchResult.value = LoadableState.error(error.toString());
      rethrow;
    }
  }

  @override
  Future train(WordDefinitionDTO definition) async {
    try {
      await network.train(definition);
      await loadData();

      // Удаляем слово из списка найденных слов
      final currentState = searchResult.value;
      if (currentState.type == LoadableStateType.data && currentState.data != null) {
        final updatedResults =
            currentState.data!.where((item) => !(item.word == definition.word && item.meaningId == definition.meaningId)).toList();
        if (updatedResults.isEmpty) {
          searchResult.value = LoadableState.nodata();
        } else {
          searchResult.value = LoadableState.data(updatedResults);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future repeatDefinition(String word, int meaningId) async {
    _updateWordStatusInActiveWords(word, meaningId, 'Доступно для повторения');
    await network.repeatDefinition(word, meaningId);
  }

  @override
  Future markDefinitionAsTrained(String word, int meaningId) async {
    _removeWordFromActiveWords(word, meaningId);
    await network.markDefinitionAsTrained(word, meaningId);
  }

  void _removeWordFromActiveWords(String word, int meaningId) {
    final state = activeWordsReactive.value;
    var newList = List<WordDefinitionDTO>.from(state.data!);
    newList.removeWhere((element) => element.word == word && element.meaningId == meaningId);
    if (newList.isEmpty) {
      activeWordsReactive.value = LoadableState.nodata();
    } else {
      activeWordsReactive.value = LoadableState.data(newList);
    }
  }

  void _updateWordStatusInActiveWords(String word, int meaningId, String nextReview) {
    final state = activeWordsReactive.value;
    var newList = List<WordDefinitionDTO>.from(state.data!);
    var index = newList.indexWhere((element) => element.word == word && element.meaningId == meaningId);
    if (index != -1) {
      var updatedWord = WordDefinitionDTO(
        word: newList[index].word,
        translation: newList[index].translation,
        meaningId: newList[index].meaningId,
        progress: newList[index].progress,
        nextReview: nextReview,
      );
      newList[index] = updatedWord;
      activeWordsReactive.value = LoadableState<List<WordDefinitionDTO>>.data(newList);
    }
  }

  @override
  Future loadActiveWords() async {
    try {
      activeWordsReactive.value = LoadableState.loading();
      // Загружаем все данные, передавая большой диапазон
      var response = await network.getActiveWords(0, 10000);
      if (response.definitions.isEmpty) {
        activeWordsReactive.value = LoadableState.nodata();
      } else {
        activeWordsReactive.value = LoadableState.data(response.definitions);
      }
    } catch (error) {
      activeWordsReactive.value = LoadableState.error(error.toString());
      rethrow;
    }
  }
}
