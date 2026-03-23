// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final players = List.generate(
      10,
      (i) => (
        rank: i + 1,
        name: ['Duelist_${1000 + i * 17}', 'Champion_${200 + i * 31}',
          'Warrior_${500 + i * 13}'][i % 3],
        rating: max(0, 1200 - i * 95),
        wins: max(0, 48 - i * 4),
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Leaderboard', style: Theme.of(context).textTheme.displayMedium)
              .animate()
              .fadeIn(),
          const SizedBox(height: 4),
          const Text('Global rankings — all languages',
                  style: TextStyle(color: AppTheme.textSecondary))
              .animate()
              .fadeIn(delay: 100.ms),
          const SizedBox(height: 28),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              PodiumItem(rank: 2, name: players[1].name, rating: players[1].rating, height: 80),
              const SizedBox(width: 12),
              PodiumItem(rank: 1, name: players[0].name, rating: players[0].rating, height: 110),
              const SizedBox(width: 12),
              PodiumItem(rank: 3, name: players[2].name, rating: players[2].rating, height: 60),
            ],
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 28),

          ...List.generate(
            players.length - 3,
            (i) => LeaderRow(
              rank: players[i + 3].rank,
              name: players[i + 3].name,
              rating: players[i + 3].rating,
              wins: players[i + 3].wins,
            ).animate().fadeIn(delay: Duration(milliseconds: 250 + i * 40)),
          ),
        ],
      ),
    );
  }
}

class PodiumItem extends StatelessWidget {
  final int rank;
  final String name;
  final int rating;
  final double height;

  const PodiumItem({
    super.key,
    required this.rank,
    required this.name,
    required this.rating,
    required this.height,
  });

  Color get _color {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFFC0C0C0);
    return const Color(0xFFCD7F32);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: _color.withOpacity(0.5)),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: _color,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
          ),
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
            '$rating pts',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Container(
            height: height,
            decoration: BoxDecoration(
              color: _color.withOpacity(0.12),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              border: Border.all(color: _color.withOpacity(0.3)),
            ),
          ),
        ],
      ),
    );
  }
}

class LeaderRow extends StatelessWidget {
  final int rank;
  final String name;
  final int rating;
  final int wins;

  const LeaderRow({
    super.key,
    required this.rank,
    required this.name,
    required this.rating,
    required this.wins,
  });

  @override
  Widget build(BuildContext context) {
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
            '$wins wins',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(width: 16),
          Text(
            '$rating pts',
            style: const TextStyle(
              color: AppTheme.accent,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}