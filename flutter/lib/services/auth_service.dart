import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:learn_english/network/network.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

enum AuthState {
  initializing,
  loggedIn,
  error,
}

class AuthService {
  final ValueNotifier<AuthState> state = ValueNotifier(AuthState.initializing);

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'openid'],
    serverClientId: const String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID'),
  );
  final AbstractNetwork _network;
  String? _authToken;
  static const String _tokenKey = 'auth_token';
  static const String _deviceKey = 'device_key';
  static const String _authTypeKey = 'auth_type';
  static const _uuid = Uuid();

  AuthService() : _network = GetIt.I<AbstractNetwork>() {
    _loadToken();
    _getOrCreateDeviceKey();
  }

  Future<void> _loadToken() async {
    state.value = AuthState.initializing;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_tokenKey);

      if (savedToken != null && _validateToken(savedToken)) {
        _authToken = savedToken;
        _network.authToken = savedToken;
        state.value = AuthState.loggedIn;
      } else {
        _authToken = null;
        _network.authToken = "";
        await prefs.remove(_tokenKey);

        // Токен отсутствует, проверяем тип авторизации
        final authType = await _getAuthType();
        if (authType == 'none') {
          final deviceKey = await getDeviceKey();
          _authToken = await _network.authenticateWithDevice(deviceKey);
          if (_authToken != null) {
            await prefs.setString(_tokenKey, _authToken!);
            _network.authToken = _authToken!;
            state.value = AuthState.loggedIn;
          } else {
            state.value = AuthState.error;
          }
        } else {
          state.value = AuthState.error;
        }
      }
    } catch (e) {
      state.value = AuthState.error;
    }
  }

  bool _validateToken(String? savedToken) {
    if (savedToken != null && savedToken.isNotEmpty) {
      return _isJwtTokenValid(savedToken);
    } else {
      return false;
    }
  }

  bool _isJwtTokenValid(String token) {
    try {
      if (JwtDecoder.isExpired(token)) {
        return false;
      }

      JwtDecoder.decode(token);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> login() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        state.value = AuthState.error;
        return;
      }

      final auth = await account.authentication;
      String? googleIdToken = auth.idToken;
      if (googleIdToken != null) {
        _authToken = await _network.authenticate(googleIdToken);
        if (_authToken != null) {
          // Сохраняем токен
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, _authToken!);
          _network.authToken = _authToken!;
          state.value = AuthState.loggedIn;
        } else {
          state.value = AuthState.error;
        }
      } else {
        state.value = AuthState.error;
      }
    } catch (e) {
      state.value = AuthState.error;
    }
  }

  Future<void> connectWithGoogleAccount() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        state.value = AuthState.error;
        return;
      }

      final auth = await account.authentication;
      String? googleIdToken = auth.idToken;
      if (googleIdToken != null) {
        final deviceKey = await getDeviceKey();
        _authToken = await _network.connectWithGoogleAccount(googleIdToken, deviceKey);
        if (_authToken != null) {
          // Сохраняем токен и тип авторизации
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, _authToken!);
          await prefs.setString(_authTypeKey, 'google');
          _network.authToken = _authToken!;
          state.value = AuthState.loggedIn;
        } else {
          state.value = AuthState.error;
        }
      } else {
        state.value = AuthState.error;
      }
    } catch (e) {
      state.value = AuthState.error;
    }
  }

  Future<void> logout() async {
    _authToken = null;
    state.value = AuthState.error;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _network.authToken = "";
    await _googleSignIn.signOut();
  }

  /// Получает или создает уникальный ключ устройства
  /// При первом запуске генерирует новый ключ и сохраняет его
  /// При последующих запусках возвращает сохраненный ключ
  Future<String> _getOrCreateDeviceKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKey = prefs.getString(_deviceKey);

      if (savedKey != null && savedKey.isNotEmpty) {
        return savedKey;
      } else {
        // Генерируем новый уникальный ключ
        final key = _uuid.v4();
        await prefs.setString(_deviceKey, key);
        return key;
      }
    } catch (e) {
      // В случае ошибки возвращаем null
      return "";
    }
  }

  /// Получает уникальный ключ устройства асинхронно
  Future<String> getDeviceKey() async {
    return await _getOrCreateDeviceKey();
  }

  /// Получает тип аутентификации из SharedPreferences
  /// Возвращает "none" по умолчанию, если тип не установлен
  Future<String> _getAuthType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authType = prefs.getString(_authTypeKey);
      return authType ?? 'none';
    } catch (e) {
      return 'none';
    }
  }

  /// Получает тип аутентификации из SharedPreferences
  /// Возвращает "none" по умолчанию, если тип не установлен
  Future<String> getAuthType() async {
    return await _getAuthType();
  }
}
