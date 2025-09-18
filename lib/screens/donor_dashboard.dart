import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'donation_form.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text("My Donations")),
      body: RefreshIndicator(
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
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No donations found"));
            }

            final donations = snapshot.data!;
            return ListView.builder(
              itemCount: donations.length,
              itemBuilder: (context, index) {
                final donation = donations[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(donation["foodDetails"] ?? "Unknown Food"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Quantity: ${donation["quantity"] ?? "N/A"}"),
                        Text(
                          "Address: ${donation["street"] ?? ""}, "
                          "${donation["city"] ?? ""}",
                        ),
                        Text("Status: ${donation["status"] ?? "Pending"}"),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
    );
  }
}
