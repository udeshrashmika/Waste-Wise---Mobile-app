import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final String userRole;
  const RegisterScreen({super.key, this.userRole = 'Resident'});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedBlock;
  final List<String> _blocks = [
    'Block A',
    'Block B',
    'Block C',
    'Block D',
    'Block E',
  ];

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    bool isResident = widget.userRole == 'Resident';

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        (isResident && _selectedBlock == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? result = await _authService.registerUser(
      email: email,
      password: password,
      fullName: name,
      phoneNumber: phone,
      apartmentId: isResident ? _selectedBlock! : 'N/A',
      role: widget.userRole,
    );

    setState(() => _isLoading = false);

    if (result == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration Successful! Please Login.")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $result")));
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandGreen = Color(0xFF1B5E36);
    const Color accentGreen = Color(0xFF2D8B49);

    bool isResident = widget.userRole == 'Resident';
    debugPrint("DEBUG: Registering as ${widget.userRole}");

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const Icon(Icons.eco_rounded, size: 70, color: accentGreen),
              Text(
                isResident ? 'Create Account' : 'Driver Registration',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (!isResident)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Chip(
                    label: Text(widget.userRole.toUpperCase()),
                    backgroundColor: accentGreen.withOpacity(0.1),
                    labelStyle: const TextStyle(
                      color: accentGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              const Text(
                'Join Waste Wise for a Cleaner Sri Lanka',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              _buildRegisterField(
                controller: _nameController,
                icon: Icons.person_outline,
                hint: 'Full Name',
              ),
              const SizedBox(height: 15),
              _buildRegisterField(
                controller: _emailController,
                icon: Icons.email_outlined,
                hint: 'Email Address',
              ),
              const SizedBox(height: 15),
              _buildRegisterField(
                controller: _phoneController,
                icon: Icons.phone_android,
                hint: 'Phone Number',
              ),
              const SizedBox(height: 15),

              if (isResident) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F1F1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<String>(
                      value: _selectedBlock,
                      hint: const Text(
                        "Select Apartment Block",
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                      isExpanded: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.apartment_outlined,
                          color: Colors.black54,
                        ),
                        border: InputBorder.none,
                      ),
                      items: _blocks.map((String block) {
                        return DropdownMenuItem<String>(
                          value: block,
                          child: Text(block),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedBlock = val),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],

              _buildRegisterField(
                controller: _passwordController,
                icon: Icons.lock_outline,
                hint: 'Password',
                isPassword: true,
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterField({
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
