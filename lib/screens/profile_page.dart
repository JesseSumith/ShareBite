import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  final String token;
  final String role;

  const ProfilePage({super.key, required this.token, required this.role});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchUserProfile(); // call it when the widget loads
  }

  Future<void> fetchUserProfile() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await http.get(
        Uri.parse("http://10.10.10.127:8080/ShareBite/me"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Failed to load profile: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Error: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text(error!));

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
                Text("👤 Name: ${userData?['name'] ?? 'N/A'}"),
                Text("📧 Email: ${userData?['email'] ?? 'N/A'}"),
                Text("📱 Phone: ${userData?['phonenum'] ?? 'N/A'}"),
                Text("🌍 Role: ${userData?['role'] ?? widget.role}"),
                Text("🏠 Address: ${userData?['address'] ?? 'N/A'}"),
                Text("🏙 City: ${userData?['city'] ?? 'N/A'}"),
                Text("🗺 State: ${userData?['state'] ?? 'N/A'}"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
