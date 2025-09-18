import 'package:flutter/material.dart';
import 'package:my_app/screens/volunteer_dashboard.dart';
import '../services/api_service.dart';
import 'register_page.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'admin_dashboard.dart';
import 'donor_dashboard.dart';
import 'ngo_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await _apiService.login(
        name: _nameController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final token = result["token"];

      print("✅ Logged in, token: $token");

      // Decode JWT
      Map<String, dynamic> decoded = JwtDecoder.decode(token);
      String role = decoded["role"];
      final userId = decoded["userid"];
      print("🔑 Role: $role");

      // Navigate based on role
      if (role == "ADMIN") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminDashboard(token: token)),
        );
      } else if (role == "DONOR") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DonorDashboard(token: token)),
        );
      } else if (role == "NGO") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => NgoDashboard(token: token)),
        );
      } else if (role == "VOLUNTEER") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                VolunteerDashboard(token: token, volunteerId: userId),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Unknown role")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login failed: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login"), backgroundColor: Colors.blue),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Enter your name" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) =>
                      value!.isEmpty ? "Enter your password" : null,
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text("Login"),
                      ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text("Don't have an account? Register here"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
