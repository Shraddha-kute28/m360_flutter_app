import 'package:flutter/material.dart';
import '../widgets/m360_app_bar.dart';
import 'add_ticket_screen.dart';
import 'all_tickets_screen.dart';
import 'profile_tab.dart';
import '../widgets/action_card.dart';

class TechnicianScreen extends StatefulWidget {
  const TechnicianScreen({super.key});

  @override
  State<TechnicianScreen> createState() => _TechnicianScreenState();
}

class _TechnicianScreenState extends State<TechnicianScreen> {
  int _selectedIndex = 0;

  void _setTab(int index) {
    setState(() => _selectedIndex = index);
  }

  final List<Widget> _pages = const [
    TechnicianHomeTab(),
    AllTicketsScreen(),
    ProfileTab(),
  ];

  final List<String> _titles = [
    '',            // Home
    'All Tickets', // Tickets
    'Profile',     // Profile
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:() async{
        return false;
      },

      child:Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _setTab,
        selectedItemColor: const Color(0xFF1E88E5),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    ),
    );
  }

  /// ================= APP BAR =================
  PreferredSizeWidget _buildAppBar() {
    /// 🏠 HOME → ONLY LOGO (CENTER)
    if (_selectedIndex == 0) {
      return AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        centerTitle: false,
        title: Image.asset(
          'images/appBarIcon.png',
          height: 37,
          fit: BoxFit.contain,
        ),
      );
    }

    /// 📄 OTHER SCREENS → LOGO LEFT + TITLE CENTER
    return M360AppBar(
      title: _titles[_selectedIndex],
    );
  }
}

/// ================= HOME TAB =================
/// ⚠️ MUST BE OUTSIDE TechnicianScreenState
class TechnicianHomeTab extends StatelessWidget {
  const TechnicianHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final parent =
    context.findAncestorStateOfType<_TechnicianScreenState>();

    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        ActionCard(
          title: 'Add Ticket',
          icon: Icons.add,
          color: Colors.blue,
          page: const AddTicketScreen(),
        ),
        ActionCard(
          title: 'All Tickets',
          icon: Icons.history,
          color: Colors.green,
          onTap: () => parent?._setTab(1),
        ),
      ],
    );
  }
}
