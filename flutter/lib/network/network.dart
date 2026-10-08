import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:learn_english/model/quiz_type.dart';
import 'package:learn_english/model/word_definition.dart';
import 'package:learn_english/network/application_request.dart';
import 'package:http/http.dart' as http;
import 'package:learn_english/network/authentication_request.dart';
import 'package:learn_english/network/device_authentication_request.dart';
import 'package:learn_english/network/google_connect_request.dart';
import 'dart:convert';
import 'package:learn_english/services/dictionary_service/requests/get_active_words_request.dart';
import 'package:learn_english/services/dictionary_service/requests/get_active_words_response.dart';
import 'package:learn_english/services/dictionary_service/requests/get_trained_words_request.dart';
import 'package:learn_english/services/dictionary_service/requests/get_trained_words_response.dart';
import 'package:learn_english/services/dictionary_service/requests/increase_learning_phase_request.dart';
import 'package:learn_english/services/dictionary_service/requests/increase_number_of_success_attempts_request.dart';
import 'package:learn_english/services/dictionary_service/requests/increase_number_of_success_attempts_response.dart';
import 'package:learn_english/services/dictionary_service/requests/reset_trained_pair_success.dart';
import 'package:learn_english/services/dictionary_service/requests/search_definition.dart';
import 'package:learn_english/services/parser_service/parser_service.dart';
import 'package:learn_english/services/auth_service.dart';
import 'package:learn_english/services/audio/requests/get_recordings_request.dart';
import 'package:learn_english/services/audio/requests/delete_recording_request.dart';
import 'package:learn_english/model/recordings_list_response.dart';
import 'package:get_it/get_it.dart';
import 'dart:io';

abstract class AbstractNetwork {
  String authToken = "";
  Future<IncreaseNumberOfSuccessAttemptsResponse> increaseNumberOfSuccessAttempts(String word, int meaningId, QuizType quizType);
  Future<List<WordDefinitionDTO>> searchDefinitions(String text);
  Future increaseLearningPhase(String word, int meaningId);
  Future resetProgress(String word, int meaningId, QuizType quizType);
  Future<ParseResponse> parseText(String text);
  Future<GetTrainedWordsResponse> getTrainedWords();
  Future<RecordingsListResponseDTO> getRecordings();
  Future<void> deleteRecording(String uuid);
  Future<bool> uploadRecording(String filePath, String uuid);
  Future<String?> authenticate(String googleIdToken);
  Future<String?> authenticateWithDevice(String deviceToken);
  Future<String?> connectWithGoogleAccount(String googleIdToken, String deviceKey);
  Future train(WordDefinitionDTO definition);
  Future markDefinitionAsTrained(String word, int meaningId);
  Future repeatDefinition(String word, int meaningId);

  /// Получает список активных слов пользователя
  /// Активные слова - это слова, которые находятся в процессе изучения (не выучены и не удалены)
  /// Используется для отображения списка слов, которые пользователь изучает
  Future<GetActiveWordsResponse> getActiveWords(int from, int to);

  /// Проверяет наличие интернет-подключения
  Future<bool> checkInternetConnection();

  /// Возвращает поток изменений подключения
  Stream<List<ConnectivityResult>> get onConnectivityChanged;

  /// Подписывается на изменения подключения
  void listenConnectivityChanges(void Function(List<ConnectivityResult>) onData);

  /// Отменяет подписку на изменения подключения
  void cancelConnectivitySubscription();
}

class NetworkError implements Exception {
  int statusCode;
  NetworkError(this.statusCode);
}

class Network extends AbstractNetwork {
  @override
  String authToken = "";

  final String baseUrl;
  final String scheme;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  Network({
    this.baseUrl = const String.fromEnvironment('API_HOST', defaultValue: 'localhost:8000'),
    this.scheme = 'https',
  });

