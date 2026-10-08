import 'package:flutter/material.dart';

class ToggleSelector extends StatefulWidget {
  final List<String> items;
  final ValueChanged<int> onSelected;
  final int initialIndex;

  const ToggleSelector({
    super.key,
    required this.items,
    required this.onSelected,
    this.initialIndex = 0,
  });

  @override
  State<ToggleSelector> createState() => _ToggleSelectorState();
}

class _ToggleSelectorState extends State<ToggleSelector> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onTap(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    widget.onSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F5),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: List.generate(widget.items.length, (index) {
          final selected = _selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onTap(index),
              child: Container(
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : [],
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  widget.items[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 15,
                    color: selected
                        ? const Color(0xFF0d6efd)
                        : const Color(0xFF495057),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
