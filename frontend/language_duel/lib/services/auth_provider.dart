import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api;

  String? _token;
  String? _userId;
  String? _userName;
  String? _role;
  bool _isLoading = false;

  AuthProvider({ApiService? api}) : _api = api ?? ApiService();

  String? get token => _token;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get role => _role;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    _userId = prefs.getString('user_id');
    _userName = prefs.getString('user_name');
    _role = prefs.getString('user_role');
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) {
      await prefs.setString('jwt_token', _token!);
      await prefs.setString('user_id', _userId!);
      await prefs.setString('user_name', _userName ?? '');
      await prefs.setString('user_role', _role ?? '');
    } else {
      await prefs.remove('jwt_token');
      await prefs.remove('user_id');
      await prefs.remove('user_name');
      await prefs.remove('user_role');
    }
  }

  /// Returns userId on success (needed for email confirmation step)
  Future<String> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
  }) async {
    _setLoading(true);
    try {
      final result = await _api.register(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        name: name,
      );
      return result.userId;
    } finally {
      _setLoading(false);
    }
  }

  /// Confirms email and signs the user in
  Future<void> confirmEmail({
    required String userId,
    required String code,
  }) async {
    _setLoading(true);
    try {
      final result = await _api.confirmEmail(userId: userId, code: code);
      _token = result.jwtToken;
      _userId = userId;
      _role = result.role;

      // Fetch user name
      try {
        final user = await _api.getUser(userId: userId, token: _token!);
        _userName = user.name;
      } catch (_) {}

      await _saveToStorage();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resendConfirmEmail(String userId) async {
    _setLoading(true);
    try {
      await _api.resendConfirmEmail(userId: userId);
    } finally {
      _setLoading(false);
    }
  }

  /// Returns null if email is confirmed, or userId if email confirmation needed
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final result = await _api.login(email: email, password: password);

      if (!result.emailConfirmed) {
        // Need email confirmation
        return result.userId;
      }

      _token = result.jwtToken; // may be null if email unconfirmed (handled by caller)
      _userId = result.userId;
      _role = result.role;

      // Fetch user name only when we actually have a token
      if (_token != null) {
        try {
          final user =
              await _api.getUser(userId: result.userId, token: _token!);
          _userName = user.name;
        } catch (_) {}
      }

      await _saveToStorage();
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _userName = null;
    _role = null;
    await _saveToStorage();
    notifyListeners();
  }
}