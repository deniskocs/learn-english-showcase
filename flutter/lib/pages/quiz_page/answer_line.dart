import 'package:flutter/material.dart';
import 'package:learn_english/pages/quiz_page/answer_card.dart';
import 'package:learn_english/pages/quiz_page/answer_descriptor.dart';

class AnswerLine extends StatelessWidget {
  final List<AnswerDescriptor> answers;
  final Function(bool) onAnswerSelected;

  const AnswerLine({
    super.key,
    required this.answers,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: AnswerCard(
              key: UniqueKey(),
              descriptor: answers[0],
              onAnswerSelected: onAnswerSelected,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnswerCard(
              key: UniqueKey(),
              descriptor: answers[1],
              onAnswerSelected: onAnswerSelected,
            ),
          ),
        ],
      ),
    );
  }
}
