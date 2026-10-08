import 'package:flutter/material.dart';
import 'package:learn_english/model/word_definition.dart';
import '../app_colors.dart';
import '../app_text_styles.dart';
import 'play_button.dart';
import 'primary_button.dart';
import 'progress_bar.dart';
import 'secondary_button.dart';
import 'word_definition.dart';
import 'list_item.dart';

class ActiveWordDefinitionItem extends StatelessWidget {
  final WordDefinitionDTO item;
  final VoidCallback onTrainPressed;
  final VoidCallback onMarkAsTrainedPressed;

  const ActiveWordDefinitionItem({
    super.key,
    required this.item,
    required this.onTrainPressed,
    required this.onMarkAsTrainedPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListItem(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              WordDefinition(item: item),
              const SizedBox(width: 12),
              if (item.word.isNotEmpty) PlayButton(word: item.word),
              PrimaryButton(
                text: 'Знаю',
                onPressed: onMarkAsTrainedPressed,
              ),
              // TODO: Replace string comparison with boolean flag from backend
              // Backend should return 'isAvailableForRepetition' boolean instead of comparing nextReview string
              if (item.nextReview != 'Доступно для повторения') ...[
                const SizedBox(width: Spacings.small),
                SecondaryButton(
                  text: 'Учить',
                  onPressed: onTrainPressed,
                ),
              ],
            ],
          ),
          SizedBox(height: Spacings.normal),
          ProgressBar(value: item.progress!),
          SizedBox(height: Spacings.extraSmall),
          Text(
            item.nextReview!,
            style: AppTextStyles.nextReview,
          ),
        ],
      ),
    );
  }
}
