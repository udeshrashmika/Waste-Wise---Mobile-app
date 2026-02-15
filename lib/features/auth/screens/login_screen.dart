import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:waste_wise/features/resident/screens/resident_main_layout.dart';
import 'package:waste_wise/features/admin/screens/admin_main_layout.dart';
import '../../truck_driver/screens/driver_main_layout.dart';
import 'register_screen.dart';
import '../../../services/auth_service.dart';

class UniversalLoginScreen extends StatefulWidget {
  final String userRole;

  const UniversalLoginScreen({super.key, required this.userRole});

  @override
  State<UniversalLoginScreen> createState() => _UniversalLoginScreenState();
}

class _UniversalLoginScreenState extends State<UniversalLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(BuildContext context) async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? firebaseRole = await _authService.loginAndGetRole(email, password);

    setState(() => _isLoading = false);

    if (firebaseRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login failed. Please check your credentials."),
        ),
      );
      return;
    }

    if (firebaseRole.trim().toLowerCase() ==
        widget.userRole.trim().toLowerCase()) {
      if (firebaseRole == 'Admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminMainLayout()),
        );
      } else if (firebaseRole == 'Truck Driver') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DriverMainLayout()),
        );
      } else if (firebaseRole == 'Resident') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ResidentMainLayout()),
        );
      }
    } else {
      await FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Access Denied: You are registered as $firebaseRole"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandGreen = Color(0xFF1B5E36);
    const Color accentGreen = Color(0xFF2D8B49);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              children: [
                const Icon(Icons.eco_rounded, size: 80, color: accentGreen),
                const Text(
                  'Waste Wise',
                  style: TextStyle(
                    color: accentGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Login as ${widget.userRole}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Waste Management For Cleaner Sri Lanka',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),
                _buildInputField(
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  hint: 'Email',
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: _passwordController,
                  icon: Icons.lock_outline,
                  hint: 'Password',
                  isPassword: true,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: accentGreen),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 180,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: _isLoading ? null : () => _handleLogin(context),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 25),
                if (widget.userRole == 'Resident')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Create account',
                          style: TextStyle(color: Colors.lightBlue),
                        ),
                      ),
                    ],
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      "Contact Admin for ${widget.userRole} account access",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
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

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF1F1F1),
        prefixIcon: Icon(icon, color: Colors.black54),
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
