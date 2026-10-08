import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:learn_english/pages/dictionary/definition_item.dart';
import 'package:learn_english/pages/dictionary/search_widget.dart';
import 'package:learn_english/services/dictionary_service/dictionary_service.dart';
import 'package:learn_english/ndl/components/loadable_state.dart';
import 'package:learn_english/model/word_definition.dart';
import 'package:learn_english/ndl/components/separated_list_view.dart';
import 'package:learn_english/ndl/components/loadable_component.dart';

class AllWordsTab extends StatefulWidget {
  const AllWordsTab({super.key});

  @override
  State<AllWordsTab> createState() => _AllWordsTabState();
}

class _AllWordsTabState extends State<AllWordsTab> {
  final AbstractDictionaryService _dictionaryService = GetIt.I.get();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          SearchWidget(onSearch: (text) => {_dictionaryService.searchDefinitions(text)}),
          Expanded(
            child: LoadableComponent<List<WordDefinitionDTO>, LoadableState<List<WordDefinitionDTO>>>(
              stateStream: _dictionaryService.searchResult.stream,
              loadFunction: () async {
                // Поиск инициируется через SearchWidget, поэтому здесь пустая функция
              },
              dataContentBuilder: (context, words) {
                return SeparatedListView<WordDefinitionDTO>(
                  items: words,
                  emptyMessage: 'Ничего не найдено',
                  itemBuilder: (context, word, index) {
                    return DefinitionItem(
                      item: word,
                      onTrainPressed: () => {_dictionaryService.train(word)},
                      onMarkAsTrainedPressed: null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
