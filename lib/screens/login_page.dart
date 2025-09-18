import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:my_app/services/api_service.dart';
import 'package:my_app/screens/donor_dashboard.dart';
import 'package:my_app/screens/ngo_dashboard.dart';
import 'package:my_app/screens/volunteer_dashboard.dart';
import 'package:my_app/screens/admin_dashboard.dart';

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
      // decode token to get role and id (adjust keys if your JWT uses different names)
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
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _login, child: const Text("Login")),
          ],
        ),
      ),
    );
  }
}