  @override
  Future<bool> checkInternetConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.isEmpty || results.first == ConnectivityResult.none) {
        return false;
      }

      // Дополнительная проверка через попытку подключения
      try {
        final result = await InternetAddress.lookup(baseUrl).timeout(
          const Duration(seconds: 3),
        );
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } catch (e) {
        log('Internet check failed: $e');
        return false;
      }
    } catch (e) {
      log('Connectivity check error: $e');
      return false;
    }
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _connectivity.onConnectivityChanged;

  @override
  void listenConnectivityChanges(void Function(List<ConnectivityResult>) onData) {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(onData);
  }

  @override
  void cancelConnectivitySubscription() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  Future<dynamic> _executeRequest(ApplicationRequest request) async {
    // Добавляем задержку в 5 секунд
    // await Future.delayed(const Duration(seconds: 5));

    final uri = Uri.https(baseUrl, request.endpoint, request.parameters);
    final headers = <String, String>{
      if (authToken.isNotEmpty) 'Authorization': authToken,
    };

    final dynamic response;

    switch (request.method) {
      case Method.get:
        response = await http.get(uri, headers: headers);
        break;
      case Method.post:
        headers['Content-Type'] = 'application/json';
        response = await http.post(
          uri,
          headers: headers,
          body: request.body,
        );
        break;
    }

    final body = utf8.decode(response.bodyBytes);
    if (response.statusCode == 200) {
      try {
        return json.decode(body);
      } catch (e) {
        log('Error parsing JSON: $e');
        throw NetworkError(response.statusCode);
      }
    } else if (response.statusCode == 401) {
      // Неавторизован - токен невалиден или истек
      log('Unauthorized (401) - token may be invalid or expired');
      // Очищаем токен
      authToken = "";
      // Пытаемся очистить токен в AuthService через GetIt
      try {
        final authService = GetIt.I.get<AuthService>();
        authService.logout();
      } catch (e) {
        log('Could not access AuthService to clear token: $e');
      }
      throw NetworkError(response.statusCode);
    } else {
      log('HTTP error: ${response.statusCode}');
      throw NetworkError(response.statusCode);
    }
  }

  List<WordDefinitionDTO> _parseDefinitions(dynamic json) {
    final list = json as List<dynamic>;
    return list.map((e) => WordDefinitionDTO.fromJson(e)).toList();
  }

  @override
  Future<List<WordDefinitionDTO>> searchDefinitions(String text) async {
    var request = SearchDefinitions(text: text);
    final response = await _executeRequest(request);
    return _parseDefinitions(response);
  }

  @override
  Future<ParseResponse> parseText(String text) async {
    var request = ParseRequest(text);
    var response = await _executeRequest(request);
    return ParseResponse.fromJson(response);
  }

  @override
  Future resetProgress(String word, int meaningId, QuizType quizType) async {
    var request = ResetTrainedPairSuccess(word, meaningId, quizType);
    return _executeRequest(request);
  }

  @override
  Future increaseLearningPhase(String word, int meaningId) async {
    var request = IncreaseLearningPhaseRequest(word, meaningId);
    return _executeRequest(request);
  }

  @override
  Future<GetTrainedWordsResponse> getTrainedWords() async {
    var request = GetTrainedWordsRequest();
    final response = await _executeRequest(request);
    return GetTrainedWordsResponse.fromJson(response);
  }

  @override
  Future<RecordingsListResponseDTO> getRecordings() async {
    var request = GetRecordingsRequest();
    final response = await _executeRequest(request);
    return RecordingsListResponseDTO.fromJson(response);
  }

  @override
  Future<void> deleteRecording(String uuid) async {
    var request = DeleteRecordingRequest(uuid);
    await _executeRequest(request);
  }

  @override
  Future<bool> uploadRecording(String filePath, String uuid) async {
    final hasInternet = await checkInternetConnection();
    if (!hasInternet) {
      log('No internet connection for upload: $filePath');
      return false;
    }

    try {
      log('Uploading file: $filePath with UUID: $uuid');

      final uri = Uri.https(baseUrl, '/uploadRecording');
      final request = http.MultipartRequest('POST', uri);

      if (authToken.isNotEmpty) {
        request.headers['Authorization'] = authToken;
      }

      final file = File(filePath);
      request.files.add(
        await http.MultipartFile.fromPath('audio', filePath),
      );

      final fileName = filePath.split('/').last;
      request.fields['fileName'] = fileName;
      request.fields['timestamp'] = DateTime.now().toIso8601String();
      request.fields['uuid'] = uuid;

      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 60),
          );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        log('File uploaded successfully: $filePath');
        try {
          file.deleteSync();
          log('File deleted after successful upload: $filePath');
        } catch (e) {
          log('Error deleting file: $e');
        }
        return true;
      } else {
        log('Failed to upload file: ${response.statusCode}');
        log('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      log('Error uploading file $filePath: $e');
      return false;
    }
  }

  @override
  Future<IncreaseNumberOfSuccessAttemptsResponse> increaseNumberOfSuccessAttempts(String word, int meaningId, QuizType quizType) async {
    var request = IncreaseNumberOfSuccessAttemptsRequest(word, meaningId, quizType);
    final response = await _executeRequest(request);
    return IncreaseNumberOfSuccessAttemptsResponse.fromJson(response);
  }

  @override
  Future<String?> authenticate(String googleIdToken) async {
    var request = AuthenticationRequest(googleIdToken);
    var response = (await _executeRequest(request)) as Map<String, dynamic>;
    if (response['status'] == 'ok') {
      authToken = response['token'];
      return authToken;
    }

    log('Error during authentication');
    return null;
  }

  @override
  Future<String?> authenticateWithDevice(String deviceToken) async {
    var request = DeviceAuthenticationRequest(deviceToken);
    var response = (await _executeRequest(request)) as Map<String, dynamic>;
    if (response['status'] == 'ok') {
      authToken = response['token'];
      return authToken;
    }

    log('Error during device authentication');
    return null;
  }

  @override
  Future<String?> connectWithGoogleAccount(String googleIdToken, String deviceKey) async {
    var request = GoogleConnectRequest(googleIdToken, deviceKey);
    var response = (await _executeRequest(request)) as Map<String, dynamic>;
    if (response['status'] == 'ok') {
      authToken = response['token'];
      return authToken;
    }

    log('Error during Google account connection');
    return null;
  }

  @override
  Future train(WordDefinitionDTO definition) async {
    var request = TrainDefinitionRequest(word: definition.word, meaningId: definition.meaningId ?? 0);
    return await _executeRequest(request);
  }

  @override
  Future markDefinitionAsTrained(String word, int meaningId) async {
    var request = MarkDefinitionAsTrainedRequest(word: word, meaningId: meaningId);
    return await _executeRequest(request);
  }

  @override
  Future repeatDefinition(String word, int meaningId) async {
    var request = RepeatDefinitionRequest(word: word, meaningId: meaningId);
    return await _executeRequest(request);
  }

  @override
  Future<GetActiveWordsResponse> getActiveWords(int from, int to) async {
    var request = GetActiveWordsRequest(from: from, to: to);
    final response = await _executeRequest(request);
    return GetActiveWordsResponse.fromJson(response);
  }
}

class TrainDefinitionRequest implements ApplicationRequest {
  @override
  String endpoint = "/trainDefinition";

  @override
  Method method = Method.get;

  @override
  Map<String, dynamic> parameters = {};

  TrainDefinitionRequest({required String word, required int meaningId}) {
    parameters = {"word": word, "id": meaningId.toString()};
  }

  @override
  String? body;
}

class MarkDefinitionAsTrainedRequest implements ApplicationRequest {
  @override
  String endpoint = "/markDefinitionAsTrained";

  @override
  Method method = Method.get;

  @override
  Map<String, dynamic> parameters = {};

  MarkDefinitionAsTrainedRequest({required String word, required int meaningId}) {
    parameters = {"word": word, "id": meaningId.toString()};
  }

  @override
  String? body;
}

class RepeatDefinitionRequest implements ApplicationRequest {
  @override
  String endpoint = "/repeatDefinition";

  @override
  Method method = Method.get;

  @override
  Map<String, dynamic> parameters = {};

  RepeatDefinitionRequest({required String word, required int meaningId}) {
    parameters = {"word": word, "id": meaningId.toString()};
  }

  @override
  String? body;
}
