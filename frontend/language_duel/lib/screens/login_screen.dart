import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/grid_background.dart';
import '../widgets/google_sign_in_button.dart' as gsi;

class LoginScreen extends StatefulWidget {
  final VoidCallback onGoToRegister;
  final void Function(String userId) onNeedsEmailConfirmation;
  final VoidCallback onLoginSuccess;
  final VoidCallback onNeedsNameSetup;

  const LoginScreen({
    super.key,
    required this.onGoToRegister,
    required this.onNeedsEmailConfirmation,
    required this.onLoginSuccess,
    required this.onNeedsNameSetup,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _googleSignIn() async {
    setState(() => _error = null);
    final auth = context.read<AuthProvider>();
    try {
      final isNewUser = await auth.signInWithGoogle();
      if (isNewUser == null) return;
      if (isNewUser) {
        widget.onNeedsNameSetup();
      } else {
        widget.onLoginSuccess();
      }
    } catch (ex) {
      setState(() => _error = ex.toString());
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);

    final auth = context.read<AuthProvider>();
    try {
      final pendingUserId = await auth.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (pendingUserId != null) {
        widget.onNeedsEmailConfirmation(pendingUserId);
      } else {
        widget.onLoginSuccess();
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Could not reach server. Check your connection.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: GridBackground()),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 0,
                vertical: 40,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BrandLogo(size: 52).animate().fadeIn(duration: 400.ms),
                      const SizedBox(height: 32),
                      Text(
                        'Welcome back',
                        style: Theme.of(context).textTheme.displayMedium,
                      ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in to continue your duels',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                      ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
                      const SizedBox(height: 40),

                      DuelTextField(
                        hint: 'you@example.com',
                        label: 'Email',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.alternate_email, size: 18),
                        textInputAction: TextInputAction.next,
                        focusNode: _emailFocus,
                        onEditingComplete: () =>
                            FocusScope.of(context).requestFocus(_passwordFocus),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email is required';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                      const SizedBox(height: 14),

                      DuelTextField(
                        hint: '••••••••',
                        label: 'Password',
                        controller: _passwordCtrl,
                        obscure: true,
                        prefixIcon: const Icon(Icons.lock_outline, size: 18),
                        textInputAction: TextInputAction.done,
                        focusNode: _passwordFocus,
                        onEditingComplete: _submit,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password is required';
                          if (v.length < 8) return 'Minimum 8 characters';
                          return null;
                        },
                      ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
                      const SizedBox(height: 20),

                      if (_error != null) ...[
                        ErrorBanner(message: _error!)
                            .animate()
                            .fadeIn()
                            .shake(hz: 3),
                        const SizedBox(height: 16),
                      ],

                      DuelButton(
                        label: 'Sign In',
                        onPressed: _submit,
                        isLoading: isLoading,
                      ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                      const SizedBox(height: 16),

                      // Web uses renderButton from google_sign_in_web (via conditional export)
                      // Mobile uses a normal OutlinedButton
                      if (kIsWeb)
                        Center(
                          child: SizedBox(
                            width: 250,
                            child: gsi.renderButton(),
                          ),
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: isLoading ? null : _googleSignIn,
                          icon: const Icon(Icons.g_mobiledata, size: 28),
                          label: const Text('Continue with Google'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.textPrimary,
                            side: const BorderSide(color: AppTheme.border),
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                          TextButton(
                            onPressed: widget.onGoToRegister,
                            child: const Text('Register'),
                          ),
                        ],
                      ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}