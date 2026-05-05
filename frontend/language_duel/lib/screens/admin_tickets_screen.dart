import 'package:flutter/material.dart';
import 'package:language_duel/l10n/app_localizations.dart'; // Додано
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../utils/app_theme.dart';
import 'ticket_detail_screen.dart';

class AdminTicketsScreen extends StatelessWidget {
  const AdminTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Додано

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.bg,
        appBar: AppBar(
          title: Text(l10n.manageTicketsTitle),
          backgroundColor: AppTheme.surface,
          bottom: TabBar(
            indicatorColor: AppTheme.accent,
            labelColor: AppTheme.accent,
            unselectedLabelColor: AppTheme.textSecondary,
            tabs: [
              Tab(text: l10n.ticketStatusOpen), 
              Tab(text: l10n.ticketStatusInProgress), 
              Tab(text: l10n.ticketStatusClosed)
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AdminTicketList(status: 'open'),
            _AdminTicketList(status: 'in-progress'),
            _AdminTicketList(status: 'closed'),
          ],
        ),
      ),
    );
  }
}

class _AdminTicketList extends StatefulWidget {
  final String status;
  const _AdminTicketList({required this.status});

  @override
  State<_AdminTicketList> createState() => _AdminTicketListState();
}

class _AdminTicketListState extends State<_AdminTicketList> {
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
      final tickets = await ApiService().getAdminTickets(token: token, status: widget.status);
      if (mounted) setState(() { _tickets = tickets; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Додано

    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_tickets == null || _tickets!.isEmpty) return Center(child: Text(l10n.noTicketsFound, style: const TextStyle(color: AppTheme.textSecondary)));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tickets!.length,
      itemBuilder: (context, i) {
        final t = _tickets![i];
        return Card(
          color: AppTheme.surfaceElevated,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text('${t.userName} (${l10n.ticketIdLabel(t.id.substring(0, 6))})', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
            subtitle: Text(t.lastMessage ?? l10n.noMessages, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.textSecondary)),
            trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TicketDetailScreen(ticketId: t.id, isAdmin: true))).then((_) => _loadTickets()),
          ),
        );
      },
    );
  }
}