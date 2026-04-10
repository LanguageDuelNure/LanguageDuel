import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:language_duel/l10n/app_localizations.dart';
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

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);

    final auth = context.read<AuthProvider>();
    final l10n = AppLocalizations.of(context)!;
    
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
      setState(() => _error = l10n.connectionError);
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
                        l10n.welcomeBackTitle,
                        style: Theme.of(context).textTheme.displayMedium,
                      ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                      const SizedBox(height: 8),
                      Text(
                        l10n.signInSubtitle,
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                      ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
                      const SizedBox(height: 40),

                      DuelTextField(
                        hint: l10n.emailHint,
                        label: l10n.emailLabel,
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.alternate_email, size: 18),
                        textInputAction: TextInputAction.next,
                        focusNode: _emailFocus,
                        onEditingComplete: () =>
                            FocusScope.of(context).requestFocus(_passwordFocus),
                        validator: (v) {
                          if (v == null || v.isEmpty) return l10n.emailRequired;
                          if (!v.contains('@')) return l10n.emailInvalid;
                          return null;
                        },
                      ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                      const SizedBox(height: 14),

                      DuelTextField(
                        hint: l10n.passwordHint,
                        label: l10n.passwordLabel,
                        controller: _passwordCtrl,
                        obscure: true,
                        prefixIcon: const Icon(Icons.lock_outline, size: 18),
                        textInputAction: TextInputAction.done,
                        focusNode: _passwordFocus,
                        onEditingComplete: () => _submit(context),
                        validator: (v) {
                          if (v == null || v.isEmpty) return l10n.passwordRequired;
                          if (v.length < 8) return l10n.passwordMinLen;
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
                        label: l10n.signInLink,
                        onPressed: () => _submit(context),
                        isLoading: isLoading,
                      ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                      const SizedBox(height: 16),

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
                          label: Text(l10n.continueWithGoogle),
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
                          Text(
                            l10n.noAccount,
                            style: const TextStyle(color: AppTheme.textSecondary),
                          ),
                          TextButton(
                            onPressed: widget.onGoToRegister,
                            child: Text(l10n.registerLink),
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