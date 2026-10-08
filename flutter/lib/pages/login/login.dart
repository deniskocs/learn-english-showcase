import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:learn_english/services/auth_service.dart';
import 'package:learn_english/ndl/app_colors.dart';
import 'package:learn_english/ndl/app_text_styles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AuthService _auth;

  @override
  void initState() {
    super.initState();
    _auth = GetIt.I<AuthService>();
  }

  void _loginButtonTapped() async {
    await _auth.login();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Learn English', style: AppTextStyles.title),
                    const SizedBox(height: 12),
                    const Text('Начни тренировку слов',
                        style: AppTextStyles.subtitle),
                    const SizedBox(height: 60),
                    InkWell(
                      onTap: _loginButtonTapped,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Войти через Google',
                                style: AppTextStyles.button),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 18,
              left: 0,
              right: 0,
              child: Text('© 2025 Learn English',
                  textAlign: TextAlign.center, style: AppTextStyles.footer),
            ),
          ],
        ),
      ),
    );
  }
}
