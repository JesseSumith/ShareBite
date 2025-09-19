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
    // Initialize the Future immediately
    _pendingDonations = _apiService.getPendingDonationsForNgo(
      widget.token,
      widget.ngoId,
    );
  }

  Future<void> _loadDonations() async {
    try {
      print("Fetching pending donations for NGO ID: ${widget.ngoId}");
      final donations = await _apiService.getPendingDonationsForNgo(
        widget.token,
        widget.ngoId,
      );
      print("Received donations: $donations");
      setState(() {
        _pendingDonations = Future.value(donations);
      });
    } catch (e) {
      print("Error loading donations: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error loading donations: $e")));
      }
    }
  }

  Future<void> _acceptDonation(int donationId) async {
    try {
      await _apiService.acceptDonation(widget.token, donationId, widget.ngoId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Donation accepted successfully")),
        );
      }
      await _loadDonations(); // Refresh list after accepting
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error accepting donation: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("NGO Dashboard"),
        backgroundColor: Colors.deepOrange.shade600,
        elevation: 4,
      ),
      drawer: MainDrawer(
        token: widget.token,
        role: "NGO",
        userId: widget.ngoId,
        city: widget.city,
      ),
      body: RefreshIndicator(
        onRefresh: _loadDonations,
        child: FutureBuilder<List<dynamic>>(
          future: _pendingDonations,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "Error: ${snapshot.error}",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  "No pending donations",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            }

            final donations = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: donations.length,
              itemBuilder: (context, index) {
                final donation = donations[index];
                final foodName =
                    donation['foodType'] ??
                    donation['foodDetails'] ??
                    'Unknown Food';

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  shadowColor: Colors.deepOrange.withOpacity(0.2),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          foodName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.deepOrange.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _infoText(
                          "Quantity",
                          donation["quantity"]?.toString() ?? 'N/A',
                        ),
                        _infoText(
                          "Address",
                          "${donation["street"] ?? ''}, ${donation["city"] ?? ''}",
                        ),
                        _infoText(
                          "Estimated Value",
                          donation["estimatedValue"]?.toString() ?? 'N/A',
                        ),
                        _infoText("Status", donation["status"] ?? 'PENDING'),
                        const SizedBox(height: 12),
                        if (donation["status"] == "PENDING")
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () => _acceptDonation(donation["id"]),
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text("Accept"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange.shade600,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 5,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
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

  Widget _infoText(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          text: "$title: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 15,
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.black54,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
