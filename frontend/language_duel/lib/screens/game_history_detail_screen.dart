import 'package:flutter/material.dart';
import 'package:language_duel/l10n/app_localizations.dart'; // Додано
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../utils/app_theme.dart';

class GameHistoryDetailScreen extends StatefulWidget {
  final String gameId;
  const GameHistoryDetailScreen({super.key, required this.gameId});

  @override
  State<GameHistoryDetailScreen> createState() => _GameHistoryDetailScreenState();
}

class _GameHistoryDetailScreenState extends State<GameHistoryDetailScreen> {
  GameHistoryDetailDto? _detail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final token = context.read<AuthProvider>().token!;
      final detail = await ApiService().getGameHistory(token: token, gameId: widget.gameId);
      if (mounted) setState(() { _detail = detail; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Додано

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: Text(l10n.matchDetailsTitle), backgroundColor: AppTheme.surface),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _detail == null
              ? Center(child: Text(l10n.failedLoadDetails, style: const TextStyle(color: AppTheme.danger)))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('${_detail!.yourName} ${l10n.vsText.toLowerCase()} ${_detail!.opponentName}', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('${_detail!.languageName} - ${_detail!.difficultyLevelName}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                    const SizedBox(height: 24),
                    ..._detail!.questions.map((q) => _QuestionCard(question: q, myUserId: context.read<AuthProvider>().userId!)).toList(),
                  ],
                ),
    );
  }
}

// ... (віджет _QuestionCard залишається без змін)
class _QuestionCard extends StatelessWidget {
  final dynamic question;
  final String myUserId;
  const _QuestionCard({required this.question, required this.myUserId});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question.name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...question.answers.map((ans) {
            bool isCorrect = ans.isCorrect;
            bool iAnswered = question.userAnswers[myUserId] == ans.id;
            
            Color bgColor = AppTheme.surfaceElevated;
            if (isCorrect) bgColor = Colors.green.withOpacity(0.2);
            else if (iAnswered && !isCorrect) bgColor = AppTheme.danger.withOpacity(0.2);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: isCorrect ? Colors.green : AppTheme.border)),
              child: Row(
                children: [
                  Expanded(child: Text(ans.name, style: const TextStyle(color: AppTheme.textPrimary))),
                  if (iAnswered) const Icon(Icons.person, size: 16, color: AppTheme.textSecondary),
                  if (isCorrect) const Icon(Icons.check, size: 16, color: Colors.green),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}