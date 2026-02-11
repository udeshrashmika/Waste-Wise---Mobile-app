import 'package:flutter/material.dart';

import '../../truck_driver/screens/driver_main_layout.dart';
import 'package:waste_wise/features/auth/screens/login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  static const Color primaryGreen = Color(0xFF2D8B49);
  static const Color darkGreen = Color(0xFF1B5E36);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.eco_rounded, size: 100, color: primaryGreen),
                const SizedBox(height: 8),
                const Text(
                  'Waste Wise',
                  style: TextStyle(
                    color: primaryGreen,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 60),

               
                _buildRoleButton(
                  context: context,
                  icon: Icons.groups_3_outlined,
                  label: 'RESIDENTS',
                  color: primaryGreen,
                  onTap: () => _navigateToLogin(context, 'Resident'),
                ),
                const SizedBox(height: 20),

                
                _buildRoleButton(
                  context: context,
                  icon: Icons.person_search_outlined,
                  label: 'ADMIN',
                  color: darkGreen,
                  onTap: () => _navigateToLogin(context, 'Admin'),
                ),
                const SizedBox(height: 20),

                
                _buildRoleButton(
                  context: context,
                  icon: Icons.local_shipping_outlined,
                  label: 'TRUCK DRIVER',
                  color: darkGreen,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DriverMainLayout(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 60),

                
                Container(
                  width: 75,
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
    );
  }

  
  void _navigateToLogin(BuildContext context, String role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UniversalLoginScreen(userRole: role),
      ),
    );
  }

  Widget _buildRoleButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 65,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }
}