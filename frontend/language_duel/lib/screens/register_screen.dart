import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/shared_widgets.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onGoToLogin;
  final void Function(String userId, String email) onRegistered;

  const RegisterScreen({
    super.key,
    required this.onGoToLogin,
    required this.onRegistered,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);

    final auth = context.read<AuthProvider>();
    try {
      final userId = await auth.register(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        confirmPassword: _confirmCtrl.text,
        name: _nameCtrl.text.trim(),
      );
      widget.onRegistered(userId, _emailCtrl.text.trim());
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (ex) {
      setState(() => _error = ex.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _BgDecoration()),
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
                      const BrandLogo(size: 52)
                          .animate()
                          .fadeIn(duration: 400.ms),
                      const SizedBox(height: 32),
                      Text(
                        'Create account',
                        style: Theme.of(context).textTheme.displayMedium,
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 8),
                      const Text(
                        'Join the dueling arena',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 15),
                      ).animate().fadeIn(delay: 150.ms),
                      const SizedBox(height: 40),

                      // Name
                      DuelTextField(
                        hint: 'Your display name',
                        label: 'Name',
                        controller: _nameCtrl,
                        prefixIcon:
                            const Icon(Icons.person_outline, size: 18),
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Name is required';
                          if (v.length < 3) return 'Minimum 3 characters';
                          if (v.length > 32) return 'Maximum 32 characters';
                          return null;
                        },
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 14),

                      // Email
                      DuelTextField(
                        hint: 'you@example.com',
                        label: 'Email',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon:
                            const Icon(Icons.alternate_email, size: 18),
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email is required';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ).animate().fadeIn(delay: 250.ms),
                      const SizedBox(height: 14),

                      // Password
                      DuelTextField(
                        hint: '••••••••',
                        label: 'Password',
                        controller: _passwordCtrl,
                        obscure: true,
                        prefixIcon: const Icon(Icons.lock_outline, size: 18),
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Password is required';
                          if (v.length < 8) return 'Minimum 8 characters';
                          if (!RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(v)) {
                            return 'Must have upper and lowercase letters';
                          }
                          return null;
                        },
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 14),

                      // Confirm password
                      DuelTextField(
                        hint: '••••••••',
                        label: 'Confirm password',
                        controller: _confirmCtrl,
                        obscure: true,
                        prefixIcon: const Icon(Icons.lock_outline, size: 18),
                        textInputAction: TextInputAction.done,
                        onEditingComplete: _submit,
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Please confirm your password';
                          if (v != _passwordCtrl.text)
                            return 'Passwords do not match';
                          return null;
                        },
                      ).animate().fadeIn(delay: 320.ms),
                      const SizedBox(height: 20),

                      if (_error != null) ...[
                        ErrorBanner(message: _error!)
                            .animate()
                            .fadeIn()
                            .shake(hz: 3),
                        const SizedBox(height: 16),
                      ],

                      DuelButton(
                        label: 'Create Account',
                        onPressed: _submit,
                        isLoading: isLoading,
                      ).animate().fadeIn(delay: 350.ms),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                          TextButton(
                            onPressed: widget.onGoToLogin,
                            child: const Text('Sign In'),
                          ),
                        ],
                      ).animate().fadeIn(delay: 380.ms),
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

class _BgDecoration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BgPainter());
  }
}

class _BgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.border.withOpacity(0.4)
      ..strokeWidth = 0.5;

    const spacing = 48.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Top-right glow
    final gradient = RadialGradient(
      center: const Alignment(0.8, -0.6),
      radius: 0.7,
      colors: [
        AppTheme.accentDim.withOpacity(0.08),
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