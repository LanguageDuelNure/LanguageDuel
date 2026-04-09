

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:language_duel/services/auth_provider.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../services/game_service.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfilePage({super.key, required this.onLogout});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserDto? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final auth = context.read<AuthProvider>();
    final userId = auth.userId;
    final token = auth.token;

    if (userId == null || token == null) {
      setState(() {
        _error = 'Not authenticated';
        _isLoading = false;
      });
      return;
    }

    try {
      final user = await ApiService().getUser(userId: userId, token: token);
      if (mounted) {
        setState(() {
          _user = user;
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userName = auth.userName ?? '';
    final role = auth.role ?? 'Player';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Profile', style: Theme.of(context).textTheme.displayMedium)
              .animate()
              .fadeIn(),
          const SizedBox(height: 28),

          
          Row(
            children: [
              _buildAvatar(userName),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _RoleBadge(role: role),
                ],
              ),
            ],
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 32),

          
          Text('Statistics', style: Theme.of(context).textTheme.titleLarge)
              .animate()
              .fadeIn(delay: 200.ms),
          const SizedBox(height: 14),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
                .animate()
                .fadeIn(delay: 250.ms)
          else if (_error != null)
            _ErrorBanner(message: _error!, onRetry: _loadUser)
          else
            _StatsGrid(user: _user!).animate().fadeIn(delay: 250.ms),

          
          if (!_isLoading && _error == null && _user!.languageRatings.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text('Ratings by language',
                    style: Theme.of(context).textTheme.titleLarge)
                .animate()
                .fadeIn(delay: 300.ms),
            const SizedBox(height: 12),
            Builder(builder: (context) {
              final gameService = context.read<GameService>();
              return Column(
                children: _user!.languageRatings.asMap().entries.map((entry) {
                  final i = entry.key;
                  final lang = entry.value;
                  final name = gameService.nameForLanguage(lang.languageId);
                  return LanguageRatingRow(
                    languageName: name,
                    rating: lang.rating,
                    maxRating: lang.maxRating,
                    totalGames: lang.totalGames,
                    totalWins: lang.totalWins,
                  ).animate().fadeIn(delay: Duration(milliseconds: 320 + i * 40));
                }).toList(),
              );
            }),
          ],

          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout, size: 18, color: AppTheme.danger),
            label: const Text('Sign Out',
                style: TextStyle(color: AppTheme.danger)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.danger),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildAvatar(String userName) {
    final imageUrl = _user?.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 36,
        backgroundImage: NetworkImage(imageUrl),
      );
    }
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accent.withOpacity(0.3),
            AppTheme.accentDim.withOpacity(0.3),
          ],
        ),
        shape: BoxShape.circle,
        border:
            Border.all(color: AppTheme.accent.withOpacity(0.4), width: 2),
      ),
      child: Center(
        child: Text(
          userName.isNotEmpty ? userName[0].toUpperCase() : '?',
          style: const TextStyle(
            color: AppTheme.accent,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}



class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
      ),
      child: Text(
        role,
        style: const TextStyle(
          color: AppTheme.accent,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
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
            child: const Text('Retry',
                style: TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final UserDto user;
  const _StatsGrid({required this.user});

  
  int get _bestRating => user.languageRatings.isEmpty
      ? 0
      : user.languageRatings
          .map((l) => l.maxRating)
          .reduce((a, b) => a > b ? a : b);

  
  int get _currentRating => user.languageRatings.isEmpty
      ? 0
      : user.languageRatings
          .map((l) => l.rating)
          .reduce((a, b) => a > b ? a : b);

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('Total matches', '${user.totalGames}', Icons.sports_esports_outlined),
      ('Total wins', '${user.totalWins}', Icons.emoji_events_outlined),
      ('Current rating', '$_currentRating', Icons.star_border),
      ('Best rating', '$_bestRating', Icons.military_tech_outlined),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: stats.map((s) {
        final (label, value, icon) = s;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppTheme.textSecondary, size: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}



class LanguageRatingRow extends StatelessWidget {
  final String languageName;
  final int rating;
  final int maxRating;
  final int totalGames;
  final int totalWins;

  const LanguageRatingRow({
    super.key,
    required this.languageName,
    required this.rating,
    required this.maxRating,
    required this.totalGames,
    required this.totalWins,
  });

  String get _difficultyLabel {
    if (rating < 30) return 'Easy';
    if (rating < 70) return 'Medium';
    if (rating < 120) return 'Hard';
    return 'Very Hard';
  }

  Color get _difficultyColor {
    if (rating < 30) return AppTheme.accent;
    if (rating < 70) return const Color(0xFF4FC3F7);
    if (rating < 120) return Colors.orange;
    return AppTheme.danger;
  }

  @override
  Widget build(BuildContext context) {
    const maxScale = 200.0;
    final fraction = (rating / maxScale).clamp(0.0, 1.0);
    final maxFraction = (maxRating / maxScale).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                languageName,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              Row(
                children: [
                  Text(
                    '$rating pts',
                    style: TextStyle(
                      color: _difficultyColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _difficultyColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: _difficultyColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      _difficultyLabel,
                      style: TextStyle(
                        color: _difficultyColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation(_difficultyColor),
            ),
          ),
          const SizedBox(height: 4),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: maxFraction,
              minHeight: 3,
              backgroundColor: AppTheme.border,
              valueColor:
                  AlwaysStoppedAnimation(_difficultyColor.withOpacity(0.3)),
            ),
          ),
          const SizedBox(height: 8),
          
          Row(
            children: [
              _StatChip(
                  label: 'W',
                  value: '$totalWins',
                  color: AppTheme.accent),
              const SizedBox(width: 8),
              _StatChip(
                  label: 'G',
                  value: '$totalGames',
                  color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              _StatChip(
                label: 'Best',
                value: '$maxRating',
                color: const Color(0xFFFFD700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        '$label $value',
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}