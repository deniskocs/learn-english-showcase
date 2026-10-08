import 'dart:async';
import 'package:flutter/material.dart';

class SearchWidget extends StatefulWidget {
  final ValueChanged<String> onSearch;

  const SearchWidget({
    super.key,
    required this.onSearch,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    // Отменяем предыдущий таймер
    _debounceTimer?.cancel();

    final text = _controller.text.trim();

    // Если строка не пустая, запускаем таймер на 0.5 секунды
    if (text.isNotEmpty) {
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        widget.onSearch(text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Введите слово для поиска...',
        hintStyle: const TextStyle(fontSize: 15),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFdee2e6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFdee2e6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF0d6efd)),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.search, color: Color(0xFF0d6efd)),
          onPressed: () {
            final text = _controller.text.trim();
            if (text.isNotEmpty) {
              _debounceTimer?.cancel();
              widget.onSearch(text);
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }
}
