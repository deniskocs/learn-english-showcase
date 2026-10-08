import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  /// Заголовок - используется для главных заголовков страниц
  static const TextStyle title = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    letterSpacing: -0.5,
  );

  /// Подзаголовок - используется для вторичных заголовков, описаний
  static const TextStyle subtitle = TextStyle(
    fontSize: 15,
    color: AppColors.secondaryText,
  );

  /// Текст кнопок - используется для текста на кнопках
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  /// Футер - используется для текста в нижней части экрана, мелких подписей
  static const TextStyle footer = TextStyle(
    fontSize: 12,
    color: AppColors.muted,
  );

  /// Выбранный элемент нижней панели - используется для активного элемента в навигации
  static const TextStyle bottomBarSelected = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  /// Невыбранный элемент нижней панели - используется для неактивного элемента в навигации
  static const TextStyle bottomBarUnselected = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  /// Заголовок слова - используется для отображения слова в списках
  static const TextStyle wordTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  /// Перевод слова - используется для отображения перевода в списках
  static const TextStyle wordTranslation = TextStyle(
    fontSize: 14,
    color: AppColors.secondaryText,
  );

  /// Текст маленькой кнопки - используется для текста на маленьких кнопках
  static const TextStyle smallButton = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  /// Текст следующего повторения - используется для отображения времени до следующего повторения слова
  static const TextStyle nextReview = TextStyle(
    fontSize: 12,
    color: AppColors.secondaryText,
  );

  /// Заголовок группы настроек - используется для заголовков групп в настройках
  static const TextStyle settingsGroupTitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.secondaryText,
    letterSpacing: 0.5,
  );

  /// Текст элемента списка - используется для текста элементов в списках настроек
  static const TextStyle listItem = TextStyle(
    fontSize: 16,
    color: AppColors.text,
  );

  /// Текст кнопки опасного действия - используется для кнопок выхода, удаления и других опасных действий
  static const TextStyle dangerButton = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.danger,
  );

  /// Заголовок диалога - используется для заголовков в модальных окнах
  static const TextStyle dialogTitle = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );

  /// Описание диалога - используется для описательного текста в модальных окнах
  static const TextStyle dialogDescription = TextStyle(
    fontSize: 15,
    color: AppColors.secondaryText,
    height: 1.5,
  );

  /// Текст кнопки диалога - используется для кнопок в модальных окнах
  static const TextStyle dialogButton = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  /// Текст чекбокса диалога - используется для текста чекбоксов в модальных окнах
  static const TextStyle dialogCheckbox = TextStyle(
    fontSize: 14,
    color: AppColors.text,
  );
}
