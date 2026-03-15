import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();

  String _selectedRole = 'Resident';
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
    _vehicleController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final vehicle = _vehicleController.text.trim();

    bool isResident = _selectedRole == 'Resident';

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        (isResident && _selectedBlock == null) ||
        (!isResident && vehicle.isEmpty)) {
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
      role: _selectedRole,
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
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: accentGreen.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentGreen.withOpacity(0.2)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    isExpanded: true,
                    items: ['Resident', 'Truck Driver'].map((String role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text("Register as $role"),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() {
                      _selectedRole = val!;
                      _selectedBlock = null;
                    }),
                  ),
                ),
              ),

              const SizedBox(height: 25),
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

              if (_selectedRole == 'Resident') ...[
                _buildBlockDropdown(),
                const SizedBox(height: 15),
              ] else ...[
                _buildRegisterField(
                  controller: _vehicleController,
                  icon: Icons.local_shipping_outlined,
                  hint: 'Vehicle Number',
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

  Widget _buildBlockDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
            prefixIcon: Icon(Icons.apartment_outlined, color: Colors.black54),
            border: InputBorder.none,
          ),
          items: _blocks
              .map(
                (block) => DropdownMenuItem(value: block, child: Text(block)),
              )
              .toList(),
          onChanged: (val) => setState(() => _selectedBlock = val),
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