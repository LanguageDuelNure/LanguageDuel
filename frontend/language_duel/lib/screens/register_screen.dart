import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:language_duel/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/grid_background.dart';

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

  Future<void> _submit(BuildContext context) async {
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GridBackground(
              glowAlignment: const Alignment(0.8, -0.6),
              glowRadius: 0.7,
              glowColor: AppTheme.accentDim,
            ),
          ),
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
                        l10n.createAccountTitle,
                        style: Theme.of(context).textTheme.displayMedium,
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 8),
                      Text(
                        l10n.joinArenaSubtitle,
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                      ).animate().fadeIn(delay: 150.ms),
                      const SizedBox(height: 40),

                      DuelTextField(
                        hint: l10n.nameHint,
                        label: l10n.nameLabel,
                        controller: _nameCtrl,
                        prefixIcon: const Icon(Icons.person_outline, size: 18),
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.isEmpty) return l10n.nameRequired;
                          if (v.length < 3) return l10n.nameMinLen;
                          if (v.length > 32) return l10n.nameMaxLen;
                          return null;
                        },
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 14),

                      DuelTextField(
                        hint: l10n.emailHint,
                        label: l10n.emailLabel,
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.alternate_email, size: 18),
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.isEmpty) return l10n.emailRequired;
                          if (!v.contains('@')) return l10n.emailInvalid;
                          return null;
                        },
                      ).animate().fadeIn(delay: 250.ms),
                      const SizedBox(height: 14),

                      DuelTextField(
                        hint: l10n.passwordHint,
                        label: l10n.passwordLabel,
                        controller: _passwordCtrl,
                        obscure: true,
                        prefixIcon: const Icon(Icons.lock_outline, size: 18),
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.isEmpty) return l10n.passwordRequired;
                          if (v.length < 8) return l10n.passwordMinLen;
                          if (!RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(v)) {
                            return l10n.passwordComplexity;
                          }
                          return null;
                        },
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 14),

                      DuelTextField(
                        hint: l10n.passwordHint,
                        label: l10n.confirmPasswordLabel,
                        controller: _confirmCtrl,
                        obscure: true,
                        prefixIcon: const Icon(Icons.lock_outline, size: 18),
                        textInputAction: TextInputAction.done,
                        onEditingComplete: () => _submit(context),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return l10n.confirmPasswordRequired;
                          }
                          if (v != _passwordCtrl.text) {
                            return l10n.passwordMismatch;
                          }
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
                        label: l10n.createAccountBtn,
                        onPressed: () => _submit(context),
                        isLoading: isLoading,
                      ).animate().fadeIn(delay: 350.ms),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.alreadyHaveAccount,
                            style: const TextStyle(color: AppTheme.textSecondary),
                          ),
                          TextButton(
                            onPressed: widget.onGoToLogin,
                            child: Text(l10n.signInLink),
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