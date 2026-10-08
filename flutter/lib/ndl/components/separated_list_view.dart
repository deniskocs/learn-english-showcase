import 'package:flutter/material.dart';
import '../app_colors.dart';

/// Универсальный компонент для отображения списка с разделителями
class SeparatedListView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final String emptyMessage;

  const SeparatedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.emptyMessage = 'Нет элементов',
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
      itemBuilder: (context, index) {
        return itemBuilder(context, items[index], index);
      },
    );
  }
}
