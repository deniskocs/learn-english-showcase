import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:learn_english/ndl/app_text_styles.dart';
import 'package:learn_english/services/config/config_service.dart';
import 'package:learn_english/services/dictionary_service/dictionary_service.dart';
import 'package:learn_english/model/quiz_type.dart';
import 'package:learn_english/model/trained_words_state.dart';
import 'package:learn_english/pages/main_page/lesson_card.dart';
import 'package:learn_english/pages/app_nav_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:learn_english/ndl/app_colors.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MainPageState();
  }

  static var barItem = BottomNavigationBarItem(
    icon: Icon(CupertinoIcons.lightbulb),
    label: 'Уроки',
  );
}

class _MainPageState extends State<MainPage> {
  final AbstractDictionaryService dictionaryService = GetIt.I.get();
  final ConfigService configService = GetIt.I.get();

  int _numberOfWordsLeft = 0;
  int _englishToRussianWordsLeft = 0;
  int _russianToEnglishWordsLeft = 0;
  int _meaningToEnglishWordsLeft = 0;
  Timer? _refreshTimer;

  @override
  initState() {
    super.initState();

    _loadData();

    dictionaryService.trainedWordsReactive.listen((value) {
      updateNumberOfWords();
    });

    configService.addSubscriber(() {
      updateNumberOfWords();
    });

    // Автоматическая перезагрузка данных каждую минуту
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _loadData();
    });
  }

  void _loadData() {
    var result = dictionaryService.loadData();
    result.then((value) => {updateNumberOfWords()});
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  int numberOfWords(QuizType type) {
    return dictionaryService.getTrainedWords(type).length;
  }

  void updateNumberOfWords() {
    setState(() {
      final state = dictionaryService.trainedWordsReactive.value;
      _loading = state.type == TrainedWordsStateType.loading;
      if (state.type == TrainedWordsStateType.data) {
        _numberOfWordsLeft = state.words.length;
      } else {
        _numberOfWordsLeft = 0;
      }
      _englishToRussianWordsLeft = numberOfWords(QuizType.englishToRussian);
      _russianToEnglishWordsLeft = numberOfWords(QuizType.russianToEnglish);
      _meaningToEnglishWordsLeft = numberOfWords(QuizType.meaningToEnglish);
    });
  }

  bool _loading = true;

  void didFilterTapped() {
    Navigator.pushNamed(context, '/filter');
  }

  LessonCard englishToRussian(BuildContext context) {
    return LessonCard(
      lessonName: "Английски -> Русский",
      wordsLeft: _englishToRussianWordsLeft,
      onTap: () => {Navigator.pushNamed(context, '/englishToRussianExercise')},
    );
  }

  LessonCard russianToEnglish(BuildContext context) {
    return LessonCard(
      lessonName: "Русский -> Английски",
      wordsLeft: _russianToEnglishWordsLeft,
      onTap: () => {Navigator.pushNamed(context, '/russianToEnglishExercise')},
    );
  }

  LessonCard meaningToEnglish(BuildContext context) {
    return LessonCard(
      lessonName: "Значение -> Слово",
      wordsLeft: _meaningToEnglishWordsLeft,
      onTap: () => {Navigator.pushNamed(context, '/meaningToEnglishExercise')},
    );
  }

  Widget buildList(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
            child: Padding(
                padding: Paddings.main,
                child: Column(spacing: Spacings.normal, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(
                    "В изучении: $_numberOfWordsLeft",
                    style: AppTextStyles.subtitle,
                  ),
                  englishToRussian(context),
                  russianToEnglish(context),
                  meaningToEnglish(context)
                ]))));
  }

  @override
  Widget build(BuildContext context) {
    final state = dictionaryService.trainedWordsReactive.value;
    return Scaffold(
        appBar: AppNavBar(title: "Learn English", didFilterTapped: didFilterTapped),
        body: _loading || state.type == TrainedWordsStateType.loading
            ? const Center(child: CircularProgressIndicator())
            : state.type == TrainedWordsStateType.error
                ? Center(child: Text('Ошибка: ${state.errorMessage ?? "Неизвестная ошибка"}'))
                : buildList(context));
  }
}
