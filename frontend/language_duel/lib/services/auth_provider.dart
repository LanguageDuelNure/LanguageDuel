import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api;

  String? _token;
  String? _userId;
  String? _userName;
  String? _role;
  bool _isLoading = false;

  // Called after web Google sign-in completes so the navigator can react
  void Function(bool isNewUser)? onWebSignInComplete;

  AuthProvider({ApiService? api}) : _api = api ?? ApiService();

  String? get token => _token;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get role => _role;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleInitialized = false;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  Future<void> loadFromStorage() async {
    if (!_isGoogleInitialized) {
      _googleSignIn.initialize(
        clientId: '15098027871-it0qhm553ev8kgle0qrsnh42303m1ks2.apps.googleusercontent.com',
      );

      if (kIsWeb) {
        _googleSignIn.authenticationEvents
            .handleError((e) {
              // Sign-in failed or was dismissed — nothing to do
            })
            .listen((event) async {
          if (event is GoogleSignInAuthenticationEventSignIn) {
            try {
              final auth = await event.user.authentication;
              final idToken = auth.idToken;
              if (idToken == null) return;

              final result = await _api.googleLogin(idToken);
              _token = result.jwtToken;
              _userId = result.userId;
              _role = result.role;

              if (_token != null) {
                try {
                  final user = await _api.getUser(
                      userId: result.userId, token: _token!);
                  _userName = user.name;
                } catch (_) {}
              }

              await _saveToStorage();
              notifyListeners();

              // Trigger navigation
              onWebSignInComplete?.call(result.isNewUser);
            } catch (_) {}
          }
        });
      }

      _isGoogleInitialized = true;
    }

    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    _userId = prefs.getString('user_id');
    _userName = prefs.getString('user_name');
    _role = prefs.getString('user_role');
    notifyListeners();
  }

  // Mobile only
  Future<bool?> signInWithGoogle() async {
    _setLoading(true);
    try {
      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw const ApiException(message: 'Failed to get Google Token');
      }

      final result = await _api.googleLogin(idToken);
      _token = result.jwtToken;
      _userId = result.userId;
      _role = result.role;

      if (_token != null) {
        try {
          final user = await _api.getUser(
              userId: result.userId, token: _token!);
          _userName = user.name;
        } catch (_) {}
      }

      await _saveToStorage();
      notifyListeners();
      return result.isNewUser;
    } catch (e) {
      if (e.toString().contains('canceled') ||
          e.toString().contains('CANCELED')) {
        return null;
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
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

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final result = await _api.login(email: email, password: password);

      if (!result.emailConfirmed) {
        return result.userId;
      }

      _token = result.jwtToken;
      _userId = result.userId;
      _role = result.role;

      if (_token != null) {
        try {
          final user = await _api.getUser(
              userId: result.userId, token: _token!);
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

  Future<void> updateName(String name) async {
    _setLoading(true);
    try {
      await _api.updateProfile(token: _token!, name: name);
      _userName = name;
      await _saveToStorage();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }
}