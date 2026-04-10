import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:language_duel/l10n/app_localizations.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';

class LanguageOption {
  final String id;
  final String name;
  const LanguageOption({required this.id, required this.name});
}

class LeaderboardPage extends StatefulWidget {
  final List<LanguageOption> languages;

  const LeaderboardPage({super.key, this.languages = const []});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final ApiService _api = ApiService();
  List<LeaderboardItemDto> _players = [];
  bool _isLoading = true;
  String? _error;
  LanguageOption? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _api.getLeaderboard(
        languageId: _selectedLanguage?.id,
      );
      if (mounted) {
        setState(() {
          _players = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onLanguageChanged(LanguageOption? option) {
    setState(() => _selectedLanguage = option);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(l10n.leaderboardTitle, style: Theme.of(context).textTheme.displayMedium)
              .animate()
              .fadeIn(),
          const SizedBox(height: 4),
          Text(
            l10n.globalRankings,
            style: const TextStyle(color: AppTheme.textSecondary),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 20),

          if (widget.languages.isNotEmpty)
            _LanguageFilter(
              languages: widget.languages,
              selected: _selectedLanguage,
              onChanged: _onLanguageChanged,
            ).animate().fadeIn(delay: 120.ms),

          const SizedBox(height: 24),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            _ErrorBanner(message: _error!, onRetry: _load)
          else if (_players.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Text(
                  l10n.noPlayers,
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            )
          else
            _LeaderboardContent(players: _players),
        ],
      ),
    );
  }
}

class _LanguageFilter extends StatelessWidget {
  final List<LanguageOption> languages;
  final LanguageOption? selected;
  final ValueChanged<LanguageOption?> onChanged;

  const _LanguageFilter({
    required this.languages,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = selected?.name ?? l10n.allLanguages;

    return PopupMenuButton<LanguageOption?>(
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.border),
      ),
      onSelected: onChanged,
      itemBuilder: (_) => [
        PopupMenuItem<LanguageOption?>(
          value: null,
          child: Text(
            l10n.allLanguages,
            style: TextStyle(
              color: selected == null
                  ? AppTheme.accent
                  : AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        ...languages.map(
          (lang) => PopupMenuItem<LanguageOption?>(
            value: lang,
            child: Text(
              lang.name,
              style: TextStyle(
                color: selected?.id == lang.id
                    ? AppTheme.accent
                    : AppTheme.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.language, color: AppTheme.textSecondary, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected != null
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down,
                color: AppTheme.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardContent extends StatelessWidget {
  final List<LeaderboardItemDto> players;
  const _LeaderboardContent({required this.players});

  @override
  Widget build(BuildContext context) {
    final top3 = players.take(3).toList();
    final rest = players.skip(3).toList();

    return Column(
      children: [
        if (top3.isNotEmpty)
          _Podium(top3: top3).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 28),
        ...rest.asMap().entries.map(
          (e) => LeaderRow(
            rank: e.value.rank,
            name: e.value.name,
            wins: e.value.totalWins,
            games: e.value.totalGames,
            imageUrl: e.value.imageUrl,
          ).animate().fadeIn(delay: Duration(milliseconds: 250 + e.key * 40)),
        ),
      ],
    );
  }
}

class _Podium extends StatelessWidget {
  final List<LeaderboardItemDto> top3;
  const _Podium({required this.top3});

  @override
  Widget build(BuildContext context) {
    LeaderboardItemDto? p(int rank) =>
        top3.where((p) => p.rank == rank).firstOrNull ??
        (top3.length >= rank ? top3[rank - 1] : null);

    final first = p(1);
    final second = p(2);
    final third = p(3);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (second != null)
          PodiumItem(
              rank: 2,
              name: second.name,
              wins: second.totalWins,
              imageUrl: second.imageUrl,
              height: 80),
        const SizedBox(width: 12),
        if (first != null)
          PodiumItem(
              rank: 1,
              name: first.name,
              wins: first.totalWins,
              imageUrl: first.imageUrl,
              height: 110),
        const SizedBox(width: 12),
        if (third != null)
          PodiumItem(
              rank: 3,
              name: third.name,
              wins: third.totalWins,
              imageUrl: third.imageUrl,
              height: 60),
      ],
    );
  }
}

class PodiumItem extends StatelessWidget {
  final int rank;
  final String name;
  final int wins;
  final String? imageUrl;
  final double height;

  const PodiumItem({
    super.key,
    required this.rank,
    required this.name,
    required this.wins,
    this.imageUrl,
    required this.height,
  });

  Color get _color {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFFC0C0C0);
    return const Color(0xFFCD7F32);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Expanded(
      child: Column(
        children: [
          _buildAvatar(),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.winsCount(wins),
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Container(
            height: height,
            decoration: BoxDecoration(
              color: _color.withOpacity(0.12),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              border: Border.all(color: _color.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: _color,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundImage: NetworkImage(imageUrl!),
        backgroundColor: _color.withOpacity(0.15),
      );
    }
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: _color.withOpacity(0.5)),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: _color,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

class LeaderRow extends StatelessWidget {
  final int rank;
  final String name;
  final int wins;
  final int games;
  final String? imageUrl;

  const LeaderRow({
    super.key,
    required this.rank,
    required this.name,
    required this.wins,
    required this.games,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _miniAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            l10n.winsGamesRatio(wins, games),
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _miniAvatar() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 14,
        backgroundImage: NetworkImage(imageUrl!),
      );
    }
    return CircleAvatar(
      radius: 14,
      backgroundColor: AppTheme.accent.withOpacity(0.15),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
            color: AppTheme.accent,
            fontSize: 12,
            fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.danger, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message,
                style: const TextStyle(color: AppTheme.danger, fontSize: 13)),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(l10n.errorRetry,
                style: const TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }
}