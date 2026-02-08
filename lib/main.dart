import 'package:flutter/material.dart';

void main() {
  runApp(const WasteWiseApp());
}

class WasteWiseApp extends StatelessWidget {
  const WasteWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WASTE WISE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.green),
      home: const SelectionScreen(),
    );
  }
}

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  // Defining the specific greens from your UI design
  static const Color lightGreen = Color(0xFF2D8B49);
  static const Color darkGreen = Color(0xFF1B5E36);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and Title Section
                  const Icon(Icons.eco_rounded, size: 100, color: lightGreen),
                  const SizedBox(height: 8),
                  const Text(
                    'Waste Wise',
                    style: TextStyle(
                      color: lightGreen,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Option 1: RESIDENTS
                  _buildMenuButton(
                    icon: Icons.groups_3_outlined,
                    label: 'RESIDENTS',
                    color: lightGreen,
                  ),
                  const SizedBox(height: 20),

                  // Option 2: ADMIN
                  _buildMenuButton(
                    icon: Icons.person_search_outlined,
                    label: 'ADMIN',
                    color: darkGreen,
                  ),
                  const SizedBox(height: 20),

                  // Option 3: TRUCK DRIVER
                  _buildMenuButton(
                    icon: Icons.airline_seat_recline_normal_rounded,
                    label: 'TRUCK DRIVER',
                    color: darkGreen,
                  ),

                  const SizedBox(height: 60),

                  // Bottom Pill Button
                  Container(
                    width: 70,
                    height: 35,
                    decoration: BoxDecoration(
                      color: darkGreen,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // A private helper method to keep the code clean and avoid errors
  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(width: 20),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
