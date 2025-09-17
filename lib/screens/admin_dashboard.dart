import 'package:flutter/material.dart';
import 'package:my_app/screens/main_drawer.dart';
import '../services/api_service.dart';

class AdminDashboard extends StatefulWidget {
  final String token;
  const AdminDashboard({super.key, required this.token});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _pendingUsers;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _pendingUsers = _apiService.getPendingUsers(widget.token);
    });
  }

  Future<void> _approveUser(int userId) async {
    try {
      await _apiService.approveUser(widget.token, userId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User approved")));
      _loadUsers();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error approving user: $e")));
    }
  }

  Future<void> _rejectUser(int userId) async {
    try {
      await _apiService.rejectUser(widget.token, userId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User rejected")));
      _loadUsers();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error rejecting user: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<List<dynamic>>(
          future: _pendingUsers,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text("Pending Users (${snapshot.data!.length})");
            }
            return const Text("Admin Dashboard");
          },
        ),
      ),
      drawer: MainDrawer(token: widget.token, role: "ADMIN"),
      body: RefreshIndicator(
        onRefresh: () async => _loadUsers(),
        child: FutureBuilder<List<dynamic>>(
          future: _pendingUsers,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No pending users"));
            }

            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                // status color
                Color statusColor;
                switch (user["status"]) {
                  case "ACCEPTED":
                    statusColor = Colors.green;
                    break;
                  case "REJECTED":
                    statusColor = Colors.red;
                    break;
                  default:
                    statusColor = Colors.orange;
                }

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ExpansionTile(
                    title: Text(user["name"] ?? "Unknown"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${user["email"]} • Role: ${user["role"]}"),
                        Text(
                          "Status: ${user["status"] ?? "PENDING"}",
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      ListTile(
                        title: const Text("Phone"),
                        subtitle: Text(user["phonenum"] ?? "N/A"),
                      ),
                      ListTile(
                        title: const Text("State"),
                        subtitle: Text(user["state"] ?? "N/A"),
                      ),
                      ListTile(
                        title: const Text("City"),
                        subtitle: Text(user["city"] ?? "N/A"),
                      ),
                      ListTile(
                        title: const Text("Address"),
                        subtitle: Text(user["address"] ?? "N/A"),
                      ),
                      const Divider(),
                      if (user["status"] == "PENDING")
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _approveUser(user["id"]),
                              icon: const Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                              label: const Text("Approve"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _rejectUser(user["id"]),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              label: const Text("Reject"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
