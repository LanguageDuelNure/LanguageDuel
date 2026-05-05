// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:language_duel/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  List<UserAdminListItemDto> _allUsers = [];
  List<UserAdminListItemDto> _filtered = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchCtrl = TextEditingController();

  /// Tracks which user IDs are mid-request (ban/unban in progress)
  final Set<String> _pendingIds = {};

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_applyFilter);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUsers());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Data ────────────────────────────────────────────────────────────────────

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();
    try {
      final users = await ApiService().getAllUsers(token: auth.token!);
      if (!mounted) return;
      setState(() {
        _allUsers = users;
        _isLoading = false;
      });
      _applyFilter();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? List.of(_allUsers)
          : _allUsers
              .where((u) =>
                  u.name.toLowerCase().contains(q) ||
                  (u.email?.toLowerCase().contains(q) ?? false))
              .toList();
    });
  }

  // ── Actions ─────────────────────────────────────────────────────────────────

  Future<void> _ban(UserAdminListItemDto user) async {
    final l10n = AppLocalizations.of(context)!;
    // Returns a Map with 'days' and 'reason'
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _BanDaysDialog(userName: user.name),
    );
    if (result == null || !mounted) return;

    setState(() => _pendingIds.add(user.id));
    final auth = context.read<AuthProvider>();
    try {
      await ApiService().banUser(
        token: auth.token!, 
        userId: user.id, 
        days: result['days'], 
        reason: result['reason'] // Passed to API
      );
      await _loadUsers();
      if (mounted) _showSnack(l10n.adminBanSuccess(user.name), AppTheme.danger);
    } catch (e) {
      if (mounted) _showSnack(e.toString(), AppTheme.danger);
    } finally {
      if (mounted) setState(() => _pendingIds.remove(user.id));
    }
  }

  Future<void> _unban(UserAdminListItemDto user) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _pendingIds.add(user.id));
    final auth = context.read<AuthProvider>();
    try {
      await ApiService().unbanUser(token: auth.token!, userId: user.id);
      await _loadUsers();
      if (mounted) {
        _showSnack(l10n.adminUnbanSuccess(user.name), AppTheme.accent);
      }
    } catch (e) {
      if (mounted) _showSnack(e.toString(), AppTheme.danger);
    } finally {
      if (mounted) setState(() => _pendingIds.remove(user.id));
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppTheme.danger.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_outlined,
                        color: AppTheme.danger, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      l10n.adminBadge,
                      style: const TextStyle(
                        color: AppTheme.danger,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 10),

              Text(l10n.adminUsersTitle,
                      style: Theme.of(context).textTheme.displayMedium)
                  .animate()
                  .fadeIn(delay: 50.ms),
              const SizedBox(height: 4),

              Text(
                _isLoading
                    ? l10n.adminLoadingUsers
                    : l10n.adminUserCount(_allUsers.length),
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 14),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 20),

              // Search
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: l10n.adminSearchHint,
                    hintStyle: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 14),
                    prefixIcon: const Icon(Icons.search,
                        color: AppTheme.textSecondary, size: 20),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close,
                                color: AppTheme.textSecondary, size: 18),
                            onPressed: () => _searchCtrl.clear(),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ).animate().fadeIn(delay: 150.ms),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _ErrorView(message: _error!, onRetry: _loadUsers)
                  : _filtered.isEmpty
                      ? _EmptyView(query: _searchCtrl.text)
                      : RefreshIndicator(
                          onRefresh: _loadUsers,
                          color: AppTheme.accent,
                          backgroundColor: AppTheme.surface,
                          child: ListView.separated(
                            padding:
                                const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (ctx, i) {
                              final user = _filtered[i];
                              return _UserTile(
                                key: ValueKey(user.id),
                                user: user,
                                isPending: _pendingIds.contains(user.id),
                                onBan: () => _ban(user),
                                onUnban: () => _unban(user),
                                index: i,
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// User tile
// ---------------------------------------------------------------------------

class _UserTile extends StatelessWidget {
  final UserAdminListItemDto user;
  final bool isPending;
  final VoidCallback onBan;
  final VoidCallback onUnban;
  final int index;

  const _UserTile({
    super.key,
    required this.user,
    required this.isPending,
    required this.onBan,
    required this.onUnban,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isBanned = user.isBanned;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isBanned
              ? AppTheme.danger.withOpacity(0.3)
              : AppTheme.border,
        ),
      ),
      child: Row(
        children: [
          _UserAvatar(user: user, isBanned: isBanned),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isBanned) ...[
                      const SizedBox(width: 8),
                      _BannedBadge(),
                    ],
                  ],
                ),
                if (user.email != null && user.email!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    user.email!,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (isBanned && user.bannedUntil != null) ...[
                  const SizedBox(height: 6),
                  _BannedUntilRow(until: user.bannedUntil!, l10n: l10n),
                ],
              ],
            ),
          ),

          const SizedBox(width: 10),

          isPending
              ? const SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppTheme.accent),
                )
              : isBanned
                  ? _ActionChip(
                      label: l10n.adminUnban,
                      color: AppTheme.accent,
                      icon: Icons.lock_open_outlined,
                      onTap: onUnban,
                    )
                  : _ActionChip(
                      label: l10n.adminBan,
                      color: AppTheme.danger,
                      icon: Icons.block_outlined,
                      onTap: onBan,
                    ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 40 * index))
        .fadeIn()
        .slideY(begin: 0.04, end: 0);
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _UserAvatar extends StatelessWidget {
  final UserAdminListItemDto user;
  final bool isBanned;

  const _UserAvatar({required this.user, required this.isBanned});

  @override
  Widget build(BuildContext context) {
    final hasImage = user.imageUrl != null && user.imageUrl!.isNotEmpty;
    return Stack(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: isBanned
              ? AppTheme.danger.withOpacity(0.15)
              : AppTheme.surfaceElevated,
          backgroundImage: hasImage ? NetworkImage(user.imageUrl!) : null,
          child: hasImage
              ? null
              : Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: isBanned
                        ? AppTheme.danger
                        : AppTheme.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
        ),
        if (isBanned)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppTheme.danger,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.surface, width: 1.5),
              ),
              child:
                  const Icon(Icons.block, color: Colors.white, size: 8),
            ),
          ),
      ],
    );
  }
}

