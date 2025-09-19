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
        return Colors.redAccent;
      case "PENDING":
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getIcon(String type) {
    switch (type.toUpperCase()) {
      case "APPROVED":
        return Icons.check_circle_outline;
      case "REJECTED":
        return Icons.cancel_outlined;
      case "PENDING":
        return Icons.hourglass_top_rounded;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.deepOrange.shade600,
        elevation: 4,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadNotifications();
          await _notifications;
        },
        child: FutureBuilder<List<dynamic>>(
          future: _notifications,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Error loading notifications:\n${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  "You don't have any notifications yet.",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            }

            final notifs = snapshot.data!;
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: notifs.length,
              itemBuilder: (context, index) {
                final notif = notifs[index];
                final createdAt = notif["createdAt"] ?? "";
                final formattedDate = createdAt.isNotEmpty
                    ? DateFormat(
                        "dd MMM yyyy, hh:mm a",
                      ).format(DateTime.parse(createdAt))
                    : "";

                final color = _getColor(notif["type"]);
                final icon = _getIcon(notif["type"]);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(14),
                    color: color.withOpacity(0.08),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: color.withOpacity(0.2),
                        child: Icon(icon, color: color, size: 26),
                      ),
                      title: Text(
                        notif["message"] ?? "No message",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
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
