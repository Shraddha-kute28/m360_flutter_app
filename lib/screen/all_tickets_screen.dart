import 'package:flutter/material.dart';
import 'package:M360/core/token_storage.dart';
import 'package:M360/screen/ptw_initiate_screen.dart';
import 'package:M360/screen/ptc_initiate_screen.dart';
import '../services/ticket_service.dart';
import '../utils/ticket_status.dart';

class AllTicketsScreen extends StatefulWidget {
  const AllTicketsScreen({super.key});

  @override
  State<AllTicketsScreen> createState() => _AllTicketsScreenState();
}

class _AllTicketsScreenState extends State<AllTicketsScreen> {
  bool isTechnician = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String _selectedStatus = 'All';

  final List<String> _statusOptions = [
    'All',
    'Open',
    'Ptw_Pending',
    'Ptw_Approved',
    'InProgress',
    'Ptc_Pending',
    'Closed',
  ];

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await TokenStorage.getRole();
    setState(() {
      isTechnician = role?.toLowerCase() == 'technician';
    });
  }

  TicketStatus _parseStatus(String? status) {
    switch (status) {
      case 'Open':
        return TicketStatus.open;
      case 'Ptw_Pending':
        return TicketStatus.ptwPending;
      case 'Ptw_Approved':
        return TicketStatus.ptwApproved;
      case 'Ptw_Rejected':
        return TicketStatus.ptwRejected;
      case 'InProgress':
        return TicketStatus.inProgress;
      case 'Ptc_Pending':
        return TicketStatus.ptcPending;
      case 'Ptc_Rejected':
        return TicketStatus.ptcRejected;
      case 'Closed':
        return TicketStatus.closed;
      default:
        return TicketStatus.open;
    }
  }

  List<Map<String, dynamic>> _filterTickets(List<Map<String, dynamic>> tickets) {
    return tickets.where((t) {
      final statusMatch =
          _selectedStatus == 'All' || t['status'] == _selectedStatus;

      final searchMatch = _searchText.isEmpty ||
          (t['machineName'] ?? '')
              .toString()
              .toLowerCase()
              .contains(_searchText.toLowerCase()) ||
          (t['eventCode'] ?? '')
              .toString()
              .toLowerCase()
              .contains(_searchText.toLowerCase());

      return statusMatch && searchMatch;
    }).toList();
  }

  Future<void> _handleTicketAction({
    required int ticketId,
    required TicketStatus status,
  }) async {
    switch (status) {
      case TicketStatus.open:
      case TicketStatus.ptwRejected:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InitiatePTWScreen(eventId: ticketId),
          ),
        );
        setState(() {});
        break;

      case TicketStatus.ptwApproved:
      case TicketStatus.ptcRejected:
        final success = await TicketService.startWork(eventId: ticketId);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Work started successfully')),
          );
          setState(() {});
        }
        break;

      case TicketStatus.inProgress:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InitiatePTCScreen(eventId: ticketId),
          ),
        );
        setState(() {});
        break;

      default:
        break;
    }
  }

  Future<void> _showHistory(
      BuildContext context, {
        required int ticketId,
        required String ticketCode,
      }) async {
    final history = await TicketService.getTicketHistory(ticketId);
    if (!mounted) return;

    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 600;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return MediaQuery.removePadding(
          context: ctx,
          removeLeft: true,
          removeRight: true,
          child: Container(
            width: isTablet ? width * 0.98 : width, // nearly full width on tablet
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Ticket History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(child: _HistoryDataTable(history: history)),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: TicketService.getAllTickets(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final tickets = _filterTickets(snapshot.data!);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchText = v),
                    decoration: InputDecoration(
                      hintText: 'Search by Machine or Ticket ID',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color(0xFFF9FBFF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final t = tickets[index];
                      final statusEnum = _parseStatus(t['status']);

                      return _TicketCard(
                        t: t,
                        statusEnum: statusEnum,
                        isTechnician: isTechnician,
                        onAction: _handleTicketAction,
                        onHistory: _showHistory,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// ================= TICKET CARD =================
class _TicketCard extends StatelessWidget {
  final Map<String, dynamic> t;
  final TicketStatus statusEnum;
  final bool isTechnician;
  final Function onAction;
  final Function onHistory;

  const _TicketCard({
    required this.t,
    required this.statusEnum,
    required this.isTechnician,
    required this.onAction,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 5,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${t['eventCode'] ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t['machineName'] ?? '--',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(statusEnum),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('By: ${t['createdBy'] ?? '--'}'),
                Text(formatDate(t['createdDate'])),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (isTechnician && statusEnum.hasAction)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onAction(
                        ticketId: t['id'],
                        status: statusEnum,
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: Text(statusEnum.actionLabel),
                    ),
                  ),
                if (isTechnician && statusEnum.hasAction)
                  const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onHistory(
                      context,
                      ticketId: t['id'],
                      ticketCode: t['eventCode'] ?? 'TCK_${t['id']}',
                    ),
                    icon: const Icon(Icons.history),
                    label: const Text('History'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// STATUS CHIP
class _StatusChip extends StatelessWidget {
  final TicketStatus status;
  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayText,
        style: TextStyle(
          color: status.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// HISTORY TABLE
class _HistoryDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  const _HistoryDataTable({required this.history});

  TicketStatus _parseHistoryStatus(String? status) {
    switch (status) {
      case 'Open':
        return TicketStatus.open;
      case 'Ptw_Pending':
        return TicketStatus.ptwPending;
      case 'Ptw_Approved':
        return TicketStatus.ptwApproved;
      case 'Ptw_Rejected':
        return TicketStatus.ptwRejected;
      case 'InProgress':
        return TicketStatus.inProgress;
      case 'Ptc_Pending':
        return TicketStatus.ptcPending;
      case 'Ptc_Rejected':
        return TicketStatus.ptcRejected;
      case 'Closed':
        return TicketStatus.closed;
      default:
        return TicketStatus.open;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowColor:
              MaterialStateProperty.all(Colors.blueAccent.shade100),
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Action By')),
                DataColumn(label: Text('Comment')),
              ],
              rows: history.map((h) {
                final statusEnum = _parseHistoryStatus(h['status']);
                return DataRow(cells: [
                  DataCell(Text(formatDate(h['actionDate']))),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusEnum.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusEnum.displayText,
                        style: TextStyle(
                          color: statusEnum.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(h['actionByName'] ?? '--')),
                  DataCell(
                    SizedBox(
                      width: 260,
                      child: Text(
                        h['actionComment'] ?? '',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

String formatDate(dynamic date) {
  if (date == null) return '--';
  final d = date.toString();
  return d.length >= 10 ? d.substring(0, 10) : d;
}
