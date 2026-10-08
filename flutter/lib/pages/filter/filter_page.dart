import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:learn_english/services/dictionary_service/dictionary_service.dart';
import 'package:learn_english/model/trained_words_state.dart';

import '../../services/config/config_service.dart';

class FilterElement extends StatefulWidget {
  final String text;
  final bool selected;
  final Function(bool selected) onTap;

  const FilterElement(
      {super.key,
      required this.text,
      required this.selected,
      required this.onTap});

  @override
  State<StatefulWidget> createState() {
    return _FilterElementState();
  }
}

class _FilterElementState extends State<FilterElement> {
  bool _selected = false;

  @override
  void initState() {
    super.initState();

    _selected = widget.selected;
  }

  void onTap() {
    widget.onTap(!_selected);
    setState(() {
      _selected = !_selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: onTap,
          child: Row(children: [
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: _selected ? Colors.blue : Colors.transparent,
                  border: Border.all(color: Colors.black)),
            ),
            const SizedBox(width: 8),
            Text(widget.text)
          ]),
        ),
      ),
      const Divider(height: 1),
    ]);
  }
}

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _FilterPageState();
  }
}

class _FilterPageState extends State<FilterPage> {
  final AbstractDictionaryService dictionaryService = GetIt.I.get();
  final ConfigService configService = GetIt.I.get();

  var _maxPhase = 0;
  final Map<int, int> _phases = <int, int>{};

  @override
  void initState() {
    super.initState();

    final state = dictionaryService.trainedWordsReactive.value;
    if (state.type == TrainedWordsStateType.data && state.data != null) {
      for (var element in state.data!) {
        if (element.trainedPhase > _maxPhase) {
          _maxPhase = element.trainedPhase;
        }

        var count = _phases[element.trainedPhase] ?? 0;
        _phases[element.trainedPhase] = count + 1;
      }
    }
  }

  void onTap(int phase, bool selected) {
    configService.selectedStages[phase] = selected;
    configService.update();
  }

  List<Widget> buildList() {
    List<Widget> list = <Widget>[];
    for (int i = 0; i < _maxPhase; i++) {
      if (_phases[i + 1] == null) {
        continue;
      }
      list.add(FilterElement(
        text: "Phase ${i + 1} (${_phases[i + 1]})",
        selected: configService.selectedStages[i + 1] ?? false,
        onTap: (selected) {
          onTap(i + 1, selected);
        },
      ));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final state = dictionaryService.trainedWordsReactive.value;
    final count = state.type == TrainedWordsStateType.data ? state.words.length : 0;
    return Scaffold(
      appBar: AppBar(
          title: Text("Filter ($count)")),
      body: Center(
        child: Column(
          children: buildList(),
        ),
      ),
    );
  }
}
