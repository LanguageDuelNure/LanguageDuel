import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:language_duel/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../services/game_service.dart';
import '../services/locale_provider.dart';
import 'game_history_screen.dart';
import 'tickets_screen.dart';
import 'admin_tickets_screen.dart';

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

  bool _isBanned = false;
  DateTime? _bannedUntil;
  String? _banReason;

  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUser(context);
    });
  }

  Future<void> _loadUser(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final userId = auth.userId;
    final token = auth.token;
    final l10n = AppLocalizations.of(context)!;

    if (userId == null || token == null) {
      if (mounted) {
        setState(() {
          _error = l10n.notAuthenticated;
          _isLoading = false;
        });
      }
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
        final isApiEx = e is ApiException;
        final banned = isApiEx && e.isBanned;
        
        setState(() {
          _isBanned = banned;
          _bannedUntil = isApiEx ? e.bannedUntil : null;
          _banReason = isApiEx ? e.banReason : null;
          _error = banned ? null : e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final l10n = AppLocalizations.of(context)!;
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    final name = file.name;

    final auth = context.read<AuthProvider>();
    if (auth.token == null) return;

    setState(() => _uploadingAvatar = true);
    try {
      await ApiService().updateProfileWithAvatar(
        token: auth.token!,
        name: auth.userName,
        imageBytes: bytes,
        imageName: name,
      );
      if (mounted) await _refreshUser();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.avatarUploadError),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _refreshUser() async {
    final auth = context.read<AuthProvider>();
    final userId = auth.userId;
    final token = auth.token;
    if (userId == null || token == null) return;
    try {
      final user = await ApiService().getUser(userId: userId, token: token);
      if (mounted) setState(() => _user = user);
    } catch (_) {}
  }

  Future<void> _showEditNameDialog() async {
    final auth = context.read<AuthProvider>();
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: auth.userName ?? '');

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => _EditNameDialog(controller: controller),
    );

    if (result != null && result.trim().isNotEmpty && mounted) {
      try {
        await context.read<AuthProvider>().updateName(result.trim());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.nameSavedSuccess),
              backgroundColor: AppTheme.accent,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.nameSaveError),
              backgroundColor: AppTheme.danger,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context)!;
    final userName = auth.userName ?? '';
    final role = auth.role ?? l10n.rolePlayer;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(l10n.profileTitle, style: Theme.of(context).textTheme.displayMedium)
              .animate()
              .fadeIn(),
          const SizedBox(height: 28),

          Row(
            children: [
              _AvatarWithUpload(
                user: _user,
                userName: userName,
                uploading: _uploadingAvatar,
                onTap: _isBanned ? () {} : _pickAndUploadAvatar,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            userName,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!_isBanned)
                          GestureDetector(
                            onTap: _showEditNameDialog,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceElevated,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: const Icon(
                                Icons.edit_outlined,
                                color: AppTheme.textSecondary,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _RoleBadge(role: role),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 32),

          if (_isBanned) ...[
            _BannedBanner(bannedUntil: _bannedUntil, banReason: _banReason).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 32),
          ],

          if (!_isBanned) ...[
          Text(l10n.statsTitle, style: Theme.of(context).textTheme.titleLarge)
              .animate()
              .fadeIn(delay: 200.ms),
          const SizedBox(height: 14),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
                .animate()
                .fadeIn(delay: 250.ms)
          else if (_error != null)
            _ErrorBanner(message: _error!, onRetry: () => _loadUser(context))
          else
            _StatsGrid(user: _user!).animate().fadeIn(delay: 250.ms),

          if (!_isLoading && _error == null && _user != null && _user!.languageRatings.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(l10n.ratingsByLanguageTitle,
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

          ],

          const SizedBox(height: 24),
          _ProfileMenuButton(
            icon: Icons.history,
            label: l10n.matchHistoryTitle, // ЛОКАЛІЗАЦІЯ
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GameHistoryScreen())),
          ).animate().fadeIn(delay: 360.ms),
          
          const SizedBox(height: 12),
          _ProfileMenuButton(
            icon: Icons.support_agent,
            label: l10n.myTicketsTitle, // ЛОКАЛІЗАЦІЯ
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TicketsScreen())),
          ).animate().fadeIn(delay: 370.ms),

          if (role == 'Admin') ...[
            const SizedBox(height: 12),
            _ProfileMenuButton(
              icon: Icons.admin_panel_settings,
              label: l10n.manageTicketsAdmin, // ЛОКАЛІЗАЦІЯ
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTicketsScreen())),
            ).animate().fadeIn(delay: 380.ms),
          ],
          
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.language, color: AppTheme.textSecondary, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      l10n.settingsLanguage,
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<Locale>(
                    value: context.watch<LocaleProvider>().locale,
                    dropdownColor: AppTheme.surfaceElevated,
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
                    items: [
                      DropdownMenuItem(
                        value: const Locale('en'),
                        child: Text(l10n.langEnglish, style: const TextStyle(color: AppTheme.textPrimary)),
                      ),
                      DropdownMenuItem(
                        value: const Locale('uk'),
                        child: Text(l10n.langUkrainian, style: const TextStyle(color: AppTheme.textPrimary)),
                      ),
                    ],
                    onChanged: (Locale? newLocale) {
                      if (newLocale != null) {
                        context.read<LocaleProvider>().setLocale(newLocale);
                      }
                    },
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 350.ms),

          const SizedBox(height: 24),

          OutlinedButton.icon(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout, size: 18, color: AppTheme.danger),
            label: Text(l10n.signOutBtn,
                style: const TextStyle(color: AppTheme.danger)),
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

