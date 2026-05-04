import 'package:flutter/material.dart';
import 'package:language_duel/l10n/app_localizations.dart'; // Додано
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../utils/app_theme.dart';
import 'ticket_detail_screen.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  List<TicketListItemDto>? _tickets;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

Future<void> _loadTickets() async {
    try {
      final token = context.read<AuthProvider>().token!;
      final tickets = await ApiService().getTicketsByUser(token: token);
      if (mounted) setState(() { _tickets = tickets; _isLoading = false; });
    } catch (e) {
      debugPrint('Error loading tickets: $e'); // Log the error to the console
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createNewTicket(AppLocalizations l10n) async {
    final msg = await _showCreateTicketDialog(l10n);
    if (msg != null && msg.trim().isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        await ApiService().createTicket(token: context.read<AuthProvider>().token!, message: msg.trim());
      } catch (e) {
        debugPrint('Ticket Error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: $e'), backgroundColor: AppTheme.danger),
          );
        }
      }
      _loadTickets();
    }
  }

  Future<String?> _showCreateTicketDialog(AppLocalizations l10n) {
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(l10n.newTicketTitle, style: const TextStyle(color: AppTheme.textPrimary)),
        content: TextField(controller: c, style: const TextStyle(color: AppTheme.textPrimary), decoration: InputDecoration(hintText: l10n.ticketIssueHint, hintStyle: const TextStyle(color: AppTheme.textSecondary))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancelBtn, style: const TextStyle(color: AppTheme.textSecondary))),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, c.text), child: Text(l10n.submitBtn)),
        ],
      ),
    );
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
    final l10n = AppLocalizations.of(context)!; // Додано

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: Text(l10n.myTicketsTitle), backgroundColor: AppTheme.surface),
      floatingActionButton: FloatingActionButton(onPressed: () => _createNewTicket(l10n), backgroundColor: AppTheme.accent, child: const Icon(Icons.add)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tickets == null || _tickets!.isEmpty
              ? Center(child: Text(l10n.noTicketsFound, style: const TextStyle(color: AppTheme.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tickets!.length,
                  itemBuilder: (context, i) {
                    final t = _tickets![i];
                    final displayId = t.id.length >= 6 ? t.id.substring(t.id.length - 6) : t.id;
                    
                    return Card(
                      color: AppTheme.surfaceElevated,
                      child: ListTile(
                        title: Text(l10n.ticketIdLabel(displayId), style: const TextStyle(color: AppTheme.textPrimary)),
                        subtitle: Text('${_translateStatus(t.status, l10n)} • ${t.createdAt.toLocal().toString().split('.')[0]}', style: const TextStyle(color: AppTheme.textSecondary)),
                        trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TicketDetailScreen(ticketId: t.id))).then((_) => _loadTickets()),
                      ),
                    );
                  },
                ),
    );
  }
}