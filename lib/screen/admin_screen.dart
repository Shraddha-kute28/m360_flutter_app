import 'package:flutter/material.dart';

import 'add_ticket_screen.dart';
import 'all_tickets_screen.dart';
import 'ptw_screen.dart';
import 'ptc_screen.dart';
import 'profile_tab.dart';
import '../widgets/m360_app_bar.dart';
import '../widgets/action_card.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;

  /// 🔑 ORDER MUST MATCH BOTTOM NAV
  final List<Widget> _pages = const [
    AdminHomeTab(),       // 0
    AllTicketsScreen(),   // 1
    PtwScreen(),          // 2
    PTCScreen(),          // 3
    ProfileTab(),         // 4
  ];

  final List<String> _titles = [
    '',             // Home (logo only)
    'All Tickets',
    'Permission To Work',
    'Permission To Close',
    'Profile',
  ];

  void _setTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:() async{
        return false;
      },

      child:Scaffold(
      appBar: _buildAppBar(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _setTab,
        selectedItemColor: const Color(0xFF1E88E5),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number), label: 'Tickets'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment), label: 'PTW'),
          BottomNavigationBarItem(
              icon: Icon(Icons.groups), label: 'PTC'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    ),
    );

  }

  /// ================= APP BAR =================
  PreferredSizeWidget _buildAppBar() {
    /// 🏠 HOME → ONLY LOGO
    if (_selectedIndex == 0) {
      return AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        title: Image.asset(
          'images/appBarIcon.png',
          height: 37,
          fit: BoxFit.contain,
        ),
      );
    }

    /// 📄 OTHER SCREENS → LOGO + TITLE
    return M360AppBar(title: _titles[_selectedIndex]);
  }
}


/// ================= HOME TAB =================
class AdminHomeTab extends StatelessWidget {
  const AdminHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final adminState =
    context.findAncestorStateOfType<_AdminScreenState>();

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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddTicketScreen()),
            );
          },
        ),
        ActionCard(
          title: 'All Tickets',
          icon: Icons.history,
          color: Colors.green,
          onTap: () => adminState?._setTab(1),
        ),
        ActionCard(
          title: 'PTW',
          icon: Icons.assignment,
          color: Colors.orange,
          onTap: () => adminState?._setTab(2),
        ),
        ActionCard(
          title: 'PTC',
          icon: Icons.groups,
          color: Colors.grey,
          onTap: () => adminState?._setTab(3),
        ),
      ],
    );
  }
}
