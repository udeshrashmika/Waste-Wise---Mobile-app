import 'package:flutter/material.dart';
import 'login_screen.dart'; // Make sure this import is correct for your folder structure

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  // 1. Variable to store the user's choice.
  // It is empty initially.
  String _selectedRole = '';

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

                // --- ROLE BUTTONS ---

                // Resident Button
                _buildRoleButton(
                  icon: Icons.groups_3_outlined,
                  label: 'Resident',
                  color: primaryGreen,
                ),
                const SizedBox(height: 20),

                // Admin Button
                _buildRoleButton(
                  icon: Icons.person_search_outlined,
                  label: 'Admin',
                  color: darkGreen,
                ),
                const SizedBox(height: 20),

                // Truck Driver Button
                _buildRoleButton(
                  icon: Icons.local_shipping_outlined,
                  label: 'Truck Driver',
                  color: darkGreen,
                ),

                const SizedBox(height: 60),

                // --- NAVIGATION BUTTON (THE FIX) ---

                // 2. We wrap the Container in a GestureDetector to make it clickable
                GestureDetector(
                  onTap: () {
                    // 3. Check if a role is selected before navigating
                    if (_selectedRole.isNotEmpty) {
                      print(
                        "Navigating to login as $_selectedRole",
                      ); // Debug print

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UniversalLoginScreen(userRole: _selectedRole),
                        ),
                      );
                    } else {
                      // 4. Show a message if no role is selected
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select a role first!"),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 75,
                    height: 35,
                    decoration: BoxDecoration(
                      // Change color to Grey if nothing selected, Green if selected
                      color: _selectedRole.isEmpty ? Colors.grey : darkGreen,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to build the selection buttons
  Widget _buildRoleButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    bool isSelected = _selectedRole == label;

    return InkWell(
      onTap: () {
        // 5. Update the state when clicked
        setState(() {
          _selectedRole = label;
        });
        print("Selected Role: $_selectedRole");
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 65,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          // Add a border if selected so you can SEE it is selected
          border: isSelected ? Border.all(color: Colors.black, width: 4) : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(width: 20),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              const Spacer(),
              // Show checkmark if selected
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
