import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_text_styles.dart';

/// Диалог завершения урока - показывается когда все слова в уроке изучены
class LessonCompleteDialog extends StatelessWidget {
  final String title;
  final String description;
  final String primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;

  const LessonCompleteDialog({
    super.key,
    required this.title,
    required this.description,
    required this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
  });

  /// Показать диалог
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String description,
    required String primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
  }) {
    return showDialog(
      context: context,
      barrierColor: AppColors.modalOverlay,
      barrierDismissible: false,
      builder: (context) => LessonCompleteDialog(
        title: title,
        description: description,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onPrimaryPressed: () {
          Navigator.of(context).pop();
          onPrimaryPressed?.call();
        },
        onSecondaryPressed: () {
          Navigator.of(context).pop();
          onSecondaryPressed?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.9, end: 1.0),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: scale,
              child: child,
            ),
          );
        },
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadiuses.dialog,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 16),
                child: Center(
                  child: Text(
                    '🎉',
                    style: const TextStyle(fontSize: 64),
                  ),
                ),
              ),

              // Body with title, description and buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.dialogTitle.copyWith(
                        fontSize: 21,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: AppTextStyles.dialogDescription,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Buttons
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Primary button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: onPrimaryPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              primaryButtonText,
                              style: AppTextStyles.dialogButton.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // Secondary button (if provided)
                        if (secondaryButtonText != null) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: onSecondaryPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondaryButtonBackground,
                                foregroundColor: AppColors.text,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                secondaryButtonText!,
                                style: AppTextStyles.dialogButton,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

