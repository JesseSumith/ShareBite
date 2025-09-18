import 'package:flutter/material.dart';
import 'package:my_app/screens/main_drawer.dart';
import '../services/api_service.dart';

class VolunteerDashboard extends StatefulWidget {
  final String token;
  final int volunteerId; // volunteer logged-in ID

  const VolunteerDashboard({
    super.key,
    required this.token,
    required this.volunteerId,
  });

  @override
  State<VolunteerDashboard> createState() => _VolunteerDashboardState();
}

class _VolunteerDashboardState extends State<VolunteerDashboard>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _availableDonations;
  late Future<List<dynamic>> _assignments;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    setState(() {
      _availableDonations = _apiService.getAvailableDonations(
        widget.token,
        widget.volunteerId,
      );
      _assignments = _apiService.getAssignments(
        widget.token,
        widget.volunteerId,
      );
    });
  }

  Future<void> _claimDonation(int donationId) async {
    try {
      await _apiService.claimDonation(
        widget.token,
        widget.volunteerId,
        donationId,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Donation claimed successfully")),
      );
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _pickupDonation(int assignmentId) async {
    try {
      await _apiService.pickupDonation(widget.token, assignmentId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Marked as Picked Up")));
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _deliverDonation(int assignmentId) async {
    try {
      await _apiService.deliverDonation(widget.token, assignmentId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Marked as Delivered")));
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget _buildDonationCard(Map<String, dynamic> donation) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text("Donation: ${donation["foodItem"] ?? "Unknown"}"),
        subtitle: Text(
          "Quantity: ${donation["quantity"] ?? "N/A"} • City: ${donation["city"] ?? "N/A"}",
        ),
        trailing: ElevatedButton(
          onPressed: () => _claimDonation(donation["id"]),
          child: const Text("Claim"),
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    final donation = assignment["donation"] ?? {};
    final status = assignment["status"] ?? "PENDING";

    return Card(
      margin: const EdgeInsets.all(8),
      child: ExpansionTile(
        title: Text(donation["foodItem"] ?? "Donation"),
        subtitle: Text("Status: $status"),
        children: [
          ListTile(
            title: const Text("From (Donor)"),
            subtitle: Text(donation["donorName"] ?? "Unknown"),
          ),
          ListTile(
            title: const Text("To (NGO)"),
            subtitle: Text(donation["ngoName"] ?? "Unknown"),
          ),
          if (status == "CLAIMED")
            ElevatedButton(
              onPressed: () => _pickupDonation(assignment["id"]),
              child: const Text("Mark as Picked Up"),
            ),
          if (status == "PICKED_UP")
            ElevatedButton(
              onPressed: () => _deliverDonation(assignment["id"]),
              child: const Text("Mark as Delivered"),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Volunteer Dashboard"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Available"),
            Tab(text: "My Assignments"),
          ],
        ),
      ),
      drawer: MainDrawer(
        token: widget.token,
        role: "VOLUNTEER",
        userId: widget.volunteerId,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 🔹 Available Donations
          RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: FutureBuilder<List<dynamic>>(
              future: _availableDonations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No available donations"));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) =>
                      _buildDonationCard(snapshot.data![index]),
                );
              },
            ),
          ),

          // 🔹 Volunteer Assignments
          RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: FutureBuilder<List<dynamic>>(
              future: _assignments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No assignments yet"));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) =>
                      _buildAssignmentCard(snapshot.data![index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
