import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:learn_english/ndl/components/active_word_definition_item.dart';
import 'package:learn_english/ndl/components/loadable_component.dart';
import 'package:learn_english/ndl/components/loadable_state.dart';
import 'package:learn_english/ndl/components/separated_list_view.dart';
import 'package:learn_english/services/dictionary_service/dictionary_service.dart';
import 'package:learn_english/model/word_definition.dart';

class ActiveWordsTab extends StatefulWidget {
  const ActiveWordsTab({super.key});

  @override
  State<ActiveWordsTab> createState() => _ActiveWordsTabState();
}

class _ActiveWordsTabState extends State<ActiveWordsTab> {
  final AbstractDictionaryService _dictionaryService = GetIt.I.get();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LoadableComponent<List<WordDefinitionDTO>, LoadableState<List<WordDefinitionDTO>>>(
        stateStream: _dictionaryService.activeWordsReactive.stream,
        loadFunction: () => _dictionaryService.loadActiveWords(),
        dataContentBuilder: (context, items) {
          return SeparatedListView<WordDefinitionDTO>(
            items: items,
            emptyMessage: 'Нет слов',
            itemBuilder: (context, word, index) {
              return ActiveWordDefinitionItem(
                item: word,
                onTrainPressed: () async {
                  await _dictionaryService.repeatDefinition(word.word, word.meaningId!);
                },
                onMarkAsTrainedPressed: () async {
                  await _dictionaryService.markDefinitionAsTrained(word.word, word.meaningId!);
                },
              );
            },
          );
        },
      ),
    );
  }
}
