import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:learn_english/model/word_definition.dart';
import 'package:learn_english/pages/app_nav_bar.dart';
import 'package:learn_english/pages/dictionary/definition_item.dart';
import 'package:learn_english/services/parser_service/parser_service.dart';
import 'package:learn_english/ndl/components/loadable_state.dart';
import 'package:learn_english/ndl/components/separated_list_view.dart';
import 'package:learn_english/ndl/components/loadable_component.dart';

class RecordingAnalysisPage extends StatefulWidget {
  final String englishText;
  final String recordingTitle;

  const RecordingAnalysisPage({
    super.key,
    required this.englishText,
    required this.recordingTitle,
  });

  @override
  State<RecordingAnalysisPage> createState() => _RecordingAnalysisPageState();
}

class _RecordingAnalysisPageState extends State<RecordingAnalysisPage> {
  final AbstractParserService _parserService = GetIt.I.get();

  Future<void> _analyzeText() async {
    await _parserService.parseText(widget.englishText);
  }

  Widget _buildContent() {
    return LoadableComponent<List<ParsedWordDescriptor>, LoadableState<List<ParsedWordDescriptor>>>(
      stateStream: _parserService.wordsStream.stream,
      loadFunction: _analyzeText,
      dataContentBuilder: (context, words) {
        return SeparatedListView<ParsedWordDescriptor>(
          items: words,
          emptyMessage: 'Не найдено новых слов для изучения',
          itemBuilder: (context, wordDescriptor, index) {
            final meaning = wordDescriptor.meanings.first;

            return DefinitionItem(
              item: WordDefinitionDTO(
                word: wordDescriptor.word,
                translation: meaning.translation,
                meaningId: meaning.meaningId,
              ),
              onTrainPressed: () => _parserService.trainWord(wordDescriptor.word, meaning.meaningId),
              onMarkAsTrainedPressed: () => _parserService.markAsTrained(wordDescriptor.word, meaning.meaningId),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppNavBar(
        title: widget.recordingTitle,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
