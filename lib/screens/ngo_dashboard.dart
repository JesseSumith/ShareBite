import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'main_drawer.dart';

class NgoDashboard extends StatefulWidget {
  final String token;
  final String city; // NGO’s city
  final int ngoId;

  const NgoDashboard({
    super.key,
    required this.token,
    required this.city,
    required this.ngoId,
  });

  @override
  State<NgoDashboard> createState() => _NgoDashboardState();
}

class _NgoDashboardState extends State<NgoDashboard> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _pendingDonations;

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    try {
      final donations = await _apiService.getPendingDonationsForNgo(
        widget.token,
        widget.ngoId,
      );
      setState(() {
        _pendingDonations = Future.value(donations);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading donations: $e")));
    }
  }

  Future<void> _acceptDonation(int donationId) async {
    try {
      await _apiService.acceptDonation(widget.token, donationId, widget.ngoId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Donation accepted successfully")),
      );
      await _loadDonations(); // Refresh list
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error accepting donation: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("NGO Dashboard")),
      drawer: MainDrawer(
        token: widget.token,
        role: "NGO",
        userId: widget.ngoId,
      ),
      body: RefreshIndicator(
        onRefresh: _loadDonations,
        child: FutureBuilder<List<dynamic>>(
          future: _pendingDonations,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No pending donations"));
            }

            final donations = snapshot.data!;
            debugPrint("✅ Donations from backend: $donations");

            return ListView.builder(
              itemCount: donations.length,
              itemBuilder: (context, index) {
                final donation = donations[index];
                final foodName =
                    donation['foodType'] ??
                    donation['foodDetails'] ??
                    'Unknown Food';

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(foodName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Quantity: ${donation["quantity"] ?? 'N/A'}"),
                        Text(
                          "Address: ${donation["street"] ?? ''}, ${donation["city"] ?? ''}",
                        ),
                        Text(
                          "Estimated Value: ${donation["estimatedValue"] ?? 'N/A'}",
                        ),
                        Text("Status: ${donation["status"] ?? 'PENDING'}"),
                      ],
                    ),
                    trailing: donation["status"] == "PENDING"
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () =>
                                    _acceptDonation(donation["id"]),
                                child: const Text("Accept"),
                              ),
                              const SizedBox(width: 8),
                            ],
                          )
                        : const SizedBox.shrink(),
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
