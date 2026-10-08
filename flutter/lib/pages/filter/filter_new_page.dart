import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learn_english/pages/app_nav_bar.dart';

class FiltersPage extends StatefulWidget {
  const FiltersPage({super.key});

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  bool newWords = true;
  bool repeatedWords = true;

  final Set<String> _activeTags = {'Бизнес', 'Путешествия', 'Фильмы'};

  final List<String> _allTags = [
    'Бизнес',
    'Путешествия',
    'Фильмы',
    'Повседневное',
    'Сленг',
    'IELTS',
    'Работа',
    'Музыка',
    'Погода',
    'Новости',
    'Технологии',
    'Общение',
  ];

  int get wordCount {
    int base = 50;
    if (newWords) base += 60;
    if (repeatedWords) base += 40;
    base += _activeTags.length * 5;
    return base;
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_activeTags.contains(tag)) {
        _activeTags.remove(tag);
      } else {
        _activeTags.add(tag);
      }
    });
  }

  void _resetFilters() {
    setState(() {
      newWords = true;
      repeatedWords = true;
      _activeTags.clear();
      _activeTags.addAll(['Бизнес', 'Путешествия', 'Фильмы']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppNavBar(title: 'Фильтры'),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 140),
            children: [
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Найдено: $wordCount слов',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6c757d),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Тип слов
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  'Тип слов',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6e6e73),
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _buildSwitchRow('Новые слова', newWords, (v) {
                      setState(() => newWords = v);
                    }),
                    const Divider(height: 0),
                    _buildSwitchRow('Повторяемые слова', repeatedWords, (v) {
                      setState(() => repeatedWords = v);
                    }),
                  ],
                ),
              ),

              // Категории
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Категории (теги)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6e6e73),
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allTags.map((t) {
                    final active = _activeTags.contains(t);
                    return GestureDetector(
                      onTap: () => _toggleTag(t),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: active
                              ? const Color(0xFF0a84ff)
                              : const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: active
                                ? const Color(0xFF0a84ff)
                                : const Color(0xFFdee2e6),
                          ),
                        ),
                        child: Text(
                          t,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color:
                                active ? Colors.white : const Color(0xFF212529),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          // Плавающие кнопки
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0a84ff),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Применить фильтр',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F3F5),
                      foregroundColor: const Color(0xFF212529),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _resetFilters,
                    child: const Text(
                      'Сбросить фильтр',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          CupertinoSwitch(
            value: value,
            activeColor: const Color(0xFF0a84ff),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
