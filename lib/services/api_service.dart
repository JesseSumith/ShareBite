import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://10.10.10.127:8080"; // replace

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

  /// =============== VOLUNTEER ENDPOINTS =================

  // 🔹 Get available donations for volunteer
  Future<List<dynamic>> getAvailableDonations(
    String token,
    int volunteerId,
  ) async {
    final url = "$baseUrl/ShareBite/volunteer/$volunteerId/available-donations";
    final response = await http.get(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token"},
    );

    print("GET $url -> ${response.statusCode} : ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception(
        "Failed to load donations [${response.statusCode}]: ${response.body}",
      );
    }
  }

  // 🔹 Claim a donation
  Future<void> claimDonation(
    String token,
    int volunteerId,
    int donationId,
  ) async {
    final url = "$baseUrl/ShareBite/volunteer/$volunteerId/claim/$donationId";
    final response = await http.post(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token"},
    );

    print("POST $url -> ${response.statusCode} : ${response.body}");

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to claim donation [${response.statusCode}]: ${response.body}",
      );
    }
  }

  // 🔹 Mark donation as picked up
  Future<void> pickupDonation(String token, int assignmentId) async {
    final url = "$baseUrl/ShareBite/volunteer/pickup/$assignmentId";
    final response = await http.put(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token"},
    );

    print("PUT $url -> ${response.statusCode} : ${response.body}");

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to mark pickup [${response.statusCode}]: ${response.body}",
      );
    }
  }

  // 🔹 Mark donation as delivered
  Future<void> deliverDonation(String token, int assignmentId) async {
    final url = "$baseUrl/ShareBite/volunteer/deliver/$assignmentId";
    final response = await http.put(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token"},
    );

    print("PUT $url -> ${response.statusCode} : ${response.body}");

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to mark delivered [${response.statusCode}]: ${response.body}",
      );
    }
  }

  // 🔹 Get volunteer assignments
  Future<List<dynamic>> getAssignments(String token, int volunteerId) async {
    final url = "$baseUrl/ShareBite/volunteer/assignments/$volunteerId";
    final response = await http.get(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token"},
    );

    print("GET $url -> ${response.statusCode} : ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception(
        "Failed to load assignments [${response.statusCode}]: ${response.body}",
      );
    }
  }

  // 🔹 Mark payment done (admin/ngo maybe)
  Future<void> markPaymentDone(String token, int assignmentId) async {
    final url =
        "$baseUrl/ShareBite/volunteer/assignments/$assignmentId/payment";
    final response = await http.put(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token"},
    );

    print("PUT $url -> ${response.statusCode} : ${response.body}");

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to mark payment [${response.statusCode}]: ${response.body}",
      );
    }
  }

  // 🔹 Fetch donor's donations

  Future<List<dynamic>> getDonorDonations(String token, int donorId) async {
    final url = Uri.parse("$baseUrl/ShareBite/donations/donor/$donorId");

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception(
        "Failed to load donor donations: ${response.statusCode} → ${response.body}",
      );
    }
  }

  // 🔹 NGO: Get pending donations assigned to this NGO
  Future<List<dynamic>> getPendingDonationsForNgo(
    String token,
    int ngoId,
  ) async {
    final url = Uri.parse("$baseUrl/ShareBite/donations/ngo/$ngoId/pending");

    print("➡️ GET: $url");

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    print("⬅️ Status: ${response.statusCode}");
    print("⬅️ Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) return data;
      throw Exception("Unexpected response format: $data");
    } else {
      throw Exception("Failed to load donations: ${response.body}");
    }
  }

  // 🔹 NGO: Accept a donation (robust version)
  Future<void> acceptDonation(String token, int donationId, int ngoId) async {
    // First attempt: query param style
    Uri urlQuery = Uri.parse(
      "$baseUrl/ShareBite/donations/$donationId/accept?ngoId=$ngoId",
    );

    // Second attempt: path param style (fallback)
    Uri urlPath = Uri.parse(
      "$baseUrl/ShareBite/donations/$donationId/accept/$ngoId",
    );

    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };

    http.Response response;

    try {
      print("➡️ PUT (query param): $urlQuery");
      response = await http.put(
        urlQuery,
        headers: headers,
        body: jsonEncode({}),
      );

      print("⬅️ Status: ${response.statusCode}");
      print("⬅️ Body: ${response.body}");

      if (response.statusCode == 200) return; // Success
    } catch (e) {
      print("Query param attempt failed: $e");
    }

    // Fallback to path param style
    try {
      print("➡️ PUT (path param fallback): $urlPath");
      response = await http.put(
        urlPath,
        headers: headers,
        body: jsonEncode({}),
      );

      print("⬅️ Status: ${response.statusCode}");
      print("⬅️ Body: ${response.body}");

      if (response.statusCode == 200) return; // Success
    } catch (e) {
      print("Path param attempt failed: $e");
    }
  }

  Future<Map<String, dynamic>> getUserProfile(String token, int userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/ShareBite/users/$userId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load user profile: ${response.body}");
    }
  }
}
