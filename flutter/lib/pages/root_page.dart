import 'package:flutter/material.dart';
import 'package:learn_english/pages/main_page/main_page.dart';
import 'package:learn_english/pages/dictionary/dictionary_page.dart';
import 'package:learn_english/pages/setting_page/settings_page.dart';
import 'package:learn_english/pages/recordings_page/recordings_page.dart';
import 'package:learn_english/ndl/app_colors.dart';
import 'package:learn_english/ndl/app_text_styles.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    MainPage(),
    DictionaryPage(),
    RecordsPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Borders.border,
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.secondaryText,
          selectedLabelStyle: AppTextStyles.bottomBarSelected,
          unselectedLabelStyle: AppTextStyles.bottomBarUnselected,
          items: [
            MainPage.barItem,
            DictionaryPage.barItem,
            RecordsPage.barItem,
            SettingsPage.barItem
          ],
        ),
      ),
    );
  }
}
