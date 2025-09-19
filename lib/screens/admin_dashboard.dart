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

  Color _getStatusColor(String? status) {
    switch (status) {
      case "ACCEPTED":
        return Colors.green.shade600;
      case "REJECTED":
        return Colors.red.shade600;
      default:
        return Colors.orange.shade600;
    }
  }

  Icon _getStatusIcon(String? status) {
    switch (status) {
      case "ACCEPTED":
        return Icon(Icons.check_circle, color: Colors.green.shade600);
      case "REJECTED":
        return Icon(Icons.cancel, color: Colors.red.shade600);
      default:
        return Icon(Icons.hourglass_top, color: Colors.orange.shade600);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<List<dynamic>>(
          future: _pendingUsers,
          builder: (context, snapshot) {
            final count = snapshot.hasData ? snapshot.data!.length : 0;
            return Text("Pending Users ($count)");
          },
        ),
      ),
      drawer: MainDrawer(token: widget.token, role: "ADMIN"),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade100, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async => _loadUsers(),
          child: FutureBuilder<List<dynamic>>(
            future: _pendingUsers,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error: ${snapshot.error}",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.red,
                    ),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    "No pending users",
                    style: theme.textTheme.titleMedium,
                  ),
                );
              }

              final users = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final statusColor = _getStatusColor(user["status"]);
                  final statusIcon = _getStatusIcon(user["status"]);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      childrenPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      iconColor: statusColor,
                      collapsedIconColor: statusColor,
                      leading: CircleAvatar(
                        backgroundColor: statusColor.withOpacity(0.2),
                        child: statusIcon,
                      ),
                      title: Text(
                        user["name"] ?? "Unknown",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.email,
                              size: 16,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                user["email"] ?? "No email",
                                style: theme.textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      children: [
                        _buildUserInfoRow(
                          Icons.phone,
                          "Phone",
                          user["phonenum"],
                        ),
                        _buildUserInfoRow(
                          Icons.location_pin,
                          "State",
                          user["state"],
                        ),
                        _buildUserInfoRow(
                          Icons.location_city,
                          "City",
                          user["city"],
                        ),
                        _buildUserInfoRow(
                          Icons.home,
                          "Address",
                          user["address"],
                        ),
                        const Divider(thickness: 1, height: 20),
                        if (user["status"] == "PENDING")
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _approveUser(user["id"]),
                                icon: const Icon(Icons.check),
                                label: const Text("Approve"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _rejectUser(user["id"]),
                                icon: const Icon(Icons.close),
                                label: const Text("Reject"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade600,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
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
      ),
    );
  }

  Widget _buildUserInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.deepOrange.shade400),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value ?? "N/A")),
        ],
      ),
    );
  }
}
