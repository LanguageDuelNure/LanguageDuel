import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../utils/app_theme.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const HomeScreen({super.key, required this.onLogout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isMobile = MediaQuery.of(context).size.width < 700;

    final pages = [
      _PlayPage(userName: auth.userName ?? 'Duelist'),
      const _LeaderboardPage(),
      _ProfilePage(
        userName: auth.userName ?? 'Duelist',
        role: auth.role ?? 'User',
        onLogout: widget.onLogout,
      ),
    ];

    if (isMobile) {
      return Scaffold(
        body: pages[_selectedIndex],
        bottomNavigationBar: _BottomNav(
          selectedIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
        ),
      );
    }

    // Side rail for wider screens
    return Scaffold(
      body: Row(
        children: [
          _SideRail(
            selectedIndex: _selectedIndex,
            onTap: (i) => setState(() => _selectedIndex = i),
          ),
          Expanded(child: pages[_selectedIndex]),
        ],
      ),
    );
  }
}

// ─── Bottom Nav (mobile) ─────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;

  const _BottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.border)),
        color: AppTheme.surface,
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                  icon: Icons.sports_esports_outlined,
                  activeIcon: Icons.sports_esports,
                  label: 'Play',
                  isActive: selectedIndex == 0,
                  onTap: () => onTap(0)),
              _NavItem(
                  icon: Icons.leaderboard_outlined,
                  activeIcon: Icons.leaderboard,
                  label: 'Ranks',
                  isActive: selectedIndex == 1,
                  onTap: () => onTap(1)),
              _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  isActive: selectedIndex == 2,
                  onTap: () => onTap(2)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: isActive ? AppTheme.accent : AppTheme.textSecondary,
            size: 24,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppTheme.accent : AppTheme.textSecondary,
              fontSize: 11,
              fontWeight:
                  isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Side Rail (desktop) ─────────────────────────────────────────────────────

class _SideRail extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;

  const _SideRail({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(right: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppTheme.accent.withOpacity(0.3)),
                  ),
                  child: const Center(
                    child: Text(
                      'LD',
                      style: TextStyle(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'LanguageDuel',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          _RailItem(
            icon: Icons.sports_esports_outlined,
            activeIcon: Icons.sports_esports,
            label: 'Play',
            isActive: selectedIndex == 0,
            onTap: () => onTap(0),
          ),
          _RailItem(
            icon: Icons.leaderboard_outlined,
            activeIcon: Icons.leaderboard,
            label: 'Leaderboard',
            isActive: selectedIndex == 1,
            onTap: () => onTap(1),
          ),
          _RailItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
            isActive: selectedIndex == 2,
            onTap: () => onTap(2),
          ),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _RailItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.accent.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive
                  ? AppTheme.accent
                  : AppTheme.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? AppTheme.accent
                    : AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: isActive
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Play Page ───────────────────────────────────────────────────────────────

class _PlayPage extends StatefulWidget {
  final String userName;

  const _PlayPage({required this.userName});

  @override
  State<_PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<_PlayPage> {
  bool _searching = false;

  void _startSearch() {
    setState(() => _searching = true);
    // Simulate searching - in production this would connect to matchmaking
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _searching = false);
        _showComingSoon();
      }
    });
  }

  void _showComingSoon() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Coming Soon',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'Real-time matchmaking is under construction.\nYou\'re first in the arena! ⚔️',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Greeting
          Text(
            'Hello, ${widget.userName} 👋',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
          ).animate().fadeIn(),
          const SizedBox(height: 4),
          Text(
            'Ready to duel?',
            style: Theme.of(context).textTheme.displayMedium,
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 32),

          // Play card
          _PlayCard(
            isSearching: _searching,
            onPlay: _startSearch,
            onCancel: () => setState(() => _searching = false),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 24),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Rating',
                  value: '0',
                  icon: Icons.star_border,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Wins',
                  value: '0',
                  icon: Icons.emoji_events_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Played',
                  value: '0',
                  icon: Icons.history,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 24),

          // Languages
          Text(
            'Choose Language',
            style: Theme.of(context).textTheme.titleLarge,
          ).animate().fadeIn(delay: 350.ms),
          const SizedBox(height: 14),
          _LanguageGrid().animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}

