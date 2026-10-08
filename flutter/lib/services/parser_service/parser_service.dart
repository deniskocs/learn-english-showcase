import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:learn_english/network/network.dart';
import 'package:learn_english/model/word_definition.dart';
import 'package:rxdart/rxdart.dart';

import '../../network/application_request.dart';
import '../../ndl/components/loadable_state.dart';

class ParseRequest implements ApplicationRequest {
  @override
  String endpoint = "parse";

  @override
  Method method = Method.post;

  @override
  Map<String, dynamic> parameters = {};

  ParseRequest(String text) {
    body = json.encode({'text': text, 'minimalRepeatNumber': 1});
  }

  @override
  String? body;
}

class Meaning {
  Meaning(this.meaningId, this.meaning, this.translation, this.examples);

  final int meaningId;
  final String meaning;
  final String translation;
  final List<String> examples;
}

class ParsedWordDescriptor {
  ParsedWordDescriptor(this.word, this.rate, this.context, this.meanings);

  final String word;
  final int rate;
  final String context;
  final List<Meaning> meanings;

  factory ParsedWordDescriptor.fromJson(Map<String, dynamic> json) {
    final meaningsJson = json["meanings"] as List<dynamic>? ?? [];
    final meanings = meaningsJson.map((m) {
      final meaningJson = m as Map<String, dynamic>;
      return Meaning(
        meaningJson["meaningId"] as int? ?? 0,
        meaningJson["meaning"] as String? ?? "",
        meaningJson["translation"] as String? ?? "",
        (meaningJson["examples"] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      );
    }).toList();

    return ParsedWordDescriptor(
      json["word"] as String? ?? "",
      json["rate"] as int? ?? 0,
      json["context"] as String? ?? "",
      meanings,
    );
  }
}

class ParseResponse {
  final List<ParsedWordDescriptor> descriptors;

  ParseResponse(this.descriptors);

  factory ParseResponse.fromJson(dynamic json) {
    final descriptors = json as List<dynamic>;
    return ParseResponse(
      descriptors.map((e) => ParsedWordDescriptor.fromJson(e)).toList(),
    );
  }
}

abstract class AbstractParserService {
  Future<void> parseText(String text);
  Future<void> markAsTrained(String word, int meaningId);
  Future<void> trainWord(String word, int meaningId);
  BehaviorSubject<LoadableState<List<ParsedWordDescriptor>>> get wordsStream;
}

class ParserService implements AbstractParserService {
  final AbstractNetwork network = GetIt.I.get();

  @override
  BehaviorSubject<LoadableState<List<ParsedWordDescriptor>>> wordsStream =
      BehaviorSubject<LoadableState<List<ParsedWordDescriptor>>>.seeded(LoadableState.loading());

  @override
  Future<void> parseText(String text) async {
    wordsStream.value = LoadableState.loading();
    try {
      final response = await network.parseText(text);
      if (response.descriptors.isEmpty) {
        wordsStream.value = LoadableState.nodata();
      } else {
        wordsStream.value = LoadableState.data(response.descriptors);
      }
    } catch (error) {
      wordsStream.value = LoadableState.error('Ошибка при анализе текста: ${error.toString()}');
    }
  }

  void _removeWordFromWords(String word, int meaningId) {
    final state = wordsStream.value;
    if (state.type == LoadableStateType.data && state.data != null) {
      final newList = state.data!.where((item) {
        return !(item.word == word && item.meanings.any((m) => m.meaningId == meaningId));
      }).toList();

      if (newList.isEmpty) {
        wordsStream.value = LoadableState.nodata();
      } else {
        wordsStream.value = LoadableState.data(newList);
      }
    }
  }

  @override
  Future<void> markAsTrained(String word, int meaningId) async {
    _removeWordFromWords(word, meaningId);
    await network.markDefinitionAsTrained(word, meaningId);
  }

  @override
  Future<void> trainWord(String word, int meaningId) async {
    _removeWordFromWords(word, meaningId);
    await network.train(WordDefinitionDTO(
      word: word,
      translation: '',
      meaningId: meaningId,
    ));
  }
}
