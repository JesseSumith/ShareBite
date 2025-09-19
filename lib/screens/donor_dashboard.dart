import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'donation_form.dart';
import 'main_drawer.dart'; // Import MainDrawer here

class DonorDashboard extends StatefulWidget {
  final String token;
  final int donorId;

  const DonorDashboard({super.key, required this.token, required this.donorId});

  @override
  State<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  late Future<List<dynamic>> _donationsFuture;

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  void _loadDonations() {
    _donationsFuture = ApiService().getDonorDonations(
      widget.token,
      widget.donorId,
    );
  }

  void _refreshDonations() {
    setState(() {
      _loadDonations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("My Donations"), elevation: 2),
      drawer: MainDrawer(
        token: widget.token,
        role: "DONOR",
        userId: widget.donorId,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            _refreshDonations();
            await _donationsFuture; // wait until data is fetched
          },
          child: FutureBuilder<List<dynamic>>(
            future: _donationsFuture,
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
                    "No donations found",
                    style: theme.textTheme.titleMedium,
                  ),
                );
              }

              final donations = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 10,
                ),
                itemCount: donations.length,
                itemBuilder: (context, index) {
                  final donation = donations[index];

                  Color statusColor;
                  switch ((donation["status"] ?? "Pending")
                      .toString()
                      .toUpperCase()) {
                    case "COMPLETED":
                      statusColor = Colors.green.shade700;
                      break;
                    case "REJECTED":
                      statusColor = Colors.red.shade700;
                      break;
                    default:
                      statusColor = Colors.orange.shade700;
                  }

                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 6,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      title: Text(
                        donation["foodType"] ?? "Unknown Food",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.kitchen,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Quantity: ${donation["quantity"] ?? "N/A"}",
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    "Address: ${donation["street"] ?? ""}, ${donation["city"] ?? ""}",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.info, size: 18, color: statusColor),
                                const SizedBox(width: 6),
                                Text(
                                  "Status: ${donation["status"] ?? "Pending"}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ],
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
      ),
      floatingActionButton: Tooltip(
        message: "Add New Donation",
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    DonationForm(token: widget.token, donorId: widget.donorId),
              ),
            );

            if (result == true) {
              _refreshDonations(); // refresh after new donation
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