class _PlayCard extends StatelessWidget {
  final bool isSearching;
  final VoidCallback onPlay;
  final VoidCallback onCancel;

  const _PlayCard({
    required this.isSearching,
    required this.onPlay,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
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
              const Text(
                'Quick Duel',
                style: TextStyle(
                  color: AppTheme.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Challenge a random opponent\nof similar skill level',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          if (isSearching) ...[
            Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.accent,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Searching for opponent...',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onCancel,
                  child: const Text('Cancel',
                      style: TextStyle(color: AppTheme.danger)),
                ),
              ],
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPlay,
                icon: const Icon(Icons.party_mode, size: 18),
                label: const Text('Find Opponent'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
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
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _LanguageGrid extends StatefulWidget {
  @override
  State<_LanguageGrid> createState() => _LanguageGridState();
}

class _LanguageGridState extends State<_LanguageGrid> {
  int _selected = 0;

  final _languages = [
    ('🇬🇧', 'English'),
    ('🇩🇪', 'German'),
    ('🇫🇷', 'French'),
    ('🇪🇸', 'Spanish'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(_languages.length, (i) {
        final (flag, name) = _languages[i];
        final isActive = _selected == i;
        return GestureDetector(
          onTap: () => setState(() => _selected = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.accent.withOpacity(0.12)
                  : AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isActive
                    ? AppTheme.accent.withOpacity(0.5)
                    : AppTheme.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(flag, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: TextStyle(
                    color: isActive
                        ? AppTheme.accent
                        : AppTheme.textSecondary,
                    fontWeight: isActive
                        ? FontWeight.w600
                        : FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ─── Leaderboard Page ────────────────────────────────────────────────────────

class _LeaderboardPage extends StatelessWidget {
  const _LeaderboardPage();

  @override
  Widget build(BuildContext context) {
    // Mock leaderboard data — replace with real API data
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
          Text('Leaderboard',
              style: Theme.of(context).textTheme.displayMedium)
              .animate().fadeIn(),
          const SizedBox(height: 4),
          const Text('Global rankings — all languages',
              style: TextStyle(color: AppTheme.textSecondary))
              .animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 28),

          // Top 3 podium
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _PodiumItem(
                  rank: 2,
                  name: players[1].name,
                  rating: players[1].rating,
                  height: 80),
              const SizedBox(width: 12),
              _PodiumItem(
                  rank: 1,
                  name: players[0].name,
                  rating: players[0].rating,
                  height: 110),
              const SizedBox(width: 12),
              _PodiumItem(
                  rank: 3,
                  name: players[2].name,
                  rating: players[2].rating,
                  height: 60),
            ],
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 28),

          // Rest of list
          ...List.generate(
            players.length - 3,
            (i) => _LeaderRow(
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

class _PodiumItem extends StatelessWidget {
  final int rank;
  final String name;
  final int rating;
  final double height;

  const _PodiumItem({
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
          Text(
            '$rating pts',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
            ),
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
          ),
        ],
      ),
    );
  }
}

class _LeaderRow extends StatelessWidget {
  final int rank;
  final String name;
  final int rating;
  final int wins;

  const _LeaderRow({
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
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
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

// ─── Profile Page ─────────────────────────────────────────────────────────────

class _ProfilePage extends StatelessWidget {
  final String userName;
  final String role;
  final VoidCallback onLogout;

  const _ProfilePage({
    required this.userName,
    required this.role,
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
          Text('Profile',
              style: Theme.of(context).textTheme.displayMedium)
              .animate().fadeIn(),
          const SizedBox(height: 28),

          // Avatar + name
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
                    userName.isNotEmpty
                        ? userName[0].toUpperCase()
                        : 'D',
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

          // Stats
          Text('Statistics',
                  style: Theme.of(context).textTheme.titleLarge)
              .animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 14),
          _StatsGrid().animate().fadeIn(delay: 250.ms),
          const SizedBox(height: 32),

          // Logout
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
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

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