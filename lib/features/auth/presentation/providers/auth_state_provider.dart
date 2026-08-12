import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/prefs_keys.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_me_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

/// The single source of truth for the current session. Screens watch this
/// for `isAuthenticated`/`isLoading`/`errorMessage`, and it doubles as the
/// `refreshListenable` for go_router's auth-based redirects.
class AuthStateProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  LoginUseCase? _loginUseCase;
  RegisterUseCase? _registerUseCase;
  LogoutUseCase? _logoutUseCase;
  GetMeUseCase? _getMeUseCase;

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  AuthStateProvider(this._prefs) {
    _checkInitialAuth();
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;

  Future<bool> login(String identifier, String password) async {
    _setLoading(true);
    _clearError();

    final useCase = _loginUseCase;
    if (useCase == null) {
      _fail('Dependencies belum siap, coba lagi.');
      return false;
    }

    final result = await useCase.call(
      LoginParams(identifier: identifier, password: password),
    );

    return result.fold(
      (failure) {
        _fail(failure.message);
        return false;
      },
      (user) {
        _currentUser = user;
        _isAuthenticated = true;
        _setLoading(false);
        return true;
      },
    );
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    final useCase = _registerUseCase;
    if (useCase == null) {
      _fail('Dependencies belum siap, coba lagi.');
      return false;
    }

    final result = await useCase.call(
      RegisterParams(username: username, email: email, password: password),
    );

    return result.fold(
      (failure) {
        _fail(failure.message);
        return false;
      },
      (user) {
        _currentUser = user;
        _isAuthenticated = true;
        _setLoading(false);
        return true;
      },
    );
  }

  Future<void> logout({bool serverSessionAlreadyEnded = false}) async {
    _setLoading(true);
    if (!serverSessionAlreadyEnded) {
      await _logoutUseCase?.call(const NoParams());
    } else {
      await _prefs.remove(PrefsKey.accessToken.value);
      await _prefs.remove(PrefsKey.refreshToken.value);
      await _prefs.remove(PrefsKey.userProfile.value);
    }
    _isAuthenticated = false;
    _currentUser = null;
    _setLoading(false);
  }

  Future<void> refreshUser() async {
    final useCase = _getMeUseCase;
    if (useCase == null) return;
    final result = await useCase.call(const NoParams());
    result.fold((_) {}, (user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  void updateDependencies(
    LoginUseCase loginUseCase,
    RegisterUseCase registerUseCase,
    LogoutUseCase logoutUseCase,
    GetMeUseCase getMeUseCase,
    DioClient dioClient,
  ) {
    _loginUseCase = loginUseCase;
    _registerUseCase = registerUseCase;
    _logoutUseCase = logoutUseCase;
    _getMeUseCase = getMeUseCase;

    dioClient.onTokenExpired = () {
      if (_isAuthenticated) {
        logout(serverSessionAlreadyEnded: true);
      }
    };
  }

  void _checkInitialAuth() {
    final token = _prefs.getString(PrefsKey.accessToken.value);
    if (token == null || token.isEmpty) return;

    _isAuthenticated = true;
    final userJson = _prefs.getString(PrefsKey.userProfile.value);
    if (userJson != null) {
      try {
        _currentUser = UserModel.fromJson(jsonDecode(userJson));
      } catch (_) {
        // Corrupt cache — stay authenticated, currentUser stays null until
        // refreshUser() runs.
      }
    }
  }

  void _fail(String message) {
    _errorMessage = message;
    _setLoading(false);
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
