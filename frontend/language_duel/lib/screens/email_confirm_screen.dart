// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:language_duel/l10n/app_localizations.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/grid_background.dart';

class EmailConfirmScreen extends StatefulWidget {
  final String userId;
  final String? email;
  final VoidCallback onConfirmed;
  final VoidCallback onGoBack;

  const EmailConfirmScreen({
    super.key,
    required this.userId,
    this.email,
    required this.onConfirmed,
    required this.onGoBack,
  });

  @override
  State<EmailConfirmScreen> createState() => _EmailConfirmScreenState();
}

class _EmailConfirmScreenState extends State<EmailConfirmScreen> {
  final _codeCtrl = PinInputController();
  String? _error;
  String? _successMsg;
  bool _resendLoading = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm(BuildContext context, String code) async {
    if (code.length < 6) return;
    setState(() => _error = null);

    final auth = context.read<AuthProvider>();
    final l10n = AppLocalizations.of(context)!;
    
    try {
      await auth.confirmEmail(userId: widget.userId, code: code);
      widget.onConfirmed();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = l10n.connectionError);
    }
  }

  Future<void> _resend(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _resendLoading = true;
      _error = null;
      _successMsg = null;
    });
    
    final auth = context.read<AuthProvider>();
    try {
      await auth.resendConfirmEmail(widget.userId);
      setState(() => _successMsg = l10n.resendSuccess);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = l10n.connectionError);
    } finally {
      setState(() => _resendLoading = false);
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
              glowAlignment: const Alignment(-0.5, 0.5),
              glowRadius: 0.8,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: widget.onGoBack,
                      icon: const Icon(Icons.arrow_back,
                          color: AppTheme.textSecondary),
                      padding: EdgeInsets.zero,
                    ).animate().fadeIn(),

                    const SizedBox(height: 24),

                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppTheme.accent.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.mark_email_unread_outlined,
                          color: AppTheme.accent, size: 32),
                    ).animate().scale(delay: 100.ms),

                    const SizedBox(height: 28),

                    Text(
                      l10n.checkEmailTitle,
                      style: Theme.of(context).textTheme.displayMedium,
                    ).animate().fadeIn(delay: 150.ms),
                    const SizedBox(height: 8),
                    Text(
                      widget.email != null
                          ? l10n.emailSentTo(widget.email!)
                          : l10n.checkEmailSubtitleFallback,
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 15,
                          height: 1.5),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 40),

                    MaterialPinField(
                      length: 6,
                      pinController: _codeCtrl,
                      keyboardType: TextInputType.number,
                      theme: MaterialPinTheme(
                        shape: MaterialPinShape.outlined,
                        cellSize: const Size(48, 56),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onChanged: (_) {},
                      onCompleted: (c) => _confirm(context, c),
                    ).animate().fadeIn(delay: 250.ms),

                    const SizedBox(height: 8),

                    if (_error != null) ...[
                      ErrorBanner(message: _error!)
                          .animate()
                          .fadeIn()
                          .shake(hz: 3),
                      const SizedBox(height: 12),
                    ],

                    if (_successMsg != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppTheme.accent.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline,
                                color: AppTheme.accent, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _successMsg!,
                                style: const TextStyle(
                                    color: AppTheme.accent, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(),
                      const SizedBox(height: 12),
                    ],

                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: CircularProgressIndicator(
                            color: AppTheme.accent,
                            strokeWidth: 2,
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.didntReceive,
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                        _resendLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.accent,
                                ),
                              )
                            : TextButton(
                                onPressed: () => _resend(context),
                                child: Text(l10n.resendCode),
                              ),
                      ],
                    ).animate().fadeIn(delay: 300.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}