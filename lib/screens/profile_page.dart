import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ProfilePage extends StatelessWidget {
  final String token;
  final String role;

  const ProfilePage({super.key, required this.token, required this.role});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> decoded = JwtDecoder.decode(token);

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "👤 Name: ${decoded['sub'] ?? 'N/A'}",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text("📧 Email: ${decoded['email'] ?? 'N/A'}"),
                Text("📱 Phone: ${decoded['phonenum'] ?? 'N/A'}"),
                Text("🌍 Role: ${decoded['role'] ?? role}"),
                const SizedBox(height: 8),
                Text("🏠 Address: ${decoded['address'] ?? 'N/A'}"),
                Text("🏙 City: ${decoded['city'] ?? 'N/A'}"),
                Text("🗺 State: ${decoded['state'] ?? 'N/A'}"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
