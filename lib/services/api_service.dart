import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://10.27.162.242:8080"; // replace

  Future<Map<String, dynamic>> login({
    required String name,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/ShareBite/login/user"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "password": password}),
    );

    print("📡 Login Status: ${response.statusCode}");
    print("📡 Login Body: ${response.body}");

    if (response.statusCode == 200) {
      // backend returns plain JWT string
      final token = response.body;
      return {"token": token};
    } else {
      throw Exception("Login failed: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phonenum,
    required String address,
    required String city,
    required String state,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/ShareBite/register/user"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "role": role, // from dropdown
        "phonenum": phonenum,
        "address": address,
        "city": city,
        "state": state,
      }),
    );

    print("📡 Status: ${response.statusCode}");
    print("📡 Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Registration failed: ${response.body}");
    }
  }

  Future<List<dynamic>> getPendingUsers(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/ShareBite/admin/pending-users"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load pending users: ${response.body}");
    }
  }

  Future<void> approveUser(String token, int userId) async {
    final response = await http.put(
      Uri.parse("$baseUrl/ShareBite/admin/users/$userId/approve"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to approve user: ${response.body}");
    }
  }

  Future<void> rejectUser(String token, int userId) async {
    final response = await http.put(
      Uri.parse("$baseUrl/ShareBite/admin/users/$userId/reject"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to reject user: ${response.body}");
    }
  }

  Future<List<dynamic>> getNotifications(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/ShareBite/notifications/my"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load notifications: ${response.body}");
    }
  }
}
