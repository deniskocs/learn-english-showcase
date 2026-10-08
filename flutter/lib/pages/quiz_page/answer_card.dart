import 'package:flutter/material.dart';
import 'package:learn_english/pages/quiz_page/answer_descriptor.dart';

class AnswerCard extends StatefulWidget {
  final AnswerDescriptor descriptor;
  final Function(bool isCorrect) onAnswerSelected;

  const AnswerCard({
    super.key,
    required this.descriptor,
    required this.onAnswerSelected,
  });

  @override
  State<StatefulWidget> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<AnswerCard> {
  bool _selected = false;

  @override
  void initState() {
    super.initState();
    _selected = false;
  }

  Color backgroundColor() {
    if (!_selected) return Colors.white;
    return widget.descriptor.isCorrect ? const Color(0xFFD1F7D6) : const Color(0xFFFDE0E0);
  }

  Color borderColor() {
    if (!_selected) return const Color(0xFFDEE2E6);
    return widget.descriptor.isCorrect ? const Color(0xFF28A745) : const Color(0xFFDC3545);
  }

  Color textColor() {
    if (!_selected) return Colors.black87;
    return widget.descriptor.isCorrect ? const Color(0xFF155724) : const Color(0xFF842029);
  }

  void _tapped() {
    if (_selected) return;
    setState(() {
      _selected = true;
    });
    widget.onAnswerSelected(widget.descriptor.isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _tapped,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: backgroundColor(),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(width: 1, color: borderColor()),
          boxShadow: const [
            BoxShadow(
              blurRadius: 4,
              offset: Offset(0, 2),
              color: Color.fromRGBO(0, 0, 0, 0.05),
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.descriptor.answer,
            textAlign: TextAlign.center,
            softWrap: true,
            overflow: TextOverflow.visible,
            maxLines: null,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor(),
            ),
          ),
        ),
      ),
    );
  }
}
