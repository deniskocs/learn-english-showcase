import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_text_styles.dart';

/// Основная кнопка с обводкой (outlined button)
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.progress,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiuses.button,
          side: const BorderSide(color: AppColors.progress, width: 1),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: AppTextStyles.smallButton.copyWith(
          color: AppColors.progress,
        ),
      ),
    );
  }
}
