import 'package:flutter/material.dart';
import '../app_text_styles.dart';
import '../app_colors.dart';
import 'package:learn_english/model/word_definition.dart';

/// Компонент для отображения определения слова (слово и перевод)
class WordDefinition extends StatelessWidget {
  final WordDefinitionDTO item;

  const WordDefinition({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.word,
            style: AppTextStyles.wordTitle,
          ),
          SizedBox(height: Spacings.extraSmall),
          Text(
            item.translation,
            style: AppTextStyles.wordTranslation,
          ),
        ],
      ),
    );
  }
}
