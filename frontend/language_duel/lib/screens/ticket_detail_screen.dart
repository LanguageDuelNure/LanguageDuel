import 'package:flutter/material.dart';
import 'package:language_duel/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../utils/app_theme.dart';

class TicketDetailScreen extends StatefulWidget {
  final String ticketId;
  final bool isAdmin;
  const TicketDetailScreen({super.key, required this.ticketId, this.isAdmin = false});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  TicketDto? _ticket;
  bool _isLoading = true;
  final TextEditingController _msgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTicket();
  }

  Future<void> _loadTicket() async {
    try {
      final token = context.read<AuthProvider>().token!;
      final ticket = await ApiService().getTicket(token: token, ticketId: widget.ticketId);
      if (mounted) setState(() { _ticket = ticket; _isLoading = false; });
    } catch (e) {
      debugPrint('Error loading ticket: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    if (_msgController.text.trim().isEmpty) return;
    final txt = _msgController.text.trim();
    _msgController.clear();
    setState(() => _isLoading = true);
    final token = context.read<AuthProvider>().token!;
    try {
      if (widget.isAdmin) {
        await ApiService().replyToTicket(token: token, ticketId: widget.ticketId, message: txt);
      } else {
        await ApiService().addUserMessage(token: token, ticketId: widget.ticketId, message: txt);
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
        return;
      }
    }
    _loadTicket();
  }

  Future<void> _closeTicket() async {
    final token = context.read<AuthProvider>().token!;
    await ApiService().closeTicket(token: token, ticketId: widget.ticketId);
    _loadTicket();
  }

  String _translateStatus(String status, AppLocalizations l10n) {
    switch (status) {
      case 'Open': return l10n.ticketStatusOpen;
      case 'InProgress': return l10n.ticketStatusInProgress;
      case 'Closed': return l10n.ticketStatusClosed;
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(l10n.ticketStatusTitle(_translateStatus(_ticket?.status ?? '', l10n))),
        backgroundColor: AppTheme.surface,
        actions: [
          if (widget.isAdmin && _ticket?.status != 'Closed')
            IconButton(
              icon: const Icon(Icons.check_circle_outline, color: Colors.green),
              onPressed: _closeTicket,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ticket == null
              ? Center(child: Text(l10n.errorLoadingTicket, style: const TextStyle(color: AppTheme.danger)))
              : Column(
                  children: [
                    // ── Closed banner ───────────────────────────────────────
                    if (_ticket!.status == 'Closed')
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        color: AppTheme.danger.withOpacity(0.12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_outline, color: AppTheme.danger, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              l10n.ticketStatusClosed,
                              style: const TextStyle(
                                color: AppTheme.danger,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ── Messages ────────────────────────────────────────────
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _ticket!.messages.length,
                        itemBuilder: (ctx, i) {
                          final msg = _ticket!.messages[i];
                          // isMyBubble: for user → their own msgs on right;
                          //             for admin → user msgs on left, admin on right
                          final bool isMyBubble = widget.isAdmin ? !msg.isMine : msg.isMine;
                          // isMine=true → ticket owner (user), isMine=false → Support
                          final String senderName = msg.isMine ? _ticket!.userName : 'Support';

                          return Align(
                            alignment: isMyBubble ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(ctx).size.width * 0.72,
                              ),
                              child: Column(
                                crossAxisAlignment: isMyBubble
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  // Sender nickname
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 3, left: 4, right: 4),
                                    child: Text(
                                      senderName,
                                      style: TextStyle(
                                        color: isMyBubble ? AppTheme.accent : AppTheme.textSecondary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  // Bubble with directional tail
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isMyBubble
                                          ? AppTheme.accent.withOpacity(0.2)
                                          : AppTheme.surfaceElevated,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(16),
                                        topRight: const Radius.circular(16),
                                        bottomLeft: Radius.circular(isMyBubble ? 16 : 4),
                                        bottomRight: Radius.circular(isMyBubble ? 4 : 16),
                                      ),
                                      border: Border.all(
                                        color: isMyBubble
                                            ? AppTheme.accent.withOpacity(0.3)
                                            : AppTheme.border,
                                      ),
                                    ),
                                    child: Text(
                                      msg.message,
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                  // Timestamp
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                                    child: Text(
                                      '${msg.createdAt.toLocal().hour.toString().padLeft(2, '0')}:${msg.createdAt.toLocal().minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // ── Input bar (hidden when closed) ──────────────────────
                    if (_ticket!.status != 'Closed')
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          border: Border(top: BorderSide(color: AppTheme.border)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _msgController,
                                style: const TextStyle(color: AppTheme.textPrimary),
                                decoration: InputDecoration(
                                  hintText: l10n.messageHint,
                                  hintStyle: const TextStyle(color: AppTheme.textSecondary),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send, color: AppTheme.accent),
                              onPressed: _sendMessage,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
    );
  }
}