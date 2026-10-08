import 'package:flutter/material.dart';

class LessonCard extends StatelessWidget {
  final String lessonName;
  final int wordsLeft;
  final GestureTapCallback? onTap;

  const LessonCard({
    super.key,
    required this.lessonName,
    required this.wordsLeft,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFdee2e6)),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lessonName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.timer_outlined,
                    size: 16, color: Color(0xFF0d6efd)),
                const SizedBox(width: 6),
                Text(
                  'Осталось $wordsLeft слов',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6c757d),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
