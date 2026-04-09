import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);

    final auth = context.read<AuthProvider>();
    try {
      await auth.updateName(_nameCtrl.text.trim());
      widget.onSetupComplete();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'An unexpected error occurred.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

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
                        'Set your display name',
                        style: Theme.of(context).textTheme.displayMedium,
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 8),
                      const Text(
                        'This is how other duelists will see you.',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                      ).animate().fadeIn(delay: 150.ms),
                      const SizedBox(height: 40),

                      DuelTextField(
                        hint: 'Your display name',
                        label: 'Name',
                        controller: _nameCtrl,
                        prefixIcon: const Icon(Icons.person_outline, size: 18),
                        textInputAction: TextInputAction.done,
                        onEditingComplete: _submit,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Name is required';
                          if (v.length < 3) return 'Minimum 3 characters';
                          return null;
                        },
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 20),

                      if (_error != null) ...[
                        ErrorBanner(message: _error!).animate().fadeIn().shake(hz: 3),
                        const SizedBox(height: 16),
                      ],

                      DuelButton(
                        label: 'Continue to Arena',
                        onPressed: _submit,
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