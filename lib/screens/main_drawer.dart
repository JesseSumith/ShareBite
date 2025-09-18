import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'notifications_page.dart';
import 'login_page.dart';
import 'admin_dashboard.dart';
import 'donor_dashboard.dart';
import 'ngo_dashboard.dart';
import 'volunteer_dashboard.dart';

class MainDrawer extends StatelessWidget {
  final String token;
  final String role;
  final int? userId;
  final String? city; // ✅ added city

  const MainDrawer({
    super.key,
    required this.token,
    required this.role,
    this.userId,
    this.city, // ✅ optional, only needed for NGO
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                "ShareBite",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Dashboard"),
            onTap: () {
              Navigator.pop(context); // close drawer
              if (role == "ADMIN") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminDashboard(token: token),
                  ),
                );
              } else if (role == "DONOR") {
                if (userId != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DonorDashboard(token: token, donorId: userId!),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Donor ID not provided")),
                  );
                }
              } else if (role == "NGO") {
                if (userId != null && city != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NgoDashboard(
                        token: token,
                        ngoId: userId!, // ✅ pass NGO's id
                        city: city!, // ✅ pass NGO's city
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("NGO ID or City not provided"),
                    ),
                  );
                }
              } else if (role == "VOLUNTEER") {
                if (userId != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VolunteerDashboard(
                        token: token,
                        volunteerId: userId!,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Volunteer ID not provided")),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfilePage(token: token, role: role),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notifications"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationsPage(token: token, role: role),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pop(context); // close drawer first
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
