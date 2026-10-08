import 'package:flutter/material.dart';
import '../app_colors.dart';

/// Компонент прогресс-бара для отображения прогресса изучения слова
/// Используется в ячейках активных слов для показа прогресса от 0 до 6
class ProgressBar extends StatelessWidget {
  /// Текущее значение прогресса (от 0 до maxValue)
  final int value;

  /// Максимальное значение прогресса (по умолчанию 6)
  final int maxValue;

  /// Высота прогресс-бара (по умолчанию 6px)
  final double height;

  const ProgressBar({
    super.key,
    required this.value,
    this.maxValue = 6,
    this.height = 6.0,
  });

  double _getProgressPercent() {
    if (maxValue == 0) return 0.0;
    final percent = (value / maxValue).clamp(0.0, 1.0);
    return percent;
  }

  @override
  Widget build(BuildContext context) {
    final progressPercent = _getProgressPercent();

    return ClipRRect(
      borderRadius: BorderRadiuses.progressBar,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: LinearProgressIndicator(
          value: progressPercent,
          minHeight: height,
          backgroundColor: AppColors.progressBackground,
          valueColor: const AlwaysStoppedAnimation<Color>(
            AppColors.progressSoft,
          ),
        ),
      ),
    );
  }
}
