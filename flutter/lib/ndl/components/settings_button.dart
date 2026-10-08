import 'package:flutter/material.dart';
import '../app_colors.dart';

/// Кнопка для настроек - карточка с текстом и действием
class SettingsButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final TextStyle textStyle;

  const SettingsButton({
    super.key,
    required this.text,
    this.onTap,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        Spacings.normal,
        Spacings.big + Spacings.small,
        Spacings.normal,
        Spacings.big + Spacings.small,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(Radiuses.card),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(Radiuses.card),
        highlightColor: AppColors.highlight,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: Spacings.medium + Spacings.extraSmall,
          ),
          child: Center(
            child: Text(
              text,
              style: textStyle,
            ),
          ),
        ),
      ),
    );
  }
}
