

import 'package:flutter/material.dart';
import 'package:language_duel/l10n/app_localizations.dart';
import '../utils/app_theme.dart';

class BottomNav extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;

  const BottomNav({super.key, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; 

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
              NavItem(
                icon: Icons.sports_esports_outlined,
                activeIcon: Icons.sports_esports,
                label: l10n.navPlay, 
                isActive: selectedIndex == 0,
                onTap: () => onTap(0),
              ),
              NavItem(
                icon: Icons.leaderboard_outlined,
                activeIcon: Icons.leaderboard,
                label: l10n.navLeaderboard, 
                isActive: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
              NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: l10n.navProfile, 
                isActive: selectedIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const NavItem({
    super.key,
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
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class SideRail extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;

  const SideRail({super.key, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; 

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
                    border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
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
          RailItem(
            icon: Icons.sports_esports_outlined,
            activeIcon: Icons.sports_esports,
            label: l10n.navPlay, 
            isActive: selectedIndex == 0,
            onTap: () => onTap(0),
          ),
          RailItem(
            icon: Icons.leaderboard_outlined,
            activeIcon: Icons.leaderboard,
            label: l10n.navLeaderboard, 
            isActive: selectedIndex == 1,
            onTap: () => onTap(1),
          ),
          RailItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: l10n.navProfile, 
            isActive: selectedIndex == 2,
            onTap: () => onTap(2),
          ),
        ],
      ),
    );
  }
}

class RailItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const RailItem({
    super.key,
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
          color: isActive ? AppTheme.accent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppTheme.accent : AppTheme.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppTheme.accent : AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}