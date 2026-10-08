import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learn_english/pages/app_nav_bar.dart';
import 'package:learn_english/pages/dictionary/active_words_tab.dart';
import 'package:learn_english/pages/dictionary/all_words_tab.dart';
import 'package:learn_english/pages/dictionary/toggle_selector.dart';
import 'package:learn_english/ndl/app_colors.dart';

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();

  static var barItem = BottomNavigationBarItem(
    icon: Icon(CupertinoIcons.book),
    label: 'Словарь',
  );
}

class _DictionaryPageState extends State<DictionaryPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(
        title: "Словарь",
      ),
      body: SafeArea(
        child: Padding(
          padding: Paddings.main,
          child: Column(
            spacing: Spacings.normal,
            children: [
              ToggleSelector(
                items: ["Активные", "Все слова"],
                onSelected: (index) {
                  setState(() {
                    _index = index;
                  });
                },
              ),
              _index == 0 ? ActiveWordsTab() : AllWordsTab(),
            ],
          ),
        ),
      ),
    );
  }
}
