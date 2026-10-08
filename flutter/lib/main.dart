import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:learn_english/ndl/app_colors.dart';
import 'package:learn_english/network/network.dart';
import 'package:learn_english/pages/filter/filter_new_page.dart';
import 'package:learn_english/pages/root_page.dart';
import 'package:learn_english/pages/login/login.dart';
import 'package:learn_english/pages/quiz_page/exercise_view_model.dart';
import 'package:learn_english/services/audio/audio_service.dart';
import 'package:learn_english/services/audio/audio_recording_service.dart';
import 'package:learn_english/services/audio/native_audio_channels.dart';
import 'package:learn_english/services/config/config_service.dart';
import 'package:learn_english/services/dictionary_service/dictionary_service.dart';
import 'package:learn_english/services/parser_service/parser_service.dart';
import 'package:learn_english/services/auth_service.dart';
import 'package:learn_english/pages/quiz_page/exercise_config.dart';
import 'pages/quiz_page/exercise_page.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GetIt.I.registerSingleton<AbstractNetwork>(Network());
  GetIt.I.registerSingleton<ConfigService>(ConfigService());
  GetIt.I.registerSingleton<NativeAudioChannels>(NativeAudioChannels.create());
  GetIt.I.registerLazySingleton<AudioService>(() => AudioServiceImpl());
  GetIt.I.registerLazySingleton<AudioRecordingService>(() => AudioRecordingServiceImpl());
  GetIt.I.registerSingleton<AbstractDictionaryService>(DictionaryService());
  GetIt.I.registerSingleton<AbstractParserService>(ParserService());
  GetIt.I.registerFactoryParam<ExerciseViewModelAbstract, ExerciseConfig, void>((config, _) => ExerciseViewModel(config));
  GetIt.I.registerSingleton<AuthService>(AuthService());

  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthService _auth;

  @override
  void initState() {
    super.initState();
    _auth = GetIt.I<AuthService>();
  }

  ThemeData _buildTheme() {
    return ThemeData(primaryColor: AppColors.primary);
  }

  Widget _buildHome(AuthState state) {
    switch (state) {
      case AuthState.initializing:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case AuthState.loggedIn:
        return const RootPage();
      case AuthState.error:
        return const LoginPage();
    }
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/filter': (_) => const FiltersPage(),
      '/englishToRussianExercise': (_) => ExercisePage.englishToRussian,
      '/russianToEnglishExercise': (_) => ExercisePage.russianToEnglish,
      '/meaningToEnglishExercise': (_) => ExercisePage.meaningToEnglish,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthState>(
      valueListenable: _auth.state,
      builder: (context, authState, _) {
        return MaterialApp(
          title: 'Learn English',
          theme: _buildTheme(),
          home: _buildHome(authState),
          routes: _buildRoutes(),
        );
      },
    );
  }
}
