import 'package:flutter/material.dart';
import 'driver_home.dart';
import 'driver_stops.dart';
import 'driver_scan.dart';
import 'driver_schedule.dart';
import 'driver_profile.dart';

class DriverMainLayout extends StatefulWidget {
  const DriverMainLayout({super.key});

  @override
  State<DriverMainLayout> createState() => _DriverMainLayoutState();
}

class _DriverMainLayoutState extends State<DriverMainLayout> {
  int _selectedIndex = 0;
  final Color brandGreen = const Color(0xFF1B5E36);

   final List<Widget> _screens = [
    const DriverHomeScreen(),
    const DriverStopsScreen(),
    const DriverScanScreen(),
    const DriverScheduleScreen(),
    const DriverProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed, 
          backgroundColor: Colors.white,
          
          selectedItemColor: brandGreen, 
          unselectedItemColor: Colors.grey, 
          
          
          selectedIconTheme: const IconThemeData(size: 32),
          unselectedIconTheme: const IconThemeData(size: 24),
          
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          
          
          showUnselectedLabels: true, 

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),       
              activeIcon: Icon(Icons.home_filled),   
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on_outlined),
              activeIcon: Icon(Icons.location_on),
              label: 'Stops',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner),
              activeIcon: Icon(Icons.qr_code_2), 
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Schedule',
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