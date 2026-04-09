import 'package:flutter/material.dart';
import 'package:language_duel/screens/setup_name_screen.dart';
import 'package:provider/provider.dart';
import 'services/auth_provider.dart';
import 'services/game_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/email_confirm_screen.dart';
import 'screens/home_screen.dart';
import 'utils/app_theme.dart';
import 'utils/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthProvider();
  await auth.loadFromStorage();
  runApp(
    ChangeNotifierProvider.value(
      value: auth,
      child: const LanguageDuelApp(),
    ),
  );
}

class LanguageDuelApp extends StatelessWidget {
  const LanguageDuelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LanguageDuel',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const _AppNavigator(),
    );
  }
}

enum _Screen { login, register, emailConfirm, setupName, home }

class _AppNavigator extends StatefulWidget {
  const _AppNavigator();

  @override
  State<_AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<_AppNavigator> {
  _Screen _screen = _Screen.login;
  String? _pendingUserId;
  String? _pendingEmail;
  GameService? _gameService;

  @override
  void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final auth = context.read<AuthProvider>();

    auth.onWebSignInComplete = (isNewUser) {
      if (isNewUser) {
        setState(() => _screen = _Screen.setupName);
      } else {
        _createGameService(auth);
        setState(() => _screen = _Screen.home);
      }
    };

    if (auth.isAuthenticated) {
      _createGameService(auth);
      setState(() => _screen = _Screen.home);
    }
  });
}

  void _createGameService(AuthProvider auth) {
    _gameService?.dispose();
    _gameService = GameService(
      baseUrl: AppConstants.serverUrl,
      token: auth.token!,
      userId: auth.userId!,
    );
    _gameService!.connect();
  }

  void _destroyGameService() {
    _gameService?.dispose();
    _gameService = null;
  }

  Widget _buildHome() {
    return ChangeNotifierProvider.value(
      value: _gameService!,
      child: HomeScreen(
        onLogout: () async {
          _destroyGameService();
          await context.read<AuthProvider>().logout();
          setState(() => _screen = _Screen.login);
        },
      ),
    );
  }

  @override
  void dispose() {
    _gameService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return switch (_screen) {
      _Screen.login => LoginScreen(
          onGoToRegister: () => setState(() => _screen = _Screen.register),
          onNeedsEmailConfirmation: (userId) => setState(() {
            _pendingUserId = userId;
            _screen = _Screen.emailConfirm;
          }),
          onNeedsNameSetup: () => setState(() => _screen = _Screen.setupName), 
          onLoginSuccess: () {
            _createGameService(context.read<AuthProvider>());
            setState(() => _screen = _Screen.home);
          },
        ),
      _Screen.register => RegisterScreen(
          onGoToLogin: () => setState(() => _screen = _Screen.login),
          onRegistered: (userId, email) => setState(() {
            _pendingUserId = userId;
            _pendingEmail = email;
            _screen = _Screen.emailConfirm;
          }),
        ),
      _Screen.emailConfirm => EmailConfirmScreen(
          userId: _pendingUserId!,
          email: _pendingEmail,
          onConfirmed: () {
            _createGameService(context.read<AuthProvider>());
            setState(() => _screen = _Screen.home);
          },
          onGoBack: () => setState(() => _screen = _Screen.login),
        ),
      _Screen.setupName => SetupNameScreen(
          onSetupComplete: () {
            _createGameService(context.read<AuthProvider>());
            setState(() => _screen = _Screen.home);
          },
        ),
      _Screen.home => _buildHome(),
    };
  }
}