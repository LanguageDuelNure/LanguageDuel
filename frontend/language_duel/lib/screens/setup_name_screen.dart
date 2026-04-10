import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:language_duel/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/grid_background.dart';

class SetupNameScreen extends StatefulWidget {
  final VoidCallback onSetupComplete;

  const SetupNameScreen({super.key, required this.onSetupComplete});

  @override
  State<SetupNameScreen> createState() => _SetupNameScreenState();
}

class _SetupNameScreenState extends State<SetupNameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);

    final auth = context.read<AuthProvider>();
    final l10n = AppLocalizations.of(context)!;
    
    try {
      await auth.updateName(_nameCtrl.text.trim());
      widget.onSetupComplete();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = l10n.unexpectedError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: GridBackground()),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BrandLogo(size: 52).animate().fadeIn(),
                      const SizedBox(height: 32),
                      Text(
                        l10n.setupNameTitle,
                        style: Theme.of(context).textTheme.displayMedium,
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 8),
                      Text(
                        l10n.setupNameSubtitle,
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                      ).animate().fadeIn(delay: 150.ms),
                      const SizedBox(height: 40),

                      DuelTextField(
                        hint: l10n.nameHint,
                        label: l10n.nameLabel,
                        controller: _nameCtrl,
                        prefixIcon: const Icon(Icons.person_outline, size: 18),
                        textInputAction: TextInputAction.done,
                        onEditingComplete: () => _submit(context),
                        validator: (v) {
                          if (v == null || v.isEmpty) return l10n.nameRequired;
                          if (v.length < 3) return l10n.nameMinLen;
                          return null;
                        },
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 20),

                      if (_error != null) ...[
                        ErrorBanner(message: _error!).animate().fadeIn().shake(hz: 3),
                        const SizedBox(height: 16),
                      ],

                      DuelButton(
                        label: l10n.continueToArena,
                        onPressed: () => _submit(context),
                        isLoading: isLoading,
                      ).animate().fadeIn(delay: 250.ms),
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