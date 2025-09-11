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
      // ignore: unused_local_variable
      final result = await _apiService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phonenum: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        role: _selectedRole!, // pass chosen role
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
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      obscureText: obscure,
      validator: (value) => value!.isEmpty ? "Enter $label" : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(controller: _nameController, label: "Name"),
                const SizedBox(height: 16),
                _buildTextField(controller: _emailController, label: "Email"),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  label: "Password",
                  obscure: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  label: "Phone Number",
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _addressController,
                  label: "Address",
                ),
                const SizedBox(height: 16),
                _buildTextField(controller: _cityController, label: "City"),
                const SizedBox(height: 16),
                _buildTextField(controller: _stateController, label: "State"),
                const SizedBox(height: 16),

                // Dropdown for role
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: "Select Role",
                    border: OutlineInputBorder(),
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
                    setState(() => _selectedRole = value);
                  },
                  validator: (value) =>
                      value == null ? "Please select a role" : null,
                ),
                const SizedBox(height: 24),

                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text("Register"),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
