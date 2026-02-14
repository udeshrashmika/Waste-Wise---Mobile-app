import 'package:flutter/material.dart';
import 'resident_home.dart';
import 'history_screen.dart';
import 'notification_screen.dart';
import 'resident_profile_screen.dart';

class ResidentMainLayout extends StatefulWidget {
  const ResidentMainLayout({super.key});

  @override
  State<ResidentMainLayout> createState() => _ResidentMainLayoutState();
}

class _ResidentMainLayoutState extends State<ResidentMainLayout> {
  int _selectedIndex = 0;
  final Color brandGreen = const Color(0xFF1B5E36);

  final List<Widget> _screens = [
    const ResidentHomeScreen(),
    const HistoryScreen(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: brandGreen,
          unselectedItemColor: Colors.grey,
          selectedIconTheme: const IconThemeData(size: 32),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none),
              activeIcon: Icon(Icons.notifications),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
