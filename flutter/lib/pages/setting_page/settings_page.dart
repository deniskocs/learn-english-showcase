import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learn_english/pages/app_nav_bar.dart';
import 'package:learn_english/ndl/app_colors.dart';
import 'package:learn_english/ndl/app_text_styles.dart';
import 'package:learn_english/ndl/components/settings_button.dart';
import 'package:learn_english/services/auth_service.dart';
import 'package:get_it/get_it.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();

  static var barItem = BottomNavigationBarItem(
    icon: Icon(CupertinoIcons.gear_alt),
    label: 'Настройки',
  );
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _authService = GetIt.I<AuthService>();
  String? _authType;
  final Map<String, bool> toggles = {
    'Английский → Русский': true,
    'Русский → Английский': true,
    'Значение → Слово': true,
    'Неправильные глаголы': true,
    'Формы глаголов': false,
    'Основные фразовые глаголы': true,
    'Продвинутые фразовые глаголы': false,
    'Базовые выражения': true,
    'Разговорные фразы': false,
  };

  @override
  void initState() {
    super.initState();
    _loadAuthType();
  }

  Future<void> _loadAuthType() async {
    final authType = await _authService.getAuthType();
    if (mounted) {
      setState(() {
        _authType = authType;
      });
    }
  }

  Future<void> _handleConnectWithGoogleAccount() async {
    try {
      await _authService.connectWithGoogleAccount();
      // Обновляем тип авторизации после успешного подключения
      await _loadAuthType();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка подключения: ${e.toString()}'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
  }

  Widget _buildGroup(String title, List<String> items) {
    return Padding(
      padding: EdgeInsets.only(top: Spacings.big + Spacings.small),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: Spacings.normal + Spacings.extraSmall,
              right: Spacings.normal + Spacings.extraSmall,
              bottom: Spacings.small - Spacings.extraSmall,
              top: Spacings.small - Spacings.extraSmall,
            ),
            child: Text(
              title.toUpperCase(),
              style: AppTextStyles.settingsGroupTitle,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: Spacings.normal),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(Radiuses.card),
            ),
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++)
                  Container(
                    decoration: BoxDecoration(
                      border: i == 0
                          ? null
                          : Border(
                              top: BorderSide(
                                color: AppColors.border,
                                width: 0.5,
                              ),
                            ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: Spacings.medium + Spacings.extraSmall,
                        horizontal: Spacings.normal + Spacings.extraSmall,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            items[i],
                            style: AppTextStyles.listItem,
                          ),
                          CupertinoSwitch(
                            value: toggles[items[i]] ?? false,
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              setState(() => toggles[items[i]] = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(title: "Настройки"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildGroup('Слова', [
              'Английский → Русский',
              'Русский → Английский',
              'Значение → Слово',
            ]),
            _buildGroup('Глаголы', [
              'Неправильные глаголы',
              'Формы глаголов',
            ]),
            _buildGroup('Фразовые глаголы', [
              'Основные фразовые глаголы',
              'Продвинутые фразовые глаголы',
            ]),
            _buildGroup('Устойчивые выражения', [
              'Базовые выражения',
              'Разговорные фразы',
            ]),
            if (_authType != null && _authType == 'none')
              SettingsButton(
                text: 'Связать с Google',
                textStyle: AppTextStyles.button.copyWith(
                  color: AppColors.primary,
                ),
                onTap: _handleConnectWithGoogleAccount,
              ),
            if (_authType != null && _authType != 'none')
              SettingsButton(
                text: 'Выйти из аккаунта',
                textStyle: AppTextStyles.dangerButton,
                onTap: _handleLogout,
              ),
          ],
        ),
      ),
    );
  }
}
