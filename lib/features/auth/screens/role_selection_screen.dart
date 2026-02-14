import 'package:flutter/material.dart';
import 'package:waste_wise/features/auth/screens/login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  static const Color primaryGreen = Color(0xFF2D8B49);
  static const Color darkGreen = Color(0xFF1B5E36);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: primaryGreen.withOpacity(0.05),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        size: 80,
                        color: primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'WASTE WISE',
                      style: TextStyle(
                        color: darkGreen,
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const Text(
                      'For a Cleaner Sri Lanka',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 50),

                    _buildRoleButton(
                      context: context,
                      icon: Icons.groups_3_rounded,
                      label: 'RESIDENTS',
                      description: 'Scan waste & check schedules',
                      color: primaryGreen,
                      onTap: () => _navigateToLogin(context, 'Resident'),
                    ),
                    const SizedBox(height: 20),

                    _buildRoleButton(
                      context: context,
                      icon: Icons.admin_panel_settings_rounded,
                      label: 'ADMIN',
                      description: 'Monitor system & analytics',
                      color: darkGreen,
                      onTap: () => _navigateToLogin(context, 'Admin'),
                    ),
                    const SizedBox(height: 20),

                    _buildRoleButton(
                      context: context,
                      icon: Icons.local_shipping_rounded,
                      label: 'TRUCK DRIVER',
                      description: 'View routes & collection tasks',
                      color: darkGreen,
                      onTap: () => _navigateToLogin(context, 'Truck Driver'),
                    ),

                    const SizedBox(height: 40),
                    const Text(
                      "Select your role to continue",
                      style: TextStyle(color: Colors.black38, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
