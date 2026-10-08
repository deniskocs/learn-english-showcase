import 'package:flutter/material.dart';
import '../app_colors.dart';

/// Компонент для элемента списка с интерактивностью
class ListItem extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const ListItem({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: AppColors.highlight,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
        child: child,
      ),
    );
  }
}
