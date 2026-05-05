import 'package:flutter/material.dart';
import 'package:language_duel/l10n/app_localizations.dart'; // Додано
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../utils/app_theme.dart';
import 'game_history_detail_screen.dart';

class GameHistoryScreen extends StatefulWidget {
  const GameHistoryScreen({super.key});

  @override
  State<GameHistoryScreen> createState() => _GameHistoryScreenState();
}

class _GameHistoryScreenState extends State<GameHistoryScreen> {
  List<GameHistoryListItemDto>? _games;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final token = context.read<AuthProvider>().token!;
      final games = await ApiService().getGamesHistory(token: token);
      if (mounted) setState(() { _games = games; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Додано

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: Text(l10n.matchHistoryTitle), backgroundColor: AppTheme.surface),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _games == null || _games!.isEmpty
              ? Center(child: Text(l10n.noMatchHistory, style: const TextStyle(color: AppTheme.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _games!.length,
                  itemBuilder: (context, i) {
                    final game = _games![i];
                    return Card(
                      color: AppTheme.surfaceElevated,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTheme.border)),
                      child: ListTile(
                        title: Text('${game.languageName} • ${game.difficultyLevelName}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                        subtitle: Text('${l10n.vsText.toLowerCase()} ${game.opponentName}\n${game.createdAt.toLocal().toString().split('.')[0]}', style: const TextStyle(color: AppTheme.textSecondary)),
                        trailing: Text(game.isVictory ? l10n.victoryLabel : l10n.defeatLabel, style: TextStyle(color: game.isVictory ? Colors.green : AppTheme.danger, fontWeight: FontWeight.bold)),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GameHistoryDetailScreen(gameId: game.id))),
                      ),
                    );
                  },
                ),
    );
  }
}