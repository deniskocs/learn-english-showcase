import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learn_english/model/word_definition.dart';
import 'package:learn_english/ndl/components/play_button.dart';
import 'package:learn_english/ndl/components/primary_button.dart';
import 'package:learn_english/ndl/components/secondary_button.dart';
import 'package:learn_english/ndl/components/word_definition.dart';
import 'package:learn_english/ndl/components/list_item.dart';

class DefinitionItem extends StatelessWidget {
  final WordDefinitionDTO item;
  final VoidCallback? onTrainPressed;
  final VoidCallback? onMarkAsTrainedPressed;

  const DefinitionItem({
    super.key,
    required this.item,
    this.onTrainPressed,
    this.onMarkAsTrainedPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListItem(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          WordDefinition(item: item),
          const SizedBox(width: 12),
          if (item.word.isNotEmpty) PlayButton(word: item.word),
          if (onMarkAsTrainedPressed != null || onTrainPressed != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onMarkAsTrainedPressed != null)
                  PrimaryButton(
                    text: 'Знаю',
                    onPressed: onMarkAsTrainedPressed,
                  ),
                if (onMarkAsTrainedPressed != null && onTrainPressed != null) const SizedBox(width: 8),
                if (onTrainPressed != null)
                  SecondaryButton(
                    text: 'Учить',
                    onPressed: onTrainPressed,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
