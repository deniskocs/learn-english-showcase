import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_text_styles.dart';

/// Диалог начала урока - показывает тип урока и его описание перед началом
class LessonStartDialog extends StatelessWidget {
  final String lessonType;
  final String description;
  final bool showNextTime;
  final ValueChanged<bool>? onShowNextTimeChanged;

  const LessonStartDialog({
    super.key,
    required this.lessonType,
    required this.description,
    this.showNextTime = false,
    this.onShowNextTimeChanged,
  });

  /// Показать диалог
  static Future<bool?> show(
    BuildContext context, {
    required String lessonType,
    required String description,
    bool showNextTime = false,
    ValueChanged<bool>? onShowNextTimeChanged,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: AppColors.modalOverlay,
      barrierDismissible: true,
      builder: (context) => LessonStartDialog(
        lessonType: lessonType,
        description: description,
        showNextTime: showNextTime,
        onShowNextTimeChanged: onShowNextTimeChanged,
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
              // Header with icon and close button
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 16),
                    child: Center(
                      child: Text(
                        '🚀',
                        style: const TextStyle(fontSize: 64),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 24,
                        color: AppColors.secondaryText,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),

              // Body with lesson type, description and checkbox
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lessonType,
                      style: AppTextStyles.dialogTitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: AppTextStyles.dialogDescription,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Checkbox
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: showNextTime,
                        onChanged: (value) {
                          onShowNextTimeChanged?.call(value ?? false);
                        },
                        activeColor: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          onShowNextTimeChanged?.call(!showNextTime);
                        },
                        child: Text(
                          'Не показывать в следующий раз',
                          style: AppTextStyles.dialogCheckbox,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
