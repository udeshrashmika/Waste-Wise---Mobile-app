import 'package:flutter/material.dart';


import 'admin_dashboard.dart';
import 'admin_schedule.dart';
import 'admin_resources.dart';
import 'admin_profile.dart';

class AdminMainLayout extends StatefulWidget {
  const AdminMainLayout({super.key});

  @override
  State<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends State<AdminMainLayout> {
  int _selectedIndex = 0;
  final Color brandGreen = const Color(0xFF1B5E36);

 
  final List<Widget> _screens = [
    const AdminDashboard(),       
    const AdminScheduleScreen(),  
    const AdminResourcesScreen(), 
    const AdminProfileScreen(),   
  ];
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: _screens.isNotEmpty 
          ? _screens[_selectedIndex] 
          : const Center(child: CircularProgressIndicator()), 
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: brandGreen,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'DASHBOARD',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'SCHEDULE',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_suggest_outlined),
            activeIcon: Icon(Icons.settings_suggest),
            label: 'RESOURCES',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'PROFILE',
          ),
        ],
      ),
    );
  }
}