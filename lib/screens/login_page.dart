import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:my_app/screens/register_page.dart';
import 'package:my_app/services/api_service.dart';
import 'package:my_app/screens/donor_dashboard.dart';
import 'package:my_app/screens/ngo_dashboard.dart';
import 'package:my_app/screens/volunteer_dashboard.dart';
import 'package:my_app/screens/admin_dashboard.dart';
import 'package:my_app/screens/register_page.dart'; // Import your registration page here

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _api = ApiService();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_nameController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter credentials")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _api.login(
        name: _nameController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final token = result["token"];
      final Map<String, dynamic> decoded = JwtDecoder.decode(token);
      final String role = (decoded["role"] ?? decoded["ROLE"] ?? "").toString();
      final int userId =
          (decoded["userid"] ?? decoded["userId"] ?? decoded["id"]) is int
          ? (decoded["userid"] ?? decoded["userId"] ?? decoded["id"])
          : int.tryParse(
                  (decoded["userid"] ?? decoded["userId"] ?? decoded["id"])
                      .toString(),
                ) ??
                0;
      final String city = (decoded["city"] ?? "") as String;

      if (role == "DONOR") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DonorDashboard(token: token, donorId: userId),
          ),
        );
      } else if (role == "NGO") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                NgoDashboard(token: token, city: city, ngoId: userId),
          ),
        );
      } else if (role == "VOLUNTEER") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                VolunteerDashboard(token: token, volunteerId: userId),
          ),
        );
      } else if (role == "ADMIN") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminDashboard(token: token)),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Unknown role: $role")));
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
    final primaryColor = const Color(0xFFEF6C00); // warm orange
    final accentColor = const Color(0xFF2E7D32); // fresh green

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Login"), backgroundColor: primaryColor),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo or icon placeholder
            Icon(Icons.fastfood_rounded, size: 100, color: primaryColor),
            const SizedBox(height: 30),

            Text(
              "Welcome Back!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            Text(
              "Login to continue helping others",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Username",
                labelStyle: TextStyle(color: accentColor),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.person, color: accentColor),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: TextStyle(color: accentColor),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.lock, color: accentColor),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 30),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 5,
                    ),
                    onPressed: _login,
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

            const SizedBox(height: 40),

            Center(
              child: RichText(
                text: TextSpan(
                  text: "Don't have an account? ",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                  children: [
                    TextSpan(
                      text: "Register here",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
