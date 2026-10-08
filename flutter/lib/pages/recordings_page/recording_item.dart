import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learn_english/model/recording_item.dart';
import 'package:learn_english/ndl/app_colors.dart';
import 'package:learn_english/ndl/app_text_styles.dart';
import 'package:learn_english/ndl/components/delete_button.dart';

enum RecordingStatus {
  uploading,
  recognizing,
  analysis,
  data;

  static RecordingStatus fromString(String? value) {
    if (value == null) return RecordingStatus.data;
    switch (value) {
      case 'uploading':
        return RecordingStatus.uploading;
      case 'recognizing':
        return RecordingStatus.recognizing;
      case 'analysis':
        return RecordingStatus.analysis;
      case 'data':
      case 'ready':
        return RecordingStatus.data;
      default:
        return RecordingStatus.data;
    }
  }
}

class RecordingItem extends StatelessWidget {
  final RecordingItemDTO item;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  RecordingItem({
    super.key,
    required this.item,
    required this.onDelete,
    this.onTap,
  });

  RecordingStatus get status => RecordingStatus.fromString(item.status);

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Недавно';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} мин назад';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ч назад';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дн назад';
    } else {
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year.toString();
      return '$day.$month.$year';
    }
  }

  @override
  Widget build(BuildContext context) {
    final canTap = item.canOpen && onTap != null;

    return GestureDetector(
      onTap: canTap ? onTap : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(Radiuses.card),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayTitle,
                    style: AppTextStyles.wordTitle,
                  ),
                  if (item.description != null && item.description!.isNotEmpty) ...[
                    const SizedBox(height: Spacings.extraSmall),
                    Text(
                      item.description!,
                      style: AppTextStyles.wordTranslation,
                    ),
                  ],
                  const SizedBox(height: Spacings.extraSmall),
                  Row(
                    children: [
                      Text(
                        _formatTime(item.displayTime),
                        style: AppTextStyles.footer.copyWith(fontSize: 13),
                      ),
                      if (status == RecordingStatus.uploading ||
                          status == RecordingStatus.recognizing ||
                          status == RecordingStatus.analysis) ...[
                        const SizedBox(width: Spacings.small),
                        const SizedBox(
                          width: 8,
                          height: 8,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            DeleteButton(onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