class _BannedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.danger.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.danger.withOpacity(0.35)),
      ),
      child: Text(
        l10n.adminBannedLabel,
        style: const TextStyle(
          color: AppTheme.danger,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _BannedUntilRow extends StatelessWidget {
  final DateTime until;
  final AppLocalizations l10n;

  const _BannedUntilRow({required this.until, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final formatted =
        '${until.year}-${until.month.toString().padLeft(2, '0')}-${until.day.toString().padLeft(2, '0')}';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.schedule_outlined,
            color: AppTheme.danger, size: 12),
        const SizedBox(width: 4),
        Text(
          l10n.adminBannedUntil(formatted),
          style: const TextStyle(
            color: AppTheme.danger,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ban-days dialog
// ---------------------------------------------------------------------------

class _BanDaysDialog extends StatefulWidget {
  final String userName;

  const _BanDaysDialog({required this.userName});

  @override
  State<_BanDaysDialog> createState() => _BanDaysDialogState();
}

class _BanDaysDialogState extends State<_BanDaysDialog> {
  final _daysCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController(); // ADDED
  final _formKey = GlobalKey<FormState>();

  static const _presets = [1, 3, 7, 14, 30];

  @override
  void dispose() {
    _daysCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.block_outlined, color: AppTheme.danger, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.adminBanDialogTitle, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
                        Text(widget.userName, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presets.map((d) {
                  return GestureDetector(
                    onTap: () => setState(() => _daysCtrl.text = '$d'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Text(l10n.adminDayCount(d), style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _daysCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: l10n.adminBanDaysHint,
                  hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  suffixText: l10n.adminDaysSuffix,
                  suffixStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                validator: (v) {
                  final n = int.tryParse(v?.trim() ?? '');
                  if (n == null || n < 1) return l10n.adminBanDaysError;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // NEW REASON FIELD
              TextFormField(
                controller: _reasonCtrl,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Reason for ban (Required)',
                  hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                validator: (v) => v?.trim().isEmpty == true ? 'Reason is required' : null,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: const BorderSide(color: AppTheme.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(l10n.adminCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(context, {
                            'days': int.parse(_daysCtrl.text.trim()),
                            'reason': _reasonCtrl.text.trim()
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.danger,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(l10n.adminConfirmBan),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error / empty states
// ---------------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: AppTheme.danger, size: 40),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(l10n.errorRetry),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accent,
                side: const BorderSide(color: AppTheme.accent),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String query;

  const _EmptyView({required this.query});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_search_outlined,
              color: AppTheme.textSecondary, size: 40),
          const SizedBox(height: 16),
          Text(
            query.isEmpty
                ? l10n.adminNoUsers
                : l10n.adminNoResults(query),
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}