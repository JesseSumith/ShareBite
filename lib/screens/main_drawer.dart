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
  final String? city; // optional, only needed for NGO

  const MainDrawer({
    super.key,
    required this.token,
    required this.role,
    this.userId,
    this.city,
  });

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepOrange.shade700),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      hoverColor: Colors.deepOrange.shade100,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepOrange.shade400,
                    Colors.deepOrange.shade700,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white.withOpacity(0.4),
                      child: Icon(
                        role == "ADMIN"
                            ? Icons.admin_panel_settings
                            : role == "DONOR"
                            ? Icons.volunteer_activism
                            : role == "NGO"
                            ? Icons.apartment
                            : role == "VOLUNTEER"
                            ? Icons.person_search
                            : Icons.account_circle,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "ShareBite",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.home,
                    title: "Dashboard",
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
                              builder: (_) => DonorDashboard(
                                token: token,
                                donorId: userId!,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Donor ID not provided"),
                            ),
                          );
                        }
                      } else if (role == "NGO") {
                        if (userId != null && city != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NgoDashboard(
                                token: token,
                                ngoId: userId!,
                                city: city!,
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
                            const SnackBar(
                              content: Text("Volunteer ID not provided"),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.person,
                    title: "Profile",
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
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.notifications,
                    title: "Notifications",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              NotificationsPage(token: token, role: role),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    height: 32,
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.logout,
                    title: "Logout",
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
            ),
          ],
        ),
      ),
    );
  }
}