class _ProfileMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileMenuButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.accent, size: 22),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w500))),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _AvatarWithUpload extends StatelessWidget {
  final UserDto? user;
  final String userName;
  final bool uploading;
  final VoidCallback onTap;

  const _AvatarWithUpload({
    required this.user,
    required this.userName,
    required this.uploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = user?.imageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return GestureDetector(
      onTap: uploading ? null : onTap,
      child: Stack(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: hasImage
                  ? null
                  : LinearGradient(
                      colors: [
                        AppTheme.accent.withOpacity(0.3),
                        AppTheme.accentDim.withOpacity(0.3),
                      ],
                    ),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppTheme.accent.withOpacity(0.4), width: 2),
            ),
            child: ClipOval(
              child: hasImage
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _InitialAvatar(userName: userName),
                    )
                  : _InitialAvatar(userName: userName),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: uploading
                ? Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppTheme.bg,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppTheme.accent.withOpacity(0.4), width: 1),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(3),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.accent),
                    ),
                  )
                : Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppTheme.accent.withOpacity(0.5), width: 1.5),
                    ),
                    child: const Icon(Icons.camera_alt,
                        size: 12, color: AppTheme.accent),
                  ),
          ),
        ],
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  final String userName;
  const _InitialAvatar({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
        style: const TextStyle(
          color: AppTheme.accent,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EditNameDialog extends StatelessWidget {
  final TextEditingController controller;
  const _EditNameDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        l10n.editNameTitle,
        style: const TextStyle(
            color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
      ),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: 32,
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: l10n.editNameHint,
          hintStyle: const TextStyle(color: AppTheme.textSecondary),
          counterStyle: const TextStyle(color: AppTheme.textSecondary),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppTheme.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppTheme.accent, width: 1.5),
          ),
        ),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancelBtn,
              style: const TextStyle(color: AppTheme.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: Text(l10n.saveBtn),
        ),
      ],
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
    final l10n = AppLocalizations.of(context)!;
    final stats = [
      (l10n.statTotalMatches, '${user.totalGames}', Icons.sports_esports_outlined),
      (l10n.statTotalWins, '${user.totalWins}', Icons.emoji_events_outlined),
      (l10n.statCurrentRating, '$_currentRating', Icons.star_border),
      (l10n.statBestRating, '$_bestRating', Icons.military_tech_outlined),
    ];

    Widget buildTile((String, String, IconData) s) {
      final (label, value, icon) = s;
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.textSecondary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [buildTile(stats[0]), const SizedBox(width: 10), buildTile(stats[1])],
          ),
        ),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [buildTile(stats[2]), const SizedBox(width: 10), buildTile(stats[3])],
          ),
        ),
      ],
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

  String _difficultyLabel(AppLocalizations l10n) {
    if (rating < 30) return l10n.diffEasy;
    if (rating < 70) return l10n.diffMedium;
    if (rating < 120) return l10n.diffHard;
    return l10n.diffVeryHard;
  }

  Color get _difficultyColor {
    if (rating < 30) return AppTheme.accent;
    if (rating < 70) return const Color(0xFF4FC3F7);
    if (rating < 120) return Colors.orange;
    return AppTheme.danger;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                    l10n.ptsSuffix(rating),
                    style: TextStyle(
                      color: _difficultyColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _difficultyColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: _difficultyColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      _difficultyLabel(l10n),
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
                  label: l10n.statW, value: '$totalWins', color: AppTheme.accent),
              const SizedBox(width: 8),
              _StatChip(
                  label: l10n.statG,
                  value: '$totalGames',
                  color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              _StatChip(
                label: l10n.statBest,
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
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _BannedBanner extends StatelessWidget {
  final DateTime? bannedUntil;
  final String? banReason;

  const _BannedBanner({this.bannedUntil, this.banReason});

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
                if (banReason != null && banReason!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.banReasonLabel(banReason!), // ЛОКАЛІЗАЦІЯ
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}