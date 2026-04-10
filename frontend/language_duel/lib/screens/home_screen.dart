import 'package:flutter/material.dart';
import 'package:language_duel/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/game_service.dart';
import '../widgets/nav_widgets.dart';
import 'game_screen.dart';
import 'play_page.dart';
import 'leaderboard_page.dart';
import 'profile_page.dart';
import 'admin_users_page.dart';

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
    final game = context.watch<GameService>();
    final l10n = AppLocalizations.of(context)!;
    final isMobile = MediaQuery.of(context).size.width < 700;
    final isAdmin = auth.role == 'Admin';

    if (game.status == GameStatus.searching ||
        game.status == GameStatus.inGame ||
        game.status == GameStatus.finished) {
      return const GameScreen();
    }

    final pages = [
      PlayPage(userName: auth.userName ?? l10n.defaultDuelistName),
      LeaderboardPage(
        languages: game.allLanguageNames.entries
            .map((e) => LanguageOption(id: e.key, name: e.value))
            .toList(),
      ),
      ProfilePage(onLogout: widget.onLogout),
      if (isAdmin) const AdminUsersPage(),
    ];

    // Clamp in case the admin tab disappears on role change
    final safeIndex = _selectedIndex.clamp(0, pages.length - 1);

    if (isMobile) {
      return Scaffold(
        body: pages[safeIndex],
        bottomNavigationBar: BottomNav(
          selectedIndex: safeIndex,
          isAdmin: isAdmin,
          onTap: (i) => setState(() => _selectedIndex = i),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          SideRail(
            selectedIndex: safeIndex,
            isAdmin: isAdmin,
            onTap: (i) => setState(() => _selectedIndex = i),
          ),
          Expanded(child: pages[safeIndex]),
        ],
      ),
    );
  }
}