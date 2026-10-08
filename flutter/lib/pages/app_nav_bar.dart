import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? didFilterTapped;

  const AppNavBar({
    super.key,
    required this.title,
    this.didFilterTapped,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Color(0xFF212529),
        ),
      ),
      centerTitle: true,
      backgroundColor: const Color(0xFFFCFCFD),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.08),
      actions: didFilterTapped != null
          ? [
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: didFilterTapped,
                  child: const Icon(CupertinoIcons.slider_horizontal_3),
                ),
              ),
            ]
          : null,
    );
  }
}
