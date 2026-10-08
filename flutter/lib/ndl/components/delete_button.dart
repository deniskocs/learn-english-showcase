import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Кнопка удаления с иконкой крестика
class DeleteButton extends StatelessWidget {
  final VoidCallback onPressed;

  const DeleteButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(
        CupertinoIcons.xmark_circle_fill,
        color: Color(0xFFDC3545),
        size: 24,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}

