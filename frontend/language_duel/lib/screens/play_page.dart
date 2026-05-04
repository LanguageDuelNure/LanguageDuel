
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:language_duel/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/game_models.dart';
import '../services/game_service.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';

class PlayPage extends StatefulWidget {
  final String userName;

  const PlayPage({super.key, required this.userName});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  List<LanguageDto> _languages = [];
  LanguageDto? _selectedLanguage;
  bool _loadingLanguages = true;
  UserDto? _user;

  @override
  void initState() {
    super.initState();
    _loadLanguages();
    _loadUserStats();
  }

  Future<void> _loadLanguages() async {
    final game = context.read<GameService>();
    final langs = await game.fetchLanguages();
    if (mounted) {
      setState(() {
        _languages = langs;
        if (langs.isNotEmpty) _selectedLanguage = langs.first;
        _loadingLanguages = false;
      });
    }
  }

  DateTime? _apiBannedUntil;
  Future<void> _loadUserStats() async {
    final auth = context.read<AuthProvider>();
    final userId = auth.userId;
    final token = auth.token;

    if (userId == null || token == null) return;

    try {
      final user = await ApiService().getUser(userId: userId, token: token);
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    } catch (e) {
      
      if (e is ApiException && e.isBanned && mounted) {
        setState(() {
          _apiBannedUntil = e.bannedUntil;
        });
      }
      debugPrint('Could not load user stats: $e');
    }
  }

  Future<void> _startSearch() async {
    if (_selectedLanguage == null) return;
    final game = context.read<GameService>();
    await game.startSearch(
      _selectedLanguage!.id,
      languageName: _selectedLanguage!.name,
      rating: game.ratingForLanguage(_selectedLanguage!.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameService>();
    final l10n = AppLocalizations.of(context)!;

    int currentWins = 0;
    int currentPlayed = 0;

    if (_user != null && _selectedLanguage != null) {
      final langStat = _user!.languageRatings
          .where((l) => l.languageId == _selectedLanguage!.id)
          .firstOrNull;
          
      if (langStat != null) {
        currentWins = langStat.totalWins;
        currentPlayed = langStat.totalGames;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            l10n.helloUser(widget.userName),
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
          ).animate().fadeIn(),
          const SizedBox(height: 4),
          Text(
            l10n.readyToDuel,
            style: Theme.of(context).textTheme.displayMedium,
          ).animate().fadeIn(delay: 100.ms),

          if (game.error != null) ...[
            const SizedBox(height: 16),
            if (game.error == 'banned')
              
              _PlayBannedBanner(bannedUntil: _user?.bannedUntil ?? game.bannedUntil).animate().fadeIn(delay: 150.ms)
            else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.danger.withOpacity(0.4)),
              ),
              child: Text(game.error!,
                  style: const TextStyle(color: AppTheme.danger, fontSize: 13)),
            ),
          ],

          if (game.error != 'banned') ...[
          const SizedBox(height: 32),

          PlayCard(
            isSearching: game.status == GameStatus.searching,
            languages: _languages,
            selectedLanguage: _selectedLanguage,
            loadingLanguages: _loadingLanguages,
            languageRatings: game.allLanguageRatings,
            onLanguageSelected: (lang) =>
                setState(() => _selectedLanguage = lang),
            onPlay: _startSearch,
            onCancel: () => context.read<GameService>().cancelSearch(),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: l10n.statRating,
                  value: _selectedLanguage != null
                      ? '${game.ratingForLanguage(_selectedLanguage!.id)}'
                      : '—',
                  icon: Icons.star_border,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: l10n.statWins, 
                  value: '$currentWins', 
                  icon: Icons.emoji_events_outlined
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: l10n.statPlayed, 
                  value: '$currentPlayed', 
                  icon: Icons.history
                ),
              ),
            ],
          ).animate().fadeIn(delay: 300.ms),
          ], 
        ],
      ),
    );
  }
}

class PlayCard extends StatelessWidget {
  final bool isSearching;
  final List<LanguageDto> languages;
  final LanguageDto? selectedLanguage;
  final bool loadingLanguages;
  final Map<String, int> languageRatings;
  final void Function(LanguageDto) onLanguageSelected;
  final VoidCallback onPlay;
  final VoidCallback onCancel;

  const PlayCard({
    super.key,
    required this.isSearching,
    required this.languages,
    required this.selectedLanguage,
    required this.loadingLanguages,
    required this.languageRatings,
    required this.onLanguageSelected,
    required this.onPlay,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accent.withOpacity(0.12),
            AppTheme.accentDim.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accent.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on, color: AppTheme.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.quickDuel,
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.challengeRandom,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          if (loadingLanguages)
            const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppTheme.accent),
              ),
            )
          else if (languages.isEmpty)
            Text(l10n.noLanguages,
                style: const TextStyle(color: AppTheme.textSecondary))
          else ...[
            Text(
              l10n.languageLabel,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: languages.map((lang) {
                final isSelected = selectedLanguage?.id == lang.id;
                final rating = languageRatings[lang.id] ?? lang.rating;
                return GestureDetector(
                  onTap: () => onLanguageSelected(lang),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.accent.withOpacity(0.15)
                          : AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppTheme.accent : AppTheme.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          lang.name,
                          style: TextStyle(
                            color: isSelected
                                ? AppTheme.accent
                                : AppTheme.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.accent.withOpacity(0.2)
                                : AppTheme.border.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$rating',
                            style: TextStyle(
                              color: isSelected
                                  ? AppTheme.accent
                                  : AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],

          if (isSearching) ...[
            Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppTheme.accent),
                ),
                const SizedBox(width: 12),
                Text(l10n.searchingOpponent,
                    style: const TextStyle(color: AppTheme.textSecondary)),
                const Spacer(),
                TextButton(
                  onPressed: onCancel,
                  child: Text(l10n.cancelBtn,
                      style: const TextStyle(color: AppTheme.danger)),
                ),
              ],
            ),
          ] else if (!loadingLanguages && languages.isNotEmpty) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: selectedLanguage != null ? onPlay : null,
                icon: const Icon(Icons.play_arrow, size: 18),
                label: Text(l10n.findOpponentBtn),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 18),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}


class _PlayBannedBanner extends StatelessWidget {
  final DateTime? bannedUntil;

  const _PlayBannedBanner({this.bannedUntil});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    
    String dateStr = '';
    if (bannedUntil != null) {
      final local = bannedUntil!.toLocal();
      dateStr = '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.danger.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.block_rounded, color: AppTheme.danger, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.bannedTitle,
                  style: const TextStyle(
                    color: AppTheme.danger,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bannedUntil != null 
                      ? l10n.bannedUntilMessage(dateStr) 
                      : l10n.bannedMessage,
                  style: TextStyle(
                    color: AppTheme.danger.withOpacity(0.8),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}