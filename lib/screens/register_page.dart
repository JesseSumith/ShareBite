import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  String? _selectedRole; // Dropdown value
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  void _register() async {
    if (!_formKey.currentState!.validate() || _selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and select a role"),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _apiService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phonenum: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        role: _selectedRole!,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Registration successful!")));

      Navigator.pop(context); // Go back to login
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Registration failed: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
  }) {
    final accentColor = const Color(0xFF2E7D32); // fresh green

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: (value) => value!.isEmpty ? "Enter $label" : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: accentColor),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: accentColor)
            : null,
        filled: true,
        fillColor: Colors.grey.shade100,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: accentColor),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFEF6C00); // warm orange
    final accentColor = const Color(0xFF2E7D32); // fresh green

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Icon(
                Icons.app_registration_rounded,
                size: 90,
                color: primaryColor,
              ),
              const SizedBox(height: 25),

              Text(
                "Create your account",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                "Join us and start making a difference",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              _buildTextField(
                controller: _nameController,
                label: "Name",
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _emailController,
                label: "Email",
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _passwordController,
                label: "Password",
                obscure: true,
                prefixIcon: Icons.lock,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _phoneController,
                label: "Phone Number",
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _addressController,
                label: "Address",
                prefixIcon: Icons.home,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _cityController,
                label: "City",
                prefixIcon: Icons.location_city,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _stateController,
                label: "State",
                prefixIcon: Icons.map,
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: "Select Role",
                  labelStyle: TextStyle(color: accentColor),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: "DONOR", child: Text("DONOR")),
                  DropdownMenuItem(value: "NGO", child: Text("NGO")),
                  DropdownMenuItem(
                    value: "VOLUNTEER",
                    child: Text("VOLUNTEER"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                },
                validator: (value) =>
                    value == null ? "Please select a role" : null,
              ),
              const SizedBox(height: 30),

              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
