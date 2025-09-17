import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  final String token;
  final String role;

  const NotificationsPage({super.key, required this.token, required this.role});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<dynamic>> _notifications;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _notifications = ApiService().getNotifications(widget.token);
    });
  }

  Color _getColor(String type) {
    switch (type.toUpperCase()) {
      case "APPROVED":
        return Colors.green;
      case "REJECTED":
        return Colors.red;
      case "PENDING":
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getIcon(String type) {
    switch (type.toUpperCase()) {
      case "APPROVED":
        return Icons.check_circle;
      case "REJECTED":
        return Icons.cancel;
      case "PENDING":
        return Icons.hourglass_empty;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadNotifications();
          await _notifications; // wait until data loads
        },
        child: FutureBuilder<List<dynamic>>(
          future: _notifications,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No notifications yet"));
            }

            final notifs = snapshot.data!;
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: notifs.length,
              itemBuilder: (context, index) {
                final notif = notifs[index];
                final createdAt = notif["createdAt"] ?? "";
                final formattedDate = createdAt.isNotEmpty
                    ? DateFormat(
                        "dd MMM yyyy, hh:mm a",
                      ).format(DateTime.parse(createdAt))
                    : "";

                return Card(
                  color: _getColor(notif["type"]).withOpacity(0.1),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: Icon(
                      _getIcon(notif["type"]),
                      color: _getColor(notif["type"]),
                      size: 32,
                    ),
                    title: Text(
                      notif["message"] ?? "No message",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getColor(notif["type"]),
                      ),
                    ),
                    subtitle: Text(formattedDate),
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
