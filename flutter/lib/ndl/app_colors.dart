import 'package:flutter/material.dart';

class AppColors {
  /// Основной цвет приложения (синий) - используется для акцентов, кнопок, ссылок
  static const Color primary = Color(0xFF0d6efd);

  /// Вторичный текст - используется для менее важного текста, подписей
  static const Color secondaryText = Color(0xFF6c757d);

  /// Цвет границ - используется для разделителей, рамок элементов
  static const Color border = Color(0xFFdee2e6);

  /// Основной цвет текста - используется для основного контента
  static const Color text = Color(0xFF495057);

  /// Приглушенный цвет - используется для неактивного текста, подсказок
  static const Color muted = Color(0xFFadb5bd);

  /// Цвет фона - используется для основного фона приложения
  static const Color background = Colors.white;

  /// Цвет фона прогресс-бара - используется для неактивной части прогресс-бара
  static const Color progressBackground = Color(0xFFE9ECEF);

  /// Цвет прогресса - используется для активной части прогресс-бара (зеленый)
  static const Color progress = Color(0xFF198754);

  /// Мягкий цвет прогресса - используется для менее навязчивого отображения прогресса
  static const Color progressSoft = Color(0xFF8db89f);

  /// Цвет подсветки при нажатии - используется для highlightColor в InkWell
  static const Color highlight = Color(0xFFF2F4F8);

  /// Цвет опасных действий - используется для кнопок выхода, удаления и других опасных действий
  static const Color danger = Color(0xFFFF3B30);

  /// Цвет overlay для модальных окон - используется для затемнения фона под диалогами
  static const Color modalOverlay = Color(0x66000000); // rgba(0,0,0,0.4)

  /// Цвет фона вторичной кнопки - используется для вторичных кнопок в диалогах
  static const Color secondaryButtonBackground = Color(0xFFF1F3F5);
}

class Borders {
  static const Border border = Border(
    top: BorderSide(color: AppColors.border),
  );
}

class Paddings {
  static const main = EdgeInsets.symmetric(horizontal: 16, vertical: 16);
}

class Spacings {
  static const extraSmall = 4.0;
  static const small = 8.0;
  static const medium = 12.0;
  static const normal = 16.0;
  static const big = 24.0;
}

class Radiuses {
  /// Радиус для карточек - используется для основных карточек элементов
  static const card = 14.0;

  /// Радиус для прогресс-бара - используется для скругления прогресс-бара
  static const progressBar = 4.0;

  /// Радиус для кнопок - используется для скругления кнопок
  static const button = 8.0;

  /// Радиус для диалогов - используется для модальных окон
  static const dialog = 18.0;
}

class BorderRadiuses {
  /// Скругление для прогресс-бара - используется для прогресс-бара
  static const progressBar = BorderRadius.all(Radius.circular(Radiuses.progressBar));

  /// Скругление для кнопок - используется для кнопок
  static const button = BorderRadius.all(Radius.circular(Radiuses.button));

  /// Скругление для диалогов - используется для модальных окон
  static const dialog = BorderRadius.all(Radius.circular(Radiuses.dialog));
}
