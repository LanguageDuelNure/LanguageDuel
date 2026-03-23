// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';

class ProfilePage extends StatelessWidget {
  final String userName;
  final String role;
  final Map<String, int> languageRatings;
  final Map<String, String> languageNames;
  final VoidCallback onLogout;

  const ProfilePage({
    super.key,
    required this.userName,
    required this.role,
    required this.languageRatings,
    required this.languageNames,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
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
              Container(
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
                  border: Border.all(
                      color: AppTheme.accent.withOpacity(0.4), width: 2),
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'D',
                    style: const TextStyle(
                      color: AppTheme.accent,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.accent.withOpacity(0.3)),
                    ),
                    child: Text(
                      role,
                      style: const TextStyle(
                        color: AppTheme.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 32),

          Text('Statistics', style: Theme.of(context).textTheme.titleLarge)
              .animate()
              .fadeIn(delay: 200.ms),
          const SizedBox(height: 14),
          const StatsGrid().animate().fadeIn(delay: 250.ms),

          if (languageRatings.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text('Ratings by language',
                    style: Theme.of(context).textTheme.titleLarge)
                .animate()
                .fadeIn(delay: 300.ms),
            const SizedBox(height: 12),
            ...languageRatings.entries.toList().asMap().entries.map((entry) {
              final i = entry.key;
              final langId = entry.value.key;
              final rating = entry.value.value;
              final name = languageNames[langId] ?? langId;
              return LanguageRatingRow(
                languageName: name,
                rating: rating,
              ).animate().fadeIn(
                  delay: Duration(milliseconds: 320 + i * 40));
            }),
          ],

          const SizedBox(height: 32),

          OutlinedButton.icon(
            onPressed: onLogout,
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
}

class LanguageRatingRow extends StatelessWidget {
  final String languageName;
  final int rating;

  const LanguageRatingRow({
    super.key,
    required this.languageName,
    required this.rating,
  });

  String get _difficultyLabel {
    if (rating < 30) return 'Легко';
    if (rating < 70) return 'Норм';
    if (rating < 120) return 'Складно';
    return 'Дуже складно';
  }

  Color get _difficultyColor {
    if (rating < 30) return AppTheme.accent;
    if (rating < 70) return const Color(0xFF4FC3F7);
    if (rating < 120) return Colors.orange;
    return AppTheme.danger;
  }

  @override
  Widget build(BuildContext context) {
    const maxRating = 120.0;
    final fraction = (rating / maxRating).clamp(0.0, 1.0);

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
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Легко  0',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 10)),
              Text('Норм  30',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 10)),
              Text('Складно  70',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 10)),
              Text('Дуже  120',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('Total matches', '0', Icons.sports_esports_outlined),
      ('Total wins', '0', Icons.emoji_events_outlined),
      ('Current rating', '0', Icons.star_border),
      ('Best rating', '0', Icons.military_tech_outlined),
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