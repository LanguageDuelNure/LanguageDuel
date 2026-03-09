import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/shared_widgets.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onGoToRegister;
  final void Function(String userId) onNeedsEmailConfirmation;
  final VoidCallback onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.onGoToRegister,
    required this.onNeedsEmailConfirmation,
    required this.onLoginSuccess,
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
          // Background grid pattern
          Positioned.fill(child: _GridBackground()),
          // Content
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
                      // Brand
                      const BrandLogo(size: 52)
                          .animate()
                          .fadeIn(duration: 400.ms),
                      const SizedBox(height: 32),
                      Text(
                        'Welcome back',
                        style: Theme.of(context).textTheme.displayMedium,
                      ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in to continue your duels',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 15),
                      ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
                      const SizedBox(height: 40),

                      // Fields
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
                      const SizedBox(height: 24),

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

class _GridBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.border.withOpacity(0.5)
      ..strokeWidth = 0.5;

    const spacing = 48.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Radial glow in the center
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 0.8,
      colors: [
        AppTheme.accent.withOpacity(0.04),
        Colors.transparent,
      ],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = gradient.createShader(
            Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}