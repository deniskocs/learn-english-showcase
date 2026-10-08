import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_text_styles.dart';

/// Вторичная кнопка с заливкой (filled button)
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiuses.button,
          side: const BorderSide(color: AppColors.primary, width: 1),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: AppTextStyles.smallButton.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }
}
