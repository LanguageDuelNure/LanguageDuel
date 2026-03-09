import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/email_confirm_screen.dart';
import 'screens/home_screen.dart';
import 'utils/app_theme.dart';

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

enum _Screen { login, register, emailConfirm, home }

class _AppNavigator extends StatefulWidget {
  const _AppNavigator();

  @override
  State<_AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<_AppNavigator> {
  _Screen _screen = _Screen.login;
  String? _pendingUserId;
  String? _pendingEmail;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isAuthenticated) {
        setState(() => _screen = _Screen.home);
      }
    });
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
          onLoginSuccess: () => setState(() => _screen = _Screen.home),
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
          onConfirmed: () => setState(() => _screen = _Screen.home),
          onGoBack: () => setState(() => _screen = _Screen.login),
        ),

      _Screen.home => HomeScreen(
          onLogout: () async {
            await context.read<AuthProvider>().logout();
            setState(() => _screen = _Screen.login);
          },
        ),
    };
  }
}