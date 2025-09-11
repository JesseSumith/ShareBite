import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://10.40.117.242:8080"; // replace

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
}
